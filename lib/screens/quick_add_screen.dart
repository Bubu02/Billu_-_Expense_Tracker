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
  bool _isExpense = true;
  int _selectedDayIndex = 1; // 13 tue
  String _currentInput = '20.00';
  String _selectedCategory = 'burger king';
  String _categoryEmoji = '🍔';
  final TextEditingController _noteController = TextEditingController();

  final List<Map<String, String>> _dateStrip = [
    {'day': '12', 'weekday': 'mon'},
    {'day': '13', 'weekday': 'tue'},
    {'day': '14', 'weekday': 'wed'},
    {'day': '15', 'weekday': 'thu'},
    {'day': '16', 'weekday': 'fri'},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onKeyPress(String key) {
    setState(() {
      if (key == '.') {
        if (!_currentInput.contains('.')) {
          _currentInput += '.';
        }
      } else {
        if (_currentInput == '0' || _currentInput == '20.00') {
          _currentInput = key;
        } else if (_currentInput.length < 9) {
          _currentInput += key;
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_currentInput.isNotEmpty) {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
        if (_currentInput.isEmpty) _currentInput = '0';
      }
    });
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
      isExpense: _isExpense,
      icon: Icons.fastfood_outlined,
      group: TransactionGroup.today,
      timestamp: DateTime.now(),
    );

    widget.onAddTransaction?.call(newTx);
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.piluColors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppHeader(
        title: 'Quick Add',
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

                  // Expense / Income Segmented Toggle
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
                          onTap: () => setState(() => _isExpense = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                            decoration: BoxDecoration(
                              color: _isExpense ? colors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              'expenses',
                              style: AppTypography.labelCaps(
                                _isExpense ? colors.onPrimary : colors.secondary,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _isExpense = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                            decoration: BoxDecoration(
                              color: !_isExpense ? colors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              'income',
                              style: AppTypography.labelCaps(
                                !_isExpense ? colors.onPrimary : colors.secondary,
                              ),
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

              // Active Amount Display
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

              // 4x3 Numeric Keypad
              SizedBox(
                width: 290,
                child: Column(
                  children: [
                    _buildKeypadRow(['1', '2', '3']),
                    const SizedBox(height: 12),
                    _buildKeypadRow(['4', '5', '6']),
                    const SizedBox(height: 12),
                    _buildKeypadRow(['7', '8', '9']),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildKeypadButton('.'),
                        _buildKeypadButton('0'),
                        // Submit Check Button
                        GestureDetector(
                          onTap: _onSubmit,
                          onLongPress: _onBackspace,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
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
    final colors = context.piluColors;

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

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: keys.map((k) => _buildKeypadButton(k)).toList(),
    );
  }

  Widget _buildKeypadButton(String key) {
    final colors = context.piluColors;

    return GestureDetector(
      onTap: () => _onKeyPress(key),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          key,
          style: AppTypography.headlineMd(colors.onSurface).copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    final colors = context.piluColors;
    final categories = [
      {'emoji': '🍔', 'name': 'burger king'},
      {'emoji': '☕', 'name': 'coffee'},
      {'emoji': '🛒', 'name': 'groceries'},
      {'emoji': '🚇', 'name': 'commute'},
      {'emoji': '🐶', 'name': 'pet care'},
      {'emoji': '🎬', 'name': 'entertainment'},
      {'emoji': '🏠', 'name': 'rent & utilities'},
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

