import 'package:flutter/material.dart';

enum TransactionCategoryType { expense, income, transfer }

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final TransactionCategoryType type;
  final bool isCustom; // True for user-created categories

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': icon.codePoint,
      'type': type.name,
      'isCustom': isCustom,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    TransactionCategoryType catType;
    switch (map['type'] as String?) {
      case 'income':
        catType = TransactionCategoryType.income;
        break;
      case 'transfer':
        catType = TransactionCategoryType.transfer;
        break;
      case 'expense':
      default:
        catType = TransactionCategoryType.expense;
    }

    return CategoryModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] as String? ?? '',
      icon: IconData(
        // ignore: non_const_argument_for_const_parameter
        map['iconCodePoint'] as int? ?? Icons.receipt_outlined.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      type: catType,
      isCustom: map['isCustom'] as bool? ?? false,
    );
  }

  static const List<CategoryModel> defaultExpenseCategories = [
    CategoryModel(id: 'cat-gen', name: 'General', icon: Icons.receipt_outlined, type: TransactionCategoryType.expense),
    CategoryModel(id: 'cat-groc', name: 'Groceries', icon: Icons.shopping_cart_outlined, type: TransactionCategoryType.expense),
    CategoryModel(id: 'cat-coff', name: 'Coffee & Drinks', icon: Icons.local_cafe_outlined, type: TransactionCategoryType.expense),
    CategoryModel(id: 'cat-dine', name: 'Dining & Food', icon: Icons.restaurant_outlined, type: TransactionCategoryType.expense),
    CategoryModel(id: 'cat-tran', name: 'Transit & Commute', icon: Icons.directions_subway_outlined, type: TransactionCategoryType.expense),
    CategoryModel(id: 'cat-shop', name: 'Shopping', icon: Icons.local_mall_outlined, type: TransactionCategoryType.expense),
    CategoryModel(id: 'cat-rent', name: 'Rent & Utilities', icon: Icons.home_outlined, type: TransactionCategoryType.expense),
    CategoryModel(id: 'cat-ent', name: 'Entertainment', icon: Icons.movie_outlined, type: TransactionCategoryType.expense),
    CategoryModel(id: 'cat-pet', name: 'Pet Care', icon: Icons.pets_outlined, type: TransactionCategoryType.expense),
  ];

  static const List<CategoryModel> defaultIncomeCategories = [
    CategoryModel(id: 'cat-sal', name: 'Salary', icon: Icons.work_outline_rounded, type: TransactionCategoryType.income),
    CategoryModel(id: 'cat-room', name: 'Room Rent', icon: Icons.real_estate_agent_outlined, type: TransactionCategoryType.income),
    CategoryModel(id: 'cat-coup', name: 'Coupon', icon: Icons.confirmation_number_outlined, type: TransactionCategoryType.income),
    CategoryModel(id: 'cat-cash', name: 'Cashback', icon: Icons.savings_outlined, type: TransactionCategoryType.income),
    CategoryModel(id: 'cat-give', name: 'Given', icon: Icons.volunteer_activism_outlined, type: TransactionCategoryType.income),
    CategoryModel(id: 'cat-inv', name: 'Investment', icon: Icons.trending_up_rounded, type: TransactionCategoryType.income),
    CategoryModel(id: 'cat-other', name: 'Other Income', icon: Icons.attach_money_rounded, type: TransactionCategoryType.income),
  ];

  static const List<CategoryModel> defaultTransferCategories = [
    CategoryModel(id: 'cat-transfer', name: 'Transfer', icon: Icons.swap_horiz_rounded, type: TransactionCategoryType.transfer),
  ];

  static List<CategoryModel> getDefaultsForType(TransactionCategoryType type) {
    switch (type) {
      case TransactionCategoryType.income:
        return defaultIncomeCategories;
      case TransactionCategoryType.transfer:
        return defaultTransferCategories;
      case TransactionCategoryType.expense:
        return defaultExpenseCategories;
    }
  }

  static CategoryModel getDefaultForType(TransactionCategoryType type) {
    return getDefaultsForType(type).first;
  }
}

