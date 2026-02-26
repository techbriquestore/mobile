import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SupportScreen')),
      body: const Center(child: Text('SupportScreen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
    );
  }
}
