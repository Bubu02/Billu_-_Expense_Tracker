import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/donut_chart_painter.dart';

class BudgetAnalyticsScreen extends StatefulWidget {
  const BudgetAnalyticsScreen({super.key});

  @override
  State<BudgetAnalyticsScreen> createState() => _BudgetAnalyticsScreenState();
}

class _BudgetAnalyticsScreenState extends State<BudgetAnalyticsScreen> {
  String _selectedPeriod = 'monthly';

  @override
  Widget build(BuildContext context) {
    final colors = context.piluColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // View Controls & Period Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'analytics',
                style: AppTypography.headlineLg(colors.primary).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  children: ['weekly', 'monthly', 'custom'].map((period) {
                    final isSelected = period == _selectedPeriod;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedPeriod = period),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected ? colors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          period,
                          style: AppTypography.labelCaps(
                            isSelected ? colors.onPrimary : colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Architectural Alert Pill (Ink Style)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '80% dining limit reached for october',
                      style: AppTypography.numericSm(colors.primary).copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: colors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Monochrome Circular Breakdown & Key Legend
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Donut Chart with Center Gauge Readout
                SizedBox(
                  width: 190,
                  height: 190,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(190, 190),
                        painter: DonutChartPainter(
                          segments: DonutSegment.sampleSegments,
                          trackColor: colors.surfaceContainer,
                          isDark: isDark,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'OCT TOTAL',
                            style: AppTypography.labelCaps(colors.secondary).copyWith(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\$1,840',
                            style: AppTypography.displayCurrencyMobile(colors.primary).copyWith(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'of \$2,400 cap',
                            style: AppTypography.labelSubtle(colors.outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Category Proportional Legend Cards (2x2 Grid)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.6,
                  children: DonutSegment.sampleSegments.map((segment) {
                    final color = isDark ? segment.darkColor : segment.lightColor;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  segment.title,
                                  style: AppTypography.labelCaps(colors.onSurface),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${(segment.percentage * 100).toInt()}% · \$${segment.amount.toInt()}',
                                  style: AppTypography.numericSm(colors.primary).copyWith(
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Category Target Logs & High-Contrast Progress Meters
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'category logs',
                style: AppTypography.headlineMd(colors.primary).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '4 active caps',
                style: AppTypography.labelSubtle(colors.secondary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: BudgetCategory.sampleCategories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final cat = BudgetCategory.sampleCategories[index];
              final percent = cat.percentage;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: colors.surfaceContainer,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                cat.icon,
                                size: 18,
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              cat.title,
                              style: AppTypography.bodyMd(colors.primary).copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '\$${cat.spent.toInt()}',
                                style: AppTypography.numericTabular(colors.primary).copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: ' / \$${cat.limit.toInt()}',
                                style: AppTypography.labelSubtle(colors.secondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Progress Track
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9999),
                      child: SizedBox(
                        height: 6,
                        child: LinearProgressIndicator(
                          value: percent,
                          backgroundColor: colors.surfaceContainer,
                          valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(percent * 100).toInt()}% spent',
                          style: AppTypography.labelSubtle(colors.secondary),
                        ),
                        Text(
                          '\$${cat.remaining.toInt()} left',
                          style: AppTypography.numericSm(colors.primary).copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

