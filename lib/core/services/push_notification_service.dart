import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import '../di/service_locator.dart';

/// Service de gestion des notifications push Firebase Cloud Messaging.
///
/// Distingue deux familles de payloads (champ `data.category`) :
///  - TRANSACTIONAL : on NE fait PAS confiance au contenu du payload pour
///    l'affichage in-app → on déclenche un refetch via [onTransactionalReceived]
///    (le centre de notifications est la source de vérité). Au tap, deep-link.
///  - BROADCAST : marketing éphémère → au tap, on enregistre l'ouverture via
///    [onBroadcastOpened] et on ouvre un éventuel deep-link. Jamais stocké in-app.
class PushNotificationService {
  FirebaseMessaging? _messaging;
  bool _initialized = false;

  // ── Hooks branchés depuis main.dart (découplage core ↔ features) ──
  /// Appelé à l'arrivée d'un push transactionnel (app au premier plan) →
  /// rafraîchir le badge et la liste.
  static void Function()? onTransactionalReceived;

  /// Appelé pour ouvrir une route de deep-link (tap sur une notification).
  static void Function(String route)? onOpenRoute;

  /// Appelé quand un broadcast est ouvert (tap) → enregistrer la métrique.
  static void Function(String campaignId)? onBroadcastOpened;

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

      // Premier plan : message reçu pendant que l'app est ouverte.
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Tap sur la notification depuis l'arrière-plan.
      FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);

      // Démarrage à froid via le tap sur une notification.
      final initialMessage = await _messaging!.getInitialMessage();
      if (initialMessage != null) {
        _handleOpenedMessage(initialMessage);
      }

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

  /// Message reçu au premier plan : on refetch pour les transactionnelles.
  void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    final category = data['category'] ?? '';
    if (kDebugMode) {
      print('FCM premier plan [$category]: ${message.notification?.title}');
    }
    if (category != 'BROADCAST') {
      // TRANSACTIONAL : ne jamais afficher depuis le payload → refetch API.
      onTransactionalReceived?.call();
    }
    // Les broadcasts au premier plan : rien (éphémère, pas de centre in-app).
  }

  /// Tap sur la notification (arrière-plan ou démarrage à froid).
  void _handleOpenedMessage(RemoteMessage message) {
    final data = message.data;
    final category = data['category'] ?? '';
    if (kDebugMode) {
      print('FCM ouvert [$category]: ${message.notification?.title}');
    }

    if (category == 'BROADCAST') {
      final campaignId = data['campaignId'];
      if (campaignId is String && campaignId.isNotEmpty) {
        onBroadcastOpened?.call(campaignId);
      }
    } else {
      // Transactionnel : rafraîchir l'état puis router.
      onTransactionalReceived?.call();
    }

    final route = data['deepLink'];
    if (route is String && route.isNotEmpty) {
      onOpenRoute?.call(route);
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

  /// Supprime le token FCM côté backend ET côté Firebase (à la déconnexion).
  /// Si aucun token n'est fourni, récupère le token courant.
  Future<void> unregisterToken([String? token]) async {
    try {
      final fcmToken = token ?? await _messaging?.getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await ServiceLocator.apiClient.delete(
          '/push-notifications/unregister/$fcmToken',
        );
        debugPrint('✅ [FCM] Token supprimé du backend');
      }
      // Invalider le token côté appareil pour ne plus rien recevoir.
      await _messaging?.deleteToken();
    } catch (e) {
      debugPrint('❌ [FCM] Erreur suppression token: $e');
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
