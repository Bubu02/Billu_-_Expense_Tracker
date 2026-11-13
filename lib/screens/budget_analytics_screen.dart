import 'package:flutter/material.dart';
import '../core/database/db_helper.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/donut_chart_painter.dart';

class BudgetAnalyticsScreen extends StatefulWidget {
  final List<TransactionModel>? transactions;

  const BudgetAnalyticsScreen({
    super.key,
    this.transactions,
  });

  @override
  State<BudgetAnalyticsScreen> createState() => _BudgetAnalyticsScreenState();
}

class _BudgetAnalyticsScreenState extends State<BudgetAnalyticsScreen> {
  String _selectedPeriod = 'Monthly';
  DateTimeRange? _customDateRange;
  List<BudgetCategory> _categories = [];
  bool _isLoading = true;

  static const _darkMonochromeShades = [
    Color(0xFFFFFFFF),
    Color(0xFFD4D4D4),
    Color(0xFFA3A3A3),
    Color(0xFF737373),
    Color(0xFF525252),
    Color(0xFF404040),
    Color(0xFF2E2E2E),
  ];

  static const _lightMonochromeShades = [
    Color(0xFF000000),
    Color(0xFF2C2C2C),
    Color(0xFF4B4B4B),
    Color(0xFF6E6E6E),
    Color(0xFF919191),
    Color(0xFFB5B5B5),
    Color(0xFFD8D8D8),
  ];

  @override
  void initState() {
    super.initState();
    _loadCategoryData();
  }

