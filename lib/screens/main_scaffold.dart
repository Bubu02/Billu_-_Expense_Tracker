import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_header.dart';
import 'budget_analytics_screen.dart';
import 'dashboard_screen.dart';
import 'quick_add_screen.dart';
import 'settings_screen.dart';
import 'wallets_screen.dart';

class MainScaffold extends StatefulWidget {
  final bool isDarkTheme;
  final ValueChanged<bool> onThemeChanged;

  const MainScaffold({
    super.key,
    required this.isDarkTheme,
    required this.onThemeChanged,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  bool _isMasked = false;

  final List<TransactionModel> _transactions = [];
  final List<AccountModel> _accounts = [];
  final List<BudgetCategory> _budgetCategories = [];

  void _onQuickAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuickAddScreen(
          onAddTransaction: (newTx) {
            setState(() {
              _transactions.insert(0, newTx);
              _currentIndex = 0;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added ${newTx.title}: ${newTx.formattedAmount}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.billuColors;

    final screens = [
      DashboardScreen(
        isMasked: _isMasked,
        onToggleMask: () => setState(() => _isMasked = !_isMasked),
        transactions: _transactions,
      ),
      BudgetAnalyticsScreen(
        transactions: _transactions,
        categories: _budgetCategories,
      ),
      WalletsScreen(
        accounts: _accounts,
        onAccountAdded: (newAcc) {
          setState(() {
            _accounts.add(newAcc);
          });
        },
      ),
      SettingsScreen(
        isDarkTheme: widget.isDarkTheme,
        onThemeChanged: widget.onThemeChanged,
        isMasked: _isMasked,
        onMaskChanged: (val) => setState(() => _isMasked = val),
      ),
    ];

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: const AppHeader(),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTabSelected: (index) => setState(() => _currentIndex = index),
        onQuickAdd: _onQuickAdd,
      ),
    );
  }
}

