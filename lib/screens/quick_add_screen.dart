import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/app_header.dart';

class QuickAddScreen extends StatefulWidget {
  final Function(TransactionModel)? onAddTransaction;
  final List<AccountModel>? accounts;
  final Function(String accountId, double amount, bool isExpense)? onUpdateBalance;

  const QuickAddScreen({
    super.key,
    this.onAddTransaction,
    this.accounts,
    this.onUpdateBalance,
  });

  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  TransactionType _selectedType = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();
  String _currentInput = '';
  String _expression = '';
  String _selectedCategory = 'General';
  String _categoryEmoji = '🏷️';
  String? _selectedAccountId;
  String? _toAccountId; // Destination account for transfers
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Select first account by default
    if (widget.accounts != null && widget.accounts!.isNotEmpty) {
      _selectedAccountId = widget.accounts!.first.id;
      // Default toAccount to second account if available
      if (widget.accounts!.length > 1) {
        _toAccountId = widget.accounts![1].id;
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // Generate 5-day date strip centered on selected date
  List<Map<String, dynamic>> _getDateStrip() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return List.generate(5, (i) {
      final d = _selectedDate.subtract(Duration(days: 2 - i));
      return {
        'date': d,
        'day': d.day.toString(),
        'weekday': weekdays[d.weekday - 1],
      };
    });
  }

  void _onKeyPress(String key) {
    setState(() {
      if (key == 'C') {
        _currentInput = '';
        _expression = '';
      } else if (['+', '-', '×', '÷'].contains(key)) {
        if (_currentInput.isNotEmpty) {
          _expression += '$_currentInput $key ';
          _currentInput = '';
        }
      } else if (key == '=') {
        _evaluateExpression();
      } else if (key == '.') {
        if (!_currentInput.contains('.')) {
          if (_currentInput.isEmpty) {
            _currentInput = '0.';
          } else {
            _currentInput += '.';
          }
        }
      } else {
        // Number key
        if (_currentInput.isEmpty && key == '0') {
          // Don't allow leading zeros
          return;
        }
        if (_currentInput.length < 12) {
          _currentInput += key;
        }
      }
    });
  }

  void _evaluateExpression() {
    if (_expression.isEmpty) return;

    try {
      String fullExpr = '$_expression$_currentInput';
      fullExpr = fullExpr.replaceAll('×', '*').replaceAll('÷', '/');

      // Simple expression evaluator
      List<String> tokens = fullExpr.split(' ');
      if (tokens.length < 3) return;

      double result = double.parse(tokens[0]);

      for (int i = 1; i < tokens.length - 1; i += 2) {
        String operator = tokens[i];
        double operand = double.parse(tokens[i + 1]);

        switch (operator) {
          case '+':
            result += operand;
            break;
          case '-':
            result -= operand;
            break;
          case '*':
            result *= operand;
            break;
          case '/':
            if (operand != 0) result /= operand;
            break;
        }
      }

      _currentInput = result.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
      _expression = '';
    } catch (e) {
      _currentInput = '';
      _expression = '';
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'groceries':
        return Icons.shopping_cart_outlined;
      case 'coffee & drinks':
      case 'coffee':
        return Icons.local_cafe_outlined;
      case 'dining & food':
      case 'dining':
        return Icons.restaurant_outlined;
      case 'transit & commute':
      case 'transit':
      case 'commute':
        return Icons.directions_subway_outlined;
      case 'shopping':
        return Icons.local_mall_outlined;
      case 'rent & utilities':
        return Icons.home_outlined;
      case 'entertainment':
        return Icons.movie_outlined;
      case 'pet care':
        return Icons.pets_outlined;
      case 'salary':
        return Icons.work_outline_rounded;
      case 'room rent':
        return Icons.real_estate_agent_outlined;
      case 'coupon':
        return Icons.confirmation_number_outlined;
      case 'cashback':
        return Icons.savings_outlined;
      case 'given':
      case 'lent/returned':
        return Icons.volunteer_activism_outlined;
      case 'investment':
        return Icons.trending_up_rounded;
      case 'other income':
        return Icons.attach_money_rounded;
      default:
        return Icons.receipt_outlined;
    }
  }

  void _onSubmit() {
    final amount = double.tryParse(_currentInput) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    // Validate transfer: must have two different accounts
    if (_selectedType == TransactionType.transfer) {
      if (_selectedAccountId == null || _toAccountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both From and To accounts')),
        );
        return;
      }
      if (_selectedAccountId == _toAccountId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('From and To accounts must be different')),
        );
        return;
      }
    }

    // Combine selected date with current time
    final now = DateTime.now();
    final transactionTimestamp = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );

    // Resolve account names for transfer display
    String txTitle;
    String txSubtitle;
    IconData txIcon;

    if (_selectedType == TransactionType.transfer) {
      final fromName = _getAccountName(_selectedAccountId);
      final toName = _getAccountName(_toAccountId);
      txTitle = 'Transfer';
      txSubtitle = '$fromName → $toName';
      txIcon = Icons.swap_horiz_rounded;
    } else {
      txTitle = _selectedCategory;
      txSubtitle = _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : 'Quick Entry';
      txIcon = _getCategoryIcon(_selectedCategory);
    }

    final newTx = TransactionModel(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      title: txTitle,
      subtitle: txSubtitle,
      amount: amount,
      type: _selectedType,
      icon: txIcon,
      group: TransactionModel.getGroupFromTimestamp(transactionTimestamp),
      timestamp: transactionTimestamp,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      accountId: _selectedAccountId,
      toAccount: _selectedType == TransactionType.transfer ? _toAccountId : null,
    );

    // Update account balances
    if (widget.onUpdateBalance != null) {
      switch (_selectedType) {
        case TransactionType.expense:
          if (_selectedAccountId != null) {
            widget.onUpdateBalance!(_selectedAccountId!, amount, true); // deduct
          }
          break;
        case TransactionType.income:
          if (_selectedAccountId != null) {
            widget.onUpdateBalance!(_selectedAccountId!, amount, false); // add
          }
          break;
        case TransactionType.transfer:
          if (_selectedAccountId != null) {
            widget.onUpdateBalance!(_selectedAccountId!, amount, true); // deduct from source
          }
          if (_toAccountId != null) {
            widget.onUpdateBalance!(_toAccountId!, amount, false); // add to destination
          }
          break;
      }
    }

    widget.onAddTransaction?.call(newTx);
    Navigator.maybePop(context);
  }

  String _getAccountName(String? accountId) {
    if (accountId == null || widget.accounts == null) return 'Unknown';
    final acc = widget.accounts!.where((a) => a.id == accountId);
    return acc.isNotEmpty ? acc.first.name : 'Unknown';
  }

  Future<void> _showDatePicker() async {
    final colors = context.billuColors;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: colors.primary,
              onPrimary: colors.onPrimary,
              surface: colors.surfaceContainerLowest,
              onSurface: colors.onSurface,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: colors.surfaceContainerLowest,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.billuColors;
    final dateStrip = _getDateStrip();

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppHeader(
        showBack: true,
        onBack: () => Navigator.maybePop(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Section (scrollable if needed)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    // Top Controls Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colors.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: colors.onSurface,
                            ),
                          ),
                        ),

                        // Expense / Income / Transfer Toggle
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainer,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildTypeSegment('Expense', TransactionType.expense),
                              _buildTypeSegment('Income', TransactionType.income),
                              _buildTypeSegment('Transfer', TransactionType.transfer),
                            ],
                          ),
                        ),

                        const SizedBox(width: 40), // Balance right side
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Horizontal Interactive Date Strip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ...dateStrip.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;
                          final itemDate = item['date'] as DateTime;
                          final isSelected = idx == 2; // Middle one is always selected

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDate = itemDate;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: EdgeInsets.symmetric(
                                horizontal: isSelected ? 16 : 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? colors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item['day']!,
                                    style: AppTypography.numericSm(
                                      isSelected ? colors.onPrimary : colors.secondary,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    item['weekday']!,
                                    style: AppTypography.labelCaps(
                                      isSelected ? colors.onPrimary : colors.secondary,
                                    ).copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        // Calendar Icon Button
                        GestureDetector(
                          onTap: _showDatePicker,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: colors.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Amount Display (Clean - No $ or USD)
                    Column(
                      children: [
                        if (_expression.isNotEmpty) ...[
                          Text(
                            _expression,
                            style: AppTypography.bodyMd(colors.secondary).copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _currentInput.isEmpty ? '0' : _currentInput,
                              style: AppTypography.displayCurrencyMobile(
                                _currentInput.isEmpty ? colors.onSurface.withValues(alpha: 0.3) : colors.onSurface,
                              ).copyWith(
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Blinking cursor
                            Container(
                              width: 2.5,
                              height: 40,
                              color: colors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Account Selector & Category/Transfer UI
                    if (widget.accounts != null && widget.accounts!.isNotEmpty) ...[
                      // From Account Selector (shown for all types)
                      _buildAccountPill(
                        label: _selectedType == TransactionType.transfer ? 'From:' : (_selectedType == TransactionType.expense ? 'From:' : 'To:'),
                        accountId: _selectedAccountId,
                        onTap: () => _showAccountPicker(isFrom: true),
                      ),
                      const SizedBox(height: 10),

                      // To Account Selector (only for Transfer)
                      if (_selectedType == TransactionType.transfer) ...[
                        _buildAccountPill(
                          label: 'To:',
                          accountId: _toAccountId,
                          onTap: () => _showAccountPicker(isFrom: false),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],

                    // Category Selector Pill (hidden for Transfer)
                    if (_selectedType != TransactionType.transfer) ...[
                      GestureDetector(
                        onTap: _showCategoryPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_categoryEmoji, style: const TextStyle(fontSize: 15)),
                              const SizedBox(width: 6),
                              Text(
                                _selectedCategory,
                                style: AppTypography.labelCaps(colors.onPrimary).copyWith(
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: colors.onPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Note Field (Simple, Clean)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: colors.outline.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: TextField(
                        controller: _noteController,
                        style: AppTypography.bodyMd(colors.onSurface).copyWith(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Add A Note...',
                          hintStyle: AppTypography.bodyMd(colors.secondary.withValues(alpha: 0.6)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Calculator Keypad (Anchored to Bottom)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(
                  top: BorderSide(
                    color: colors.surfaceContainer,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildKeypadRow(['7', '8', '9', '÷']),
                  const SizedBox(height: 12),
                  _buildKeypadRow(['4', '5', '6', '×']),
                  const SizedBox(height: 12),
                  _buildKeypadRow(['1', '2', '3', '-']),
                  const SizedBox(height: 12),
                  _buildKeypadRow(['C', '0', '.', '+']),
                  const SizedBox(height: 12),
                  // Bottom Row: Equals + Submit
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildCalcButton('=', isEquals: true),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _onSubmit,
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primary.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.check_rounded,
                              size: 28,
                              color: colors.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSegment(String label, TransactionType type) {
    final colors = context.billuColors;
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        if (_selectedType != type) {
          setState(() {
            _selectedType = type;
            if (type == TransactionType.expense) {
              _selectedCategory = 'General';
              _categoryEmoji = '🏷️';
            } else if (type == TransactionType.income) {
              _selectedCategory = 'Salary';
              _categoryEmoji = '💼';
            }
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: AppTypography.labelCaps(
            isSelected ? colors.onPrimary : colors.secondary,
          ).copyWith(fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      children: keys.asMap().entries.map((entry) {
        final key = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: entry.key < keys.length - 1 ? 12 : 0),
            child: _buildCalcButton(key),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalcButton(String key, {bool isEquals = false}) {
    final colors = context.billuColors;
    final isOperator = ['+', '-', '×', '÷', '='].contains(key);
    final isClear = key == 'C';

    Color bgColor;
    Color textColor;

    if (isClear) {
      bgColor = colors.error.withValues(alpha: 0.15);
      textColor = colors.error;
    } else if (isOperator || isEquals) {
      bgColor = colors.primary.withValues(alpha: 0.15);
      textColor = colors.primary;
    } else {
      bgColor = colors.surfaceContainer;
      textColor = colors.onSurface;
    }

    return GestureDetector(
      onTap: () => _onKeyPress(key),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          key,
          style: AppTypography.headlineMd(textColor).copyWith(
            fontSize: isEquals ? 26 : 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountPill({
    required String label,
    required String? accountId,
    required VoidCallback onTap,
  }) {
    final colors = context.billuColors;
    final accountName = _getAccountName(accountId);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelCaps(colors.onSurfaceVariant).copyWith(
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              accountName,
              style: AppTypography.bodyMd(colors.onSurface).copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountPicker({required bool isFrom}) {
    final colors = context.billuColors;
    final accounts = widget.accounts ?? [];

    // For the "To" account picker in transfer mode, filter out the currently selected "From" account
    final filteredAccounts = isFrom
        ? accounts
        : accounts.where((a) => a.id != _selectedAccountId).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isFrom ? 'From Account' : 'To Account',
                        style: AppTypography.headlineMd(colors.onSurface),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                ...filteredAccounts.map((acc) {
                  final isSelected = isFrom
                      ? acc.id == _selectedAccountId
                      : acc.id == _toAccountId;
                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary.withValues(alpha: 0.15)
                            : colors.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        acc.icon,
                        size: 18,
                        color: isSelected ? colors.primary : colors.onSurfaceVariant,
                      ),
                    ),
                    title: Text(
                      acc.name,
                      style: AppTypography.bodyMd(colors.onSurface).copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    subtitle: Text(
                      acc.formattedBalance,
                      style: AppTypography.numericSm(colors.onSurfaceVariant),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_rounded, size: 20, color: colors.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        if (isFrom) {
                          _selectedAccountId = acc.id;
                          // If from and to are now the same, clear toAccountId
                          if (_toAccountId == acc.id && _selectedType == TransactionType.transfer) {
                            _toAccountId = accounts
                                .where((a) => a.id != acc.id)
                                .map((a) => a.id)
                                .firstOrNull;
                          }
                        } else {
                          _toAccountId = acc.id;
                        }
                      });
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCategoryPicker() {
    final colors = context.billuColors;
    final categories = _selectedType == TransactionType.income
        ? [
            {'emoji': '💼', 'name': 'Salary'},
            {'emoji': '🏠', 'name': 'Room Rent'},
            {'emoji': '🎟️', 'name': 'Coupon'},
            {'emoji': '🪙', 'name': 'Cashback'},
            {'emoji': '🤝', 'name': 'Given'},
            {'emoji': '📈', 'name': 'Investment'},
            {'emoji': '💵', 'name': 'Other Income'},
          ]
        : [
            {'emoji': '🏷️', 'name': 'General'},
            {'emoji': '🛒', 'name': 'Groceries'},
            {'emoji': '☕', 'name': 'Coffee & Drinks'},
            {'emoji': '🍽️', 'name': 'Dining & Food'},
            {'emoji': '🚇', 'name': 'Transit & Commute'},
            {'emoji': '🛍️', 'name': 'Shopping'},
            {'emoji': '🏠', 'name': 'Rent & Utilities'},
            {'emoji': '🎬', 'name': 'Entertainment'},
            {'emoji': '🐾', 'name': 'Pet Care'},
          ];

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Category',
                        style: AppTypography.headlineMd(colors.onSurface),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                ...categories.map((c) {
                  return ListTile(
                    leading: Text(c['emoji']!, style: const TextStyle(fontSize: 22)),
                    title: Text(
                      c['name']!,
                      style: AppTypography.bodyMd(colors.onSurface),
                    ),
                    onTap: () {
                      setState(() {
                        _categoryEmoji = c['emoji']!;
                        _selectedCategory = c['name']!;
                      });
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
