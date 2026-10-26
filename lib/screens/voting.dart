import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VotingScreen extends StatelessWidget {
  final String chamaId;
  const VotingScreen({super.key, required this.chamaId});

  void _castVote(String requestId, String memberId, String vote) {
    FirebaseFirestore.instance.collection('loanRequests').doc(requestId).update({
      'votes': FieldValue.arrayUnion([
        {'member_id': memberId, 'vote': vote}
      ]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loan Voting')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('loanRequests')
            .where('chama_id', isEqualTo: chamaId)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pending loan requests'));
          }
          final doc = snapshot.data!.docs.first;
          final request = doc.data() as Map<String, dynamic>;
          final votes = (request['votes'] as List?) ?? [];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Member requests KSh ${request['amount']}'),
                Text('Max eligible: KSh ${request['max_eligible_amount']}'),
                Text('Votes: ${votes.length}'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _castVote(doc.id, 'current_member', 'yes'),
                      child: const Text('Approve'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => _castVote(doc.id, 'current_member', 'no'),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}