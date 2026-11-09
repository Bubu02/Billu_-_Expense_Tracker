import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkTheme;
  final ValueChanged<bool> onThemeChanged;
  final bool isMasked;
  final ValueChanged<bool> onMaskChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkTheme,
    required this.onThemeChanged,
    required this.isMasked,
    required this.onMaskChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricUnlock = true;
  bool _localSmsParser = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.piluColors;

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
                'settings',
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
                          'pilu member',
                          style: AppTypography.numericSm(colors.onSurface).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'local vault active',
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
                        'offline first',
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
              'APPEARANCE & THEME',
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
                          'Monochrome high-contrast system',
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
                  'SECURITY & PRIVACY',
                  style: AppTypography.labelCaps(colors.secondary).copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                Text('3 active', style: AppTypography.labelSubtle(colors.secondary)),
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
                  title: 'biometric unlock',
                  subtitle: 'fingerprint & face id authentication',
                  trailing: _buildToggleSwitch(
                    value: _biometricUnlock,
                    onChanged: (val) => setState(() => _biometricUnlock = val),
                  ),
                ),
                Divider(color: colors.surfaceContainer, height: 1),
                _buildSettingRow(
                  icon: Icons.visibility_off_rounded,
                  title: 'privacy mask mode',
                  subtitle: 'hide ledger amounts in public view',
                  trailing: _buildToggleSwitch(
                    value: widget.isMasked,
                    onChanged: (val) => widget.onMaskChanged(val),
                  ),
                ),
                Divider(color: colors.surfaceContainer, height: 1),
                _buildSettingRow(
                  icon: Icons.mark_chat_read_rounded,
                  title: 'local sms parser',
                  subtitle: '100% on-device transaction capture',
                  trailing: _buildToggleSwitch(
                    value: _localSmsParser,
                    onChanged: (val) => setState(() => _localSmsParser = val),
                  ),
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
                  'DATA & EXPORT',
                  style: AppTypography.labelCaps(colors.secondary).copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                Text('sqlite encrypted', style: AppTypography.labelSubtle(colors.secondary)),
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
                  title: 'export vault archive',
                  subtitle: 'csv • json • signed pdf statements',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'download',
                      style: AppTypography.labelCaps(colors.onSurface),
                    ),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export ready: CSV, JSON, and PDF bundles generated.')),
                    );
                  },
                ),
                Divider(color: colors.surfaceContainer, height: 1),
                _buildSettingRow(
                  icon: Icons.cloud_sync_outlined,
                  title: 'encrypted cloud backup',
                  subtitle: 'last synced today 09:15 am',
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.secondary,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Syncing with Google Drive isolated app container...')),
                    );
                  },
                ),
                Divider(color: colors.surfaceContainer, height: 1),
                _buildSettingRow(
                  icon: Icons.delete_forever_rounded,
                  iconColor: colors.error,
                  title: 'erase local database',
                  subtitle: 'purge cached indexes & ledger files',
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
                          'reset',
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
                        title: Text('Erase Local Database?', style: AppTypography.headlineMd(colors.onSurface)),
                        content: Text(
                          'Are you sure you want to permanently erase local database? This cannot be undone.',
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Vault database wiped.')),
                              );
                            },
                            child: Text('Reset', style: AppTypography.bodyMd(colors.error)),
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
                      'pilu android v1.0.4 • build 2025.10',
                      style: AppTypography.labelSubtle(colors.secondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'pure minimal budgeting • no ads • no cloud tracking',
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

  Widget _buildSettingRow({
    required IconData icon,
    Color? iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final colors = context.piluColors;

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
    final colors = context.piluColors;

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

