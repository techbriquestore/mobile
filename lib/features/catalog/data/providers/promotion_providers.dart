import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/providers/core_providers.dart';
import '../models/promotion.dart';

// Promotions Service
class PromotionsService {
  final dynamic _apiClient;

  PromotionsService(this._apiClient);

  Future<List<Promotion>> getActivePromotions() async {
    final response = await _apiClient.get('${ApiConstants.baseUrl}/promotions/active');
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => Promotion.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Promotion> validateCode(String code) async {
    final response = await _apiClient.get('${ApiConstants.baseUrl}/promotions/code/$code');
    return Promotion.fromJson(response.data as Map<String, dynamic>);
  }
}

// Providers
final promotionsServiceProvider = Provider<PromotionsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PromotionsService(apiClient);
});

final activePromotionsProvider = FutureProvider<List<Promotion>>((ref) async {
  final service = ref.watch(promotionsServiceProvider);
  return service.getActivePromotions();
});

// Validate promo code provider
final promoCodeValidatorProvider = FutureProvider.family<Promotion, String>((ref, code) async {
  final service = ref.watch(promotionsServiceProvider);
  return service.validateCode(code);
});
