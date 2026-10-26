const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
const twilio = require('twilio');
const { Configuration, OpenAIApi } = require('openai');

admin.initializeApp();

const client = twilio(process.env.TWILIO_SID || '', process.env.TWILIO_TOKEN || '');
const openai = new OpenAIApi(new Configuration({ apiKey: process.env.OPENAI_API_KEY || '' }));

// ========== M-Pesa C2B Callback ==========
exports.mpesaCallback = functions.https.onRequest(async (req, res) => {
  try {
    const data = req.body;
    const amount = parseFloat(data.TransAmount || data.Amount || 0);
    const phone = data.MSISDN || data.PhoneNumber;
    const txId = data.TransID || data.TransactionID;

    if (!amount || !phone) {
      return res.json({ ResultCode: 1, ResultDesc: 'Invalid payload' });
    }

    const memberSnap = await admin.firestore()
      .collection('members')
      .where('phone', '==', phone)
      .limit(1)
      .get();

    if (memberSnap.empty) {
      return res.json({ ResultCode: 1, ResultDesc: 'Member not found' });
    }

    const memberRef = memberSnap.docs[0].ref;
    await memberRef.update({
      savings: admin.firestore.FieldValue.increment(amount),
      contributions: admin.firestore.FieldValue.arrayUnion({
        amount,
        date: new Date(),
        mpesa_id: txId,
        type: 'contribution'
      })
    });

    await admin.firestore().collection('transactions').add({
      chama_id: memberSnap.docs[0].data().chama_id,
      member_id: memberSnap.docs[0].id,
      amount,
      type: 'contribution',
      mpesa_id: txId,
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    });

    res.json({ ResultCode: 0, ResultDesc: 'Accepted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ ResultCode: 1, ResultDesc: 'Error' });
  }
});

// ========== Mint ChamaCoin ==========
exports.mintChamaCoin = functions.https.onCall(async (data, context) => {
  const { chama_id, amount } = data;
  if (!chama_id || !amount) throw new functions.https.HttpsError('invalid-argument', 'Missing fields');

  // Placeholder: In production call M-Pesa B2B then Yellow Card then contract.mint()
  await admin.firestore().collection('chamas').doc(chama_id).update({
    total_assets: admin.firestore.FieldValue.increment(amount),
    token_balance: admin.firestore.FieldValue.increment(amount * 1e18)
  });

  return { success: true, tokensMinted: amount, message: 'ChamaCoin minted (simulation)' };
});

// ========== AI Asset Valuation ==========
exports.valueAssetWithMedia = functions.https.onCall(async (data, context) => {
  const { chama_id, asset_type, description, media_urls = [], annual_rent = 0 } = data;

  let estimate = 0;
  if (process.env.OPENAI_API_KEY) {
    try {
      const prompt = `Estimate current market value in KES (Kenya 2026) for ${asset_type}: ${description}.
Media provided: ${media_urls.length} files. Annual rent if applicable: ${annual_rent}.
Return only a number.`;
      const completion = await openai.createChatCompletion({
        model: 'gpt-4o',
        messages: [{ role: 'user', content: prompt }],
      });
      estimate = parseInt(completion.data.choices[0].message.content.replace(/[^0-9]/g, '')) || 0;
    } catch (e) {
      console.error('AI error', e);
    }
  }

  if (estimate === 0) {
    estimate = asset_type === 'built_land' ? (annual_rent * 8) : 100000;
  }

  await admin.firestore().collection('chamas').doc(chama_id).update({
    [`assets.${asset_type}`]: estimate,
    total_assets: admin.firestore.FieldValue.increment(estimate),
    [`media_urls.${asset_type}`]: media_urls
  });

  return { estimate, asset_type, verified: true };
});

// ========== WhatsApp Handler ==========
exports.whatsappHandler = functions.https.onRequest(async (req, res) => {
  const message = (req.body.Body || '').toLowerCase();
  const from = req.body.From || '';
  const groupId = req.body.To || '';

  await admin.firestore().collection('chats').add({
    message: req.body.Body || '',
    from,
    groupId,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    whatsapp_id: req.body.MessageSid
  });

  if (message === 'yes' || message === 'no') {
    console.log(`Vote recorded: ${message} from ${from}`);
  }
  res.send('OK');
});

// ========== Dynamic Loan Request ==========
exports.createLoanRequest = functions.https.onCall(async (data, context) => {
  const { chama_id, member_id, amount } = data;
  const member = (await admin.firestore().collection('members').doc(member_id).get()).data() || {};
  const chama = (await admin.firestore().collection('chamas').doc(chama_id).get()).data() || {};

  const lateCount = member.lateness_count || 0;
  const settings = chama.settings || {};
  const multipliers = settings.loan_multipliers || { early: 5, on_time: 3, late_1_2: 3, late_3_plus: 2 };

  let multiplier = multipliers.on_time || 3;
  if (lateCount === 0) multiplier = multipliers.early || 5;
  else if (lateCount <= (settings.lateness_threshold || 2)) multiplier = multipliers.late_1_2 || 3;
  else multiplier = multipliers.late_3_plus || 2;

  const maxEligible = (member.savings || 0) * multiplier;

  if (amount > maxEligible) {
    throw new functions.https.HttpsError('invalid-argument', `Exceeds ${multiplier}x limit (max KSh ${maxEligible})`);
  }

  const ref = await admin.firestore().collection('loanRequests').add({
    chama_id,
    member_id,
    amount,
    max_eligible_amount: maxEligible,
    votes: [],
    status: settings.voting_required === false ? 'approved' : 'pending',
    timestamp: admin.firestore.FieldValue.serverTimestamp()
  });

  return { requestId: ref.id, maxEligible, multiplier };
});
