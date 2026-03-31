import '../../../../core/network/api_client.dart';

class PaymentResult {
  final Map<String, dynamic> payment;
  final String orderId;
  final String orderNumber;
  final String status;
  final int totalAmount;
  final int totalPaid;
  final int remaining;

  const PaymentResult({
    required this.payment,
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    required this.totalPaid,
    required this.remaining,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    final order = json['order'] as Map<String, dynamic>;
    return PaymentResult(
      payment: json['payment'] as Map<String, dynamic>,
      orderId: order['id'] as String,
      orderNumber: order['orderNumber'] as String,
      status: order['status'] as String,
      totalAmount: order['totalAmount'] as int,
      totalPaid: order['totalPaid'] as int,
      remaining: order['remaining'] as int,
    );
  }
}

class OrderPaymentsData {
  final List<PaymentInfo> payments;
  final int totalAmount;
  final int totalPaid;
  final int remaining;
  final int? paymentDuration;

  const OrderPaymentsData({
    required this.payments,
    required this.totalAmount,
    required this.totalPaid,
    required this.remaining,
    this.paymentDuration,
  });

  factory OrderPaymentsData.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>;
    return OrderPaymentsData(
      payments: (json['payments'] as List<dynamic>)
          .map((e) => PaymentInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: summary['totalAmount'] as int,
      totalPaid: summary['totalPaid'] as int,
      remaining: summary['remaining'] as int,
      paymentDuration: summary['paymentDuration'] as int?,
    );
  }

  double get progressPercent =>
      totalAmount > 0 ? (totalPaid / totalAmount).clamp(0.0, 1.0) : 0.0;
}

class PaymentInfo {
  final String id;
  final String orderId;
  final int amount;
  final String method;
  final String status;
  final String? providerTxId;
  final DateTime? paidAt;
  final DateTime createdAt;
  final Map<String, dynamic>? order;

  const PaymentInfo({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.method,
    required this.status,
    this.providerTxId,
    this.paidAt,
    required this.createdAt,
    this.order,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      amount: json['amount'] as int,
      method: json['method'] as String,
      status: json['status'] as String,
      providerTxId: json['providerTxId'] as String?,
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      order: json['order'] as Map<String, dynamic>?,
    );
  }

  String get methodLabel {
    switch (method) {
      case 'ORANGE_MONEY': return 'Orange Money';
      case 'MTN_MONEY': return 'MTN Money';
      case 'MOOV_MONEY': return 'Moov Money';
      case 'WAVE': return 'Wave';
      case 'VISA': return 'Visa';
      case 'MASTERCARD': return 'Mastercard';
      default: return method;
    }
  }

  bool get isConfirmed => status == 'CONFIRMED';
}

class PaymentHistoryPage {
  final List<PaymentInfo> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const PaymentHistoryPage({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory PaymentHistoryPage.fromJson(Map<String, dynamic> json) => PaymentHistoryPage(
        data: (json['data'] as List<dynamic>)
            .map((e) => PaymentInfo.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int,
        page: json['page'] as int,
        pageSize: json['pageSize'] as int,
        totalPages: json['totalPages'] as int,
      );
}

class PaymentService {
  final ApiClient _client;

  PaymentService(this._client);

  /// Simulate a payment (dev mode)
  Future<PaymentResult> simulatePayment({
    required String orderId,
    required int amount,
    required String method,
    String? providerPhone,
  }) async {
    final response = await _client.post('/payments/simulate', data: {
      'orderId': orderId,
      'amount': amount,
      'method': method,
      if (providerPhone != null) 'providerPhone': providerPhone,
    });
    return PaymentResult.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get payments for a specific order
  Future<OrderPaymentsData> getOrderPayments(String orderId) async {
    final response = await _client.get('/payments/order/$orderId');
    return OrderPaymentsData.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get user's payment history
  Future<PaymentHistoryPage> getPaymentHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.get('/payments/history', queryParams: {
      'page': page,
      'pageSize': pageSize,
    });
    return PaymentHistoryPage.fromJson(response.data as Map<String, dynamic>);
  }
}
