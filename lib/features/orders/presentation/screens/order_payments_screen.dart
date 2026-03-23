import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class OrderPaymentsScreen extends StatelessWidget {
  final String orderId;
  const OrderPaymentsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    // TODO: Charger les paiements depuis le backend avec orderId
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('Mes paiements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Paiements - Commande #$orderId',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Les échéances seront chargées depuis le backend',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
