import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/product_category.dart';
import '../../models/product.dart';
import '../../providers/catalog_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();
  String? _selectedCategory;
  bool _showFilters = false;
  String _sortBy = 'pertinence';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(catalogProductsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Container(
          height: 42,
          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: _searchCtrl,
            autofocus: true,
            onChanged: (v) {
              setState(() {});
              ref.read(catalogFiltersProvider.notifier).setSearch(v);
            },
            decoration: InputDecoration(
              hintText: 'Rechercher un produit...',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        setState(() => _searchCtrl.clear());
                        ref.read(catalogFiltersProvider.notifier).setSearch(null);
                      },
                      child: Icon(Icons.close, color: Colors.grey.shade400, size: 18),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: _showFilters ? AppColors.primary : AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Filtres ──────────────────────────────────────────────────
          if (_showFilters)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CATÉGORIE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: BriqueCategories.all.map((cat) {
                      final selected = _selectedCategory == cat.id;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = selected ? null : cat.id);
                          ref.read(catalogFiltersProvider.notifier).setCategory(selected ? null : cat.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300),
                          ),
                          child: Text(cat.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? Colors.white : AppColors.textSecondary)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text('TRIER PAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 0.5)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _sortBy,
                          isExpanded: true, underline: const SizedBox(),
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          items: const [
                            DropdownMenuItem(value: 'pertinence', child: Text('Pertinence')),
                            DropdownMenuItem(value: 'prix_asc', child: Text('Prix croissant')),
                            DropdownMenuItem(value: 'prix_desc', child: Text('Prix décroissant')),
                          ],
                          onChanged: (v) => setState(() => _sortBy = v!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // ─── Contenu ──────────────────────────────────────────────────
          Expanded(
            child: _searchCtrl.text.isEmpty
                ? _buildSuggestions()
                : productsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => Center(
                      child: Text('Erreur de chargement', style: TextStyle(color: Colors.grey.shade500)),
                    ),
                    data: (page) {
                      var products = page.data;
                      if (_sortBy == 'prix_asc') {
                        products = [...products]..sort((a, b) => a.unitPrice.compareTo(b.unitPrice));
                      } else if (_sortBy == 'prix_desc') {
                        products = [...products]..sort((a, b) => b.unitPrice.compareTo(a.unitPrice));
                      }
                      return products.isEmpty
                          ? _buildNoResults()
                          : _buildResults(products, page.total);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Catégories populaires', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: BriqueCategories.all.map((cat) => GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = cat.id);
                ref.read(catalogFiltersProvider.notifier).setCategory(cat.id);
                _searchCtrl.text = cat.label;
                ref.read(catalogFiltersProvider.notifier).setSearch(cat.label);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: cat.bgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon, size: 16, color: cat.color),
                    const SizedBox(width: 6),
                    Text(cat.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cat.color)),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Aucun résultat pour "${_searchCtrl.text}"', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          Text('Essayez avec d\'autres mots-clés', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildResults(List<Product> products, int total) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text('$total résultat(s)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final p = products[index];
              final cat = BriqueCategories.findByBackendCategory(p.category);
              return GestureDetector(
                onTap: () => context.push('/product/${p.id}'),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      // Image ou placeholder
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: p.primaryImageUrl != null
                            ? Image.network(p.primaryImageUrl!, width: 52, height: 52, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _iconPlaceholder(cat))
                            : _iconPlaceholder(cat),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text('Réf: ${p.reference} • ${cat?.label ?? p.category}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      Text('${p.unitPrice.toStringAsFixed(0)} F', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _iconPlaceholder(ProductCategory? cat) {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(color: cat?.bgColor ?? Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
      child: Icon(cat?.icon ?? Icons.view_in_ar_rounded, color: cat?.color ?? AppColors.primary, size: 26),
    );
  }
}
