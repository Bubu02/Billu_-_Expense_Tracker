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

  static List<TransactionModel> sampleData = [
    TransactionModel(
      id: 'tx-1',
      title: 'coffee',
      subtitle: 'starbucks • 08:42 am',
      amount: 8.95,
      isExpense: true,
      icon: Icons.local_cafe_outlined,
      group: TransactionGroup.today,
      timestamp: DateTime.now(),
    ),
    TransactionModel(
      id: 'tx-2',
      title: 'pet care',
      subtitle: 'petco • recurring',
      amount: 64.50,
      isExpense: true,
      icon: Icons.pets_outlined,
      group: TransactionGroup.today,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    TransactionModel(
      id: 'tx-3',
      title: 'commute',
      subtitle: 'metro card topup',
      amount: 35.00,
      isExpense: true,
      icon: Icons.directions_subway_outlined,
      group: TransactionGroup.today,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    TransactionModel(
      id: 'tx-4',
      title: 'groceries',
      subtitle: "trader joe's",
      amount: 199.44,
      isExpense: true,
      icon: Icons.shopping_cart_outlined,
      group: TransactionGroup.today,
      timestamp: DateTime.now().subtract(const Duration(hours: 7)),
    ),
    TransactionModel(
      id: 'tx-5',
      title: 'audiobook',
      subtitle: 'audible',
      amount: 14.99,
      isExpense: true,
      icon: Icons.headphones_outlined,
      group: TransactionGroup.yesterday,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TransactionModel(
      id: 'tx-6',
      title: 'dispatch issue',
      subtitle: 'magazine stand',
      amount: 27.11,
      isExpense: true,
      icon: Icons.auto_stories_outlined,
      group: TransactionGroup.yesterday,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    ),
  ];
}

