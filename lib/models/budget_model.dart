import 'package:flutter/material.dart';

/// Represents a category paired with its budget limit and current spending.
class BudgetCategory {
  final String id;
  final String title;
  final double spent;
  final double? limit;
  final IconData icon;

  const BudgetCategory({
    required this.id,
    required this.title,
    required this.spent,
    this.limit,
    required this.icon,
  });

  /// Whether a positive budget limit has been configured.
  bool get hasBudget => limit != null && limit! > 0;

  /// Percentage of budget spent (0.0 to 1.0), clamped.
  double get percentage => hasBudget ? (spent / limit!).clamp(0.0, 1.0) : 0.0;

  /// Remaining budget amount.
  double get remaining => hasBudget ? (limit! - spent).clamp(0.0, double.infinity) : 0.0;

  /// Whether the budget is exhausted (>= 100%).
  bool get isBudgetExceeded => hasBudget && spent >= limit!;

  /// Whether to show an alert (>= 80% of budget).
  bool get shouldShowAlert => hasBudget && spent >= limit! * 0.8;

  /// Build from a database or memory map.
  factory BudgetCategory.fromMap(Map<String, dynamic> map) {
    final rawLimit = map['monthly_budget'];
    double? limitVal;
    if (rawLimit is num && rawLimit > 0) {
      limitVal = rawLimit.toDouble();
    }

    final rawSpent = map['total'];
    double spentVal = 0.0;
    if (rawSpent is num) {
      spentVal = rawSpent.toDouble();
    }

    final iconCode = map['category_icon'];
    IconData iconData = Icons.receipt_outlined;
    if (iconCode is int) {
      iconData = IconData(
        // ignore: non_const_argument_for_const_parameter
        iconCode,
        fontFamily: 'MaterialIcons',
      );
    }

    return BudgetCategory(
      id: (map['category_id'] ?? '').toString(),
      title: map['category_name'] as String? ?? 'General',
      spent: spentVal,
      limit: limitVal,
      icon: iconData,
    );
  }

  /// Create a copy with updated values.
  BudgetCategory copyWith({
    String? id,
    String? title,
    double? spent,
    double? limit,
    IconData? icon,
  }) {
    return BudgetCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      spent: spent ?? this.spent,
      limit: limit ?? this.limit,
      icon: icon ?? this.icon,
    );
  }
}

/// Represents a month-scoped budget definition paired with its actual spend.
class CategoryBudget {
  final int id; // budgets.id (0 when unsaved)
  final String categoryId; // categories.id as string
  final String title; // Title Case category name
  final String monthYear; // 'YYYY-MM'
  final double limitAmount;
  final double spent;
  final int iconName; // Material icon codePoint
  final bool isAlert;

  const CategoryBudget({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.monthYear,
    required this.limitAmount,
    required this.spent,
    required this.iconName,
    this.isAlert = false,
  });

  /// Percentage of budget spent (0.0 to 1.0), clamped.
  double get percentage => (limitAmount > 0) ? (spent / limitAmount).clamp(0.0, 1.0) : 0.0;

  /// Remaining budget amount.
  double get remaining => (limitAmount - spent).clamp(0.0, double.infinity);

  /// Whether the budget is exhausted (>= 100%).
  bool get isBudgetExceeded => spent >= limitAmount;

  /// Whether to show an alert (>= 80% of budget).
  bool get shouldShowAlert => spent >= limitAmount * 0.8;

  /// Build from a budgets table row joined with category info and computed spend.
  factory CategoryBudget.fromMap(
    Map<String, dynamic> map, {
    double spent = 0.0,
    bool isAlert = false,
  }) {
    return CategoryBudget(
      id: map['id'] as int? ?? 0,
      categoryId: (map['category_id'] as num).toString(),
      title: map['category_name'] as String? ?? '',
      monthYear: map['month_year'] as String? ?? '',
      limitAmount: (map['limit_amount'] as num).toDouble(),
      spent: spent,
      iconName: map['category_icon'] as int? ?? Icons.receipt_outlined.codePoint,
      isAlert: isAlert,
    );
  }

  /// Create a copy with updated values.
  CategoryBudget copyWith({
    int? id,
    String? categoryId,
    String? title,
    String? monthYear,
    double? limitAmount,
    double? spent,
    int? iconName,
    bool? isAlert,
  }) {
    return CategoryBudget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      monthYear: monthYear ?? this.monthYear,
      limitAmount: limitAmount ?? this.limitAmount,
      spent: spent ?? this.spent,
      iconName: iconName ?? this.iconName,
      isAlert: isAlert ?? this.isAlert,
    );
  }
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
