import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/catalog/presentation/screens/catalog_screen.dart';
import '../../features/catalog/presentation/screens/product_detail_screen.dart';
import '../../features/catalog/presentation/screens/category_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/preorders/presentation/screens/preorders_screen.dart';
import '../../features/preorders/presentation/screens/preorder_detail_screen.dart';
import '../../features/preorders/presentation/screens/create_preorder_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/addresses_screen.dart';
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

final appRouterProvider = Provider<GoRouter>((ref) {
  // Auth routes that don't require authentication
  const authRoutes = ['/login', '/register', '/otp', '/forgot-password', '/onboarding', '/splash'];
  
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isAuthRoute = authRoutes.contains(state.matchedLocation);
      final isInitializing = authState.status == AuthStatus.initial;
      final isSplash = state.matchedLocation == '/splash';
      
      // Show splash while initializing
      if (isInitializing && !isSplash) {
        return '/splash';
      }
      
      // After initialization, redirect from splash
      if (!isInitializing && isSplash) {
        return isAuthenticated ? '/home' : '/login';
      }
      
      // If not authenticated and trying to access protected route, redirect to login
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }
      
      // If authenticated and trying to access auth route, redirect to home
      if (isAuthenticated && isAuthRoute && !isSplash) {
        return '/home';
      }
      
      return null; // No redirect
    },
    routes: [
      // === Splash Screen ===
      GoRoute(path: '/splash', name: 'splash', builder: (_, __) => const SplashScreen()),

      // === Onboarding ===
      GoRoute(path: '/onboarding', name: 'onboarding', builder: (_, __) => const OnboardingScreen()),

      // === Auth (sans shell) ===
      GoRoute(path: '/login', name: 'login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', name: 'register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/otp', name: 'otp', builder: (_, __) => const OtpScreen()),
      GoRoute(path: '/forgot-password', name: 'forgotPassword', builder: (_, __) => const ForgotPasswordScreen()),

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
          GoRoute(path: '/orders', name: 'orders', builder: (_, __) => const OrdersScreen(),
            routes: [
              GoRoute(path: ':orderId', name: 'orderDetail', builder: (_, state) => OrderDetailScreen(orderId: state.pathParameters['orderId']!)),
            ],
          ),
          GoRoute(path: '/profile', name: 'profile', builder: (_, __) => const ProfileScreen(),
            routes: [
              GoRoute(path: 'edit', name: 'editProfile', builder: (_, __) => const EditProfileScreen()),
              GoRoute(path: 'addresses', name: 'addresses', builder: (_, __) => const AddressesScreen()),
              GoRoute(path: 'payments', name: 'paymentHistory', builder: (_, __) => const PaymentHistoryScreen()),
              GoRoute(path: 'settings', name: 'settings', builder: (_, __) => const SettingsScreen()),
              GoRoute(path: 'change-password', name: 'changePassword', builder: (_, __) => const ChangePasswordScreen()),
            ],
          ),
        ],
      ),

      // === Hors shell ===
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
        );
      }),
      GoRoute(path: '/order-payments/:orderId', name: 'orderPayments', builder: (_, state) => OrderPaymentsScreen(orderId: state.pathParameters['orderId']!)),
      GoRoute(path: '/preorders', name: 'preorders', builder: (_, __) => const PreordersScreen(),
        routes: [
          GoRoute(path: 'create', name: 'createPreorder', builder: (_, __) => const CreatePreorderScreen()),
          GoRoute(path: ':preorderId', name: 'preorderDetail', builder: (_, state) => PreorderDetailScreen(preorderId: state.pathParameters['preorderId']!)),
        ],
      ),
      GoRoute(path: '/order-tracking/:orderId', name: 'orderTracking', builder: (_, state) => OrderTrackingScreen(orderId: state.pathParameters['orderId']!)),
      GoRoute(path: '/notifications', name: 'notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/support', name: 'support', builder: (_, __) => const SupportScreen()),
      GoRoute(path: '/faq', name: 'faq', builder: (_, __) => const FaqScreen()),
      GoRoute(path: '/legal', name: 'legal', builder: (_, __) => const LegalScreen()),
      GoRoute(path: '/claim/:orderId', name: 'claim', builder: (_, state) => ClaimScreen(orderId: state.pathParameters['orderId']!)),
    ],
  );
});
