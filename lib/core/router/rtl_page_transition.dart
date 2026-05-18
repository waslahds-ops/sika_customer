import 'package:flutter/material.dart';

/// Custom page route that supports RTL-aware transitions
class RTLCustomPage<T> extends Page<T> {
  final Widget child;
  final bool isRTL;
  final Curve curve;

  const RTLCustomPage({
    required this.child,
    required this.isRTL,
    this.curve = Curves.easeInOut,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return _RTLPageRoute<T>(
      settings: this,
      builder: (context) => child,
      isRTL: isRTL,
      curve: curve,
    );
  }
}

class _RTLPageRoute<T> extends PageRoute<T> {
  _RTLPageRoute({
    required this.builder,
    required this.isRTL,
    required this.curve,
    RouteSettings? settings,
  }) : super(settings: settings);

  final WidgetBuilder builder;
  final bool isRTL;
  final Curve curve;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get opaque => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // For RTL (Arabic): slide from right to left (positive x to 0)
    // For LTR (English): slide from left to right (negative x to 0)
    final isRtl = isRTL;
    final startOffset = isRtl ? const Offset(1, 0) : const Offset(-1, 0);

    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: startOffset,
          end: Offset.zero,
        ).chain(CurveTween(curve: curve)),
      ),
      child: child,
    );
  }
}
