import 'package:flutter/material.dart';

/// Page Flip Transition Widget
/// Creates a flip animation from bottom-right to top-left
class PageFlipTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const PageFlipTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeInOut,
  });

  @override
  State<PageFlipTransition> createState() => _PageFlipTransitionState();
}

class _PageFlipTransitionState extends State<PageFlipTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    // Start animation after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final progress = _flipAnimation.value;
        
        // Calculate the perspective transform
        // Flip from bottom-right to top-left
        final perspectiveX = (1.0 - progress) * 0.001;
        final perspectiveY = (1.0 - progress) * 0.001;
        
        return Transform(
          alignment: Alignment.bottomRight,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateX(perspectiveY * 1.57) // pi/2
            ..rotateY(perspectiveX * 1.57) // pi/2
            ..rotateZ(progress * -0.785), // pi/4 (45 degrees)
          child: Opacity(
            opacity: 1.0 - (progress * 0.1),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Page Flip Page Route - Use this to transition between pages with flip effect
class PageFlipPageRoute<T> extends PageRoute<T> {
  final Widget child;
  final Duration duration;

  PageFlipPageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  bool get opaque => false;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.0),
        end: Offset.zero,
      ).animate(animation),
      child: Transform(
        alignment: Alignment.bottomRight,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX((1.0 - animation.value) * 1.57)
          ..rotateY((1.0 - animation.value) * 1.57)
          ..rotateZ(animation.value * -0.785),
        child: Opacity(
          opacity: 1.0 - (animation.value * 0.1),
          child: child,
        ),
      ),
    );
  }
}
