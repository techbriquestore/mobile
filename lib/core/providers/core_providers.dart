import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/service_locator.dart';
import '../network/api_client.dart';
import '../network/connectivity_service.dart';

/// Provider pour le service de connectivité.
///
/// Note : Utilise actuellement ServiceLocator pour la rétrocompatibilité.
/// À terme, ce provider devrait créer directement l'instance.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  // TODO: Migrer vers une création directe quand ServiceLocator sera supprimé
  // return ConnectivityService();
  return ServiceLocator.connectivityService;
});

/// Provider pour le client API.
///
/// Note : Utilise actuellement ServiceLocator pour la rétrocompatibilité.
/// À terme, ce provider devrait créer directement l'instance avec ses dépendances.
final apiClientProvider = Provider<ApiClient>((ref) {
  // TODO: Migrer vers une création directe quand ServiceLocator sera supprimé
  // final connectivity = ref.watch(connectivityServiceProvider);
  // return ApiClient(connectivityService: connectivity);
  return ServiceLocator.apiClient;
});

/// Stream de l'état de connectivité.
///
/// Émet `true` quand l'appareil est connecté, `false` sinon.
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).onConnectivityChanged;
});

/// Provider pour vérifier si l'appareil est actuellement connecté.
final isConnectedProvider = FutureProvider<bool>((ref) async {
  return ref.watch(connectivityServiceProvider).isConnected;
});
