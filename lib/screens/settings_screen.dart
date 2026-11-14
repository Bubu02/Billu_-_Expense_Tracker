import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../core/database/db_helper.dart';
import '../core/storage/storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkTheme;
  final ValueChanged<bool> onThemeChanged;
  final bool isMasked;
  final ValueChanged<bool> onMaskChanged;
  final VoidCallback? onEraseData;
  final VoidCallback? onCurrencyChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkTheme,
    required this.onThemeChanged,
    required this.isMasked,
    required this.onMaskChanged,
    this.onEraseData,
    this.onCurrencyChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricUnlock = true;
  String _userName = 'billu member';
  String _currencyCode = 'USD';
  String _currencySymbol = '\$';

  @override
  void initState() {
    super.initState();
    _userName = StorageService.instance.getUserName();
    _currencyCode = StorageService.instance.getCurrencyCode();
    _currencySymbol = StorageService.instance.getCurrencySymbol();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.billuColors;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Version Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Settings',
                style: AppTypography.headlineMd(colors.primary).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'v1.0.4',
                  style: AppTypography.labelCaps(colors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Member Profile Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida/ALJJyrDpMNnjojhc77tbkUFWJkiBK459sYew1814QocxFzOywLt1UXLQcTvCBdZpkgvxhl_xjCDOhNVAsCI--tOn-zLi41F0UTIZM800MpKNg8cQsqNIpYxgxvx9US_5QYLSogPaerqxRZ88x7YRI9m8VRODjXDv4rjAc9LKTsw67ckbdiI843ynR-OtJQX4QXCI591CpGh8zUqGftdjPb_UwUW_SvDNvJBKt7aOLIYVJDchnQ',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          style: AppTypography.numericSm(colors.onSurface).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Local Vault Active',
                          style: AppTypography.labelSubtle(colors.secondary),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: colors.surfaceBright,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Offline First',
                        style: AppTypography.labelCaps(colors.onPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Theme Selector (Live Light & Dark Preview)
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Text(
              'Appearance & Theme',
              style: AppTypography.labelCaps(colors.secondary).copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        widget.isDarkTheme ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        size: 18,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isDarkTheme ? 'Dark Precision' : 'Light Wireframe',
                          style: AppTypography.bodyMd(colors.onSurface).copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Monochrome High-Contrast System',
                          style: AppTypography.labelSubtle(colors.secondary),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildToggleSwitch(
                  value: widget.isDarkTheme,
                  onChanged: (val) => widget.onThemeChanged(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Security & Privacy
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Security & Privacy',
                  style: AppTypography.labelCaps(colors.secondary).copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                Text('2 Active', style: AppTypography.labelSubtle(colors.secondary)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSettingRow(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric Unlock',
                  subtitle: 'Fingerprint & Face ID Authentication',
                  trailing: _buildToggleSwitch(
                    value: _biometricUnlock,
                    onChanged: (val) => setState(() => _biometricUnlock = val),
                  ),
                ),
                Divider(color: colors.surfaceContainer, height: 1),
                _buildSettingRow(
                  icon: Icons.visibility_off_rounded,
                  title: 'Privacy Mask Mode',
                  subtitle: 'Hide Ledger Amounts In Public View',
                  trailing: _buildToggleSwitch(
                    value: widget.isMasked,
                    onChanged: (val) => widget.onMaskChanged(val),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Currency Selection
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Text(
              'Currency',
              style: AppTypography.labelCaps(colors.secondary).copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSettingRow(
                  icon: Icons.currency_exchange_rounded,
                  title: 'Currency',
                  subtitle: '$_currencyCode ($_currencySymbol)',
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.secondary,
                  ),
                  onTap: () => _showCurrencyPicker(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Data & Export
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Data & Export',
                  style: AppTypography.labelCaps(colors.secondary).copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                Text('SQLite Encrypted', style: AppTypography.labelSubtle(colors.secondary)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSettingRow(
                  icon: Icons.file_download_outlined,
                  title: 'Export To Csv',
                  subtitle: 'Export Transactions To Csv File',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'Export',
                      style: AppTypography.labelCaps(colors.onSurface),
                    ),
                  ),
                  onTap: () => _exportToCsv(context),
                ),
                Divider(color: colors.surfaceContainer, height: 1),
                _buildSettingRow(
                  icon: Icons.cloud_sync_outlined,
                  title: 'Backup Or Restore To Google Drive',
                  subtitle: 'Cloud Sync & Recovery',
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.secondary,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening Google Drive backup & restore...')),
                    );
                  },
                ),
                Divider(color: colors.surfaceContainer, height: 1),
                _buildSettingRow(
                  icon: Icons.delete_forever_rounded,
                  iconColor: colors.error,
                  title: 'Erase Local Database',
                  subtitle: '',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Reset',
                          style: AppTypography.labelCaps(colors.onSurface),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: colors.surfaceContainerLowest,
                        title: Text('Erase All Data?', style: AppTypography.headlineMd(colors.onSurface)),
                        content: Text(
                          'This will permanently delete all transactions and reset account balances.',
                          style: AppTypography.bodyMd(colors.onSurfaceVariant),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel', style: AppTypography.bodyMd(colors.onSurface)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onEraseData?.call();
                            },
                            child: Text('Erase', style: AppTypography.bodyMd(colors.error)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Zen Statement
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 16,
                      color: colors.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'billu android v1.0.4 • build 2025.10',
                      style: AppTypography.labelSubtle(colors.secondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Pure Minimal Budgeting • No Ads • No Cloud Tracking',
                  style: AppTypography.labelSubtle(colors.secondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    final colors = context.billuColors;
    final List<Map<String, String>> currencies = [
      {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
      {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
      {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
      {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
      {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
      {'code': 'CAD', 'symbol': 'CA\$', 'name': 'Canadian Dollar'},
      {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
      {'code': 'CHF', 'symbol': 'CHF', 'name': 'Swiss Franc'},
      {'code': 'CNY', 'symbol': '¥', 'name': 'Chinese Yuan'},
      {'code': 'SGD', 'symbol': 'S\$', 'name': 'Singapore Dollar'},
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
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Currency',
                  style: AppTypography.headlineMd(colors.onSurface),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: currencies.length,
                    separatorBuilder: (_, __) => Divider(color: colors.surfaceContainer, height: 1),
                    itemBuilder: (context, index) {
                      final currency = currencies[index];
                      final isSelected = currency['code'] == _currencyCode;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected ? colors.primary : colors.surfaceContainer,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            currency['symbol']!,
                            style: AppTypography.labelCaps(
                              isSelected ? colors.onPrimary : colors.onSurface,
                            ).copyWith(fontSize: 14),
                          ),
                        ),
                        title: Text(
                          currency['name']!,
                          style: AppTypography.bodyMd(colors.onSurface).copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        subtitle: Text(
                          '${currency['code']} (${currency['symbol']})',
                          style: AppTypography.labelSubtle(colors.onSurfaceVariant),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: colors.primary, size: 22)
                            : null,
                        onTap: () async {
                          final selectedCode = currency['code']!;
                          final selectedSymbol = currency['symbol']!;
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);

                          setState(() {
                            _currencyCode = selectedCode;
                            _currencySymbol = selectedSymbol;
                          });
                          await StorageService.instance.setCurrency(
                            selectedSymbol,
                            selectedCode,
                          );
                          if (mounted) {
                            navigator.pop();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Currency updated to $selectedCode ($selectedSymbol)',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            widget.onCurrencyChanged?.call();
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportToCsv(BuildContext context) async {
    final colors = context.billuColors;
    final messenger = ScaffoldMessenger.of(context);

    // Show progress indicator
    messenger.showSnackBar(
      SnackBar(
        content: Text('Preparing Csv...', style: AppTypography.bodyMd(colors.onSurface)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 30),
      ),
    );

    try {
      // Fetch transactions from database with joined category and account data
      final transactions = await DBHelper.instance.getAllTransactionsForExport();

      if (transactions.isEmpty) {
        if (mounted) {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text('No Transactions To Export', style: AppTypography.bodyMd(colors.onSurface)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // Build CSV rows with Title Case headers
      final List<List<dynamic>> csvData = [
        ['Date', 'Type', 'Category', 'Account', 'Amount', 'Note'],
      ];

      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

      for (final tx in transactions) {
        final dateStr = tx['date'] != null ? dateFormat.format(DateTime.parse(tx['date'] as String)) : '';
        final type = tx['type'] as String? ?? '';
        final category = tx['category'] as String? ?? '';
        final account = tx['account'] as String? ?? '';
        final amount = (tx['amount'] as num?)?.toString() ?? '0';
        final note = (tx['note'] as String?)?.replaceAll('"', '""') ?? '';

        csvData.add([dateStr, type, category, account, amount, note]);
      }

      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(csvData);

      // Generate filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'billu_transactions_$timestamp.csv';

      // Use FilePicker to let user choose destination folder
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Folder To Save Csv',
      );

      if (selectedDirectory == null) {
        // User cancelled folder selection
        if (mounted) {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text('Export Cancelled', style: AppTypography.bodyMd(colors.onSurface)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // Write CSV file to selected directory
      final file = File('$selectedDirectory/$fileName');
      await file.writeAsString(csvString, encoding: utf8);

      if (mounted) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Saved Csv To Selected Folder', style: AppTypography.bodyMd(colors.onSurface)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Export Failed: $e', style: AppTypography.bodyMd(colors.onSurface)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildSettingRow({
    required IconData icon,
    Color? iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final colors = context.billuColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 18,
                color: iconColor ?? colors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMd(colors.onSurface).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.labelSubtle(colors.secondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colors = context.billuColors;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? colors.primary : colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(9999),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: value ? colors.onPrimary : colors.secondary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

