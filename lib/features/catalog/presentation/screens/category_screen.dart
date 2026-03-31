import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/product.dart';
import '../../providers/catalog_providers.dart';

Color _hexColor(String? hex, Color fallback) {
  if (hex == null) return fallback;
  try {
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  } catch (_) {
    return fallback;
  }
}

class CategoryScreen extends ConsumerStatefulWidget {
  final String categoryId;
  const CategoryScreen({super.key, required this.categoryId});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    // Appliquer le filtre catégorie au chargement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(catalogFiltersProvider.notifier).setCategory(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final category = categoriesAsync.asData?.value
        .where((c) => c.slug == widget.categoryId || c.id == widget.categoryId)
        .firstOrNull;
    final productsAsync = ref.watch(catalogProductsProvider);

    final catColor = _hexColor(category?.colorHex, AppColors.primary);
    final catBgColor = _hexColor(category?.bgColorHex, const Color(0xFFF5F5F5));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(catalogFiltersProvider.notifier).setCategory(null);
                      context.pop();
                    },
                    child: const Icon(Icons.arrow_back_ios_new,
                        size: 20, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: catBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.view_in_ar_rounded, size: 20, color: catColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category?.label ?? widget.categoryId,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        productsAsync.when(
                          data: (page) => Text(
                            '${page.total} produit${page.total > 1 ? 's' : ''}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                          loading: () => Text('Chargement...', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Chip "Tous" uniquement (sous-catégories supprimées)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _SubChip(
                      label: 'Tous',
                      isSelected: true,
                      color: catColor,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ─── Grille produits ───────────────────────────────────────────
            Expanded(
              child: productsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('Erreur de chargement', style: TextStyle(color: Colors.grey.shade500)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(catalogProductsProvider),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
                data: (page) => page.data.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 52, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text('Aucun produit dans cette catégorie',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.62,
                        ),
                        itemCount: page.data.length,
                        itemBuilder: (context, i) =>
                            _ProductCard(product: page.data[i], catColor: catColor, catBgColor: catBgColor),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub Chip ─────────────────────────────────────────────────────────────────
class _SubChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _SubChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: isSelected ? color : Colors.grey.shade300, width: 1.2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// Product Card
class _ProductCard extends StatelessWidget {
  final Product product;
  final Color catColor;
  final Color catBgColor;
  const _ProductCard({required this.product, required this.catColor, required this.catBgColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/catalog/product/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: product.primaryImageUrl != null
                        ? Image.network(
                            product.primaryImageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 8,
                    child: Text(
                      product.reference,
                      style: TextStyle(fontSize: 9, color: catColor.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.3),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${product.unitPrice.toStringAsFixed(0)} F ',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                                ),
                                TextSpan(
                                  text: '/ unité',
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: AppColors.primary, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      color: catBgColor,
      child: Center(child: Icon(Icons.view_in_ar_rounded, size: 56, color: catColor)),
    );
  }
}
