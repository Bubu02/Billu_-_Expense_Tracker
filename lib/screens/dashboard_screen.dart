import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/sparkline_painter.dart';

class DashboardScreen extends StatefulWidget {
  final bool isMasked;
  final VoidCallback onToggleMask;
  final VoidCallback? onSearchTap;
  final Function(TransactionModel)? onTransactionTap;

  const DashboardScreen({
    super.key,
    required this.isMasked,
    required this.onToggleMask,
    this.onSearchTap,
    this.onTransactionTap,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedMonth = 'oct';
  String _selectedTimeframe = 'this month';
  final List<String> _months = ['jul', 'aug', 'sep', 'oct', 'nov', 'dec'];

  @override
  Widget build(BuildContext context) {
    final colors = context.piluColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final todayTransactions = TransactionModel.sampleData
        .where((t) => t.group == TransactionGroup.today)
        .toList();
    final yesterdayTransactions = TransactionModel.sampleData
        .where((t) => t.group == TransactionGroup.yesterday)
        .toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Utility Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Period Selector Pill
              GestureDetector(
                onTap: _showTimeframeMenu,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedTimeframe,
                        style: AppTypography.labelCaps(colors.onSurface).copyWith(
                          fontSize: 12,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.expand_more_rounded,
                        size: 16,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),

              // Search & Mask Privacy Action Buttons
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onSearchTap ?? () {},
                    icon: Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: colors.onSurface,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.surfaceContainer,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: widget.onToggleMask,
                    icon: Icon(
                      widget.isMasked
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 20,
                      color: colors.onSurface,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.surfaceContainer,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hero Spend Summary & Sinusoidal Sparkline
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live Pace & Total Spend Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL SPEND',
                      style: AppTypography.labelCaps(colors.onSurfaceVariant).copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'live pace',
                          style: AppTypography.labelSubtle(colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Amount Display + USD Tag
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      widget.isMasked ? '\$••••••' : '\$301.95',
                      style: AppTypography.displayCurrencyMobile(colors.primary),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'USD',
                      style: AppTypography.labelCaps(colors.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Baseline comparison
                Text(
                  '18% lower than previous 30-day baseline',
                  style: AppTypography.labelSubtle(colors.onSurfaceVariant),
                ),
                const SizedBox(height: 20),

                // Sparkline Spline with Pin Tooltip
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Canvas Sparkline
                    SizedBox(
                      width: double.infinity,
                      height: 84,
                      child: CustomPaint(
                        painter: SparklinePainter(
                          lineColor: colors.primary,
                          gridLineColor: colors.outline,
                          pointColor: colors.primary,
                          isDark: isDark,
                        ),
                      ),
                    ),

                    // Floating Tooltip on active curve point (approx 72% across)
                    Positioned(
                      top: 4,
                      left: 190,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(9999),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              'today \$8.95',
                              style: AppTypography.labelCaps(colors.onPrimary).copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Transform.rotate(
                            angle: 0.785398, // 45 deg
                            child: Container(
                              width: 6,
                              height: 6,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Day Annotations
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 2, right: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('day 01', style: AppTypography.labelCaps(colors.onSurfaceVariant)),
                      Text('day 15', style: AppTypography.labelCaps(colors.onSurfaceVariant)),
                      Text(
                        'today',
                        style: AppTypography.labelCaps(colors.primary).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Horizontal Timeline Month Switcher
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _months.map((month) {
                final isSelected = month == _selectedMonth;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMonth = month),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        month,
                        style: AppTypography.labelSubtle(
                          isSelected ? colors.onPrimary : colors.onSurfaceVariant,
                        ).copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Mindful Budget Health Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.eco_rounded,
                        size: 20,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'envelope in rhythm',
                          style: AppTypography.headlineMd(colors.primary).copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$18.05 unallocated buffer remains',
                          style: AppTypography.labelSubtle(colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '84%',
                    style: AppTypography.labelCaps(colors.onSurface).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Ledger: Today
          _buildTransactionSection(
            context,
            title: 'today',
            totalAmount: '—\$308.89',
            transactions: todayTransactions,
          ),
          const SizedBox(height: 20),

          // Ledger: Yesterday
          _buildTransactionSection(
            context,
            title: 'yesterday',
            totalAmount: '—\$42.10',
            transactions: yesterdayTransactions,
          ),
          const SizedBox(height: 32),

          // Subtle Receipt End Mark
          Center(
            child: Column(
              children: [
                Text(
                  'PILU LEDGER • SYNC 1M AGO',
                  style: AppTypography.labelCaps(colors.onSurfaceVariant.withValues(alpha: 0.6)).copyWith(
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 48,
                  height: 3,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTransactionSection(
    BuildContext context, {
    required String title,
    required String totalAmount,
    required List<TransactionModel> transactions,
  }) {
    final colors = context.piluColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: AppTypography.labelCaps(colors.onSurfaceVariant).copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                widget.isMasked ? '—\$•••' : totalAmount,
                style: AppTypography.numericSm(colors.primary).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: transactions.length,
            separatorBuilder: (_, __) => Divider(
              color: colors.surfaceContainer,
              height: 1,
            ),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return InkWell(
                onTap: () => widget.onTransactionTap?.call(tx),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          tx.icon,
                          size: 18,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.title,
                              style: AppTypography.bodyMd(colors.primary).copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              tx.subtitle,
                              style: AppTypography.labelSubtle(colors.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.isMasked ? '-\$•••' : tx.formattedAmount,
                        style: AppTypography.numericTabular(colors.primary).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showTimeframeMenu() {
    final colors = context.piluColors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final options = ['this week', 'this month', 'last 30 days', 'this year'];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((opt) {
                final isCurrent = opt == _selectedTimeframe;
                return ListTile(
                  title: Text(
                    opt,
                    style: AppTypography.bodyMd(colors.onSurface).copyWith(
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  trailing: isCurrent
                      ? Icon(Icons.check_rounded, color: colors.primary, size: 20)
                      : null,
                  onTap: () {
                    setState(() => _selectedTimeframe = opt);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

