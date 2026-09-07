import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF0A846B);
  static const Color primaryHover = Color(0xFF097A61);
  static const Color primaryLight = Color(0xFF10B981);
  static const Color primarySurface = Color(0xFFECFDF5);

  // Semantic
  static const Color success = Color(0xFF149C6D);
  static const Color successSurface = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF5A524);
  static const Color warningSurface = Color(0xFFFFFBEB);
  static const Color danger = Color(0xFFE5484D);
  static const Color dangerSurface = Color(0xFFFEF2F2);

  // Neutral - Light
  static const Color background = Color(0xFFF8FAFB);
  static const Color surface = Colors.white;
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  // Neutral - Dark
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkDivider = Color(0xFF334155);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0A846B), Color(0xFF06A67A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
