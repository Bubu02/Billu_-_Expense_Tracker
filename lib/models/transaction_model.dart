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
  final String? note; // Optional note field
  final String? accountId; // Account associated with this transaction

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
    this.note,
    this.accountId,
  });

  // Legacy compatibility
  bool get isExpense => type == TransactionType.expense;

  /// Formats amount with the given currency symbol
  String formatAmountWithCurrency(String currencySymbol) {
    String prefix;
    switch (type) {
      case TransactionType.expense:
        prefix = '-';
        break;
      case TransactionType.income:
        prefix = '+';
        break;
      case TransactionType.transfer:
        prefix = '';
        break;
    }
    return '$prefix$currencySymbol${amount.toStringAsFixed(2)}';
  }

  /// Formats amount with the given currency symbol, without +/- prefix
  String formatAmountPlain(String currencySymbol) {
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  /// Legacy formattedAmount for backward compatibility (uses \$)
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
      'note': note,
      'accountId': accountId,
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
      note: map['note'] as String?,
      accountId: map['accountId'] as String?,
    );
  }

  // Helper to determine group from timestamp
  static TransactionGroup getGroupFromTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (txDate == today) {
      return TransactionGroup.today;
    } else if (txDate == yesterday) {
      return TransactionGroup.yesterday;
    } else {
      return TransactionGroup.earlier;
    }
  }

  static List<TransactionModel> sampleData = [];
}

