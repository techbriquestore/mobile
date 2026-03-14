import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/product_category.dart';
import '../../domain/models/brick_product.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 100;

  @override
  Widget build(BuildContext context) {
    final product = BrickProductMock.all.cast<BrickProduct?>().firstWhere(
          (p) => p!.id == widget.productId,
          orElse: () => null,
        );

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Produit introuvable')),
        body: const Center(child: Text('Ce produit n\'existe pas.')),
      );
    }

    final category = BriqueCategories.findById(product.categoryId);
    final subCategory = BriqueCategories.findSubById(product.subCategoryId);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ─── Image Header ─────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 260,
                  pinned: true,
                  backgroundColor: category?.bgColor ?? const Color(0xFFF5F5F5),
                  leading: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 18, color: AppColors.textPrimary),
                    ),
                  ),
                  actions: [
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ajouté aux favoris !'), backgroundColor: AppColors.success, duration: Duration(seconds: 1)),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                        child: const Icon(Icons.favorite_border, size: 20, color: AppColors.error),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/cart'),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shopping_cart_outlined,
                            size: 20, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Center(
                      child: Icon(
                        category?.icon ?? Icons.view_in_ar_rounded,
                        size: 100,
                        color: category?.color ?? AppColors.primary,
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Product Info ───────────────────────────────────
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category + SubCategory badges
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (category?.color ?? AppColors.primary)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    category?.label ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: category?.color ?? AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (subCategory != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      subCategory.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                const Spacer(),
                                // Stock badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: product.inStock
                                        ? AppColors.success
                                        : AppColors.error,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    product.inStock
                                        ? 'EN STOCK (${product.stockQty})'
                                        : 'RUPTURE',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Réf : ${product.reference}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text:
                                      '${product.pricePerUnit.toStringAsFixed(0)} FCFA ',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                TextSpan(
                                  text: '/ ${product.unit}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ─── Description ────────────────────────────────────
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              product.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ─── Specs ──────────────────────────────────────────
                      if (product.specs.isNotEmpty)
                        Container(
                          color: Colors.white,
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Caractéristiques',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 14),
                              ...product.specs.entries.map((e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: (category?.color ??
                                                    AppColors.primary)
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            Icons.info_outline,
                                            size: 18,
                                            color: category?.color ??
                                                AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                e.key,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              Text(
                                                e.value,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Bottom bar: Quantity + Add to cart ──────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Quantity selector
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_quantity > 1) setState(() => _quantity -= 10);
                        },
                        child: Container(
                          width: 40,
                          height: 44,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          child: const Icon(Icons.remove, size: 18),
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Center(
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _quantity += 10),
                        child: Container(
                          width: 40,
                          height: 44,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: const Icon(Icons.add, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Add to cart button
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: product.inStock ? () {} : null,
                      icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                      label: Text(
                        'Ajouter  ${(product.pricePerUnit * _quantity).toStringAsFixed(0)} F',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
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
