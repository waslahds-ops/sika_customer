import 'dart:math' as math;

import 'package:flutter/material.dart';

class RaysPainter extends CustomPainter {
  final Color color;

  RaysPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final numberOfRays = 20;
    final maxRadius = size.width / 2;

    for (int i = 0; i < numberOfRays; i++) {
      final angle = (i * 2 * math.pi) / numberOfRays;

      final path = Path();
      path.moveTo(center.dx, center.dy);

      // Create a triangular ray
      final x1 = center.dx + maxRadius * math.cos(angle - 0.05);
      final y1 = center.dy + maxRadius * math.sin(angle - 0.05);
      final x2 = center.dx + maxRadius * math.cos(angle + 0.05);
      final y2 = center.dy + maxRadius * math.sin(angle + 0.05);

      path.lineTo(x1, y1);
      path.lineTo(x2, y2);
      path.close();

      // Create gradient effect by varying opacity
      final rayPaint = Paint()
        ..color = color.withValues(alpha: color.opacity * (0.3 + (i % 3) * 0.3))
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

