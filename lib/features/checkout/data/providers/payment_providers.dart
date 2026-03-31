import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/service_locator.dart';
import '../services/payment_service.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(ServiceLocator.apiClient);
});

final orderPaymentsProvider =
    FutureProvider.autoDispose.family<OrderPaymentsData, String>((ref, orderId) async {
  final service = ref.read(paymentServiceProvider);
  return service.getOrderPayments(orderId);
});

final paymentHistoryProvider =
    FutureProvider.autoDispose<PaymentHistoryPage>((ref) async {
  final service = ref.read(paymentServiceProvider);
  return service.getPaymentHistory();
});
