import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billu_expense_tracker/main.dart';
import 'package:billu_expense_tracker/screens/onboarding_screen.dart';
import 'package:billu_expense_tracker/screens/main_scaffold.dart';
import 'package:billu_expense_tracker/screens/dashboard_screen.dart';
import 'package:billu_expense_tracker/screens/quick_add_screen.dart';
import 'package:billu_expense_tracker/screens/budget_analytics_screen.dart';
import 'package:billu_expense_tracker/screens/wallets_screen.dart';
import 'package:billu_expense_tracker/screens/settings_screen.dart';

void main() {
  testWidgets('Billu app complete flow: onboarding, dashboard, tabs, quick-add, and theme toggle',
      (WidgetTester tester) async {
    // 1. Build BilluApp
    await tester.pumpWidget(const BilluApp());
    await tester.pumpAndSettle();

    // 2. Verify Onboarding screen is displayed initially
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('get started'), findsOneWidget);
    expect(find.text('your minimal budgeting app'), findsOneWidget);

    // 3. Tap 'get started' to navigate to MainScaffold
    await tester.tap(find.text('get started'));
    await tester.pumpAndSettle();

    expect(find.byType(MainScaffold), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('\$301.95'), findsOneWidget);

    // 4. Test Privacy Masking on Dashboard
    final visibilityIcon = find.byIcon(Icons.visibility_rounded);
    expect(visibilityIcon, findsOneWidget);
    await tester.tap(visibilityIcon);
    await tester.pumpAndSettle();

    // Amount is now masked
    expect(find.text('\$••••••'), findsOneWidget);

    // Unmask
    await tester.tap(find.byIcon(Icons.visibility_off_rounded));
    await tester.pumpAndSettle();
    expect(find.text('\$301.95'), findsOneWidget);

    // 5. Test Navigation to Stats (Budget & Analytics)
    await tester.tap(find.text('stats'));
    await tester.pumpAndSettle();
    expect(find.byType(BudgetAnalyticsScreen), findsOneWidget);
    expect(find.text('analytics'), findsOneWidget);
    expect(find.text('\$1,840'), findsOneWidget);

    // 6. Test Navigation to Vault (Wallets)
    await tester.tap(find.text('vault'));
    await tester.pumpAndSettle();
    expect(find.byType(WalletsScreen), findsOneWidget);
    expect(find.text('wallets & cards'), findsOneWidget);
    expect(find.text('\$14,820.50'), findsOneWidget);

    // 7. Test Navigation to Setup (Settings) & Theme Toggle
    await tester.tap(find.text('setup'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('settings'), findsOneWidget);
    expect(find.text('pilu member'), findsOneWidget);

    // 8. Test Quick Add Navigation (Floating '+' button)
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(QuickAddScreen), findsOneWidget);
    expect(find.text('\$20.00'), findsOneWidget);

    // Tap numeric keypad keys: 5, 0
    await tester.tap(find.widgetWithText(GestureDetector, '5'));
    await tester.pumpAndSettle();
    expect(find.text('\$5'), findsOneWidget);

    await tester.tap(find.widgetWithText(GestureDetector, '0'));
    await tester.pumpAndSettle();
    expect(find.text('\$50'), findsOneWidget);

    // Submit transaction
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();

    // Verify returning to MainScaffold
    expect(find.byType(MainScaffold), findsOneWidget);
  });
}

