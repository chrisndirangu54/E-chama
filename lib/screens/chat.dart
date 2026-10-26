import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String chamaId;
  const ChatScreen({super.key, required this.chamaId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    FirebaseFirestore.instance.collection('chats').add({
      'chama_id': widget.chamaId,
      'message': _controller.text.trim(),
      'sender_id': 'current_user',
      'timestamp': FieldValue.serverTimestamp(),
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chama Chat (Synced with WhatsApp)')),
      body: Column(children: [
        Expanded(child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('chats').where('chama_id', isEqualTo: widget.chamaId).orderBy('timestamp').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            return ListView(children: snapshot.data!.docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              return ListTile(title: Text(data['message'] ?? ''), subtitle: Text(data['sender_id'] ?? ''));
            }).toList());
          },
        )),
        Padding(padding: const EdgeInsets.all(8), child: Row(children: [
          Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Message'))),
          IconButton(icon: const Icon(Icons.send), onPressed: _send),
        ])),
      ]),
    );
  }
}