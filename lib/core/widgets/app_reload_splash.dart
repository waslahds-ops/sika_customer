import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/app_loader.dart';

/// Overlay widget that shows a splash screen during app reload
class AppReloadSplash extends ConsumerWidget {
  const AppReloadSplash({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App logo or custom animation
          Center(
            child: Column(
              children: [
                // Loader animation
                const SizedBox(width: 80, height: 80, child: AppLoader()),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
