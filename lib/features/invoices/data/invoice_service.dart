import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';

/// Service pour gérer les factures côté client
class InvoiceService {
  final ApiClient _apiClient;

  InvoiceService(this._apiClient);

  /// Récupère l'URL de téléchargement d'une facture pour une commande
  Future<String> getOrderInvoiceUrl(String orderId) async {
    final response = await _apiClient.get('/invoices/order/$orderId');
    if (response.data != null && response.data['pdfUrl'] != null) {
      return response.data['pdfUrl'] as String;
    }
    throw Exception('Aucune facture disponible pour cette commande');
  }

  /// Récupère l'URL de téléchargement d'une facture pour une échéance de précommande
  Future<String> getScheduleInvoiceUrl(String scheduleId) async {
    final response = await _apiClient.get('/invoices/schedule/$scheduleId');
    if (response.data != null && response.data['pdfUrl'] != null) {
      return response.data['pdfUrl'] as String;
    }
    throw Exception('Aucune facture disponible pour cette échéance');
  }

  /// Ouvre l'URL de téléchargement dans le navigateur
  Future<void> openInvoiceInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Impossible d\'ouvrir le lien de téléchargement');
    }
  }

  /// Télécharge et ouvre la facture d'une commande
  Future<void> downloadOrderInvoice(String orderId) async {
    try {
      final downloadUrl = '${_apiClient.baseUrl}/invoices/order/$orderId/download';
      await openInvoiceInBrowser(downloadUrl);
    } catch (e) {
      throw Exception('Erreur lors du téléchargement de la facture: $e');
    }
  }

  /// Télécharge et ouvre la facture d'une échéance
  Future<void> downloadScheduleInvoice(String scheduleId) async {
    try {
      final downloadUrl = '${_apiClient.baseUrl}/invoices/schedule/$scheduleId/download';
      await openInvoiceInBrowser(downloadUrl);
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
