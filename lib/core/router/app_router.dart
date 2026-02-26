import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
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
import '../../shared/layouts/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/catalog',
    debugLogDiagnostics: true,
    routes: [
      // === Auth (sans shell) ===
      GoRoute(path: '/login', name: 'login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', name: 'register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/otp', name: 'otp', builder: (_, __) => const OtpScreen()),
      GoRoute(path: '/forgot-password', name: 'forgotPassword', builder: (_, __) => const ForgotPasswordScreen()),

      // === Main App (avec bottom nav) ===
      ShellRoute(
        builder: (_, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/catalog', name: 'catalog', builder: (_, __) => const CatalogScreen(),
            routes: [
              GoRoute(path: 'category/:categoryId', name: 'category', builder: (_, state) => CategoryScreen(categoryId: state.pathParameters['categoryId']!)),
              GoRoute(path: 'product/:productId', name: 'productDetail', builder: (_, state) => ProductDetailScreen(productId: state.pathParameters['productId']!)),
            ],
          ),
          GoRoute(path: '/simulator', name: 'simulator', builder: (_, __) => const SimulatorScreen()),
          GoRoute(path: '/cart', name: 'cart', builder: (_, __) => const CartScreen()),
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
            ],
          ),
        ],
      ),

      // === Hors shell ===
      GoRoute(path: '/checkout', name: 'checkout', builder: (_, __) => const CheckoutScreen()),
      GoRoute(path: '/preorders', name: 'preorders', builder: (_, __) => const PreordersScreen(),
        routes: [
          GoRoute(path: 'create', name: 'createPreorder', builder: (_, __) => const CreatePreorderScreen()),
          GoRoute(path: ':preorderId', name: 'preorderDetail', builder: (_, state) => PreorderDetailScreen(preorderId: state.pathParameters['preorderId']!)),
        ],
      ),
      GoRoute(path: '/notifications', name: 'notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/support', name: 'support', builder: (_, __) => const SupportScreen()),
      GoRoute(path: '/faq', name: 'faq', builder: (_, __) => const FaqScreen()),
      GoRoute(path: '/claim/:orderId', name: 'claim', builder: (_, state) => ClaimScreen(orderId: state.pathParameters['orderId']!)),
    ],
  );
});
