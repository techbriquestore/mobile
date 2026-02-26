import 'package:flutter/material.dart';

class ClaimScreen extends StatelessWidget {
  final String orderId; const ClaimScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ClaimScreen')),
      body: const Center(child: Text('ClaimScreen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
    );
  }
}
