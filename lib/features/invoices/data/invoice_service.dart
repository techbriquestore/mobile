import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/core_providers.dart';

/// Service pour gérer les factures côté client
class InvoiceService {
  final ApiClient _apiClient;

  InvoiceService(this._apiClient);

  /// Télécharge la facture d'une commande et retourne les bytes du PDF
  Future<Uint8List> downloadOrderInvoice(String orderId) async {
    try {
      final response = await _apiClient.dio.get<List<int>>(
        '/invoices/order/$orderId/download',
        options: Options(responseType: ResponseType.bytes),
      );
      
      if (response.data == null || response.data!.isEmpty) {
        throw Exception('Aucune donnée reçue');
      }
      
      return Uint8List.fromList(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Facture non trouvée');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Session expirée, veuillez vous reconnecter');
      }
      throw Exception('Erreur lors du téléchargement: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors du téléchargement de la facture: $e');
    }
  }

  /// Télécharge la facture d'une échéance et retourne les bytes du PDF
  Future<Uint8List> downloadScheduleInvoice(String scheduleId) async {
    try {
      final response = await _apiClient.dio.get<List<int>>(
        '/invoices/schedule/$scheduleId/download',
        options: Options(responseType: ResponseType.bytes),
      );
      
      if (response.data == null || response.data!.isEmpty) {
        throw Exception('Aucune donnée reçue');
      }
      
      return Uint8List.fromList(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Facture non trouvée');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Session expirée, veuillez vous reconnecter');
      }
      throw Exception('Erreur lors du téléchargement: ${e.message}');
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
