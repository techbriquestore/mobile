import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/providers/core_providers.dart';

class UserPreferences {
  final bool preferSms;
  final bool preferWhatsapp;
  final bool preferEmail;
  final bool preferPush;
  final bool notifOrders;
  final bool notifPromotions;
  final bool darkMode;
  final String language;

  const UserPreferences({
    this.preferSms = true,
    this.preferWhatsapp = true,
    this.preferEmail = false,
    this.preferPush = true,
    this.notifOrders = true,
    this.notifPromotions = true,
    this.darkMode = false,
    this.language = 'fr',
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      preferSms: json['preferSms'] as bool? ?? true,
      preferWhatsapp: json['preferWhatsapp'] as bool? ?? true,
      preferEmail: json['preferEmail'] as bool? ?? false,
      preferPush: json['preferPush'] as bool? ?? true,
      notifOrders: json['notifOrders'] as bool? ?? true,
      notifPromotions: json['notifPromotions'] as bool? ?? true,
      darkMode: json['darkMode'] as bool? ?? false,
      language: json['language'] as String? ?? 'fr',
    );
  }

  UserPreferences copyWith({
    bool? preferSms,
    bool? preferWhatsapp,
    bool? preferEmail,
    bool? preferPush,
    bool? notifOrders,
    bool? notifPromotions,
    bool? darkMode,
    String? language,
  }) {
    return UserPreferences(
      preferSms: preferSms ?? this.preferSms,
      preferWhatsapp: preferWhatsapp ?? this.preferWhatsapp,
      preferEmail: preferEmail ?? this.preferEmail,
      preferPush: preferPush ?? this.preferPush,
      notifOrders: notifOrders ?? this.notifOrders,
      notifPromotions: notifPromotions ?? this.notifPromotions,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
    );
  }
}

class PreferencesService {
  final ApiClient _apiClient;
  PreferencesService(this._apiClient);

  Future<UserPreferences> getPreferences() async {
    final response = await _apiClient.get(ApiConstants.userPreferences);
    return UserPreferences.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserPreferences> updatePreferences(Map<String, dynamic> data) async {
    final response = await _apiClient.patch(ApiConstants.userPreferences, data: data);
    return UserPreferences.fromJson(response.data as Map<String, dynamic>);
  }
}

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService(ref.watch(apiClientProvider));
});

final preferencesProvider = AsyncNotifierProvider<PreferencesNotifier, UserPreferences>(PreferencesNotifier.new);

class PreferencesNotifier extends AsyncNotifier<UserPreferences> {
  @override
  Future<UserPreferences> build() async {
    try {
      final service = ref.read(preferencesServiceProvider);
      return await service.getPreferences();
    } catch (_) {
      return const UserPreferences();
    }
  }

  Future<void> updatePreference(String key, dynamic value) async {
    final service = ref.read(preferencesServiceProvider);
    try {
      final updated = await service.updatePreferences({key: value});
      state = AsyncData(updated);
    } catch (e) {
      // Revert on error
      ref.invalidateSelf();
    }
  }
}
