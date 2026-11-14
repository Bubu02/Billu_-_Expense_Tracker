import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/storage/storage_service.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/sparkline_painter.dart';

class DashboardScreen extends StatefulWidget {
  final bool isMasked;
  final VoidCallback onToggleMask;
  final VoidCallback? onSearchTap;
  final Function(TransactionModel)? onTransactionTap;
  final List<TransactionModel>? transactions;

  const DashboardScreen({
    super.key,
    required this.isMasked,
    required this.onToggleMask,
    this.onSearchTap,
    this.onTransactionTap,
    this.transactions,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

enum GraphMode { expense, income }

class _DashboardScreenState extends State<DashboardScreen> {
  late DateTime _currentMonth;
  String _selectedTimeRange = 'This Month';
  final List<String> _timeRangeOptions = ['7 Days', '15 Days', 'This Month', 'Custom'];
  GraphMode _graphMode = GraphMode.expense;
  DateTimeRange? _customDateRange;

  @override
  void initState() {
    super.initState();
    // Initialize to current device month and year
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
  }

  DateTimeRange _getActiveDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_selectedTimeRange) {
      case '7 Days':
        return DateTimeRange(
          start: today.subtract(const Duration(days: 6)),
          end: today,
        );
      case '15 Days':
        return DateTimeRange(
          start: today.subtract(const Duration(days: 14)),
          end: today,
        );
      case 'Custom':
        if (_customDateRange != null) {
          final s = _customDateRange!.start;
          final e = _customDateRange!.end;
          return DateTimeRange(
            start: DateTime(s.year, s.month, s.day),
            end: DateTime(e.year, e.month, e.day),
          );
        }
        return DateTimeRange(
          start: today.subtract(const Duration(days: 6)),
          end: today,
        );
      case 'This Month':
      default:
        final start = DateTime(_currentMonth.year, _currentMonth.month, 1);
        final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
        final end = DateTime(_currentMonth.year, _currentMonth.month, daysInMonth);
        return DateTimeRange(start: start, end: end);
    }
  }

  // Generate contiguous daily array mapping dates to sum (excluding transfers)
  List<MapEntry<DateTime, double>> _getDailyDataPoints() {
    final allTransactions = widget.transactions ?? [];
    final range = _getActiveDateRange();
    final targetType = _graphMode == GraphMode.expense
        ? TransactionType.expense
        : TransactionType.income;

    // Filter by type (Expense / Income, excluding Transfer) & date range
    final activeRangeTxs = allTransactions.where((tx) {
      if (tx.type != targetType) return false;
      final txDate = DateTime(tx.timestamp.year, tx.timestamp.month, tx.timestamp.day);
      return !txDate.isBefore(range.start) && !txDate.isAfter(range.end);
    }).toList();

    // Contiguous list covering every single day
    final results = <MapEntry<DateTime, double>>[];
    var current = range.start;
    while (!current.isAfter(range.end)) {
      final dayTxs = activeRangeTxs.where((tx) =>
          tx.timestamp.year == current.year &&
          tx.timestamp.month == current.month &&
          tx.timestamp.day == current.day);
      final dayTotal = dayTxs.fold<double>(0.0, (sum, tx) => sum + tx.amount);
      results.add(MapEntry(current, dayTotal));
      current = current.add(const Duration(days: 1));
    }
    return results;
  }

  // Filter transactions for the active display range
  List<TransactionModel> _getDisplayTransactions() {
    final allTransactions = widget.transactions ?? [];
    final range = _getActiveDateRange();
    return allTransactions.where((tx) {
      final txDate = DateTime(tx.timestamp.year, tx.timestamp.month, tx.timestamp.day);
      return !txDate.isBefore(range.start) && !txDate.isAfter(range.end);
    }).toList();
  }

  // Filter transactions for the current month
  List<TransactionModel> _getMonthlyTransactions() {
    final allTransactions = widget.transactions ?? [];
    return allTransactions.where((tx) {
      return tx.timestamp.year == _currentMonth.year &&
          tx.timestamp.month == _currentMonth.month;
    }).toList();
  }

  // Group transactions by date
  Map<String, List<TransactionModel>> _groupTransactionsByDate(List<TransactionModel> transactions) {
    final Map<String, List<TransactionModel>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final tx in transactions) {
      final txDate = DateTime(tx.timestamp.year, tx.timestamp.month, tx.timestamp.day);
      String dateKey;

      if (txDate == today) {
        dateKey = 'Today';
      } else if (txDate == yesterday) {
        dateKey = 'Yesterday';
      } else {
        dateKey = DateFormat('dd MMMM yyyy').format(txDate);
      }

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(tx);
    }

    // Sort by date (most recent first)
    final sortedKeys = grouped.keys.toList();
    sortedKeys.sort((a, b) {
      if (a == 'Today') return -1;
      if (b == 'Today') return 1;
      if (a == 'Yesterday') return -1;
      if (b == 'Yesterday') return 1;

      try {
        final dateA = DateFormat('dd MMMM yyyy').parse(a);
        final dateB = DateFormat('dd MMMM yyyy').parse(b);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    final Map<String, List<TransactionModel>> sortedGrouped = {};
    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.billuColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencySymbol = StorageService.instance.getCurrencySymbol();

    // 1. Normalized contiguous daily array for chart
    final dailyEntries = _getDailyDataPoints();
    final dailyTotals = dailyEntries.map((e) => e.value).toList();
    final maxY = dailyTotals.isEmpty ? 0.0 : dailyTotals.reduce((a, b) => a > b ? a : b);

    // Active range transactions for active graph type
    final displayTransactions = _getDisplayTransactions();
    final targetType = _graphMode == GraphMode.expense
        ? TransactionType.expense
        : TransactionType.income;
    final activeTypeTransactions = displayTransactions.where((t) => t.type == targetType).toList();

    // Total for active period and type
    final totalActiveAmount = dailyTotals.fold<double>(0.0, (sum, val) => sum + val);

    // Monthly totals for budget health card
    final monthlyTransactions = _getMonthlyTransactions();
    final monthlyExpense = monthlyTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    // Group transactions by date for ledger section
    final groupedTransactions = _groupTransactionsByDate(displayTransactions);

    // Dynamic tooltip & active peak point calculation
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayIdx = dailyEntries.indexWhere((e) =>
        e.key.year == today.year &&
        e.key.month == today.month &&
        e.key.day == today.day);

    String? tooltipLabel;
    int? activeIndex;

    if (todayIdx != -1 && dailyTotals[todayIdx] > 0.0) {
      activeIndex = todayIdx;
      tooltipLabel = 'Today $currencySymbol${dailyTotals[todayIdx].toStringAsFixed(2)}';
    } else if (maxY > 0.0) {
      final peakIdx = dailyTotals.indexOf(maxY);
      activeIndex = peakIdx;
      final peakDate = dailyEntries[peakIdx].key;
      final dateStr = DateFormat('MMM d').format(peakDate);
      tooltipLabel = '$dateStr $currencySymbol${maxY.toStringAsFixed(2)}';
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),

          // Month Navigator (Above Everything)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left Arrow
              IconButton(
                onPressed: _decrementMonth,
                icon: Icon(
                  Icons.chevron_left,
                  size: 24,
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(4),
                  minimumSize: const Size(32, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 12),
              // Month Label
              Text(
                _getMonthLabel(),
                style: AppTypography.headlineMd(colors.onSurface).copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 12),
              // Right Arrow
              IconButton(
                onPressed: _incrementMonth,
                icon: Icon(
                  Icons.chevron_right,
                  size: 24,
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(4),
                  minimumSize: const Size(32, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
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
                // Total Spend Indicator & Graph Type Dropdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _graphMode == GraphMode.expense ? 'Total Spend' : 'Total Income',
                      style: AppTypography.labelCaps(colors.onSurfaceVariant).copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Expense / Income Dropdown
                    GestureDetector(
                      onTap: _showGraphTypeMenu,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainer.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colors.outline.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _graphMode == GraphMode.expense ? 'Expenses' : 'Income',
                              style: AppTypography.labelSubtle(colors.onSurface).copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: colors.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Amount Display + Currency Tag (Compacted)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      widget.isMasked
                          ? '$currencySymbol••••••'
                          : '$currencySymbol${totalActiveAmount.toStringAsFixed(2)}',
                      style: AppTypography.displayCurrencyMobile(colors.primary).copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      StorageService.instance.getCurrencyCode(),
                      style: AppTypography.labelCaps(colors.onSurfaceVariant).copyWith(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Baseline comparison (Compacted)
                Text(
                  activeTypeTransactions.isEmpty
                      ? 'No ${_graphMode == GraphMode.expense ? 'Spending' : 'Income'} Recorded This Period'
                      : '${activeTypeTransactions.length} Transaction${activeTypeTransactions.length == 1 ? '' : 's'} Tracked',
                  style: AppTypography.labelSubtle(colors.onSurfaceVariant).copyWith(
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 18),

                // Native Line Chart Canvas with 0-Baseline & Theme Awareness
                SizedBox(
                  width: double.infinity,
                  height: 160,
                  child: CustomPaint(
                    painter: SparklinePainter(
                      dataPoints: dailyTotals,
                      maxY: maxY,
                      isDark: isDark,
                      isExpense: _graphMode == GraphMode.expense,
                      tooltipLabel: tooltipLabel,
                      activeIndex: activeIndex,
                      lineColor: colors.primary,
                      gridLineColor: colors.outline,
                      pointColor: colors.primary,
                    ),
                  ),
                ),

                // Dynamic Numeric X-Axis Date Labels
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 2, right: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _getNumericDateLabels(colors, dailyEntries),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Time-Range Filter (Replacing Month Strip)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.surfaceContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: _timeRangeOptions.map((option) {
                final isSelected = option == _selectedTimeRange;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (option == 'Custom') {
                        _showCustomDatePicker();
                      } else {
                        setState(() => _selectedTimeRange = option);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        option,
                        style: AppTypography.labelSubtle(
                          isSelected ? colors.onPrimary : colors.onSurfaceVariant,
                        ).copyWith(
                          fontSize: 12,
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
                          'Envelope In Rhythm',
                          style: AppTypography.headlineMd(colors.primary).copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          monthlyTransactions.isEmpty
                              ? 'All Clear • No Expenses Yet'
                              : '$currencySymbol${(1000.0 - monthlyExpense).clamp(0.0, 99999.0).toStringAsFixed(2)} Buffer Remains',
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
                    monthlyTransactions.isEmpty ? '100%' : '${((1.0 - (monthlyExpense / 1000.0).clamp(0.0, 1.0)) * 100).toInt()}%',
                    style: AppTypography.labelCaps(colors.onSurface).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Ledger Section - Date-Grouped Transactions
          if (monthlyTransactions.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.surfaceContainer,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 38,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.45),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Recent Entries',
                    style: AppTypography.labelCaps(colors.onSurfaceVariant).copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap The + Button To Log Your First Transaction',
                    style: AppTypography.labelSubtle(colors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            // Date-Grouped Transaction Sections
            ...groupedTransactions.entries.map((entry) {
              final dateLabel = entry.key;
              final transactions = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTransactionSection(
                    context,
                    title: dateLabel,
                    transactions: transactions,
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }),
          ],
          const SizedBox(height: 32),

          // Subtle Receipt End Mark
          Center(
            child: Column(
              children: [
                Text(
                  'Billu Ledger • Offline Vault',
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

  Color _getTransactionAmountColor(TransactionType type, BilluColorsExtension colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (type) {
      case TransactionType.expense:
        return isDark ? Colors.redAccent : Colors.red;
      case TransactionType.income:
        return isDark ? Colors.greenAccent : Colors.green;
      case TransactionType.transfer:
        return isDark ? Colors.blueAccent : Colors.blue;
    }
  }

  String _formatTransactionAmount(TransactionModel tx, bool isMasked, BilluColorsExtension colors) {
    final currencySymbol = StorageService.instance.getCurrencySymbol();
    if (isMasked) {
      return '$currencySymbol•••';
    }
    return '$currencySymbol${tx.amount.toStringAsFixed(2)}';
  }

  Widget _buildTransactionSection(
    BuildContext context, {
    required String title,
    required List<TransactionModel> transactions,
  }) {
    final colors = context.billuColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
          child: Text(
            title,
            style: AppTypography.labelCaps(colors.onSurfaceVariant).copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
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
              final amountColor = _getTransactionAmountColor(tx.type, colors);
              final formattedAmount = _formatTransactionAmount(tx, widget.isMasked, colors);
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
                        formattedAmount,
                        style: AppTypography.numericTabular(amountColor).copyWith(
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

  // Helper methods for month navigation
  void _decrementMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _selectedTimeRange = 'This Month';
    });
  }

  void _incrementMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _selectedTimeRange = 'This Month';
    });
  }

  String _getMonthLabel() {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[_currentMonth.month - 1]} ${_currentMonth.year}';
  }

  // Dynamic numeric date labels based on contiguous daily entries
  List<Widget> _getNumericDateLabels(dynamic colors, List<MapEntry<DateTime, double>> entries) {
    if (entries.isEmpty) return [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final labelStyle = AppTypography.labelCaps(colors.onSurfaceVariant).copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );
    final todayStyle = labelStyle.copyWith(
      color: colors.primary,
      fontWeight: FontWeight.w700,
    );

    List<int> labelIndices;
    if (entries.length <= 7) {
      labelIndices = List.generate(entries.length, (i) => i);
    } else if (entries.length <= 16) {
      labelIndices = [
        0,
        (entries.length * 0.25).round(),
        (entries.length * 0.5).round(),
        (entries.length * 0.75).round(),
        entries.length - 1,
      ];
    } else {
      labelIndices = [
        0,
        6,
        13,
        20,
        27,
        entries.length - 1,
      ].where((i) => i < entries.length).toList();
    }

    return labelIndices.map((idx) {
      final date = entries[idx].key;
      final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
      return Text(
        date.day.toString(),
        style: isToday ? todayStyle : labelStyle,
      );
    }).toList();
  }

  // Show graph type selection menu
  void _showGraphTypeMenu() {
    final colors = context.billuColors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final options = [
          {'label': 'Expenses', 'mode': GraphMode.expense},
          {'label': 'Income', 'mode': GraphMode.income},
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((opt) {
                final isCurrent = opt['mode'] == _graphMode;
                return ListTile(
                  title: Text(
                    opt['label'] as String,
                    style: AppTypography.bodyMd(colors.onSurface).copyWith(
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  trailing: isCurrent
                      ? Icon(Icons.check_rounded, color: colors.primary, size: 20)
                      : null,
                  onTap: () {
                    setState(() => _graphMode = opt['mode'] as GraphMode);
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

  // Show custom date range picker
  Future<void> _showCustomDatePicker() async {
    final now = DateTime.now();
    final initialRange = _customDateRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 6)),
          end: now,
        );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedTimeRange = 'Custom';
      });
    }
  }
}

