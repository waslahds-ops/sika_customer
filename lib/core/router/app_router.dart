import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sika_customer/core/router/route_paths.dart';
import 'package:sika_customer/core/widgets/route_gate.dart';
import 'package:sika_customer/features/profile/presentation/screens/voucher_screen.dart';
import 'package:sika_customer/features/profile/presentation/screens/wallet_screen.dart';
import 'package:sika_customer/features/wallet/presentation/screens/transactions_screen.dart';
import 'package:sika_customer/l10n/app_localizations.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/verification_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/set_password_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/profile/presentation/screens/edit_username_screen.dart';
import '../../features/profile/presentation/screens/edit_email_screen.dart';
import '../../features/profile/presentation/screens/edit_phone_screen.dart';
import '../../features/profile/presentation/screens/about_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/main_navigation_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/orders/presentation/screens/my_orders_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/track_order_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/addresses_screen.dart';
import '../../features/profile/presentation/screens/payment_methods_screen.dart';
import '../../features/profile/presentation/screens/password_management_screen.dart';
import '../../features/profile/presentation/screens/verify_for_password_change_screen.dart';
import '../../features/profile/presentation/screens/confirm_password_change_screen.dart';
import '../../features/profile/presentation/screens/favorites_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/notifications_screen.dart';
import '../../features/stores/presentation/screens/stores_screen.dart';
import '../../features/stores/presentation/screens/store_details_screen.dart';
import '../../features/stores/domain/entities/store_entities.dart';
import '../../features/home/presentation/screens/category_stores_screen.dart';
import '../../features/stores/presentation/screens/product_details_screen.dart';
import '../../features/orders/domain/entities/order_entities.dart';
import '../../features/booking/presentation/view/booking_screen.dart';
import '../../features/orders/presentation/screens/order_confirmation_screen.dart';
import '../../features/orders/presentation/screens/order_tracking_screen.dart';
import '../../injection_container.dart';
import '../../features/support/presentation/screens/support_screen.dart';

// Auth notifier for GoRouter
class AuthNotifierForRouter extends ChangeNotifier {
  final Ref ref;

  AuthNotifierForRouter(this.ref) {
    ref.listen<dynamic>(authProvider, (previous, next) {
      notifyListeners();
    });
  }
}

