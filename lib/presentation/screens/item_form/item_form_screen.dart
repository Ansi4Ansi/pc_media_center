import 'package:flutter/material.dart';

class ItemFormScreen extends StatelessWidget {
  const ItemFormScreen({super.key, this.itemId});

  final String? itemId;

  @override
  Widget build(BuildContext context) {
    final isEditing = itemId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Item' : 'Add Item')),
      body: const Center(child: Text('Item Form Screen — stub')),
    );
  }
}
