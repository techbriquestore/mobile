import 'package:flutter/material.dart';

class PreordersScreen extends StatelessWidget {
  const PreordersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PreordersScreen')),
      body: const Center(child: Text('PreordersScreen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
    );
  }
}
