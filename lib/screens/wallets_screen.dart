import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/stepped_chart_painter.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  String _selectedCurrency = 'USD';
  final List<String> _currencies = ['USD', 'EUR', 'GBP'];

  @override
  Widget build(BuildContext context) {
    final colors = context.piluColors;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'wallets & cards',
                    style: AppTypography.headlineLg(colors.primary).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _showAddAccountSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: colors.onSurface),
                      const SizedBox(width: 4),
                      Text(
                        '+ add account',
                        style: AppTypography.labelCaps(colors.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Net Liquidity Hero Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag + Currency Switcher
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'NET LIQUIDITY',
                          style: AppTypography.labelCaps(colors.onSurfaceVariant).copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainer,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _currencies.map((curr) {
                          final isSelected = curr == _selectedCurrency;
                          final symbol = curr == 'USD' ? '\$' : (curr == 'EUR' ? '€' : '£');
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCurrency = curr),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: isSelected ? colors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                '$curr $symbol',
                                style: AppTypography.labelCaps(
                                  isSelected ? colors.onPrimary : colors.onSurfaceVariant,
                                ).copyWith(fontSize: 10),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Amount + Stepped Sparkline
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$14,820.50',
                          style: AppTypography.displayCurrencyMobile(colors.primary).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              size: 14,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '+3.8%',
                              style: AppTypography.numericSm(colors.primary).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'vs last billing cycle',
                              style: AppTypography.labelSubtle(colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Stepped Path Sparkline
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: CustomPaint(
                        painter: SteppedChartPainter(
                          lineColor: colors.primary,
                          baseLineColor: colors.outlineVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Quick Micro-distribution Meter
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'cash vs credit ratio',
                          style: AppTypography.labelSubtle(colors.onSurfaceVariant),
                        ),
                        Text(
                          '92% liquid',
                          style: AppTypography.numericSm(colors.onSurface).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9999),
                      child: SizedBox(
                        height: 6,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 57,
                              child: Container(color: colors.primary),
                            ),
                            Expanded(
                              flex: 35,
                              child: Container(color: colors.secondary),
                            ),
                            Expanded(
                              flex: 8,
                              child: Container(color: colors.surfaceContainerHighest),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Accounts & Wallets List Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIVE VAULTS (4)',
                style: AppTypography.labelCaps(colors.onSurfaceVariant).copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'ordered by flow',
                style: AppTypography.labelSubtle(colors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Accounts List Cards
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: AccountModel.sampleAccounts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final acc = AccountModel.sampleAccounts[index];

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: colors.surfaceContainer,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            acc.icon,
                            size: 19,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                acc.name,
                                style: AppTypography.headlineMd(colors.onSurface).copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                acc.subtitle,
                                style: AppTypography.labelSubtle(colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: acc.isPrimaryBadge
                                    ? colors.primary
                                    : colors.surfaceContainer,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                acc.badgeText.toUpperCase(),
                                style: AppTypography.labelCaps(
                                  acc.isPrimaryBadge
                                      ? colors.onPrimary
                                      : colors.onSurface,
                                ).copyWith(fontSize: 9),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              acc.formattedBalance,
                              style: AppTypography.numericTabular(colors.primary).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (acc.footerLeft != null && acc.footerRight != null) ...[
                      const SizedBox(height: 12),
                      Divider(color: colors.surfaceContainer, height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                acc.footerLeft!,
                                style: AppTypography.labelSubtle(colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                          Text(
                            acc.footerRight!,
                            style: AppTypography.numericSm(colors.primary).copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showAddAccountSheet() {
    final colors = context.piluColors;
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
                  'Add New Account',
                  style: AppTypography.headlineMd(colors.onSurface),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.account_balance_outlined),
                  title: const Text('Bank Account (Plaid)'),
                  subtitle: const Text('Connect checking or savings'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.credit_card_outlined),
                  title: const Text('Credit Card'),
                  subtitle: const Text('Auto-sync balances and statements'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: const Text('Manual Cash Wallet'),
                  subtitle: const Text('Track physical currency envelope'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

