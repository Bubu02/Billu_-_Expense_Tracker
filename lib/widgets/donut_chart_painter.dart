import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/budget_model.dart';

class DonutChartPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final Color trackColor;
  final bool isDark;

  const DonutChartPainter({
    required this.segments,
    required this.trackColor,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 14.0;

    // 1. Base track circle
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Segmented Arcs
    double startAngle = -math.pi / 2; // start from top (12 o'clock)
    const gapAngle = 0.03; // subtle crisp architectural gap

    for (final segment in segments) {
      final sweepAngle = (segment.percentage * 2 * math.pi) - gapAngle;
      final arcColor = isDark ? segment.darkColor : segment.lightColor;

      final arcPaint = Paint()
        ..color = arcColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + (gapAngle / 2),
        sweepAngle,
        false,
        arcPaint,
      );

      startAngle += segment.percentage * 2 * math.pi;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.isDark != isDark;
  }
}

