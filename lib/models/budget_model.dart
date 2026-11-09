import 'package:flutter/material.dart';

class BudgetCategory {
  final String title;
  final double spent;
  final double limit;
  final IconData icon;

  const BudgetCategory({
    required this.title,
    required this.spent,
    required this.limit,
    required this.icon,
  });

  double get percentage => (spent / limit).clamp(0.0, 1.0);
  double get remaining => (limit - spent).clamp(0.0, double.infinity);

  static List<BudgetCategory> sampleCategories = [];
}

class DonutSegment {
  final String title;
  final double percentage;
  final double amount;
  final Color lightColor;
  final Color darkColor;

  const DonutSegment({
    required this.title,
    required this.percentage,
    required this.amount,
    required this.lightColor,
    required this.darkColor,
  });

  static List<DonutSegment> sampleSegments = [];
}

