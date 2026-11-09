import 'package:flutter/material.dart';

class SparklinePainter extends CustomPainter {
  final Color lineColor;
  final Color gridLineColor;
  final Color pointColor;
  final bool isDark;
  final bool hasData;

  const SparklinePainter({
    required this.lineColor,
    required this.gridLineColor,
    required this.pointColor,
    this.isDark = false,
    this.hasData = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Scale factors from SVG 320x80
    final sx = w / 320.0;
    final sy = h / 80.0;

    // 1. Draw dashed reference baseline (y = 56 * sy)
    final dashPaint = Paint()
      ..color = gridLineColor.withValues(alpha: 0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    _drawDashedLine(
      canvas,
      Offset(0, 56 * sy),
      Offset(w, 56 * sy),
      dashWidth: 4,
      dashSpace: 4,
      paint: dashPaint,
    );

    // 2. Draw secondary dashed guidance axis (y = 24 * sy)
    final guidePaint = Paint()
      ..color = gridLineColor.withValues(alpha: 0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    _drawDashedLine(
      canvas,
      Offset(0, 24 * sy),
      Offset(w, 24 * sy),
      dashWidth: 2,
      dashSpace: 6,
      paint: guidePaint,
    );

    if (!hasData) {
      // Draw quiet baseline placeholder
      final linePaint = Paint()
        ..color = lineColor.withValues(alpha: 0.25)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(0, 56 * sy), Offset(w, 56 * sy), linePaint);
      return;
    }

    // 3. Draw smooth continuous sinusoidal spline:
    // M0 64 C25 64, 45 42, 70 42 C95 42, 110 58, 135 58 C160 58, 175 22, 205 22 C225 22, 230 46, 250 46 C270 46, 290 14, 320 18
    final path = Path();
    path.moveTo(0 * sx, 64 * sy);
    path.cubicTo(25 * sx, 64 * sy, 45 * sx, 42 * sy, 70 * sx, 42 * sy);
    path.cubicTo(95 * sx, 42 * sy, 110 * sx, 58 * sy, 135 * sx, 58 * sy);
    path.cubicTo(160 * sx, 58 * sy, 175 * sx, 22 * sy, 205 * sx, 22 * sy);
    path.cubicTo(225 * sx, 22 * sy, 230 * sx, 46 * sy, 250 * sx, 46 * sy);
    path.cubicTo(270 * sx, 46 * sy, 290 * sx, 14 * sy, 320 * sx, 18 * sy);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.25
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // 4. Draw active point indicator at (230, 46)
    final cx = 230.0 * sx;
    final cy = 46.0 * sy;

    // Outer glow ring
    final ringPaint = Paint()
      ..color = pointColor.withValues(alpha: isDark ? 0.25 : 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 9.0, ringPaint);

    // Inner solid point
    final pointPaint = Paint()
      ..color = pointColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 4.5, pointPaint);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end, {
    required double dashWidth,
    required double dashSpace,
    required Paint paint,
  }) {
    double currentX = start.dx;
    while (currentX < end.dx) {
      final nextX = (currentX + dashWidth).clamp(start.dx, end.dx);
      canvas.drawLine(Offset(currentX, start.dy), Offset(nextX, start.dy), paint);
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.gridLineColor != gridLineColor ||
        oldDelegate.pointColor != pointColor ||
        oldDelegate.isDark != isDark ||
        oldDelegate.hasData != hasData;
  }
}

