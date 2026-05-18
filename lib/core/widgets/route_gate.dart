import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sika_customer/core/router/route_paths.dart';
import 'package:sika_customer/features/home/presentation/screens/main_navigation_screen.dart';
import 'package:sika_customer/features/home/presentation/widgets/home_shimmer_loader.dart';
import 'package:sika_customer/features/splash/spalsh_loader_screen.dart';

class RootGate extends ConsumerStatefulWidget {
  const RootGate({super.key});

  @override
  ConsumerState<RootGate> createState() => _RootGateState();
}

class _RootGateState extends ConsumerState<RootGate> {
  bool showLoader = true;
  bool showShimmer = false;
  String targetRoute = mainNoTransitionRoute;

  void _onLoaderFinish(String route) {
    final shouldShowShimmer = route == mainNoTransitionRoute;
    setState(() {
      showLoader = false;
      targetRoute = route;
      showShimmer = shouldShowShimmer;
    });

    if (shouldShowShimmer) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          showShimmer = false;
        });
        context.go(route);
      });
    } else {
      Future.microtask(() {
        if (mounted) context.go(route);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// 👇 Page that will be revealed
        const MainNavigationScreen(),

        /// 👆 Animated overlay
        if (showLoader)
          LoaderScreen(
            onFinish: _onLoaderFinish,
          ),
        if (!showLoader && showShimmer)
          const Positioned.fill(
            child: Material(
              color: Colors.white,
              child: HomeShimmerLoader(),
            ),
          ),
      ],
    );
  }
}
