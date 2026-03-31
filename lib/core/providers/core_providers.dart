import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/service_locator.dart';
import '../network/api_client.dart';
import '../network/connectivity_service.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ServiceLocator.connectivityService;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ServiceLocator.apiClient;
});
