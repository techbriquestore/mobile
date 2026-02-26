import 'package:flutter/material.dart';

class PreorderDetailScreen extends StatelessWidget {
  final String preorderId; const PreorderDetailScreen({super.key, required this.preorderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PreorderDetailScreen')),
      body: const Center(child: Text('PreorderDetailScreen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
    );
  }
}
