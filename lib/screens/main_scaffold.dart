import 'package:flutter/material.dart';
import '../core/database/db_helper.dart';
import '../core/storage/storage_service.dart';
import '../models/account_model.dart';
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

  List<TransactionModel> _transactions = [];
  List<AccountModel> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadPersistedData();
  }

  Future<void> _loadPersistedData() async {
    final storage = StorageService.instance;
    setState(() {
      _transactions = storage.getTransactions();
      _accounts = storage.getAccounts();
      _isMasked = storage.isMasked();
    });
  }

  void _onQuickAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuickAddScreen(
          accounts: _accounts,
          onAddTransaction: (newTx) {
            setState(() {
              _transactions.insert(0, newTx);
              _currentIndex = 0;
            });
            StorageService.instance.saveTransactions(_transactions);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added ${newTx.title}: ${newTx.formattedAmount}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onUpdateBalance: (String accountId, double amount, bool isDeduct) {
            setState(() {
              final idx = _accounts.indexWhere((a) => a.id == accountId);
              if (idx != -1) {
                final acc = _accounts[idx];
                _accounts[idx] = acc.copyWith(
                  balance: isDeduct ? acc.balance - amount : acc.balance + amount,
                );
              }
            });
            StorageService.instance.saveAccounts(_accounts);
          },
        ),
      ),
    );
  }

  Future<void> _onEraseData() async {
    await DBHelper.instance.purgeDatabase();
    await StorageService.instance.eraseAllData();
    if (!mounted) return;
    setState(() {
      _transactions = [];
      _accounts = [];
      _currentIndex = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Local data erased successfully'),
        behavior: SnackBarBehavior.floating,
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
      ),
      WalletsScreen(
        accounts: _accounts,
        onAccountAdded: (newAcc) {
          setState(() {
            _accounts.add(newAcc);
          });
          StorageService.instance.saveAccounts(_accounts);
        },
      ),
      SettingsScreen(
        isDarkTheme: widget.isDarkTheme,
        onThemeChanged: widget.onThemeChanged,
        isMasked: _isMasked,
        onMaskChanged: (val) {
          setState(() => _isMasked = val);
          StorageService.instance.setMasked(val);
        },
        onEraseData: _onEraseData,
        onCurrencyChanged: () {
          setState(() {
            // Reload accounts and transactions to reflect new currency
            _loadPersistedData();
          });
        },
      ),
    ];

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppHeader(
        isMasked: _currentIndex == 0 ? _isMasked : null,
        onToggleMask: _currentIndex == 0
            ? () {
                setState(() => _isMasked = !_isMasked);
                StorageService.instance.setMasked(_isMasked);
              }
            : null,
      ),
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

