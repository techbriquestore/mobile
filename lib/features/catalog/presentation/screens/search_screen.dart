import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  String _sortBy = 'pertinence';
  RangeValues _priceRange = const RangeValues(0, 500000);
  String? _selectedCategory;
  bool _showFilters = false;

  final _categories = ['Briques pleines', 'Briques creuses', 'Briques réfractaires', 'Briques décoratives', 'Hourdis'];

  final _recentSearches = ['Brique pleine rouge', 'Hourdis 20', 'Parpaing 15', 'Brique creuse'];

  final _mockResults = [
    _SearchResult(name: 'Brique Pleine Rouge 10x20x40', ref: 'BPR-1020', price: 150, unit: 'unité', category: 'Briques pleines', icon: Icons.crop_square, color: Colors.red),
    _SearchResult(name: 'Brique Creuse 15x20x40', ref: 'BC-1520', price: 175, unit: 'unité', category: 'Briques creuses', icon: Icons.check_box_outline_blank, color: Colors.orange),
    _SearchResult(name: 'Hourdis Français 16', ref: 'HF-16', price: 850, unit: 'unité', category: 'Hourdis', icon: Icons.view_module, color: Colors.blue),
    _SearchResult(name: 'Brique Réfractaire Standard', ref: 'BRF-STD', price: 1200, unit: 'unité', category: 'Briques réfractaires', icon: Icons.whatshot, color: Colors.deepOrange),
    _SearchResult(name: 'Parpaing Décoratif Ajouré', ref: 'PDA-01', price: 2500, unit: 'unité', category: 'Briques décoratives', icon: Icons.grid_view, color: Colors.teal),
    _SearchResult(name: 'Brique Pleine Grise 10x20x40', ref: 'BPG-1020', price: 140, unit: 'unité', category: 'Briques pleines', icon: Icons.crop_square, color: Colors.grey),
  ];

  List<_SearchResult> get _filteredResults {
    var results = _mockResults;
    if (_searchCtrl.text.isNotEmpty) {
      final q = _searchCtrl.text.toLowerCase();
      results = results.where((r) => r.name.toLowerCase().contains(q) || r.ref.toLowerCase().contains(q)).toList();
    }
    if (_selectedCategory != null) {
      results = results.where((r) => r.category == _selectedCategory).toList();
    }
    results = results.where((r) => r.price >= _priceRange.start && r.price <= _priceRange.end).toList();
    if (_sortBy == 'prix_asc') {
      results.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'prix_desc') {
      results.sort((a, b) => b.price.compareTo(a.price));
    }
    return results;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredResults;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary), onPressed: () => context.pop()),
        title: Container(
          height: 42,
          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: _searchCtrl,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Rechercher un produit...',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () => setState(() => _searchCtrl.clear()),
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
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list, color: _showFilters ? AppColors.primary : AppColors.textPrimary, size: 22),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters panel
          if (_showFilters)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chips
                  Text('CATÉGORIE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _categories.map((c) {
                      final selected = _selectedCategory == c;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = selected ? null : c),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300),
                          ),
                          child: Text(c, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? Colors.white : AppColors.textSecondary)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Price range
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('PRIX (FCFA)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 0.5)),
                      Text('${_priceRange.start.toInt()} - ${_priceRange.end.toInt()} F', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0, max: 500000, divisions: 50,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _priceRange = v),
                  ),

                  // Sort
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

          // Content
          Expanded(
            child: _searchCtrl.text.isEmpty
                ? _buildRecentSearches()
                : results.isEmpty
                    ? _buildNoResults()
                    : _buildResults(results),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recherches récentes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
              GestureDetector(
                onTap: () {},
                child: const Text('Effacer', style: TextStyle(fontSize: 13, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._recentSearches.map((s) => GestureDetector(
            onTap: () => setState(() => _searchCtrl.text = s),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.history, size: 18, color: Colors.grey.shade400),
                  const SizedBox(width: 12),
                  Text(s, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
            ),
          )),
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
          Text('Essayez avec d\'autres mots-clés ou filtres', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildResults(List<_SearchResult> results) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text('${results.length} résultat(s)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final r = results[index];
              return GestureDetector(
                onTap: () => context.push('/catalog/product/${r.ref}'),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(color: r.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(r.icon, color: r.color, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text('Réf: ${r.ref} • ${r.category}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      Text('${r.price.toStringAsFixed(0)} F', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
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
}

class _SearchResult {
  final String name, ref, unit, category;
  final double price;
  final IconData icon;
  final Color color;

  const _SearchResult({required this.name, required this.ref, required this.price, required this.unit, required this.category, required this.icon, required this.color});
}
