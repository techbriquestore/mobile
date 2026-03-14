import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class _CartItem {
  final String id;
  final String name;
  final String reference;
  final double unitPrice;
  final String unit;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  int quantity;

  _CartItem({
    required this.id,
    required this.name,
    required this.reference,
    required this.unitPrice,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.quantity,
  });

  double get total => unitPrice * quantity;
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<_CartItem> _items = [
    _CartItem(
      id: 'bp20_std',
      name: 'Brique Pleine 20cm Standard',
      reference: 'BP-20-STD',
      unitPrice: 250,
      unit: 'unité',
      icon: Icons.view_in_ar_rounded,
      iconColor: const Color(0xFFE65100),
      bgColor: const Color(0xFFFFF3E0),
      quantity: 2000,
    ),
    _CartItem(
      id: 'hf_16',
      name: 'Hourdis Français 16cm',
      reference: 'HF-16',
      unitPrice: 400,
      unit: 'unité',
      icon: Icons.layers_rounded,
      iconColor: const Color(0xFF2E7D32),
      bgColor: const Color(0xFFE8F5E9),
      quantity: 500,
    ),
    _CartItem(
      id: 'bc12_std',
      name: 'Brique Creuse 12cm Standard',
      reference: 'BC-12-STD',
      unitPrice: 160,
      unit: 'unité',
      icon: Icons.widgets_rounded,
      iconColor: const Color(0xFF1565C0),
      bgColor: const Color(0xFFE3F2FD),
      quantity: 1000,
    ),
  ];

  double get _subTotal => _items.fold(0, (sum, item) => sum + item.total);
  double get _deliveryFee => 15000;
  double get _total => _subTotal + _deliveryFee;

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'Mon Panier (${_items.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Votre panier est vide',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  Text('Parcourez notre catalogue pour ajouter des produits',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade400)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/catalog'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                    ),
                    child: const Text('Voir le catalogue',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // ─── Cart Items ───────────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _removeItem(index),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.white, size: 28),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              // Product icon
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: item.bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(item.icon,
                                    color: item.iconColor, size: 28),
                              ),
                              const SizedBox(width: 14),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.unitPrice.toStringAsFixed(0)} F / ${item.unit}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500),
                                    ),
                                    const SizedBox(height: 10),
                                    // Quantity + Total
                                    Row(
                                      children: [
                                        // Qty controls
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF5F5F5),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  if (item.quantity > 10) {
                                                    setState(() =>
                                                        item.quantity -= 10);
                                                  }
                                                },
                                                child: const SizedBox(
                                                  width: 32,
                                                  height: 32,
                                                  child: Icon(Icons.remove,
                                                      size: 16),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 44,
                                                child: Center(
                                                  child: Text(
                                                    '${item.quantity}',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => setState(
                                                    () => item.quantity += 10),
                                                child: const SizedBox(
                                                  width: 32,
                                                  height: 32,
                                                  child:
                                                      Icon(Icons.add, size: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${item.total.toStringAsFixed(0)} F',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ─── Summary + Checkout ───────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _PriceRow(
                          label: 'Sous-total',
                          value: '${_subTotal.toStringAsFixed(0)} FCFA'),
                      const SizedBox(height: 8),
                      _PriceRow(
                          label: 'Livraison',
                          value: '${_deliveryFee.toStringAsFixed(0)} FCFA'),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          Text('${_total.toStringAsFixed(0)} FCFA',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => context.push('/checkout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: const Text('Passer la commande',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        Text(value,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
    );
  }
}
