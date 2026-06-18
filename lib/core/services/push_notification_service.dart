import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import '../di/service_locator.dart';

/// Service de gestion des notifications push Firebase Cloud Messaging
class PushNotificationService {
  FirebaseMessaging? _messaging;
  bool _initialized = false;

  /// Initialise Firebase SEULEMENT (sans demander permissions ni token)
  /// À appeler au démarrage de l'app
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialiser Firebase avec les options de configuration
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      
      _messaging = FirebaseMessaging.instance;

      // Écouter les messages en premier plan
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Message reçu en premier plan: ${message.notification?.title}');
        }
      });

      // Écouter les messages quand l'app est en arrière-plan
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Message ouvert depuis arrière-plan: ${message.notification?.title}');
        }
      });

      _initialized = true;
      if (kDebugMode) {
        print('✅ Firebase initialisé (sans permissions)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur initialisation FCM: $e');
      }
    }
  }

  /// Demande les permissions et enregistre le token FCM
  /// À appeler APRÈS la connexion de l'utilisateur
  Future<void> requestPermissionAndRegisterToken() async {
    debugPrint('📱 [FCM] Début requestPermissionAndRegisterToken');
    
    try {
      _messaging ??= FirebaseMessaging.instance;
      debugPrint('📱 [FCM] FirebaseMessaging instance obtenue');

      // Demander la permission pour les notifications
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('📱 [FCM] Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('❌ [FCM] Permission refusée par l\'utilisateur');
        return;
      }

      // Obtenir le token FCM
      debugPrint('📱 [FCM] Récupération du token...');
      String? token = await _messaging!.getToken();
      
      if (token != null) {
        debugPrint('📱 [FCM] Token obtenu: ${token.substring(0, 30)}...');
        await _registerToken(token);
      } else {
        debugPrint('❌ [FCM] Token est null - Google Play Services peut-être absent ou pas à jour');
      }

      // Écouter les refresh de token
      _messaging!.onTokenRefresh.listen((newToken) {
        debugPrint('📱 [FCM] Token refreshed: ${newToken.substring(0, 30)}...');
        _registerToken(newToken);
      });
    } catch (e, stackTrace) {
      debugPrint('❌ [FCM] Erreur demande permission/token: $e');
      debugPrint('❌ [FCM] StackTrace: $stackTrace');
    }
  }

  /// Enregistre le token FCM auprès du backend
  Future<void> _registerToken(String token) async {
    debugPrint('📱 [FCM] Envoi du token au backend...');
    
    try {
      // Utiliser l'ApiClient qui gère automatiquement l'authentification
      final response = await ServiceLocator.apiClient.post(
        '/push-notifications/register',
        data: {
          'token': token,
          'platform': _getPlatform(),
        },
      );
      
      debugPrint('✅ [FCM] Token enregistré avec succès! Response: ${response.statusCode}');
    } catch (e, stackTrace) {
      debugPrint('❌ [FCM] Erreur enregistrement token: $e');
      debugPrint('❌ [FCM] StackTrace: $stackTrace');
    }
  }

  /// Supprime le token FCM (logout)
  Future<void> unregisterToken(String token) async {
    try {
      // TODO: Appeler l'API backend pour supprimer le token
      // DELETE /api/v1/push-notifications/unregister/:token
      
      if (kDebugMode) {
        print('Token à supprimer: $token');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur suppression token: $e');
      }
    }
  }

  /// Retourne la plateforme actuelle
  String _getPlatform() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'android';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ios';
    } else {
      return 'web';
    }
  }

  /// Obtient le token FCM actuel
  Future<String?> getToken() async {
    return await _messaging?.getToken();
  }

  /// Supprime le token FCM (pour logout)
  Future<void> deleteToken() async {
    await _messaging?.deleteToken();
  }
}
