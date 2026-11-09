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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'balance': balance,
      'badgeText': badgeText,
      'isPrimaryBadge': isPrimaryBadge,
      'iconCodePoint': icon.codePoint,
      'footerLeft': footerLeft,
      'footerRight': footerRight,
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'] as String? ?? 'acc-${DateTime.now().millisecondsSinceEpoch}',
      name: map['name'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      badgeText: map['badgeText'] as String? ?? '',
      isPrimaryBadge: map['isPrimaryBadge'] as bool? ?? false,
      icon: IconData(
        // ignore: non_const_argument_for_const_parameter
        map['iconCodePoint'] as int? ?? Icons.account_balance_outlined.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      footerLeft: map['footerLeft'] as String?,
      footerRight: map['footerRight'] as String?,
    );
  }

  static const List<AccountModel> sampleAccounts = [];
}

