import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('e-Chama Dashboard')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('members').limit(1).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text('No member records yet'));
          final member = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Savings: KSh ${member['savings'] ?? 0}', style: Theme.of(context).textTheme.headlineSmall),
              Text('ChamaCoin Value: KSh ${member['token_value'] ?? 1.0}'),
              Text('AI Tip: ${member['ai_tip'] ?? 'Loading...'}'),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/assets'), child: const Text('Manage Assets')),
              ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/trading'), child: const Text('Trade ChamaCoin')),
              ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/voting'), child: const Text('Voting & Loans')),
              ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/chat'), child: const Text('Chat (WhatsApp Sync)')),
              ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/insurance'), child: const Text('Insurance for Registered Chamas')),
            ],
          );
        },
      ),
    );
  }
}