import 'package:flutter/material.dart';
import '../services/bima_guardian_insurance.dart';

/// Insurance application intake. An approved HTTPS gateway and authenticated
/// user token must be provided by the app's secure configuration layer.
class ChamaInsuranceScreen extends StatefulWidget {
  final ChamaInsuranceService? service;
  final String chamaId;
  const ChamaInsuranceScreen({super.key, required this.chamaId, this.service});

  @override
  State<ChamaInsuranceScreen> createState() => _ChamaInsuranceScreenState();
}

class _ChamaInsuranceScreenState extends State<ChamaInsuranceScreen> {
  final registration = TextEditingController();
  final authorization = TextEditingController();
  final consent = TextEditingController();
  final sumInsured = TextEditingController();
  String product = 'property';
  String subtype = 'commercial';
  bool busy = false;
  String result = '';

  static const covers = <String, List<String>>{
    'property': ['commercial', 'fire_theft', 'all_risks'],
    'medical': ['group', 'sme'],
    'motor': ['commercial', 'fleet'],
    'agriculture': ['crop', 'agribusiness'],
  };

  Future<void> quote() async {
    if (widget.service == null) {
      setState(() => result = 'Insurance unavailable: secure partner gateway not configured.');
      return;
    }
    setState(() { busy = true; result = ''; });
    try {
      final response = await widget.service!.quoteRegisteredGroup(
        chamaId: widget.chamaId,
        registrationNumber: registration.text.trim(),
        authorizationReference: authorization.text.trim(),
        consentReference: consent.text.trim(),
        product: product,
        subtype: subtype,
        sumInsured: num.parse(sumInsured.text.trim()),
      );
      if (!mounted) return;
      setState(() => result = 'Indicative quote (not bound): $response');
    } catch (error) {
      if (!mounted) return;
      setState(() => result = 'Unable to obtain quote: $error');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    registration.dispose(); authorization.dispose(); consent.dispose(); sumInsured.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Business and Chama Insurance')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Registered groups may request indicative quotes. Registration, group approval and signing authority must be verified before an application can proceed.'),
      TextField(controller: registration, decoration: const InputDecoration(labelText: 'Registration reference')),
      TextField(controller: authorization, decoration: const InputDecoration(labelText: 'Authorized signatory / mandate reference')),
      TextField(controller: consent, decoration: const InputDecoration(labelText: 'Insurance data-sharing consent reference')),
      DropdownButtonFormField<String>(
        value: product,
        items: covers.keys.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: (v) => setState(() { product = v!; subtype = covers[v]!.first; }),
        decoration: const InputDecoration(labelText: 'Insurance product'),
      ),
      DropdownButtonFormField<String>(
        value: subtype,
        items: covers[product]!.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: (v) => setState(() => subtype = v!),
        decoration: const InputDecoration(labelText: 'Type of cover'),
      ),
      TextField(controller: sumInsured, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sum insured (KES)')),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: busy ? null : quote, child: Text(busy ? 'Requesting...' : 'Request indicative quote')),
      Text(result),
    ]),
  );
}
