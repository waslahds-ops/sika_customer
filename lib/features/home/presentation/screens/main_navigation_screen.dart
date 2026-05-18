import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import 'package:go_router/go_router.dart';
import 'package:sika_customer/features/butler/presentation/view/driver_screen.dart';
import 'package:sika_customer/features/orders/presentation/screens/my_orders_screen.dart';
import 'package:sika_customer/features/home/presentation/widgets/glovo_bottom_nav_bar.dart';
import 'package:sika_customer/l10n/app_localizations.dart';

import 'home_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../../injection_container.dart';

// Provider to manage navigation tab index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    // Ensure auth token is set from storage
    Future.microtask(() async {
      final authRepo = ref.read(authRepositoryProvider);
      final token = await authRepo.getStoredToken();
      if (token != null && token.isNotEmpty) {
        print('🔐 [MainNav] Token found in storage, setting in DioClient');
        final dioClient = ref.read(dioClientProvider);
        dioClient.setAuthToken(token);
      }
    });
  }

  void _onTabTapped(int index) {
    final currentIndex = ref.read(navigationIndexProvider);

    // Check if user is trying to access Orders tab (index 1)
    if (index == 1) {
      final authState = ref.read(authProvider);
      if (!authState.isAuthenticated) {
        // User is not logged in, navigate to login
        context.push('/login');
        return;
      }
    }

    // Allow navigation
    if (index != currentIndex) {
      setState(() {
        _previousIndex = currentIndex;
      });
      ref.read(navigationIndexProvider.notifier).state = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final l10n = AppLocalizations.of(context)!;

    // Create pages with proper keys
    final pages = [
      HomeScreen(key: const ValueKey('home')),
      const MyOrdersScreen(key: ValueKey('orders')),
      const DriverScreen(key: ValueKey('driver')),
      const ProfileScreen(key: ValueKey('profile')),
    ];

    // Localized labels
    final labels = [l10n.home, l10n.orders, l10n.butler, l10n.profile];
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        reverse: currentIndex < _previousIndex,
        transitionBuilder: (child, animation, secondaryAnimation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: pages[currentIndex],
      ),
      bottomNavigationBar: GlovoBottomNavBar(
        key: ValueKey(currentIndex),
        currentIndex: currentIndex,
        onTap: _onTabTapped,
        activeIcons: glovoActiveNavIcons,
        inactiveIcons: glovoInactiveNavIcons,
        labels: labels,
      ),
    );
  }
}