// GoRouter configuration
final goRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = AuthNotifierForRouter(ref);

  return GoRouter(
    initialLocation: splashRoute,
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToVerification = state.matchedLocation == '/verification';
      final isGoingToForgotPassword =
          state.matchedLocation == '/forgot-password';
      final isGoingToResetPassword = state.matchedLocation == '/reset-password';
      final isGoingToSetPassword = state.matchedLocation == '/set-password';
      final isGoingToSplashLoader = state.matchedLocation == '/';
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';
      final isGoingToMain = state.matchedLocation == mainRoute;
      final isGoingToMainNoTransition =
          state.matchedLocation == mainNoTransitionRoute;

      // Allow splash screens and onboarding always
      if (isGoingToSplashLoader || isGoingToOnboarding) {
        return null;
      }

      // Allow verification, password reset, and set password screens
      if (isGoingToVerification ||
          isGoingToForgotPassword ||
          isGoingToResetPassword ||
          isGoingToSetPassword) {
        return null;
      }

      // Allow browsing (main screen) without authentication
      if (isGoingToMain || isGoingToMainNoTransition) return null;

      // Allow auth screens
      if (isGoingToLogin) return null;

      // If authenticated and going to login, redirect to main
      if (isAuthenticated && isGoingToLogin) {
        return '/main';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: splashRoute,
        name: 'splash',
        builder: (context, state) => const RootGate(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/verification',
        name: 'verification',
        builder: (context, state) {
          // Support both query parameters and extra data
          final extra = state.extra as Map<String, dynamic>?;
          final phoneNumber =
              extra?['phoneNumber'] ??
              state.uri.queryParameters['phoneNumber'] ??
              '';
          final email = extra?['email'] ?? state.uri.queryParameters['email'];
          final isPasswordReset =
              extra?['isPasswordReset'] ??
              (state.uri.queryParameters['isPasswordReset'] == 'true') ??
              false;
          return VerificationScreen(
            phoneNumber: phoneNumber,
            email: email,
            isPasswordReset: isPasswordReset as bool,
          );
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final phoneNumber = state.uri.queryParameters['phoneNumber'] ?? '';
          final email = state.uri.queryParameters['email'];
          return ResetPasswordScreen(phoneNumber: phoneNumber, email: email);
        },
      ),
      GoRoute(
        path: '/set-password',
        name: 'set-password',
        builder: (context, state) => const SetPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: mainRoute,
        name: 'main',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: mainNoTransitionRoute,
        name: 'main-no-transition',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const MainNavigationScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/stores',
        name: 'stores',
        builder: (context, state) => const StoresScreen(),
      ),
      GoRoute(
        path: '/store-details/:storeId',
        name: 'store-details',
        builder: (context, state) {
          final store = state.extra as StoreEntity?;

          if (store != null) {
            return StoreDetailsScreen(store: store);
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.storeNotFound),
            ),
            body: Center(
              child: Text(
                AppLocalizations.of(context)!.storeInformationNotAvailable,
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/product/:productId',
        name: 'product',
        builder: (context, state) {
          final productId = int.tryParse(state.pathParameters['productId'] ?? '');
          final product = state.extra as ProductEntity?;

          if (productId == null) {
            return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.productNotFound),
              ),
              body: Center(
                child: Text(
                  AppLocalizations.of(context)!.productInformationNotAvailable,
                ),
              ),
            );
          }

          return ProductDetailsLoader(
            productId: productId,
            initialProduct: product,
          );
        },
      ),

      GoRoute(
        path: '/category-stores/:categoryId',
        name: 'category-stores',
        builder: (context, state) {
          final category = state.extra as CategoryEntity?;

          if (category != null) {
            return CategoryStoresScreen(category: category);
          }
          //? TODO: Localizations

          // Fallback
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.categoryNotFound),
            ),
            body: Center(
              child: Text(
                AppLocalizations.of(context)!.categoryInformationNotAvailable,
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/my-orders',
        name: 'my-orders',
        builder: (context, state) => const MyOrdersScreen(),
      ),
      GoRoute(
        path: '/booking',
        name: 'booking',
        builder: (context, state) => const BookingScreen(),
      ),
      GoRoute(
        path: '/order-confirmation',
        name: 'order-confirmation',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final orderId = extra?['orderId'] as int?;
          return OrderConfirmationScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/order-detail/:orderId',
        name: 'order-detail',
        builder: (context, state) {
          final orderId =
              int.tryParse(state.pathParameters['orderId'] ?? '0') ?? 0;
          final orderData = state.extra as OrderEntity?;
          return OrderDetailScreen(orderId: orderId, orderData: orderData);
        },
      ),
      GoRoute(
        path: '/track-order/:orderId',
        name: 'track-order',
        builder: (context, state) {
          final orderId =
              int.tryParse(state.pathParameters['orderId'] ?? '0') ?? 0;
          return TrackOrderScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/order-tracking',
        name: 'order-tracking',
        builder: (context, state) => const OrderTrackingScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/edit-username',
        name: 'edit-username',
        builder: (context, state) => const EditUsernameScreen(),
      ),
      GoRoute(
        path: '/edit-email',
        name: 'edit-email',
        builder: (context, state) => const EditEmailScreen(),
      ),
      GoRoute(
        path: '/edit-phone',
        name: 'edit-phone',
        builder: (context, state) => const EditPhoneScreen(),
      ),
      GoRoute(
        path: '/vouchers',
        name: 'vouchers',
        builder: (context, state) => const VouchersScreen(),
      ),
      GoRoute(
        path: '/wallet',
        name: 'wallet',
        builder: (context, state) => const WalletPointsPage(),
      ),
      GoRoute(
        path: '/transactions',
        name: 'transactions',
        builder: (context, state) => const TransactionsScreen(),
      ),
      GoRoute(
        path: '/addresses',
        name: 'addresses',
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: '/payment-methods',
        name: 'payment-methods',
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: '/password-management',
        name: 'password-management',
        builder: (context, state) => const PasswordManagementScreen(),
      ),
      GoRoute(
        path: '/verify-for-password-change',
        name: 'verify-for-password-change',
        builder: (context, state) => const VerifyForPasswordChangeScreen(),
      ),
      GoRoute(
        path: '/confirm-password-change',
        name: 'confirm-password-change',
        builder: (context, state) => const ConfirmPasswordChangeScreen(),
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/support',
        name: 'support',
        builder: (context, state) => const SupportScreen(),
      ),
    ],

    //? TODO: Localizations
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          '${AppLocalizations.of(context)!.pageNotFound} ${state.matchedLocation}',
        ),
      ),
    ),
  );
});
