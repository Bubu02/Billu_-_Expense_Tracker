import 'package:flutter/material.dart';

class AccountModel {
  final String id;
  final String name;
  final String subtitle;
  final double balance;
  final String badgeText;
  final bool isPrimaryBadge;
  final IconData icon;
  final String? footerLeft;
  final String? footerRight;

  const AccountModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.balance,
    required this.badgeText,
    this.isPrimaryBadge = false,
    required this.icon,
    this.footerLeft,
    this.footerRight,
  });

  String get formattedBalance {
    if (balance < 0) {
      return '-\$${balance.abs().toStringAsFixed(2)}';
    }
    return '\$${balance.toStringAsFixed(2)}';
  }

  static List<AccountModel> sampleAccounts = [
    AccountModel(
      id: 'acc-1',
      name: 'chase checking •••• 4092',
      subtitle: 'synced 2m ago via plaid',
      balance: 8450.00,
      badgeText: 'primary',
      isPrimaryBadge: true,
      icon: Icons.account_balance_outlined,
    ),
    AccountModel(
      id: 'acc-2',
      name: 'apple card •••• 1184',
      subtitle: 'limit: \$10,000 (12% used)',
      balance: -1220.50,
      badgeText: 'active',
      isPrimaryBadge: false,
      icon: Icons.credit_card_outlined,
      footerLeft: 'statement closing in 6 days',
      footerRight: 'autopay on',
    ),
    AccountModel(
      id: 'acc-3',
      name: 'physical cash',
      subtitle: 'emergency pouch & envelope',
      balance: 340.00,
      badgeText: 'untracked',
      isPrimaryBadge: false,
      icon: Icons.payments_outlined,
      footerLeft: 'last audited 3d ago',
      footerRight: 'manual count',
    ),
    AccountModel(
      id: 'acc-4',
      name: 'vault savings (ally •••• 9201)',
      subtitle: '4.35% apy yield • locked',
      balance: 7251.00,
      badgeText: 'growth',
      isPrimaryBadge: false,
      icon: Icons.savings_outlined,
      footerLeft: 'interest paid Oct 31 (+\$26.31)',
      footerRight: 'compounding',
    ),
  ];
}

