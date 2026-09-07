import 'package:flutter/material.dart';

class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double? monthlyLimit;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.monthlyLimit,
  });

  ExpenseCategory copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    double? monthlyLimit,
    bool clearLimit = false,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      monthlyLimit: clearLimit ? null : (monthlyLimit ?? this.monthlyLimit),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'colorValue': color.value,
      'monthlyLimit': monthlyLimit,
    };
  }

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: IconData(
        json['iconCodePoint'] as int,
        fontFamily: json['iconFontFamily'] as String?,
      ),
      color: Color(json['colorValue'] as int),
      monthlyLimit: (json['monthlyLimit'] as num?)?.toDouble(),
    );
  }

  static List<ExpenseCategory> defaultCategories() {
    return [
      ExpenseCategory(
        id: 'food',
        name: 'أكل وشرب',
        icon: Icons.restaurant_outlined,
        color: const Color(0xFFF59E0B),
      ),
      ExpenseCategory(
        id: 'transport',
        name: 'مواصلات',
        icon: Icons.directions_car_outlined,
        color: const Color(0xFF3B82F6),
      ),
      ExpenseCategory(
        id: 'bills',
        name: 'فواتير',
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFFEF4444),
      ),
      ExpenseCategory(
        id: 'groceries',
        name: 'بقالة',
        icon: Icons.shopping_cart_outlined,
        color: const Color(0xFF10B981),
      ),
      ExpenseCategory(
        id: 'entertainment',
        name: 'ترفيه',
        icon: Icons.sports_esports_outlined,
        color: const Color(0xFF8B5CF6),
      ),
      ExpenseCategory(
        id: 'health',
        name: 'صحة',
        icon: Icons.local_hospital_outlined,
        color: const Color(0xFFEC4899),
      ),
      ExpenseCategory(
        id: 'education',
        name: 'تعليم',
        icon: Icons.school_outlined,
        color: const Color(0xFF06B6D4),
      ),
      ExpenseCategory(
        id: 'clothing',
        name: 'ملابس',
        icon: Icons.checkroom_outlined,
        color: const Color(0xFFF97316),
      ),
      ExpenseCategory(
        id: 'gifts',
        name: 'هدايا',
        icon: Icons.card_giftcard_outlined,
        color: const Color(0xFFA855F7),
      ),
      ExpenseCategory(
        id: 'other',
        name: 'أخرى',
        icon: Icons.more_horiz_outlined,
        color: const Color(0xFF6B7280),
      ),
    ];
  }
}
