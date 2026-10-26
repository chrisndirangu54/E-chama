# Setup Guide

## 1. Firebase
1. Create a Firebase project.
2. Enable Firestore, Auth, Storage, Cloud Functions.
3. Download google-services.json / GoogleService-Info.plist locally. Do not commit secrets.
4. Configure server-side variables TWILIO_SID, TWILIO_TOKEN, OPENAI_API_KEY, and M-Pesa credentials.

## 2. M-Pesa Daraja
- Register on developer.safaricom.co.ke.
- Configure C2B callback URL to the mpesaCallback function.
- Obtain B2B credentials before building payment flows.

## 3. WhatsApp
- Set up a verified WhatsApp Business integration.
- Configure webhook to whatsappHandler.

## 4. Blockchain
- Compile and review ChamaCoin.sol and ChamaDEX.sol before testnet deployment.
- Store contract addresses in Firestore chama documents.

## 5. AI Valuation
- Configure supported AI providers and server-side credentials.
- Store media in Firebase Storage with authenticated access controls.

## 6. Run
```bash
flutter pub get
flutter run
```

**Important:** This is a prototype and is not safe to deploy for live payments, loans, token transfers or investment operations without authentication, webhook verification, idempotency, security rules and audited financial logic.
