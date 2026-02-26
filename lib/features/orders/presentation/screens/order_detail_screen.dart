import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId; const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OrderDetailScreen')),
      body: const Center(child: Text('OrderDetailScreen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
    );
  }
}
