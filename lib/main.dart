import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_scaffold.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const BilluApp());
}

class BilluApp extends StatefulWidget {
  const BilluApp({super.key});

  @override
  State<BilluApp> createState() => _BilluAppState();
}

class _BilluAppState extends State<BilluApp> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _hasCompletedOnboarding = false;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _themeMode == ThemeMode.dark;

    return MaterialApp(
      title: 'Pilu - Minimal Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: _hasCompletedOnboarding
          ? MainScaffold(
              isDarkTheme: isDark,
              onThemeChanged: _toggleTheme,
            )
          : OnboardingScreen(
              onGetStarted: () {
                setState(() => _hasCompletedOnboarding = true);
              },
            ),
    );
  }
}

