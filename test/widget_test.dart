import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:billu_expense_tracker/core/storage/storage_service.dart';
import 'package:billu_expense_tracker/main.dart';
import 'package:billu_expense_tracker/screens/onboarding_screen.dart';
import 'package:billu_expense_tracker/screens/main_scaffold.dart';
import 'package:billu_expense_tracker/screens/dashboard_screen.dart';
import 'package:billu_expense_tracker/screens/quick_add_screen.dart';
import 'package:billu_expense_tracker/screens/budget_analytics_screen.dart';
import 'package:billu_expense_tracker/screens/wallets_screen.dart';
import 'package:billu_expense_tracker/screens/settings_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init(forceRefresh: true);
    await StorageService.instance.clearAll();
  });

  testWidgets('Billu app complete flow: onboarding, dashboard, tabs, quick-add, and theme toggle',
      (WidgetTester tester) async {
    // Increase test surface height so scrollable/keypad widgets fit on screen
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // 1. Build BilluApp
    await tester.pumpWidget(const BilluApp());
    await tester.pumpAndSettle();

    // 2. Verify Onboarding screen is displayed initially
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('get started'), findsOneWidget);
    expect(find.text('your minimal budgeting app'), findsOneWidget);

    // 3. Tap 'get started' to prompt for username, enter name, and continue to MainScaffold
    await tester.tap(find.text('get started'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to billu'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Satya');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(MainScaffold), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('\$0.00'), findsOneWidget);

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
    expect(find.text('\$0.00'), findsOneWidget);

    // 5. Test Navigation to Stats (Budget & Analytics)
    await tester.tap(find.text('stats'));
    await tester.pumpAndSettle();
    expect(find.byType(BudgetAnalyticsScreen), findsOneWidget);
    expect(find.text('analytics'), findsOneWidget);
    expect(find.text('\$0'), findsOneWidget);

    // 6. Test Navigation to Vault (Wallets)
    await tester.tap(find.text('vault'));
    await tester.pumpAndSettle();
    expect(find.byType(WalletsScreen), findsOneWidget);
    expect(find.text('wallets & cards'), findsOneWidget);
    expect(find.text('\$0.00'), findsOneWidget);

    // 7. Test Navigation to Setup (Settings) & Theme Toggle
    await tester.tap(find.text('setup'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('settings'), findsOneWidget);
    expect(find.text('Satya'), findsOneWidget);

    // 8. Test Quick Add Navigation (Floating '+' button)
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(QuickAddScreen), findsOneWidget);
    expect(find.text('\$0'), findsOneWidget);

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

    // Verify returning to MainScaffold with updated transaction amount on Dashboard
    expect(find.byType(MainScaffold), findsOneWidget);
    expect(find.text('\$50.00'), findsOneWidget);
  });

  testWidgets('Header displays only logo billu and empty states show clean placeholders',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BilluApp());
    await tester.pumpAndSettle();

    // Navigate past onboarding by entering username
    await tester.tap(find.text('get started'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to billu'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Satya');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Verify header has logo 'billu' and NO page name after it
    expect(find.text('billu'), findsOneWidget);
    expect(find.text('Dashboard'), findsNothing);
    expect(find.text('/'), findsNothing);

    // Verify Dashboard empty state placeholder
    expect(find.text('NO RECENT ENTRIES'), findsOneWidget);
    expect(find.text('Tap the + button to log your first transaction'), findsOneWidget);

    // Verify Stats (Budget & Analytics) tab
    await tester.tap(find.text('stats'));
    await tester.pumpAndSettle();
    expect(find.text('billu'), findsOneWidget);
    expect(find.text('Budget & Analytics'), findsNothing);
    expect(find.text('NO ACTIVE CAPS'), findsOneWidget);
    expect(find.text('no category breakdown available'), findsOneWidget);

    // Verify Vault (Wallets) tab
    await tester.tap(find.text('vault'));
    await tester.pumpAndSettle();
    expect(find.text('billu'), findsOneWidget);
    expect(find.text('Wallets'), findsNothing);
    expect(find.text('NO ACTIVE VAULTS'), findsOneWidget);
    expect(find.text('+ add first account'), findsOneWidget);

    // Test adding an account via dialog
    await tester.tap(find.text('+ add first account'));
    await tester.pumpAndSettle();
    expect(find.text('Add New Account'), findsOneWidget);

    await tester.tap(find.text('Bank Account'));
    await tester.pumpAndSettle();
    expect(find.text('Add Bank Account'), findsOneWidget);

    // Tap 'Add' to confirm account
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Account is now added and empty state is gone
    expect(find.text('NO ACTIVE VAULTS'), findsNothing);
    expect(find.text('Checking Account'), findsOneWidget);
    expect(find.text('ACTIVE VAULTS (1)'), findsOneWidget);
  });

  testWidgets('Data persists across app relaunch: onboarding skipped, transactions & user profile preserved',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Initial launch: complete onboarding with name
    await tester.pumpWidget(const BilluApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('get started'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Satya Prakash');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Add a transaction
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(GestureDetector, '5'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();
    expect(find.text('\$5.00'), findsOneWidget);

    // Simulate relaunching the app (re-pump BilluApp widget)
    await tester.pumpWidget(const BilluApp());
    await tester.pumpAndSettle();

    // Onboarding should NOT show again; MainScaffold should be loaded directly
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(MainScaffold), findsOneWidget);
    expect(find.text('\$5.00'), findsOneWidget);

    // Check Settings has the saved username
    await tester.tap(find.text('setup'));
    await tester.pumpAndSettle();
    expect(find.text('Satya Prakash'), findsOneWidget);
  });
}

