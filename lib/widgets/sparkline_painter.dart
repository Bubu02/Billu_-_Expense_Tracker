import 'package:flutter/material.dart';

class SparklinePainter extends CustomPainter {
  final Color lineColor;
  final Color gridLineColor;
  final Color pointColor;
  final bool isDark;
  final bool hasData;
  final List<double> dataPoints;

  const SparklinePainter({
    required this.lineColor,
    required this.gridLineColor,
    required this.pointColor,
    this.isDark = false,
    this.hasData = false,
    this.dataPoints = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Scale factor for y-axis
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

    if (!hasData || dataPoints.isEmpty) {
      // Draw quiet baseline placeholder
      final linePaint = Paint()
        ..color = lineColor.withValues(alpha: 0.25)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(0, 56 * sy), Offset(w, 56 * sy), linePaint);
      return;
    }

    // 3. Draw line chart based on actual data points
    final maxValue = dataPoints.reduce((a, b) => a > b ? a : b);
    final minValue = dataPoints.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    // Normalize data to fit chart height (leaving padding top and bottom)
    final chartTop = 10.0 * sy;
    final chartBottom = 70.0 * sy;
    final chartHeight = chartBottom - chartTop;

    List<Offset> points = [];
    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i / (dataPoints.length - 1).clamp(1, double.infinity)) * w;
      double y;
      if (range > 0) {
        final normalized = (dataPoints[i] - minValue) / range;
        y = chartBottom - (normalized * chartHeight);
      } else {
        y = (chartTop + chartBottom) / 2;
      }
      points.add(Offset(x, y));
    }

    // Draw smooth path through points
    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);

      if (points.length == 1) {
        path.lineTo(points[0].dx, points[0].dy);
      } else if (points.length == 2) {
        path.lineTo(points[1].dx, points[1].dy);
      } else {
        for (int i = 0; i < points.length - 1; i++) {
          final p0 = i > 0 ? points[i - 1] : points[i];
          final p1 = points[i];
          final p2 = points[i + 1];
          final p3 = i < points.length - 2 ? points[i + 2] : p2;

          final cp1x = p1.dx + (p2.dx - p0.dx) / 6;
          final cp1y = p1.dy + (p2.dy - p0.dy) / 6;
          final cp2x = p2.dx - (p3.dx - p1.dx) / 6;
          final cp2y = p2.dy - (p3.dy - p1.dy) / 6;

          path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
        }
      }
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.25
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // 4. Draw active point indicator at last data point
    if (points.isNotEmpty) {
      final lastPoint = points.last;
      final cx = lastPoint.dx;
      final cy = lastPoint.dy;

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
        oldDelegate.hasData != hasData ||
        oldDelegate.dataPoints != dataPoints;
  }
}

