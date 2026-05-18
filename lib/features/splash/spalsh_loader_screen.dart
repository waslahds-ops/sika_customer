import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../core/constants/app_pallete.dart';
import '../../core/router/route_paths.dart';
import '../../core/services/onboarding_service.dart';
import '../../injection_container.dart';

class LoaderScreen extends ConsumerStatefulWidget {
  const LoaderScreen({super.key, required this.onFinish});

  final void Function(String targetRoute) onFinish;

  @override
  ConsumerState<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends ConsumerState<LoaderScreen>
    with TickerProviderStateMixin {
  late final AnimationController _circleController;
  bool _navigationTriggered = false;
  String _resolvedRoute = mainNoTransitionRoute;

  @override
  void initState() {
    super.initState();
    _circleController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _triggerNavigation();
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareLoader();
    });
  }

  Future<void> _prepareLoader() async {
    await _checkAuthAndFinish();
    if (!mounted) return;
    _circleController.forward();
  }

  Future<void> _checkAuthAndFinish() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    try {
      final onboardingService = OnboardingService();
      final hasCompletedOnboarding =
          await onboardingService.hasCompletedOnboarding();

      if (!hasCompletedOnboarding) {
      _resolvedRoute = '/onboarding';
      return;
    }

      final authRepo = ref.read(authRepositoryProvider);
      final token = await authRepo.getStoredToken();
      await authRepo.getStoredUserData();

      if (token != null && token.isNotEmpty) {
        final apiService = ref.read(apiServiceProvider);
        final dioClient = ref.read(dioClientProvider);
        apiService.setAuthToken(token);
        dioClient.setAuthToken(token);

        await ref.read(authProvider.notifier).checkAuthStatus();
      }

      _resolvedRoute = mainNoTransitionRoute;
    } catch (_) {
      _resolvedRoute = mainNoTransitionRoute;
    }
  }

  @override
  void dispose() {
    _circleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Color(0xffffbef53)),
          Center(
            child: Lottie.asset(
              'assets/lottie/splash_loader.json',
              width: 1024,
              height: 1024,
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
          
          CustomPaint(
            painter: CircleCoverPainter(animation: _circleController),
          ),
        ],
      ),
    );
  }

  
  void _triggerNavigation() {
    if (_navigationTriggered) return;
    _navigationTriggered = true;
    widget.onFinish(_resolvedRoute);
  }
}

class CircleCoverPainter extends CustomPainter {
  CircleCoverPainter({required this.animation}) : super(repaint: animation);

  final Animation<double> animation;

  static const List<_CircleConfig> _circleConfigs = [
    _CircleConfig(
      offsetFactor: Offset(0.2, 0.2),
      color: Color(0xffffbef53),
      start: 0.0,
      duration: 0.5,
    ),
    _CircleConfig(
      offsetFactor: Offset(0.8, 0.2),
      color: AppPallete.primaryGreen,
      start: 0.15,
      duration: 0.55,
    ),
    _CircleConfig(
      offsetFactor: Offset(0.5, 0.8),
      color: Color(0xFF1AA73B),
      start: 0.35,
      duration: 0.65,
    ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final maxRadius = sqrt(size.width * size.width + size.height * size.height);

    for (final config in _circleConfigs) {
      final localProgress =
          ((animation.value - config.start) / config.duration).clamp(0.0, 1.0);
      if (localProgress <= 0) continue;

      final paint = Paint()
        ..color = config.color.withOpacity(localProgress * 0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        config.center(size),
        localProgress * maxRadius,
        paint,
      );
    }

    if (animation.value > 0.85) {
      final overlayProgress =
          ((animation.value - 0.85) / 0.15).clamp(0.0, 1.0);
      final overlayPaint = Paint()
        ..color = AppPallete.primaryDark.withOpacity(overlayProgress * 0.85);
      canvas.drawRect(Offset.zero & size, overlayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CircleCoverPainter oldDelegate) {
    return oldDelegate.animation.value != animation.value;
  }
}

class _CircleConfig {
  const _CircleConfig({
    required this.offsetFactor,
    required this.color,
    required this.start,
    required this.duration,
  });

  final Offset offsetFactor;
  final Color color;
  final double start;
  final double duration;

  Offset center(Size size) {
    return Offset(size.width * offsetFactor.dx, size.height * offsetFactor.dy);
  }
}
