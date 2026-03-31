import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/models/order.dart';
import '../services/order_service.dart';

// ─── Service provider ─────────────────────────────────────────────────────────

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(ServiceLocator.apiClient);
});

// ─── Filtres ──────────────────────────────────────────────────────────────────

class OrderFilters {
  final OrderStatus? status;
  final String? search;
  final int page;

  const OrderFilters({this.status, this.search, this.page = 1});

  OrderFilters copyWith({
    OrderStatus? status,
    String? search,
    int? page,
    bool clearStatus = false,
    bool clearSearch = false,
  }) {
    return OrderFilters(
      status: clearStatus ? null : (status ?? this.status),
      search: clearSearch ? null : (search ?? this.search),
      page: page ?? this.page,
    );
  }
}

class OrderFiltersNotifier extends Notifier<OrderFilters> {
  @override
  OrderFilters build() => const OrderFilters();

  void setStatus(OrderStatus? value) {
    state = state.copyWith(status: value, clearStatus: value == null, page: 1);
  }

  void setSearch(String? value) {
    state = state.copyWith(
      search: value,
      clearSearch: value == null || value.isEmpty,
      page: 1,
    );
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
  }

  void reset() {
    state = const OrderFilters();
  }
}

final orderFiltersProvider =
    NotifierProvider<OrderFiltersNotifier, OrderFilters>(
  OrderFiltersNotifier.new,
);

// ─── Provider liste commandes ─────────────────────────────────────────────────

final ordersProvider = FutureProvider.autoDispose<OrdersPage>((ref) async {
  final service = ref.read(orderServiceProvider);
  final filters = ref.watch(orderFiltersProvider);

  return service.getOrders(
    status: filters.status?.backendValue,
    search: filters.search,
    page: filters.page,
  );
});

// ─── Provider détail commande ─────────────────────────────────────────────────

final orderByIdProvider =
    FutureProvider.autoDispose.family<OrderModel, String>((ref, id) async {
  final service = ref.read(orderServiceProvider);
  return service.getOrderById(id);
});
