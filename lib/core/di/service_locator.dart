import '../network/api_client.dart';
import '../network/connectivity_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static late final ApiClient apiClient;
  static late final ConnectivityService connectivityService;

  static Future<void> init() async {
    connectivityService = ConnectivityService();
    apiClient = ApiClient(connectivityService: connectivityService);
  }
}