  @override
  void didUpdateWidget(covariant BudgetAnalyticsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != widget.transactions) {
      _loadCategoryData();
    }
  }

  List<TransactionModel> _getFilteredTransactions() {
    final all = widget.transactions ?? [];
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'Weekly':
        final startOfWeek = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return all.where((t) => !t.timestamp.isBefore(startOfWeek) && !t.timestamp.isAfter(endOfToday)).toList();
      case 'Custom':
        if (_customDateRange != null) {
          final start = DateTime(_customDateRange!.start.year, _customDateRange!.start.month, _customDateRange!.start.day);
          final end = DateTime(_customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day, 23, 59, 59);
          return all.where((t) => !t.timestamp.isBefore(start) && !t.timestamp.isAfter(end)).toList();
        }
        return all;
      case 'Monthly':
      default:
        return all.where((t) => t.timestamp.year == now.year && t.timestamp.month == now.month).toList();
    }
  }

  Future<void> _loadCategoryData() async {
    final db = DBHelper.instance;

    // Get all expense categories from SQLite
    final allCategoryRows = await db.getAllCategories();
    final allCategories = allCategoryRows.where((row) => row['type'] == 'expense').toList();

    // Sum transactions by category for the active period
    final filteredTransactions = _getFilteredTransactions();
    final expenseTransactions = filteredTransactions.where((t) => t.isExpense).toList();

    final spendingMap = <String, double>{};
    for (final tx in expenseTransactions) {
      final key = tx.title.trim().toLowerCase();
      spendingMap[key] = (spendingMap[key] ?? 0.0) + tx.amount;
    }

    final List<BudgetCategory> loadedCategories = [];
    for (final category in allCategories) {
      final name = category['name'] as String? ?? 'General';
      final spent = spendingMap[name.trim().toLowerCase()] ?? 0.0;
      final rawBudget = category['monthly_budget'];
      final double? budgetVal = (rawBudget is num && rawBudget > 0) ? rawBudget.toDouble() : null;

      final iconCode = category['icon'];
      final iconData = iconCode is int
          ? IconData(
              // ignore: non_const_argument_for_const_parameter
              iconCode,
              fontFamily: 'MaterialIcons',
            )
          : Icons.receipt_outlined;

      loadedCategories.add(BudgetCategory(
        id: category['id'].toString(),
        title: name,
        spent: spent,
        limit: budgetVal,
        icon: iconData,
      ));
    }

    if (mounted) {
      setState(() {
        _categories = loadedCategories;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateCategoryBudget(String categoryId, double? newLimit) async {
    final db = DBHelper.instance;
    final id = int.tryParse(categoryId);
    if (id != null) {
      await db.updateCategoryBudget(id, newLimit);
      await _loadCategoryData();
    }
  }

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
        _selectedPeriod = 'Custom';
      });
      await _loadCategoryData();
    }
  }

  Future<void> _showBudgetDialog(BudgetCategory category) async {
    final colors = context.billuColors;
    final currentLimit = category.limit;

    final TextEditingController amountController = TextEditingController(
      text: currentLimit != null && currentLimit > 0
          ? currentLimit.toStringAsFixed(2)
          : '',
    );

    final result = await showDialog<double?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Set Budget • ${category.title}',
            style: AppTypography.headlineMd(colors.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Spend: \$${category.spent.toStringAsFixed(2)}',
                style: AppTypography.bodyMd(colors.onSurface),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTypography.bodyMd(colors.onSurface),
                decoration: InputDecoration(
                  labelText: 'Monthly Budget Limit',
                  labelStyle: AppTypography.labelSubtle(colors.onSurfaceVariant),
                  hintText: 'e.g., 200.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.outlineVariant),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (category.hasBudget)
              TextButton(
                onPressed: () => Navigator.pop(context, 0.0), // 0.0 signals clearing limit
                child: Text(
                  'Clear Limit',
                  style: TextStyle(color: colors.error),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(amountController.text.trim());
                if (value != null && value > 0) {
                  Navigator.pop(context, value);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      if (result <= 0) {
        await _updateCategoryBudget(category.id, null);
      } else {
        await _updateCategoryBudget(category.id, result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.billuColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredTransactions = _getFilteredTransactions();
    final expenseTransactions = filteredTransactions.where((t) => t.isExpense).toList();

    final totalSpent = expenseTransactions.fold<double>(0.0, (sum, t) => sum + t.amount);

    final categoryTotals = <String, double>{};
    for (final tx in expenseTransactions) {
      categoryTotals[tx.title] = (categoryTotals[tx.title] ?? 0.0) + tx.amount;
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final segments = <DonutSegment>[];
    for (int i = 0; i < sortedEntries.length; i++) {
      final e = sortedEntries[i];
      final pct = totalSpent > 0 ? e.value / totalSpent : 0.0;
      final darkColor = _darkMonochromeShades[i % _darkMonochromeShades.length];
      final lightColor = _lightMonochromeShades[i % _lightMonochromeShades.length];

      segments.add(DonutSegment(
        title: e.key,
        percentage: pct,
        amount: e.value,
        lightColor: lightColor,
        darkColor: darkColor,
      ));
    }

    // Calculate total budget cap from active categories
    final totalBudgetCap = _categories.fold<double>(0.0, (sum, c) => sum + (c.limit ?? 0.0));

    // Filter categories with alerts (spent >= 80% of limit)
    final alertCategories = _categories.where((c) => c.shouldShowAlert).toList();
    final hasAlerts = alertCategories.isNotEmpty;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  children: ['Weekly', 'Monthly', 'Custom'].map((period) {
                    final isSelected = period == _selectedPeriod;
                    return GestureDetector(
                      onTap: () {
                        if (period == 'Custom') {
                          _showCustomDatePicker();
                        } else {
                          setState(() => _selectedPeriod = period);
                          _loadCategoryData();
                        }
                      },
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

          // Alert Pill - Only shown when budget thresholds are crossed
          if (hasAlerts) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: colors.error.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_rounded,
                    size: 16,
                    color: colors.error,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Alert: ${alertCategories.map((c) => c.title).join(', ')}',
                      style: AppTypography.numericSm(colors.error).copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

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
                          segments: segments,
                          trackColor: colors.surfaceContainer,
                          isDark: isDark,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedPeriod == 'Weekly'
                                ? 'Week Total'
                                : _selectedPeriod == 'Custom'
                                    ? 'Period Total'
                                    : 'Month Total',
                            style: AppTypography.labelCaps(colors.secondary).copyWith(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\$${totalSpent.toStringAsFixed(totalSpent.truncateToDouble() == totalSpent ? 0 : 2)}',
                            style: AppTypography.displayCurrencyMobile(colors.primary).copyWith(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            totalBudgetCap > 0
                                ? 'of \$${totalBudgetCap.toStringAsFixed(totalBudgetCap.truncateToDouble() == totalBudgetCap ? 0 : 2)} Budget Cap'
                                : 'No Budget Cap',
                            style: AppTypography.labelSubtle(colors.outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Category Proportional Legend Cards (2x2 Grid) or Placeholder
                if (segments.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Text(
                        'No Category Breakdown Available',
                        style: AppTypography.labelSubtle(colors.onSurfaceVariant),
                      ),
                    ),
                  ),
                ] else ...[
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.6,
                    children: segments.map((segment) {
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
                                    '${(segment.percentage * 100).toInt()}% · \$${segment.amount.toStringAsFixed(segment.amount.truncateToDouble() == segment.amount ? 0 : 2)}',
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
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Category Budget Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category Budgets',
                style: AppTypography.headlineMd(colors.primary).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_categories.where((c) => c.hasBudget).length} Active Caps',
                style: AppTypography.labelSubtle(colors.secondary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_categories.isEmpty)
            _buildNoCategoriesPlaceholder(colors)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return _buildCategoryBudgetRow(cat, colors, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNoCategoriesPlaceholder(BilluColorsExtension colors) {
    return Container(
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
            Icons.pie_chart_outline_rounded,
            size: 38,
            color: colors.onSurfaceVariant.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 12),
          Text(
            'No Categories Yet',
            style: AppTypography.labelCaps(colors.onSurfaceVariant).copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Categories will appear here as you track expenses',
            style: AppTypography.labelSubtle(colors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBudgetRow(
    BudgetCategory cat,
    BilluColorsExtension colors,
    bool isDark,
  ) {
    final hasBudget = cat.hasBudget;
    final percent = cat.percentage;

    return GestureDetector(
      onTap: () async {
        await _showBudgetDialog(cat);
      },
      child: Container(
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
                        text: '\$${cat.spent.toStringAsFixed(cat.spent.truncateToDouble() == cat.spent ? 0 : 2)}',
                        style: AppTypography.numericTabular(colors.primary).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: hasBudget
                            ? ' / \$${cat.limit!.toStringAsFixed(cat.limit!.truncateToDouble() == cat.limit! ? 0 : 2)}'
                            : ' / Set Budget',
                        style: AppTypography.labelSubtle(colors.secondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress Track (only shown when budget is set)
            if (hasBudget) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: colors.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percent >= 1.0 ? colors.error : colors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Alert indicator row
            if (cat.shouldShowAlert)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: colors.error.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          size: 12,
                          color: colors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(percent * 100).toInt()}%',
                          style: AppTypography.labelCaps(colors.error).copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
