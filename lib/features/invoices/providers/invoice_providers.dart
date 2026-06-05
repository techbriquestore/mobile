import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../data/invoice_download_service.dart';

/// Provider pour le service de téléchargement de factures
final invoiceDownloadServiceProvider = Provider<InvoiceDownloadService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InvoiceDownloadService(apiClient.dio, apiClient.baseUrl);
});
