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

  AccountModel copyWith({
    String? id,
    String? name,
    String? subtitle,
    double? balance,
    String? badgeText,
    bool? isPrimaryBadge,
    IconData? icon,
    String? footerLeft,
    String? footerRight,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      balance: balance ?? this.balance,
      badgeText: badgeText ?? this.badgeText,
      isPrimaryBadge: isPrimaryBadge ?? this.isPrimaryBadge,
      icon: icon ?? this.icon,
      footerLeft: footerLeft ?? this.footerLeft,
      footerRight: footerRight ?? this.footerRight,
    );
  }

  static const List<AccountModel> sampleAccounts = [];
}

