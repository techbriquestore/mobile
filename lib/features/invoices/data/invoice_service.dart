import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';

/// Service pour gérer les factures côté client
class InvoiceService {
  final ApiClient _apiClient;

  InvoiceService(this._apiClient);

  /// Télécharge et ouvre la facture d'une commande
  Future<void> downloadOrderInvoice(String orderId) async {
    try {
      final token = _apiClient.accessToken;
      if (token == null) {
        throw Exception('Non connecté');
      }
      final downloadUrl = Uri.parse('${_apiClient.baseUrl}/invoices/order/$orderId/download')
          .replace(queryParameters: {'token': token});
      
      if (await canLaunchUrl(downloadUrl)) {
        await launchUrl(downloadUrl, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Impossible d\'ouvrir le lien de téléchargement');
      }
    } catch (e) {
      throw Exception('Erreur lors du téléchargement de la facture: $e');
    }
  }

  /// Télécharge et ouvre la facture d'une échéance
  Future<void> downloadScheduleInvoice(String scheduleId) async {
    try {
      final token = _apiClient.accessToken;
      if (token == null) {
        throw Exception('Non connecté');
      }
      final downloadUrl = Uri.parse('${_apiClient.baseUrl}/invoices/schedule/$scheduleId/download')
          .replace(queryParameters: {'token': token});
      
      if (await canLaunchUrl(downloadUrl)) {
        await launchUrl(downloadUrl, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Impossible d\'ouvrir le lien de téléchargement');
      }
    } catch (e) {
      throw Exception('Erreur lors du téléchargement de la facture: $e');
    }
  }
}

/// Provider pour le service de factures
final invoiceServiceProvider = Provider<InvoiceService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InvoiceService(apiClient);
});
