import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class _FavoriteProduct {
  final String id, name, ref, category;
  final double price;
  final IconData icon;
  final Color color;
  bool isFavorite;

  _FavoriteProduct({required this.id, required this.name, required this.ref, required this.price, required this.category, required this.icon, required this.color, this.isFavorite = true});
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final List<_FavoriteProduct> _favorites = [
    _FavoriteProduct(id: 'BPR-1020', name: 'Brique Pleine Rouge 10x20x40', ref: 'BPR-1020', price: 150, category: 'Briques pleines', icon: Icons.crop_square, color: Colors.red),
    _FavoriteProduct(id: 'BC-1520', name: 'Brique Creuse 15x20x40', ref: 'BC-1520', price: 175, category: 'Briques creuses', icon: Icons.check_box_outline_blank, color: Colors.orange),
    _FavoriteProduct(id: 'HF-16', name: 'Hourdis Français 16', ref: 'HF-16', price: 850, category: 'Hourdis', icon: Icons.view_module, color: Colors.blue),
    _FavoriteProduct(id: 'BRF-STD', name: 'Brique Réfractaire Standard', ref: 'BRF-STD', price: 1200, category: 'Briques réfractaires', icon: Icons.whatshot, color: Colors.deepOrange),
  ];

  @override
  Widget build(BuildContext context) {
    final active = _favorites.where((f) => f.isFavorite).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        centerTitle: true,
        title: const Text('Mes favoris', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        actions: [
          if (active.isNotEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                child: Text('${active.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
      body: active.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Aucun favori', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade400)),
                  const SizedBox(height: 8),
                  Text('Ajoutez des produits à vos favoris\npour les retrouver facilement', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/catalog'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    child: const Text('Parcourir le catalogue'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: active.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final p = active[index];
                return GestureDetector(
                  onTap: () => context.push('/catalog/product/${p.id}'),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(color: p.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                          child: Icon(p.icon, color: p.color, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text('Réf: ${p.ref} • ${p.category}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                              const SizedBox(height: 4),
                              Text('${p.price.toStringAsFixed(0)} F/unité', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => p.isFavorite = false),
                              child: Container(
                                width: 38, height: 38,
                                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.favorite, color: AppColors.error, size: 20),
                              ),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.name} ajouté au panier'), backgroundColor: AppColors.success));
                              },
                              child: Container(
                                width: 38, height: 38,
                                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.add_shopping_cart, color: AppColors.primary, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
