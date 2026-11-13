import 'package:flutter/material.dart';

/// Theme-aware, 0-baseline line chart painter for daily expenses and income.
class SparklinePainter extends CustomPainter {
  final List<double> dataPoints;
  final double maxY;
  final bool isDark;
  final bool isExpense;
  final String? tooltipLabel;
  final int? activeIndex;
  final Color? lineColor;
  final Color? gridLineColor;
  final Color? pointColor;

  const SparklinePainter({
    required this.dataPoints,
    required this.maxY,
    required this.isDark,
    this.isExpense = true,
    this.tooltipLabel,
    this.activeIndex,
    this.lineColor,
    this.gridLineColor,
    this.pointColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Chart padding
    const topPadding = 24.0;
    const bottomPadding = 6.0;
    final baselineY = h - bottomPadding;
    final availableHeight = baselineY - topPadding;

    // Theme-adaptive colors
    final primaryColor = lineColor ?? (isDark ? Colors.white : Colors.black);
    final baselineColor = isDark ? Colors.white24 : Colors.black26;
    final gridColor = gridLineColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06));
    final activeNodeColor = pointColor ?? primaryColor;

    // 1. Draw subtle horizontal grid lines (at 33% and 66% height)
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    _drawDashedLine(
      canvas,
      Offset(0, baselineY - availableHeight * 0.33),
      Offset(w, baselineY - availableHeight * 0.33),
      dashWidth: 4,
      dashSpace: 4,
      paint: gridPaint,
    );
    _drawDashedLine(
      canvas,
      Offset(0, baselineY - availableHeight * 0.66),
      Offset(w, baselineY - availableHeight * 0.66),
      dashWidth: 4,
      dashSpace: 4,
      paint: gridPaint,
    );

