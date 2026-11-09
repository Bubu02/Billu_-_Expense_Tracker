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

  static const List<AccountModel> sampleAccounts = [];
}

