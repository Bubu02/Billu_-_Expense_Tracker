import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/storage/storage_service.dart';
import 'screens/main_scaffold.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize storage and request permission
  await StorageService.instance.init();
  await StorageService.instance.requestStoragePermission();

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

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = StorageService.instance;
    setState(() {
      _hasCompletedOnboarding = storage.hasCompletedOnboarding();
      _themeMode = storage.isDarkMode() ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    StorageService.instance.setDarkMode(isDark);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _themeMode == ThemeMode.dark;

    return MaterialApp(
      title: 'Billu - Minimal Expense Tracker',
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

