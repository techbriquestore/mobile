import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import '../di/service_locator.dart';

/// Service de gestion des notifications push Firebase Cloud Messaging
class PushNotificationService {
  FirebaseMessaging? _messaging;
  bool _initialized = false;

  /// Initialise Firebase et FCM
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

      // Demander la permission pour les notifications
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (kDebugMode) {
        print('Permission status: ${settings.authorizationStatus}');
      }

      // Obtenir le token FCM
      String? token = await _messaging!.getToken();
      if (token != null) {
        if (kDebugMode) {
          print('FCM Token: $token');
        }
        await _registerToken(token);
      }

      // Écouter les refresh de token
      _messaging!.onTokenRefresh.listen((newToken) {
        if (kDebugMode) {
          print('Token refreshed: $newToken');
        }
        _registerToken(newToken);
      });

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
    } catch (e) {
      if (kDebugMode) {
        print('Erreur initialisation FCM: $e');
      }
    }
  }

  /// Enregistre le token FCM auprès du backend
  Future<void> _registerToken(String token) async {
    try {
      // Utiliser l'ApiClient qui gère automatiquement l'authentification
      await ServiceLocator.apiClient.post(
        '/push-notifications/register',
        data: {
          'token': token,
          'platform': _getPlatform(),
        },
      );
      
      if (kDebugMode) {
        print('✅ Token FCM enregistré: ${token.substring(0, 20)}...');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur enregistrement token: $e');
        // L'utilisateur n'est peut-être pas connecté, on réessaiera plus tard
      }
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
