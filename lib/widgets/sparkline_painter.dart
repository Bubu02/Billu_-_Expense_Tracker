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

    // Define chart area with padding - baseline at very bottom
    const chartTop = 15.0;
    final baselineY = h - 2.0; // Base X-axis at bottom (spend = 0)
    final chartHeight = baselineY - chartTop;

    // 1. Draw base X-axis (0 baseline) - continuous horizontal line at bottom
    final baselinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.24)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, baselineY), Offset(w, baselineY), baselinePaint);

    // 2. Draw subtle upper reference guide lines
    final guidePaint = Paint()
      ..color = gridLineColor.withValues(alpha: 0.12)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Upper grid lines at 25%, 50%, 75%
    _drawDashedLine(
      canvas,
      Offset(0, chartTop + chartHeight * 0.25),
      Offset(w, chartTop + chartHeight * 0.25),
      dashWidth: 3,
      dashSpace: 5,
      paint: guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(0, chartTop + chartHeight * 0.5),
      Offset(w, chartTop + chartHeight * 0.5),
      dashWidth: 3,
      dashSpace: 5,
      paint: guidePaint,
    );

    if (!hasData || dataPoints.isEmpty) {
      // Draw flat line at baseline when no data
      final linePaint = Paint()
        ..color = lineColor.withValues(alpha: 0.25)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(0, baselineY), Offset(w, baselineY), linePaint);
      return;
    }

    // 3. Draw dynamic spending path with 0-baseline support
    final maxValue = dataPoints.reduce((a, b) => a > b ? a : b);

    // Handle case where all values are 0
    if (maxValue == 0) {
      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(0, baselineY), Offset(w, baselineY), linePaint);
      return;
    }

    // Build path: flat at baseline for 0s, peak upward for positive values
    final path = Path();
    final List<Offset> points = [];

    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i / (dataPoints.length - 1).clamp(1, double.infinity)) * w;
      double y;

      if (dataPoints[i] == 0) {
        y = baselineY; // Stay on baseline
      } else {
        final normalized = dataPoints[i] / maxValue; // 0.0 to 1.0
        y = baselineY - (normalized * chartHeight * 0.85); // Peak upward
      }

      points.add(Offset(x, y));
    }

    // Draw smooth path with quadratic bezier transitions
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);

      if (points.length == 1) {
        path.lineTo(points[0].dx, points[0].dy);
      } else if (points.length == 2) {
        path.lineTo(points[1].dx, points[1].dy);
      } else {
        // Use quadratic bezier for smooth transitions
        for (int i = 0; i < points.length - 1; i++) {
          final p1 = points[i];
          final p2 = points[i + 1];

          // Control point is midpoint slightly adjusted
          final cpX = (p1.dx + p2.dx) / 2;
          final cpY = (p1.dy + p2.dy) / 2;

          path.quadraticBezierTo(cpX, cpY, p2.dx, p2.dy);
        }
      }
    }

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // 4. Draw active point indicator at highest non-zero peak
    if (points.isNotEmpty && maxValue > 0) {
      // Find highest peak point
      int peakIndex = 0;
      double peakValue = dataPoints[0];
      for (int i = 1; i < dataPoints.length; i++) {
        if (dataPoints[i] > peakValue) {
          peakValue = dataPoints[i];
          peakIndex = i;
        }
      }

      if (peakValue > 0 && peakIndex < points.length) {
        final peakPoint = points[peakIndex];
        final cx = peakPoint.dx;
        final cy = peakPoint.dy;

        // Outer glow ring
        final ringPaint = Paint()
          ..color = pointColor.withValues(alpha: isDark ? 0.25 : 0.12)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(cx, cy), 10.0, ringPaint);

        // Inner solid point
        final pointPaint = Paint()
          ..color = pointColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(cx, cy), 5.0, pointPaint);
      }
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