    // 2. Draw continuous horizontal X-axis line across baselineY first
    final baselinePaint = Paint()
      ..color = baselineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, baselineY), Offset(w, baselineY), baselinePaint);

    // 3. Handle zero-data or empty list edge case
    if (dataPoints.isEmpty) {
      final emptyPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.2)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, baselineY), Offset(w, baselineY), emptyPaint);
      return;
    }

    final totalDays = dataPoints.length;
    final effectiveMaxY = maxY > 0.0 ? maxY * 1.15 : 1.0;

    // Map each day to coordinate (x, y)
    final points = <Offset>[];
    for (int i = 0; i < totalDays; i++) {
      final x = totalDays > 1 ? (i / (totalDays - 1)) * w : w / 2;
      final v = dataPoints[i];
      // When v == 0, y equals baselineY exactly
      final y = v <= 0.0
          ? baselineY
          : baselineY - ((v / effectiveMaxY) * availableHeight);
      points.add(Offset(x, y));
    }

    // If all values are 0.0, render a flat line along baselineY
    if (maxY <= 0.0) {
      final flatPaint = Paint()
        ..color = primaryColor
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(0, baselineY), Offset(w, baselineY), flatPaint);
      return;
    }

    // 4. Draw area gradient under peaks (fading to transparent at baselineY)
    final fillPath = _buildSplinePath(
      points,
      baselineY,
      topPadding,
      asAreaFill: true,
    );

    final gradientTopColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientTopColor, Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromLTRB(0, topPadding, w, baselineY))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 5. Draw primary spline data line connecting points
    final linePath = _buildSplinePath(
      points,
      baselineY,
      topPadding,
      asAreaFill: false,
    );

    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // 6. Draw small solid circular nodes strictly on data points where value > 0
    final nodePaint = Paint()
      ..color = activeNodeColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      if (dataPoints[i] > 0.0) {
        canvas.drawCircle(points[i], 3.0, nodePaint);
      }
    }

    // 7. Active peak indicator & tooltip
    int? targetIndex = activeIndex;
    if (targetIndex == null ||
        targetIndex < 0 ||
        targetIndex >= points.length ||
        dataPoints[targetIndex] <= 0.0) {
      // Fallback: find highest non-zero peak
      double highest = 0.0;
      int highestIdx = -1;
      for (int i = 0; i < dataPoints.length; i++) {
        if (dataPoints[i] > highest) {
          highest = dataPoints[i];
          highestIdx = i;
        }
      }
      if (highestIdx != -1) {
        targetIndex = highestIdx;
      }
    }

    if (targetIndex != null &&
        targetIndex >= 0 &&
        targetIndex < points.length &&
        dataPoints[targetIndex] > 0.0) {
      final peakPt = points[targetIndex];

      // Outer glow ring
      final glowPaint = Paint()
        ..color = activeNodeColor.withValues(alpha: isDark ? 0.25 : 0.15)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(peakPt, 7.0, glowPaint);
      canvas.drawCircle(peakPt, 4.0, nodePaint);

      // Render tooltip pill if label is provided
      if (tooltipLabel != null && tooltipLabel!.isNotEmpty) {
        final textSpan = TextSpan(
          text: tooltipLabel,
          style: TextStyle(
            color: isDark ? Colors.black : Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        const pillPaddingH = 10.0;
        const pillPaddingV = 4.0;
        final pillWidth = textPainter.width + pillPaddingH * 2;
        final pillHeight = textPainter.height + pillPaddingV * 2;

        final tooltipY = (peakPt.dy - pillHeight - 10.0).clamp(2.0, baselineY - pillHeight - 8.0);
        final pillCenterX = peakPt.dx.clamp(pillWidth / 2 + 4.0, w - pillWidth / 2 - 4.0);

        // Indicator line from peak up to tooltip
        final indicatorLinePaint = Paint()
          ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.35)
          ..strokeWidth = 1.0;
        canvas.drawLine(
          Offset(peakPt.dx, tooltipY + pillHeight),
          Offset(peakPt.dx, peakPt.dy - 6.0),
          indicatorLinePaint,
        );

        // Tooltip pill background
        final pillRRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(pillCenterX, tooltipY + pillHeight / 2),
            width: pillWidth,
            height: pillHeight,
          ),
          const Radius.circular(9999),
        );

        final pillBgPaint = Paint()
          ..color = isDark ? Colors.white : Colors.black
          ..style = PaintingStyle.fill;

        canvas.drawRRect(pillRRect, pillBgPaint);

        // Tooltip text
        textPainter.paint(
          canvas,
          Offset(
            pillCenterX - textPainter.width / 2,
            tooltipY + pillPaddingV,
          ),
        );
      }
    }
  }

  /// Builds a smooth spline path through the points with 0-baseline clamping.
  Path _buildSplinePath(
    List<Offset> points,
    double baselineY,
    double topPadding, {
    bool asAreaFill = false,
  }) {
    final path = Path();
    if (points.isEmpty) return path;

    if (asAreaFill) {
      path.moveTo(points.first.dx, baselineY);
      path.lineTo(points.first.dx, points.first.dy);
    } else {
      path.moveTo(points.first.dx, points.first.dy);
    }

    if (points.length == 1) {
      if (asAreaFill) {
        path.lineTo(points.first.dx, baselineY);
        path.close();
      }
      return path;
    }

    if (points.length == 2) {
      final p0 = points[0];
      final p1 = points[1];
      final isP0Zero = (p0.dy - baselineY).abs() < 0.01;
      final isP1Zero = (p1.dy - baselineY).abs() < 0.01;

      if (isP0Zero && isP1Zero) {
        path.lineTo(p1.dx, p1.dy);
      } else {
        final dx = (p1.dx - p0.dx) * 0.35;
        path.cubicTo(
          p0.dx + dx,
          p0.dy,
          p1.dx - dx,
          p1.dy,
          p1.dx,
          p1.dy,
        );
      }
      if (asAreaFill) {
        path.lineTo(p1.dx, baselineY);
        path.close();
      }
      return path;
    }

    const k = 0.2; // Spline tension factor

    for (int i = 0; i < points.length - 1; i++) {
      final pCurr = points[i];
      final pNext = points[i + 1];
      final pPrev = i > 0
          ? points[i - 1]
          : Offset(pCurr.dx - (pNext.dx - pCurr.dx), pCurr.dy);
      final pAfter = (i + 2 < points.length)
          ? points[i + 2]
          : Offset(pNext.dx + (pNext.dx - pCurr.dx), pNext.dy);

      double cp1x = pCurr.dx + (pNext.dx - pPrev.dx) * k;
      double cp1y = pCurr.dy + (pNext.dy - pPrev.dy) * k;

      double cp2x = pNext.dx - (pAfter.dx - pCurr.dx) * k;
      double cp2y = pNext.dy - (pAfter.dy - pCurr.dy) * k;

      // Monotonicity / peak flattening:
      // If pCurr is a local extremum (peak/valley or flat), zero its departing vertical slope
      final dPrev = pCurr.dy - pPrev.dy;
      final dNext = pNext.dy - pCurr.dy;
      if (dPrev * dNext <= 0) {
        cp1y = pCurr.dy;
      }

      // If pNext is a local extremum (peak/valley or flat), zero its arriving vertical slope
      final dAfter = pAfter.dy - pNext.dy;
      if (dNext * dAfter <= 0) {
        cp2y = pNext.dy;
      }

      // Zero-baseline constraints: ensure baseline runs are strictly flat
      final isCurrZero = (pCurr.dy - baselineY).abs() < 0.01;
      final isNextZero = (pNext.dy - baselineY).abs() < 0.01;
      if (isCurrZero && isNextZero) {
        cp1y = baselineY;
        cp2y = baselineY;
      }

      // Clamp control points strictly within [topPadding, baselineY]
      cp1y = cp1y.clamp(topPadding, baselineY);
      cp2y = cp2y.clamp(topPadding, baselineY);

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, pNext.dx, pNext.dy);
    }

    if (asAreaFill) {
      path.lineTo(points.last.dx, baselineY);
      path.close();
    }

    return path;
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
    return oldDelegate.isDark != isDark ||
        oldDelegate.isExpense != isExpense ||
        oldDelegate.maxY != maxY ||
        oldDelegate.tooltipLabel != tooltipLabel ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridLineColor != gridLineColor ||
        oldDelegate.pointColor != pointColor ||
        !_listEquals(oldDelegate.dataPoints, dataPoints);
  }

  static bool _listEquals(List<double> a, List<double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
