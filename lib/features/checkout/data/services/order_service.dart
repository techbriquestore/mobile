import '../../../../core/network/api_client.dart';

class OrderItem {
  final String productId;
  final int quantity;
  final double? unitPrice;

  const OrderItem({
    required this.productId,
    required this.quantity,
    this.unitPrice,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
        if (unitPrice != null) 'unitPrice': unitPrice!.round(),
      };
}

class CreateOrderRequest {
  final List<OrderItem> items;
  final String? deliveryAddressId;
  final String deliveryMode;
  final String? deliveryNotes;
  final int paymentDuration;

  const CreateOrderRequest({
    required this.items,
    this.deliveryAddressId,
    this.deliveryMode = 'STANDARD',
    this.deliveryNotes,
    this.paymentDuration = 1,
  });

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        if (deliveryAddressId != null) 'deliveryAddressId': deliveryAddressId,
        'deliveryMode': deliveryMode,
        if (deliveryNotes != null) 'deliveryNotes': deliveryNotes,
        'paymentDuration': paymentDuration,
      };
}

class Order {
  final String id;
  final String orderNumber;
  final String status;
  final int subtotal;
  final int deliveryFee;
  final int totalAmount;
  final String deliveryMode;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.deliveryMode,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        orderNumber: json['orderNumber'] as String,
        status: json['status'] as String,
        subtotal: json['subtotal'] as int,
        deliveryFee: json['deliveryFee'] as int,
        totalAmount: json['totalAmount'] as int,
        deliveryMode: json['deliveryMode'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class OrdersPage {
  final List<Order> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const OrdersPage({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory OrdersPage.fromJson(Map<String, dynamic> json) => OrdersPage(
        data: (json['data'] as List<dynamic>)
            .map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int,
        page: json['page'] as int,
        pageSize: json['pageSize'] as int,
        totalPages: json['totalPages'] as int,
      );
}

class OrderService {
  final ApiClient _client;

  OrderService(this._client);

  Future<Order> createOrder(CreateOrderRequest request) async {
    final response = await _client.post('/orders', data: request.toJson());
    return Order.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OrdersPage> getOrders({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (status != null) 'status': status,
    };
    final response = await _client.get('/orders', queryParams: params);
    return OrdersPage.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Order> getOrderById(String id) async {
    final response = await _client.get('/orders/$id');
    return Order.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Order> cancelOrder(String id, {String? reason}) async {
    final response = await _client.patch(
      '/orders/$id/cancel',
      data: reason != null ? {'reason': reason} : null,
    );
    return Order.fromJson(response.data as Map<String, dynamic>);
  }
}
