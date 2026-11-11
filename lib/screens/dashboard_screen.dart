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
  String _selectedTimeRange = 'this month';
  final List<String> _timeRangeOptions = ['7 days', '15 days', 'this month', 'custom'];
  GraphMode _graphMode = GraphMode.expense;

  @override
  void initState() {
    super.initState();
    // Initialize to current device month and year
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
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

    // Filter transactions for current month
    final monthlyTransactions = _getMonthlyTransactions();

    // Calculate totals for current month
    final totalExpense = monthlyTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final totalIncome = monthlyTransactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    // Group transactions by date
    final groupedTransactions = _groupTransactionsByDate(monthlyTransactions);

    // Get today's transactions for tooltip
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayTransactions = monthlyTransactions.where((t) {
      final txDate = DateTime(t.timestamp.year, t.timestamp.month, t.timestamp.day);
      return txDate == today;
    }).toList();

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
                      'TOTAL SPEND',
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
                          : '$currencySymbol${(_graphMode == GraphMode.expense ? totalExpense : totalIncome).toStringAsFixed(2)}',
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
                  monthlyTransactions.isEmpty
                      ? 'No spending recorded this period'
                      : '${monthlyTransactions.length} Transaction${monthlyTransactions.length == 1 ? '' : 's'} tracked',
                  style: AppTypography.labelSubtle(colors.onSurfaceVariant).copyWith(
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 18),

                // Sparkline Canvas (Expanded Height)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Canvas Sparkline (Increased from 84 to 160)
                    SizedBox(
                      width: double.infinity,
                      height: 160,
                      child: CustomPaint(
                        painter: SparklinePainter(
                          lineColor: colors.primary,
                          gridLineColor: colors.outline,
                          pointColor: colors.primary,
                          isDark: isDark,
                          hasData: monthlyTransactions.isNotEmpty,
                          dataPoints: _generateDataPoints(monthlyTransactions),
                        ),
                      ),
                    ),

                    if (monthlyTransactions.isNotEmpty && todayTransactions.isNotEmpty)
                      Positioned(
                        top: 8,
                        left: 190,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Vertical indicator line
                            Container(
                              width: 1,
                              height: 20,
                              color: colors.primary.withValues(alpha: 0.4),
                            ),
                            // Tooltip badge
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
                                'today \$${todayTransactions.fold<double>(0.0, (s, t) => s + t.amount).toStringAsFixed(2)}',
                                style: AppTypography.labelCaps(colors.onPrimary).copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                // Dynamic Numeric X-Axis Date Labels
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 2, right: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _getNumericDateLabels(colors),
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
                      if (option == 'custom') {
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
                          'envelope in rhythm',
                          style: AppTypography.headlineMd(colors.primary).copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          monthlyTransactions.isEmpty
                              ? 'All Clear • No Expenses Yet'
                              : '$currencySymbol${(1000.0 - totalExpense).clamp(0.0, 99999.0).toStringAsFixed(2)} Buffer Remains',
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
                    monthlyTransactions.isEmpty ? '100%' : '${((1.0 - (totalExpense / 1000.0).clamp(0.0, 1.0)) * 100).toInt()}%',
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
                    'NO RECENT ENTRIES',
                    style: AppTypography.labelCaps(colors.onSurfaceVariant).copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap the + button to log your first transaction',
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
                  'BILLU LEDGER • OFFLINE VAULT',
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
    required List<TransactionModel> transactions,
  }) {
    final colors = context.billuColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
          child: Text(
            title.toUpperCase(),
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

  // Helper methods for month navigation
  void _decrementMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _incrementMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  String _getMonthLabel() {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[_currentMonth.month - 1]} ${_currentMonth.year}';
  }

  // Generate numeric date labels based on selected range
  List<Widget> _getNumericDateLabels(dynamic colors) {
    final now = DateTime.now();
    final labelStyle = AppTypography.labelCaps(colors.onSurfaceVariant).copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );
    final todayStyle = labelStyle.copyWith(
      color: colors.primary,
      fontWeight: FontWeight.w700,
    );

    switch (_selectedTimeRange) {
      case '7 days':
        // Show all 7 consecutive days
        final startDay = now.day - 6;
        return List.generate(7, (i) {
          final day = startDay + i;
          final isToday = i == 6;
          return Text(
            day.toString(),
            style: isToday ? todayStyle : labelStyle,
          );
        });

      case '15 days':
        // Sample with interval ~3-4 days: 5 ticks
        final days = [
          now.day - 14, // 15 days ago
          now.day - 10,
          now.day - 6,
          now.day - 3,
          now.day, // today
        ];
        return days.asMap().entries.map((e) {
          final isToday = e.key == days.length - 1;
          return Text(
            e.value.clamp(1, 31).toString(),
            style: isToday ? todayStyle : labelStyle,
          );
        }).toList();

      case 'this month':
      default:
        // Sample with interval ~6-7 days across month
        final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
        final labels = [
          1,
          7,
          14,
          21,
          28,
          daysInMonth, // last day of month
        ];
        return labels.map((day) {
          final isToday = day == now.day && _currentMonth.month == now.month && _currentMonth.year == now.year;
          return Text(
            day.toString(),
            style: isToday ? todayStyle : labelStyle,
          );
        }).toList();
    }
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

  // Generate data points for the graph
  List<double> _generateDataPoints(List<TransactionModel> transactions) {
    if (transactions.isEmpty) return [];

    // Generate sample data based on selected range
    switch (_selectedTimeRange) {
      case '7 days':
        return [0.0, 15.0, 25.0, 10.0, 30.0, 45.0, 52.0];
      case '15 days':
        return [0.0, 10.0, 20.0, 15.0, 25.0, 30.0, 20.0, 35.0, 40.0, 30.0, 45.0, 50.0, 48.0, 55.0, 52.0];
      case 'this month':
      default:
        // Generate monthly data (30 days)
        return List.generate(30, (i) {
          if (i < 5) return 0.0; // First few days flat at baseline
          return (i * 2.0) + (i % 3 * 5.0); // Varied spending pattern
        });
    }
  }

  // Show custom date range picker
  void _showCustomDatePicker() {
    final colors = context.billuColors;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Custom Date Range',
          style: AppTypography.headlineMd(colors.onSurface),
        ),
        content: Text(
          'Custom date picker coming soon',
          style: AppTypography.bodyMd(colors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTypography.bodyMd(colors.primary).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

