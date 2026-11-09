import 'package:flutter/material.dart';

class ConstellationPainter extends CustomPainter {
  final Color lineColor;

  const ConstellationPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 340.0;
    final sy = size.height / 340.0;

    final paint = Paint()
      ..color = lineColor.withValues(alpha: 0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final curves = [
      // Top-left arc
      _CurveData(68, 85, 105, 105, 120, 135, 140, 150),
      // Top-right arc
      _CurveData(270, 70, 230, 95, 205, 125, 195, 150),
      // Mid-left horizontal arc
      _CurveData(40, 185, 80, 180, 110, 180, 130, 180),
      // Mid-right horizontal arc
      _CurveData(295, 185, 260, 185, 230, 185, 205, 185),
      // Bottom-left arc
      _CurveData(85, 275, 110, 245, 135, 220, 150, 205),
      // Bottom-right arc
      _CurveData(260, 270, 230, 240, 205, 215, 190, 205),
    ];

    for (final c in curves) {
      final path = Path();
      path.moveTo(c.x1 * sx, c.y1 * sy);
      path.cubicTo(
        c.cx1 * sx,
        c.cy1 * sy,
        c.cx2 * sx,
        c.cy2 * sy,
        c.x2 * sx,
        c.y2 * sy,
      );
      _drawDashedPath(canvas, path, paint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLength = 3.0;
    const dashSpace = 4.0;
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final next = (distance + dashLength).clamp(0.0, metric.length);
        final segment = metric.extractPath(distance, next);
        canvas.drawPath(segment, paint);
        distance += dashLength + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant ConstellationPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}

class _CurveData {
  final double x1, y1;
  final double cx1, cy1;
  final double cx2, cy2;
  final double x2, y2;

  _CurveData(this.x1, this.y1, this.cx1, this.cy1, this.cx2, this.cy2, this.x2, this.y2);
}

