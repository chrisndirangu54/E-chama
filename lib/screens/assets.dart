import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AssetScreen extends StatefulWidget {
  final String chamaId;
  const AssetScreen({super.key, required this.chamaId});
  @override
  State<AssetScreen> createState() => _AssetScreenState();
}

class _AssetScreenState extends State<AssetScreen> {
  final _typeController = TextEditingController();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  List<XFile> _media = [];

  Future<void> _pickMedia() async {
    final images = await ImagePicker().pickMultiImage();
    setState(() => _media.addAll(images));
  }

  Future<void> _addAsset() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Asset submitted for AI valuation')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assets & AI Valuation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            items: const [
              DropdownMenuItem(value: 'vehicle', child: Text('Vehicle')),
              DropdownMenuItem(value: 'land', child: Text('Land (Barren)')),
              DropdownMenuItem(value: 'built_land', child: Text('Built Land + Rent')),
              DropdownMenuItem(value: 'business', child: Text('Business')),
              DropdownMenuItem(value: 'machinery', child: Text('Machinery')),
            ],
            onChanged: (v) => _typeController.text = v ?? '',
            decoration: const InputDecoration(labelText: 'Asset Type'),
          ),
          TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')),
          TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Purchase Price / Annual Rent'), keyboardType: TextInputType.number),
          ElevatedButton(onPressed: _pickMedia, child: const Text('Add Photos / Videos')),
          Wrap(children: _media.map((m) => Chip(label: Text(m.name))).toList()),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _addAsset, child: const Text('Submit for AI Valuation')),
          const Divider(),
          const Text('Current Assets', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}