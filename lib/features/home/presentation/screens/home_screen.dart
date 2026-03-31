import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cart/data/providers/cart_provider.dart';
import '../../../catalog/models/product.dart';
import '../../../catalog/providers/catalog_providers.dart';

Color _hexColor(String? hex, Color fallback) {
  if (hex == null) return fallback;
  try {
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  } catch (_) {
    return fallback;
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.asData?.value ?? [];
    final productsAsync = ref.watch(catalogProductsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/images/logo.png', width: 32, height: 32, fit: BoxFit.contain),
            ),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(children: [
                TextSpan(
                  text: 'BRIQUES',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                TextSpan(
                  text: '.STORE',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ]),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 24),
            color: AppColors.textPrimary,
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 24),
            color: AppColors.textPrimary,
            onPressed: () => context.push('/notifications'),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, size: 24),
                color: AppColors.textPrimary,
                onPressed: () => context.push('/cart'),
              ),
              if (ref.watch(cartProvider).itemCount > 0)
                Positioned(
                  right: 6, top: 6,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: Center(child: Text(
                      '${ref.watch(cartProvider).itemCount}',
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                    )),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ─── Promo Banner ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFFF6D00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'OFFRE LIMITÉE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '-15% sur les briques\nréfractaires',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pour toute commande supérieure à 500 unités.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => context.push('/promotions'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'En profiter',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Accès rapides ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text('Accès rapide', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _QuickAccessCard(icon: Icons.favorite_outline, label: 'Favoris', color: AppColors.error, onTap: () => context.push('/favorites')),
                  const SizedBox(width: 10),
                  _QuickAccessCard(icon: Icons.receipt_long_outlined, label: 'Commandes', color: const Color(0xFF9C27B0), onTap: () => context.go('/orders')),
                  const SizedBox(width: 10),
                  _QuickAccessCard(icon: Icons.local_offer_outlined, label: 'Promotions', color: AppColors.primary, onTap: () => context.push('/promotions')),
                  const SizedBox(width: 10),
                  _QuickAccessCard(icon: Icons.support_agent, label: 'Support', color: AppColors.info, onTap: () => context.push('/support')),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Catégories (depuis backend) ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Catégories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/catalog'),
                    child: const Text('Voir tout', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (categoriesAsync.isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            else if (categoriesAsync.hasError)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Text('Erreur de chargement', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => ref.invalidate(categoriesProvider),
                      child: const Text('Réessayer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ),
                  ],
                ),
              )
            else if (categories.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Aucune catégorie', style: TextStyle(color: Colors.grey.shade500)),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: categories.take(4).map((cat) {
                    final color = _hexColor(cat.colorHex, AppColors.primary);
                    final bgColor = _hexColor(cat.bgColorHex, AppColors.primary.withValues(alpha: 0.1));
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 44) / 2,
                      child: _CategoryCard(
                        icon: Icons.view_in_ar_rounded,
                        label: cat.label,
                        color: color,
                        bgColor: bgColor,
                        onTap: () => context.push('/catalog/category/${cat.slug}'),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 24),

            // ─── Populaires (depuis backend) ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Populaires',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/catalog'),
                    child: const Text('Tout voir', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 210,
              child: productsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(child: Text('Erreur de chargement', style: TextStyle(color: Colors.grey.shade500))),
                data: (page) {
                  if (page.data.isEmpty) {
                    return Center(child: Text('Aucun produit', style: TextStyle(color: Colors.grey.shade500)));
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: page.data.take(6).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final product = page.data[i];
                      return _ProductCard(product: product, onTap: () => context.push('/catalog/product/${product.id}'));
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Accès rapide card ───
class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// Carte catégorie
class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Carte produit populaire
class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cat = product.category;
    Color bgColor = const Color(0xFFF5F5F5);
    Color iconColor = AppColors.primary;
    if (cat?.bgColorHex != null) {
      try { bgColor = Color(int.parse('FF${cat!.bgColorHex!.replaceAll('#', '')}', radix: 16)); } catch (_) {}
    }
    if (cat?.colorHex != null) {
      try { iconColor = Color(int.parse('FF${cat!.colorHex!.replaceAll('#', '')}', radix: 16)); } catch (_) {}
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 155,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image produit
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: product.primaryImageUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        product.primaryImageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 100,
                        errorBuilder: (_, __, ___) => Center(child: Icon(Icons.view_in_ar_rounded, size: 48, color: iconColor)),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Center(child: CircularProgressIndicator(strokeWidth: 2, color: iconColor));
                        },
                      ),
                    )
                  : Center(child: Icon(Icons.view_in_ar_rounded, size: 48, color: iconColor)),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Réf: ${product.reference}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${product.unitPrice.toStringAsFixed(0)} F',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 16),
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
  }
}
