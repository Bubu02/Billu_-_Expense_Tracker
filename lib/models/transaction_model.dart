import 'package:flutter/material.dart';

enum TransactionGroup { today, yesterday, earlier }

class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final bool isExpense;
  final IconData icon;
  final TransactionGroup group;
  final DateTime timestamp;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.isExpense = true,
    required this.icon,
    required this.group,
    required this.timestamp,
  });

  String get formattedAmount {
    final prefix = isExpense ? '-\$' : '+\$';
    return '$prefix${amount.toStringAsFixed(2)}';
  }

  static List<TransactionModel> sampleData = [];
}

