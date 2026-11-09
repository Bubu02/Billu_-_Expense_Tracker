import 'package:flutter/material.dart';

class SteppedChartPainter extends CustomPainter {
  final Color lineColor;
  final Color baseLineColor;
  final bool hasData;

  const SteppedChartPainter({
    required this.lineColor,
    required this.baseLineColor,
    this.hasData = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 80.0;
    final sy = size.height / 40.0;

    // 1. Dashed baseline at y = 38
    final basePaint = Paint()
      ..color = baseLineColor.withValues(alpha: 0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, 38 * sy),
        Offset((x + 2 * sx).clamp(0, size.width), 38 * sy),
        basePaint,
      );
      x += 5 * sx;
    }

    if (!hasData) return;

    // 2. Stepped path:
    // M0 32 L16 32 L16 26 L32 26 L32 20 L48 20 L48 12 L64 12 L64 4 L80 4
    final path = Path();
    path.moveTo(0 * sx, 32 * sy);
    path.lineTo(16 * sx, 32 * sy);
    path.lineTo(16 * sx, 26 * sy);
    path.lineTo(32 * sx, 26 * sy);
    path.lineTo(32 * sx, 20 * sy);
    path.lineTo(48 * sx, 20 * sy);
    path.lineTo(48 * sx, 12 * sy);
    path.lineTo(64 * sx, 12 * sy);
    path.lineTo(64 * sx, 4 * sy);
    path.lineTo(80 * sx, 4 * sy);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant SteppedChartPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.baseLineColor != baseLineColor ||
        oldDelegate.hasData != hasData;
  }
}

