import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/account_model.dart';
import '../../models/transaction_model.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const String _keyUserName = 'billu_user_name';
  static const String _keyOnboardingDone = 'billu_onboarding_completed';
  static const String _keyDarkMode = 'billu_dark_mode';
  static const String _keyMasked = 'billu_masked';
  static const String _keyTransactions = 'billu_transactions_json';
  static const String _keyAccounts = 'billu_accounts_json';

  SharedPreferences? _prefs;

  Future<void> init({bool forceRefresh = false}) async {
    if (forceRefresh || _prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  /// Request storage permission on mobile platforms.
  Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Storage permission request skipped or not supported: $e');
      return true;
    }
  }

  // ── User Profile ────────────────────────────────────────────────────────

  String getUserName() {
    return _prefs?.getString(_keyUserName) ?? 'billu member';
  }

  Future<void> setUserName(String name) async {
    await init();
    await _prefs?.setString(_keyUserName, name.trim());
  }

  // ── Onboarding ──────────────────────────────────────────────────────────

  bool hasCompletedOnboarding() {
    return _prefs?.getBool(_keyOnboardingDone) ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await init();
    await _prefs?.setBool(_keyOnboardingDone, completed);
  }

  // ── Preferences ─────────────────────────────────────────────────────────

  bool isDarkMode() {
    return _prefs?.getBool(_keyDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool isDark) async {
    await init();
    await _prefs?.setBool(_keyDarkMode, isDark);
  }

  bool isMasked() {
    return _prefs?.getBool(_keyMasked) ?? false;
  }

  Future<void> setMasked(bool masked) async {
    await init();
    await _prefs?.setBool(_keyMasked, masked);
  }

  // ── Transactions ────────────────────────────────────────────────────────

  List<TransactionModel> getTransactions() {
    final raw = _prefs?.getString(_keyTransactions);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => TransactionModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      return [];
    }
  }

  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    await init();
    try {
      final list = transactions.map((t) => t.toMap()).toList();
      await _prefs?.setString(_keyTransactions, jsonEncode(list));
    } catch (e) {
      debugPrint('Error saving transactions: $e');
    }
  }

  // ── Accounts ────────────────────────────────────────────────────────────

  List<AccountModel> getAccounts() {
    final raw = _prefs?.getString(_keyAccounts);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => AccountModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading accounts: $e');
      return [];
    }
  }

  Future<void> saveAccounts(List<AccountModel> accounts) async {
    await init();
    try {
      final list = accounts.map((a) => a.toMap()).toList();
      await _prefs?.setString(_keyAccounts, jsonEncode(list));
    } catch (e) {
      debugPrint('Error saving accounts: $e');
    }
  }

  // ── Reset ───────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await init();
    await _prefs?.clear();
  }
}
