import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/service_locator.dart';
import '../../../cart/data/providers/cart_provider.dart';
import '../services/order_service.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(ServiceLocator.apiClient);
});

final ordersProvider = FutureProvider.family<OrdersPage, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(orderServiceProvider);
  return service.getOrders(
    status: params['status'] as String?,
    page: params['page'] as int? ?? 1,
    pageSize: params['pageSize'] as int? ?? 20,
  );
});

final orderByIdProvider = FutureProvider.family<Order, String>((ref, id) async {
  final service = ref.watch(orderServiceProvider);
  return service.getOrderById(id);
});

class CreateOrderState {
  final bool isLoading;
  final Order? order;
  final String? error;

  const CreateOrderState({
    this.isLoading = false,
    this.order,
    this.error,
  });

  CreateOrderState copyWith({
    bool? isLoading,
    Order? order,
    String? error,
  }) {
    return CreateOrderState(
      isLoading: isLoading ?? this.isLoading,
      order: order ?? this.order,
      error: error,
    );
  }
}

class CreateOrderNotifier extends Notifier<CreateOrderState> {
  @override
  CreateOrderState build() => const CreateOrderState();

  Future<Order?> createOrder({
    required List<Map<String, dynamic>> items,
    String? deliveryAddressId,
    String deliveryMode = 'STANDARD',
    String? deliveryNotes,
    int paymentDuration = 1,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final orderItems = items.map((item) => OrderItem(
            productId: item['productId'] as String,
            quantity: item['quantity'] as int,
            unitPrice: (item['unitPrice'] as num?)?.toDouble(),
          )).toList();

      final request = CreateOrderRequest(
        items: orderItems,
        deliveryAddressId: deliveryAddressId,
        deliveryMode: deliveryMode,
        deliveryNotes: deliveryNotes,
        paymentDuration: paymentDuration,
      );

      final orderService = ref.read(orderServiceProvider);
      final order = await orderService.createOrder(request);
      
      // Clear cart after successful order
      ref.read(cartProvider.notifier).clear();
      
      state = state.copyWith(isLoading: false, order: order);
      return order;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = const CreateOrderState();
  }
}

final createOrderProvider =
    NotifierProvider<CreateOrderNotifier, CreateOrderState>(CreateOrderNotifier.new);
