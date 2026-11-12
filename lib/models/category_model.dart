import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String emoji;
  final IconData icon;
  final String type; // 'expense' | 'income'

  const CategoryModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.icon,
    this.type = 'expense',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'iconCodePoint': icon.codePoint,
      'type': type,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] as String? ?? '',
      emoji: map['emoji'] as String? ?? '🏷️',
      icon: IconData(
        // ignore: non_const_argument_for_const_parameter
        map['iconCodePoint'] as int? ?? Icons.receipt_outlined.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      type: map['type'] as String? ?? 'expense',
    );
  }

  static const List<CategoryModel> defaultExpenseCategories = [
    CategoryModel(id: 'cat-gen', name: 'General', emoji: '🏷️', icon: Icons.receipt_outlined, type: 'expense'),
    CategoryModel(id: 'cat-groc', name: 'Groceries', emoji: '🛒', icon: Icons.shopping_cart_outlined, type: 'expense'),
    CategoryModel(id: 'cat-coff', name: 'Coffee & Drinks', emoji: '☕', icon: Icons.local_cafe_outlined, type: 'expense'),
    CategoryModel(id: 'cat-dine', name: 'Dining & Food', emoji: '🍽️', icon: Icons.restaurant_outlined, type: 'expense'),
    CategoryModel(id: 'cat-tran', name: 'Transit & Commute', emoji: '🚇', icon: Icons.directions_subway_outlined, type: 'expense'),
    CategoryModel(id: 'cat-shop', name: 'Shopping', emoji: '🛍️', icon: Icons.local_mall_outlined, type: 'expense'),
    CategoryModel(id: 'cat-rent', name: 'Rent & Utilities', emoji: '🏠', icon: Icons.home_outlined, type: 'expense'),
    CategoryModel(id: 'cat-ent', name: 'Entertainment', emoji: '🎬', icon: Icons.movie_outlined, type: 'expense'),
    CategoryModel(id: 'cat-pet', name: 'Pet Care', emoji: '🐾', icon: Icons.pets_outlined, type: 'expense'),
  ];

  static const List<CategoryModel> defaultIncomeCategories = [
    CategoryModel(id: 'cat-sal', name: 'Salary', emoji: '💼', icon: Icons.work_outline_rounded, type: 'income'),
    CategoryModel(id: 'cat-room', name: 'Room Rent', emoji: '🏠', icon: Icons.real_estate_agent_outlined, type: 'income'),
    CategoryModel(id: 'cat-coup', name: 'Coupon', emoji: '🎟️', icon: Icons.confirmation_number_outlined, type: 'income'),
    CategoryModel(id: 'cat-cash', name: 'Cashback', emoji: '🪙', icon: Icons.savings_outlined, type: 'income'),
    CategoryModel(id: 'cat-give', name: 'Given', emoji: '🤝', icon: Icons.volunteer_activism_outlined, type: 'income'),
    CategoryModel(id: 'cat-inv', name: 'Investment', emoji: '📈', icon: Icons.trending_up_rounded, type: 'income'),
    CategoryModel(id: 'cat-other', name: 'Other Income', emoji: '💵', icon: Icons.attach_money_rounded, type: 'income'),
  ];
}

