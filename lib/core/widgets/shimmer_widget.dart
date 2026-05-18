import 'package:flutter/material.dart';
import '../constants/app_pallete.dart';

class ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final double highlightWidth;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
    this.highlightWidth = 0.28,
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor ?? AppPallete.greyLight;
    final highlight = widget.highlightColor ?? AppPallete.white;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Map animation (-2..2) to 0..1
        final mid = (_animation.value + 2) / 4;
        final half = (widget.highlightWidth).clamp(0.05, 0.6) / 2;
        final left = (mid - half).clamp(0.0, 1.0);
        final center = mid.clamp(0.0, 1.0);
        final right = (mid + half).clamp(0.0, 1.0);

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(-1.0, 0.0),
              end: Alignment(1.0, 0.0),
              colors: [base, highlight, base],
              stops: [left, center, right],
            ),
          ),
        );
      },
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double size;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerCircle({
    super.key,
    required this.size,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }
}

class ShimmerLine extends StatelessWidget {
  final double width;
  final double height;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLine({
    super.key,
    required this.width,
    this.height = 16,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(4),
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }
}
