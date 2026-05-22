import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/phone_input_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/complete_profile_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/catalog/presentation/screens/catalog_screen.dart';
import '../../features/catalog/presentation/screens/product_detail_screen.dart';
import '../../features/catalog/presentation/screens/category_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/preorders/presentation/screens/preorder_detail_screen.dart';
import '../../features/preorders/presentation/screens/create_preorder_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/projects_screen.dart';
import '../../features/profile/presentation/screens/project_detail_screen.dart';
import '../../features/profile/presentation/screens/payment_history_screen.dart';
import '../../features/simulator/presentation/screens/simulator_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/support/presentation/screens/support_screen.dart';
import '../../features/support/presentation/screens/faq_screen.dart';
import '../../features/support/presentation/screens/claim_screen.dart';
import '../../features/support/presentation/screens/legal_screen.dart';
import '../../features/catalog/presentation/screens/search_screen.dart';
import '../../features/catalog/presentation/screens/favorites_screen.dart';
import '../../features/catalog/presentation/screens/promotions_screen.dart';
import '../../features/checkout/presentation/screens/order_success_screen.dart';
import '../../features/checkout/presentation/screens/payment_screen.dart';
import '../../features/orders/presentation/screens/order_tracking_screen.dart';
import '../../features/orders/presentation/screens/order_payments_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../shared/layouts/main_shell.dart';
import '../../shared/widgets/splash_screen.dart';

