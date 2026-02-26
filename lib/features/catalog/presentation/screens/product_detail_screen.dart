import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId; const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ProductDetailScreen')),
      body: const Center(child: Text('ProductDetailScreen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
    );
  }
}
