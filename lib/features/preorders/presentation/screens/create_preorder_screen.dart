import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class CreatePreorderScreen extends StatefulWidget {
  const CreatePreorderScreen({super.key});

  @override
  State<CreatePreorderScreen> createState() => _CreatePreorderScreenState();
}

class _CreatePreorderScreenState extends State<CreatePreorderScreen> {
  String _selectedProduct = 'Brique Pleine 20cm Standard';
  int _quantity = 1000;
  int _installments = 3;
  final _noteController = TextEditingController();

  final _products = [
    {'name': 'Brique Pleine 20cm Standard', 'price': 250},
    {'name': 'Brique Pleine 15cm Standard', 'price': 200},
    {'name': 'Brique Creuse 15cm', 'price': 180},
    {'name': 'Brique Creuse 12cm', 'price': 160},
    {'name': 'Hourdis Français 16cm', 'price': 400},
    {'name': 'Hourdis Américain', 'price': 450},
  ];

  int get _unitPrice => (_products.firstWhere((p) => p['name'] == _selectedProduct)['price'] as int);
  int get _total => _unitPrice * _quantity;
  int get _perInstallment => (_total / _installments).round();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('Nouvelle pré-commande', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Product ───
                  _Label('Produit'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedProduct, isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                        items: _products.map((p) => DropdownMenuItem(value: p['name'] as String, child: Text(p['name'] as String))).toList(),
                        onChanged: (v) { if (v != null) setState(() => _selectedProduct = v); },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ─── Quantity ───
                  _Label('Quantité (unités)'),
                  Container(
                    height: 56, padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () { if (_quantity > 100) setState(() => _quantity -= 100); },
                          child: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.remove, color: AppColors.primary, size: 20)),
                        ),
                        Expanded(child: Center(child: Text('$_quantity', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)))),
                        GestureDetector(
                          onTap: () => setState(() => _quantity += 100),
                          child: Container(width: 44, height: 44, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.add, color: Colors.white, size: 20)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ─── Installments ───
                  _Label('Nombre d\'échéances'),
                  Row(
                    children: [2, 3, 4, 6].map((n) {
                      final selected = _installments == n;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _installments = n),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            height: 48,
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300),
                            ),
                            child: Center(child: Text('$n x', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.textPrimary))),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // ─── Notes ───
                  _Label('Notes (optionnel)'),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: TextField(
                      controller: _noteController, maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Instructions spéciales, date souhaitée...',
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Summary ───
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Prix unitaire', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                          Text('$_unitPrice FCFA', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        ]),
                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Quantité', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                          Text('$_quantity unités', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        ]),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1)),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          Text('$_total FCFA', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        ]),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity, padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10)),
                          child: Text('$_installments échéances de $_perInstallment FCFA', textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28), color: Colors.white,
            child: SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pré-commande créée avec succès !'), backgroundColor: AppColors.success)); context.pop(); },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                child: const Text('Créer la pré-commande', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
    );
  }
}
