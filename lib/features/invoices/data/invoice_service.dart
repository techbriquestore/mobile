import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';

/// Service pour gérer les factures côté client
class InvoiceService {
  final ApiClient _apiClient;

  InvoiceService(this._apiClient);

  /// Télécharge et ouvre la facture d'une commande
  @Deprecated('Utilisez InvoiceDownloadService.downloadAndOpenOrderInvoice à la place')
  Future<void> downloadOrderInvoice(String orderId) async {
    throw Exception('Cette méthode est dépréciée. Utilisez InvoiceDownloadService.');
  }

  /// Télécharge et ouvre la facture d'une échéance
  @Deprecated('Utilisez InvoiceDownloadService.downloadAndOpenScheduleInvoice à la place')
  Future<void> downloadScheduleInvoice(String scheduleId) async {
    throw Exception('Cette méthode est dépréciée. Utilisez InvoiceDownloadService.');
  }
}

/// Provider pour le service de factures
final invoiceServiceProvider = Provider<InvoiceService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InvoiceService(apiClient);
});
