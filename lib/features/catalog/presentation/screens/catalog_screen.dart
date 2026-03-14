import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/product_category.dart';
import '../../domain/models/brick_product.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedSubCategoryId;
  bool _stockOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BrickProduct> get _filteredProducts {
    final query = _searchController.text.trim();
    List<BrickProduct> products;

    if (query.isNotEmpty) {
      products = BrickProductMock.search(query);
    } else if (_selectedSubCategoryId != null) {
      products = BrickProductMock.bySubCategory(_selectedSubCategoryId!);
    } else if (_selectedCategoryId != null) {
      products = BrickProductMock.byCategory(_selectedCategoryId!);
    } else {
      products = BrickProductMock.all;
    }

    if (_stockOnly) products = products.where((p) => p.inStock).toList();
    return products;
  }

  ProductCategory? get _activeCategory =>
      _selectedCategoryId != null
          ? BriqueCategories.findById(_selectedCategoryId!)
          : null;

  void _selectCategory(String catId) {
    setState(() {
      if (_selectedCategoryId == catId) {
        _selectedCategoryId = null;
        _selectedSubCategoryId = null;
      } else {
        _selectedCategoryId = catId;
        _selectedSubCategoryId = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Top bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_ios_new,
                        size: 20, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Rechercher une brique...',
                          hintStyle: TextStyle(
                              fontSize: 14, color: Colors.grey.shade400),
                          prefixIcon: Icon(Icons.search,
                              color: Colors.grey.shade400, size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  child: Icon(Icons.close,
                                      color: Colors.grey.shade400, size: 18),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        color: AppColors.textPrimary,
                        onPressed: () => context.push('/cart'),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle),
                          child: const Center(
                            child: Text('3',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ─── Catégories ────────────────────────────────────────────────
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Chip "Tous"
                  _CategoryChip(
                    label: 'Tous',
                    icon: Icons.grid_view_rounded,
                    isSelected: _selectedCategoryId == null,
                    color: AppColors.primary,
                    onTap: () => setState(() {
                      _selectedCategoryId = null;
                      _selectedSubCategoryId = null;
                    }),
                  ),
                  const SizedBox(width: 8),
                  // Chips catégories
                  ...BriqueCategories.all.map((cat) {
                    final isSelected = _selectedCategoryId == cat.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CategoryChip(
                        label: cat.label,
                        icon: cat.icon,
                        isSelected: isSelected,
                        color: cat.color,
                        onTap: () => _selectCategory(cat.id),
                      ),
                    );
                  }),
                  // Chip "En stock"
                  _CategoryChip(
                    label: 'En stock',
                    icon: Icons.check_circle_outline,
                    isSelected: _stockOnly,
                    color: AppColors.success,
                    onTap: () => setState(() => _stockOnly = !_stockOnly),
                  ),
                ],
              ),
            ),

            // ─── Sous-catégories (si catégorie sélectionnée) ───────────────
            if (_activeCategory != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // "Tous" dans la catégorie
                    _SubCategoryChip(
                      label: 'Tous',
                      isSelected: _selectedSubCategoryId == null,
                      color: _activeCategory!.color,
                      onTap: () =>
                          setState(() => _selectedSubCategoryId = null),
                    ),
                    const SizedBox(width: 8),
                    ..._activeCategory!.subCategories.map((sub) {
                      final isSelected = _selectedSubCategoryId == sub.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _SubCategoryChip(
                          label: sub.label,
                          isSelected: isSelected,
                          color: _activeCategory!.color,
                          onTap: () => setState(
                              () => _selectedSubCategoryId = sub.id),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // ─── Compteur résultats ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${products.length} produit${products.length > 1 ? 's' : ''}',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),

            // ─── Grille produits ───────────────────────────────────────────
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off,
                              size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('Aucun produit trouvé',
                              style: TextStyle(
                                  color: Colors.grey.shade400, fontSize: 14)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.62,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return _ProductCard(product: products[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Category Chip ─────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
              color: isSelected ? color : Colors.grey.shade300, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color: isSelected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-Category Chip ────────────────────────────────────────────────────────
class _SubCategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _SubCategoryChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
              color: isSelected ? color : Colors.grey.shade300, width: 1.2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? color : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final BrickProduct product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final category = BriqueCategories.findById(product.categoryId);
    final bgColor = category?.bgColor ?? const Color(0xFFF5F5F5);
    final iconColor = category?.color ?? AppColors.primary;
    final icon = category?.icon ?? Icons.view_in_ar_rounded;

    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
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
            // ── Image placeholder + badges ─────────────────────────────
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Icon(icon, size: 56, color: iconColor),
                    ),
                  ),
                  // Stock badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: product.inStock
                            ? AppColors.success
                            : AppColors.error,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.inStock ? 'EN STOCK' : 'RUPTURE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  // Référence
                  Positioned(
                    bottom: 6,
                    right: 8,
                    child: Text(
                      product.reference,
                      style: TextStyle(
                        fontSize: 9,
                        color: iconColor.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Infos produit ──────────────────────────────────────────
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
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
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
                                  text:
                                      '${product.pricePerUnit.toStringAsFixed(0)} F ',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                TextSpan(
                                  text: '/ ${product.unit}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: product.inStock ? () {} : null,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: product.inStock
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              color: product.inStock
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                              size: 18,
                            ),
                          ),
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
}
