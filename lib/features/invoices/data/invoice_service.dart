import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
      debugPrint('📄 Téléchargement facture commande: $orderId');
      
      final response = await _apiClient.dio.get(
        '/invoices/order/$orderId/download',
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      
      debugPrint('📄 Réponse reçue: ${response.statusCode}, type: ${response.data.runtimeType}');
      
      if (response.data == null) {
        throw Exception('Aucune donnée reçue');
      }
      
      // Convertir la réponse en bytes
      final bytes = response.data is List<int> 
          ? Uint8List.fromList(response.data as List<int>)
          : Uint8List.fromList(List<int>.from(response.data));
      
      if (bytes.isEmpty) {
        throw Exception('PDF vide reçu');
      }
      
      debugPrint('📄 PDF reçu: ${bytes.length} bytes');
      return bytes;
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.type}, ${e.message}');
      debugPrint('❌ Response: ${e.response?.statusCode} - ${e.response?.data}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('Facture non trouvée');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Session expirée, veuillez vous reconnecter');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Erreur serveur lors de la génération du PDF');
      }
      throw Exception('Erreur réseau: ${e.message ?? e.type.name}');
    } catch (e) {
      debugPrint('❌ Exception: $e');
      throw Exception('Erreur: $e');
    }
  }

  /// Télécharge la facture d'une échéance et retourne les bytes du PDF
  Future<Uint8List> downloadScheduleInvoice(String scheduleId) async {
    try {
      debugPrint('📄 Téléchargement facture échéance: $scheduleId');
      
      final response = await _apiClient.dio.get(
        '/invoices/schedule/$scheduleId/download',
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      
      debugPrint('📄 Réponse reçue: ${response.statusCode}, type: ${response.data.runtimeType}');
      
      if (response.data == null) {
        throw Exception('Aucune donnée reçue');
      }
      
      // Convertir la réponse en bytes
      final bytes = response.data is List<int> 
          ? Uint8List.fromList(response.data as List<int>)
          : Uint8List.fromList(List<int>.from(response.data));
      
      if (bytes.isEmpty) {
        throw Exception('PDF vide reçu');
      }
      
      debugPrint('📄 PDF reçu: ${bytes.length} bytes');
      return bytes;
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.type}, ${e.message}');
      debugPrint('❌ Response: ${e.response?.statusCode} - ${e.response?.data}');
      
      if (e.response?.statusCode == 404) {
        throw Exception('Facture non trouvée');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Session expirée, veuillez vous reconnecter');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Erreur serveur lors de la génération du PDF');
      }
      throw Exception('Erreur réseau: ${e.message ?? e.type.name}');
    } catch (e) {
      debugPrint('❌ Exception: $e');
      throw Exception('Erreur: $e');
    }
  }
}

/// Provider pour le service de factures
final invoiceServiceProvider = Provider<InvoiceService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InvoiceService(apiClient);
});
