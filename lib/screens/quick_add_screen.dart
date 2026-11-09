import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/app_header.dart';

class QuickAddScreen extends StatefulWidget {
  final Function(TransactionModel)? onAddTransaction;

  const QuickAddScreen({super.key, this.onAddTransaction});

  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  TransactionType _selectedType = TransactionType.expense;
  int _selectedDayIndex = 2; // today
  String _currentInput = '0';
  String _expression = '';
  String _selectedCategory = 'general';
  String _categoryEmoji = '🏷️';
  final TextEditingController _noteController = TextEditingController();

  late final List<Map<String, String>> _dateStrip;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    const weekdays = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    _dateStrip = List.generate(5, (i) {
      final d = now.subtract(Duration(days: 2 - i));
      return {
        'day': d.day.toString(),
        'weekday': weekdays[d.weekday - 1],
      };
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onKeyPress(String key) {
    setState(() {
      if (key == 'C') {
        _currentInput = '0';
        _expression = '';
      } else if (['+', '-', '×', '÷'].contains(key)) {
        if (_currentInput != '0' && _currentInput.isNotEmpty) {
          _expression += '$_currentInput $key ';
          _currentInput = '0';
        }
      } else if (key == '=') {
        _evaluateExpression();
      } else if (key == '.') {
        if (!_currentInput.contains('.')) {
          if (_currentInput == '0' || _currentInput.isEmpty) {
            _currentInput = '0.';
          } else {
            _currentInput += '.';
          }
        }
      } else {
        // Number key
        if (_currentInput == '0') {
          _currentInput = key;
        } else if (_currentInput.length < 12) {
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
      _currentInput = '0';
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

    final newTx = TransactionModel(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      title: _selectedCategory,
      subtitle: _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : 'quick entry',
      amount: amount,
      type: _selectedType,
      icon: _getCategoryIcon(_selectedCategory),
      group: TransactionGroup.today,
      timestamp: DateTime.now(),
    );

    widget.onAddTransaction?.call(newTx);
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.billuColors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppHeader(
        showBack: true,
        onBack: () => Navigator.maybePop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              // Top Segmented Controls Row
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

                  // Expense / Income / Transfer Segmented Toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _selectedType = TransactionType.expense),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: _selectedType == TransactionType.expense ? colors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              'expense',
                              style: AppTypography.labelCaps(
                                _selectedType == TransactionType.expense ? colors.onPrimary : colors.secondary,
                              ).copyWith(fontSize: 11),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _selectedType = TransactionType.income),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: _selectedType == TransactionType.income ? colors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              'income',
                              style: AppTypography.labelCaps(
                                _selectedType == TransactionType.income ? colors.onPrimary : colors.secondary,
                              ).copyWith(fontSize: 11),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _selectedType = TransactionType.transfer),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: _selectedType == TransactionType.transfer ? colors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              'transfer',
                              style: AppTypography.labelCaps(
                                _selectedType == TransactionType.transfer ? colors.onPrimary : colors.secondary,
                              ).copyWith(fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick Mode / Currency
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'USD',
                      style: AppTypography.numericSm(colors.onSurface),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Horizontal Weekday Date Strip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ...List.generate(_dateStrip.length, (idx) {
                    final item = _dateStrip[idx];
                    final isSelected = idx == _selectedDayIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDayIndex = idx),
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
                              ),
                            ),
                            Text(
                              item['weekday']!,
                              style: AppTypography.labelCaps(
                                isSelected ? colors.onPrimary : colors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  Container(
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
                ],
              ),
              const SizedBox(height: 16),

              // Active Amount Display with Expression
              Column(
                children: [
                  if (_expression.isNotEmpty)
                    Text(
                      _expression,
                      style: AppTypography.bodyMd(colors.secondary).copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  if (_expression.isNotEmpty) const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '\$$_currentInput',
                        style: AppTypography.displayCurrencyMobile(colors.onSurface).copyWith(
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 2.5,
                        height: 32,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Merchant / Category Selector Pill
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
              const SizedBox(height: 16),

              // Action Helpers Row: Split bill, Scan receipt, Cash/bank
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionChip(
                      icon: Icons.bolt_rounded,
                      label: 'split bill',
                    ),
                    const SizedBox(width: 8),
                    _buildActionChip(
                      icon: Icons.attach_file_rounded,
                      label: 'scan receipt',
                    ),
                    const SizedBox(width: 8),
                    _buildActionChip(
                      icon: Icons.credit_card_rounded,
                      label: 'cash / bank',
                      trailingIcon: Icons.expand_more_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Note / Tag Input Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      size: 20,
                      color: colors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _noteController,
                        style: AppTypography.bodyMd(colors.onSurface),
                        decoration: InputDecoration(
                          hintText: 'add note or #tags...',
                          hintStyle: AppTypography.bodyMd(colors.secondary),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.tag_rounded,
                        size: 18,
                        color: colors.secondary,
                      ),
                      onPressed: () {
                        _noteController.text += ' #personal';
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Calculator Keypad (4x5 grid)
              SizedBox(
                width: 320,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCalcButton('7'),
                        _buildCalcButton('8'),
                        _buildCalcButton('9'),
                        _buildCalcButton('÷', isOperator: true),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCalcButton('4'),
                        _buildCalcButton('5'),
                        _buildCalcButton('6'),
                        _buildCalcButton('×', isOperator: true),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCalcButton('1'),
                        _buildCalcButton('2'),
                        _buildCalcButton('3'),
                        _buildCalcButton('-', isOperator: true),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCalcButton('C', isClear: true),
                        _buildCalcButton('0'),
                        _buildCalcButton('.'),
                        _buildCalcButton('+', isOperator: true),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCalcButton('=', isEquals: true, width: 230),
                        // Submit Check Button
                        GestureDetector(
                          onTap: _onSubmit,
                          child: Container(
                            width: 74,
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
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    IconData? trailingIcon,
  }) {
    final colors = context.billuColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.onSurface),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelCaps(colors.onSurface),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 2),
            Icon(trailingIcon, size: 14, color: colors.secondary),
          ],
        ],
      ),
    );
  }

  Widget _buildCalcButton(
    String key, {
    bool isOperator = false,
    bool isClear = false,
    bool isEquals = false,
    double width = 74,
  }) {
    final colors = context.billuColors;

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
        width: width,
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

  void _showCategoryPicker() {
    final colors = context.billuColors;
    final categories = [
      {'emoji': '🏷️', 'name': 'general'},
      {'emoji': '🛒', 'name': 'groceries'},
      {'emoji': '☕', 'name': 'coffee & drinks'},
      {'emoji': '🍽️', 'name': 'dining & food'},
      {'emoji': '🚇', 'name': 'transit & commute'},
      {'emoji': '🛍️', 'name': 'shopping'},
      {'emoji': '🏠', 'name': 'rent & utilities'},
      {'emoji': '🎬', 'name': 'entertainment'},
      {'emoji': '🐾', 'name': 'pet care'},
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

