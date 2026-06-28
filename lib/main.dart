import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/di/service_locator.dart';
import 'core/services/push_notification_service.dart';
import 'features/notifications/data/providers/notification_providers.dart';

/// Container Riverpod global : permet d'invalider des providers depuis des
/// callbacks hors widget (ex: réception d'un push FCM).
final appContainer = ProviderContainer();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.init();

  // Brancher les hooks FCM (découplage core ↔ features)
  _wireFcmHandlers();

  // Initialiser les notifications push
  try {
    final pushNotificationService = PushNotificationService();
    await pushNotificationService.initialize();
    debugPrint('✅ Firebase initialisé avec succès');
  } catch (e, stackTrace) {
    debugPrint('❌ Erreur initialisation Firebase: $e');
    debugPrint('StackTrace: $stackTrace');
    // L'app continue même si Firebase échoue
  }

  runApp(UncontrolledProviderScope(
    container: appContainer,
    child: const BriquesStoreApp(),
  ));
}

/// Connecte les callbacks statiques du service FCM aux providers + router.
void _wireFcmHandlers() {
  // Push transactionnel reçu/ouvert → rafraîchir badge + liste (refetch API).
  PushNotificationService.onTransactionalReceived = () {
    appContainer.invalidate(unreadCountProvider);
    appContainer.invalidate(notificationsProvider);
  };

  // Tap sur une notification → deep-link vers l'écran concerné.
  PushNotificationService.onOpenRoute = (route) {
    try {
      appContainer.read(appRouterProvider).push(route);
    } catch (e) {
      debugPrint('Deep-link échoué ($route): $e');
    }
  };

  // Ouverture d'un broadcast → enregistrer la métrique (best-effort).
  PushNotificationService.onBroadcastOpened = (campaignId) {
    () async {
      try {
        await ServiceLocator.apiClient.post('/broadcasts/$campaignId/open');
      } catch (_) {
        // best-effort : on ignore les erreurs de tracking
      }
    }();
  };
}

class BriquesStoreApp extends ConsumerWidget {
  const BriquesStoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'BRIQUES.STORE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
