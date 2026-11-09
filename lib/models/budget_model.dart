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

  static List<BudgetCategory> sampleCategories = [
    const BudgetCategory(
      title: 'groceries',
      spent: 350,
      limit: 400,
      icon: Icons.shopping_basket_outlined,
    ),
    const BudgetCategory(
      title: 'dining',
      spent: 120,
      limit: 150,
      icon: Icons.restaurant_outlined,
    ),
    const BudgetCategory(
      title: 'commute',
      spent: 85,
      limit: 120,
      icon: Icons.directions_subway_outlined,
    ),
    const BudgetCategory(
      title: 'shopping',
      spent: 145,
      limit: 250,
      icon: Icons.local_mall_outlined,
    ),
  ];
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

  static List<DonutSegment> sampleSegments = [
    const DonutSegment(
      title: 'dining & food',
      percentage: 0.38,
      amount: 700,
      lightColor: Color(0xFF000000),
      darkColor: Color(0xFFFFFFFF),
    ),
    const DonutSegment(
      title: 'rent & bills',
      percentage: 0.32,
      amount: 588,
      lightColor: Color(0xFF474747),
      darkColor: Color(0xFFB6B5B4),
    ),
    const DonutSegment(
      title: 'commute',
      percentage: 0.15,
      amount: 276,
      lightColor: Color(0xFF7E7576),
      darkColor: Color(0xFF7E7576),
    ),
    const DonutSegment(
      title: 'shopping',
      percentage: 0.15,
      amount: 276,
      lightColor: Color(0xFFCFC4C5),
      darkColor: Color(0xFF444748),
    ),
  ];
}

