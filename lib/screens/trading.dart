import 'package:flutter/material.dart';

class TradingScreen extends StatelessWidget {
  final String chamaId;
  const TradingScreen({super.key, required this.chamaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChamaCoin Trading')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Intrinsic Value', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('KSh 1.00 per token (updates with assets & returns)'),
            const SizedBox(height: 20),
            const Text('List Tokens for Sale'),
            TextField(decoration: const InputDecoration(labelText: 'Amount of tokens')),
            TextField(decoration: const InputDecoration(labelText: 'Price per token (KSh)')),
            ElevatedButton(onPressed: () {}, child: const Text('List Trade')),
            const Divider(),
            const Text('Open Trades'),
          ],
        ),
      ),
    );
  }
}