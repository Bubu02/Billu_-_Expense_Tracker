import 'package:flutter/material.dart';
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

  final List<String> _titles = [
    'Dashboard',
    'Budget & Analytics',
    'Wallets',
    'Settings',
  ];

  void _onQuickAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuickAddScreen(
          onAddTransaction: (newTx) {
            setState(() {
              // Automatically return to dashboard tab
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
    final colors = context.piluColors;

    final screens = [
      DashboardScreen(
        isMasked: _isMasked,
        onToggleMask: () => setState(() => _isMasked = !_isMasked),
      ),
      const BudgetAnalyticsScreen(),
      const WalletsScreen(),
      SettingsScreen(
        isDarkTheme: widget.isDarkTheme,
        onThemeChanged: widget.onThemeChanged,
        isMasked: _isMasked,
        onMaskChanged: (val) => setState(() => _isMasked = val),
      ),
    ];

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppHeader(
        title: _titles[_currentIndex],
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

