import '../../../../core/network/api_client.dart';
import '../../domain/models/order.dart';

class OrderService {
  final ApiClient _client;

  OrderService(this._client);

  Future<OrdersPage> getOrders({
    String? status,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (status != null) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await _client.get('/orders', queryParams: params);
    return OrdersPage.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OrderModel> getOrderById(String id) async {
    final response = await _client.get('/orders/$id');
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OrderModel> cancelOrder(String id, {String? reason}) async {
    final response = await _client.patch('/orders/$id/cancel', data: {
      if (reason != null) 'reason': reason,
    });
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Créer une commande avec paiement instantané (1x)
  Future<OrderModel> createOrder({
    required List<Map<String, dynamic>> items,
    String? deliveryAddressId,
    String deliveryMode = 'STANDARD',
    String? deliveryNotes,
  }) async {
    final response = await _client.post('/orders', data: {
      'items': items,
      if (deliveryAddressId != null) 'deliveryAddressId': deliveryAddressId,
      'deliveryMode': deliveryMode,
      if (deliveryNotes != null) 'deliveryNotes': deliveryNotes,
      'paymentDuration': 1, // Paiement immédiat
    });
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }
}
