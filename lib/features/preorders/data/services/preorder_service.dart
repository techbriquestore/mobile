import '../../../../core/network/api_client.dart';
import '../../domain/models/preorder.dart';

class PreorderService {
  final ApiClient _client;

  PreorderService(this._client);

  /// Créer une pré-commande avec paiement échelonné
  Future<Preorder> createPreorder({
    required List<Map<String, dynamic>> items,
    required int durationMonths,
    String? deliveryAddressId,
    String deliveryMode = 'STANDARD',
  }) async {
    final response = await _client.post('/preorders', data: {
      'items': items,
      'durationMonths': durationMonths,
      if (deliveryAddressId != null) 'deliveryAddressId': deliveryAddressId,
      'deliveryMode': deliveryMode,
    });
    return Preorder.fromJson(response.data as Map<String, dynamic>);
  }

  /// Lister mes pré-commandes
  Future<PreordersPage> getPreorders({
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

    final response = await _client.get('/preorders', queryParams: params);
    return PreordersPage.fromJson(response.data as Map<String, dynamic>);
  }

  /// Détail d'une pré-commande
  Future<PreorderDetail> getPreorderById(String id) async {
    final response = await _client.get('/preorders/$id');
    return PreorderDetail.fromJson(response.data as Map<String, dynamic>);
  }

  /// Simuler les options d'échelonnement
  Future<List<Map<String, dynamic>>> getInstallmentOptions(int totalAmount) async {
    final response = await _client.get(
      '/preorders/installment-options',
      queryParams: {'totalAmount': totalAmount.toString()},
    );
    return List<Map<String, dynamic>>.from(response.data as List<dynamic>);
  }

  /// Payer une échéance (client)
  Future<PreorderSchedule> paySchedule(String scheduleId) async {
    final response = await _client.post('/preorders/schedules/$scheduleId/pay');
    return PreorderSchedule.fromJson(response.data as Map<String, dynamic>);
  }
}
