import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/service_locator.dart';
import '../models/product.dart';
import '../services/product_service.dart';

// ─── Service provider ─────────────────────────────────────────────────────────

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(ServiceLocator.apiClient);
});

// ─── Filtres état ─────────────────────────────────────────────────────────────

class CatalogFilters {
  final String? search;
  final String? category;
  final bool stockOnly;
  final int page;
  final int pageSize;

  const CatalogFilters({
    this.search,
    this.category,
    this.stockOnly = false,
    this.page = 1,
    this.pageSize = 20,
  });

  CatalogFilters copyWith({
    String? search,
    String? category,
    bool? stockOnly,
    int? page,
    int? pageSize,
    bool clearSearch = false,
    bool clearCategory = false,
  }) {
    return CatalogFilters(
      search: clearSearch ? null : (search ?? this.search),
      category: clearCategory ? null : (category ?? this.category),
      stockOnly: stockOnly ?? this.stockOnly,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

// ─── Notifier filtres ─────────────────────────────────────────────────────────

class CatalogFiltersNotifier extends StateNotifier<CatalogFilters> {
  CatalogFiltersNotifier() : super(const CatalogFilters());

  void setSearch(String? value) {
    state = state.copyWith(
      search: value,
      clearSearch: value == null || value.isEmpty,
      page: 1,
    );
  }

  void setCategory(String? catId) {
    state = state.copyWith(
      category: catId,
      clearCategory: catId == null,
      page: 1,
    );
  }

  void toggleStockOnly() {
    state = state.copyWith(stockOnly: !state.stockOnly, page: 1);
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
  }

  void reset() {
    state = const CatalogFilters();
  }
}

final catalogFiltersProvider =
    StateNotifierProvider<CatalogFiltersNotifier, CatalogFilters>(
  (ref) => CatalogFiltersNotifier(),
);

// ─── Provider liste produits ──────────────────────────────────────────────────

final catalogProductsProvider = FutureProvider.autoDispose<ProductsPage>((ref) async {
  final service = ref.read(productServiceProvider);
  final filters = ref.watch(catalogFiltersProvider);

  return service.getProducts(
    search: filters.search,
    category: filters.category,
    page: filters.page,
    pageSize: filters.pageSize,
  );
});

// ─── Provider produit par ID ──────────────────────────────────────────────────

final productByIdProvider =
    FutureProvider.autoDispose.family<Product, String>((ref, id) async {
  final service = ref.read(productServiceProvider);
  return service.getProductById(id);
});
