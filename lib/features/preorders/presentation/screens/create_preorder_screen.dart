import 'package:flutter/material.dart';

class CreatePreorderScreen extends StatelessWidget {
  const CreatePreorderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CreatePreorderScreen')),
      body: const Center(child: Text('CreatePreorderScreen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
    );
  }
}