class AuthNotifierForRouter extends ChangeNotifier {
  AuthNotifierForRouter(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}

final _authNotifierForRouterProvider = Provider<AuthNotifierForRouter>((ref) {
  return AuthNotifierForRouter(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  // Routes d'authentification (accessibles sans être connecté)
  const authRoutes = [
    '/onboarding',
    '/splash',
    '/auth/phone',
    '/auth/verify-otp',
  ];

  // Routes accessibles même avec profil incomplet
  const profileIncompleteRoutes = [
    '/auth/complete-profile',
    '/auth/phone',
    '/auth/verify-otp',
    '/splash',
  ];

  final authNotifier = ref.watch(_authNotifierForRouterProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isProfileComplete = authState.isProfileComplete;
      final isAuthRoute = authRoutes.contains(state.matchedLocation);
      final isProfileIncompleteRoute =
          profileIncompleteRoutes.contains(state.matchedLocation);
      final isInitializing = authState.status == AuthStatus.initial;
      final isSplash = state.matchedLocation == '/splash';
      final isCompleteProfileRoute =
          state.matchedLocation == '/auth/complete-profile';
      print('[ROUTER] redirect: route=${state.matchedLocation}, status=${authState.status}, isAuth=$isAuthenticated, profileComplete=$isProfileComplete');

      // Afficher le splash pendant l'initialisation
      if (isInitializing && !isSplash) {
        return '/splash';
      }

      // Après initialisation, rediriger depuis le splash
      if (!isInitializing && isSplash) {
        if (!isAuthenticated) {
          return '/auth/phone'; // Nouveau parcours OTP
        }
        if (!isProfileComplete) {
          return '/auth/complete-profile';
        }
        return '/home';
      }

      // Si non authentifié et tentative d'accès à une route protégée
      if (!isAuthenticated && !isAuthRoute) {
        return '/auth/phone';
      }

      // Si authentifié mais profil incomplet
      if (isAuthenticated && !isProfileComplete && !isProfileIncompleteRoute) {
        return '/auth/complete-profile';
      }

      // Si authentifié avec profil complet et tentative d'accès à une route auth
      if (isAuthenticated &&
          isProfileComplete &&
          (isAuthRoute || isCompleteProfileRoute) &&
          !isSplash) {
        return '/home';
      }

      return null; // Pas de redirection
    },
    routes: [
      // === Splash Screen ===
      GoRoute(path: '/splash', name: 'splash', builder: (_, __) => const SplashScreen()),

      // === Onboarding ===
      GoRoute(path: '/onboarding', name: 'onboarding', builder: (_, __) => const OnboardingScreen()),

      // === Auth OTP ===
      GoRoute(
        path: '/auth/phone',
        name: 'phoneInput',
        builder: (_, __) => const PhoneInputScreen(),
      ),
      GoRoute(
        path: '/auth/verify-otp',
        name: 'verifyOtp',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OtpVerificationScreen(
            phone: extra['phone'] as String? ?? '',
            purpose: extra['purpose'] as String?,
            debugCode: extra['debugCode'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/auth/complete-profile',
        name: 'completeProfile',
        builder: (_, __) => const CompleteProfileScreen(),
      ),

      // === Main App (avec bottom nav) ===
      ShellRoute(
        builder: (_, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', name: 'home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/catalog', name: 'catalog', builder: (_, __) => const CatalogScreen(),
            routes: [
              GoRoute(path: 'category/:categoryId', name: 'category', builder: (_, state) => CategoryScreen(categoryId: state.pathParameters['categoryId']!)),
              GoRoute(path: 'product/:productId', name: 'productDetail', builder: (_, state) => ProductDetailScreen(productId: state.pathParameters['productId']!)),
            ],
          ),
          GoRoute(path: '/simulator', name: 'simulator', builder: (_, __) => const SimulatorScreen()),
          GoRoute(path: '/orders', name: 'orders', builder: (_, state) {
            final tab = state.uri.queryParameters['tab'];
            final initialTab = (tab == 'preorders' || tab == '1') ? 1 : 0;
            return OrdersScreen(initialTab: initialTab);
          }),
          GoRoute(path: '/profile', name: 'profile', builder: (_, __) => const ProfileScreen(),
            routes: [
              GoRoute(path: 'edit', name: 'editProfile', builder: (_, __) => const EditProfileScreen()),
              GoRoute(path: 'addresses', name: 'addresses', builder: (_, __) => const ProjectsScreen()),
              GoRoute(path: 'payments', name: 'paymentHistory', builder: (_, __) => const PaymentHistoryScreen()),
              GoRoute(path: 'settings', name: 'settings', builder: (_, __) => const SettingsScreen()),
              GoRoute(path: 'change-password', name: 'changePassword', builder: (_, __) => const ChangePasswordScreen()),
            ],
          ),
        ],
      ),

      // === Hors shell ===
      GoRoute(path: '/orders/:orderId', name: 'orderDetail', builder: (_, state) => OrderDetailScreen(orderId: state.pathParameters['orderId']!)),
      GoRoute(path: '/search', name: 'search', builder: (_, __) => const SearchScreen()),
      GoRoute(path: '/favorites', name: 'favorites', builder: (_, __) => const FavoritesScreen()),
      GoRoute(path: '/promotions', name: 'promotions', builder: (_, __) => const PromotionsScreen()),
      GoRoute(path: '/cart', name: 'cart', builder: (_, __) => const CartScreen()),
      GoRoute(path: '/checkout', name: 'checkout', builder: (_, __) => const CheckoutScreen()),
      GoRoute(path: '/order-success/:orderId', name: 'orderSuccess', builder: (_, state) => OrderSuccessScreen(orderId: state.pathParameters['orderId']!)),
      GoRoute(path: '/payment', name: 'payment', builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return PaymentScreen(
          amount: (extra['amount'] as num?)?.toDouble() ?? 0,
          orderId: extra['orderId'] as String? ?? '',
          isFirstPayment: extra['isFirstPayment'] as bool? ?? false,
          totalInstallments: extra['totalInstallments'] as int? ?? 1,
          scheduleId: extra['scheduleId'] as String?,
          preorderId: extra['preorderId'] as String?,
          scheduleIndex: extra['scheduleIndex'] as int?,
        );
      }),
      GoRoute(path: '/order-payments/:orderId', name: 'orderPayments', builder: (_, state) => OrderPaymentsScreen(orderId: state.pathParameters['orderId']!)),
      // /preorders redirige vers l'onglet "Mes Achats > Pré-commandes" (unification navigation)
      GoRoute(path: '/preorders', redirect: (_, __) => '/orders?tab=preorders'),
      GoRoute(path: '/preorders/create', name: 'createPreorder', builder: (_, __) => const CreatePreorderScreen()),
      GoRoute(path: '/preorders/:preorderId', name: 'preorderDetail', builder: (_, state) => PreorderDetailScreen(preorderId: state.pathParameters['preorderId']!)),
      GoRoute(path: '/order-tracking/:orderId', name: 'orderTracking', builder: (_, state) => OrderTrackingScreen(orderId: state.pathParameters['orderId']!)),
      GoRoute(path: '/notifications', name: 'notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/support', name: 'support', builder: (_, __) => const SupportScreen()),
      GoRoute(path: '/faq', name: 'faq', builder: (_, __) => const FaqScreen()),
      GoRoute(path: '/legal', name: 'legal', builder: (_, __) => const LegalScreen()),
      GoRoute(path: '/claim/:orderId', name: 'claim', builder: (_, state) => ClaimScreen(orderId: state.pathParameters['orderId']!)),
      GoRoute(path: '/projects', name: 'projects', builder: (_, __) => const ProjectsScreen()),
      GoRoute(path: '/projects/:projectId', name: 'projectDetail', builder: (_, state) => ProjectDetailScreen(projectId: state.pathParameters['projectId']!)),
    ],
  );
});
