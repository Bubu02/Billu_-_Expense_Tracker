import 'package:flutter/material.dart';

enum TransactionGroup { today, yesterday, earlier }

enum TransactionType { expense, income, transfer }

class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final IconData icon;
  final TransactionGroup group;
  final DateTime timestamp;
  final String? fromAccount; // For transfers
  final String? toAccount; // For transfers

  const TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.type = TransactionType.expense,
    required this.icon,
    required this.group,
    required this.timestamp,
    this.fromAccount,
    this.toAccount,
  });

  // Legacy compatibility
  bool get isExpense => type == TransactionType.expense;

  String get formattedAmount {
    String prefix;
    switch (type) {
      case TransactionType.expense:
        prefix = '-\$';
        break;
      case TransactionType.income:
        prefix = '+\$';
        break;
      case TransactionType.transfer:
        prefix = '\$';
        break;
    }
    return '$prefix${amount.toStringAsFixed(2)}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'type': type.name,
      'iconCodePoint': icon.codePoint,
      'group': group.name,
      'timestamp': timestamp.toIso8601String(),
      'fromAccount': fromAccount,
      'toAccount': toAccount,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    TransactionGroup grp;
    switch (map['group']) {
      case 'today':
        grp = TransactionGroup.today;
        break;
      case 'yesterday':
        grp = TransactionGroup.yesterday;
        break;
      default:
        grp = TransactionGroup.earlier;
    }

    TransactionType txType;
    switch (map['type']) {
      case 'income':
        txType = TransactionType.income;
        break;
      case 'transfer':
        txType = TransactionType.transfer;
        break;
      case 'expense':
      default:
        txType = TransactionType.expense;
    }

    // Legacy support: if 'type' doesn't exist, use 'isExpense'
    if (map['type'] == null && map['isExpense'] != null) {
      txType = (map['isExpense'] as bool) ? TransactionType.expense : TransactionType.income;
    }

    return TransactionModel(
      id: map['id'] as String? ?? 'tx-${DateTime.now().millisecondsSinceEpoch}',
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: txType,
      icon: IconData(
        // ignore: non_const_argument_for_const_parameter
        map['iconCodePoint'] as int? ?? Icons.receipt_outlined.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      group: grp,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      fromAccount: map['fromAccount'] as String?,
      toAccount: map['toAccount'] as String?,
    );
  }

  static List<TransactionModel> sampleData = [];
}

