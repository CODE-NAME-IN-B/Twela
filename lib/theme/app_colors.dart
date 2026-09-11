import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Brand ───────────────────────────────────────────
  static const Color primary = Color(0xFF0A846B);
  static const Color primaryHover = Color(0xFF097A61);
  static const Color primaryLight = Color(0xFF10B981);
  static const Color primarySurface = Color(0xFFECFDF5);

  // ─── Semantic: Transaction Types ─────────────────────
  static const Color income = Color(0xFF149C6D);
  static const Color incomeSurface = Color(0xFFECFDF5);
  static const Color incomeLight = Color(0xFFD1FAE5);

  static const Color expense = Color(0xFFC4483A);
  static const Color expenseSurface = Color(0xFFFEF2F2);
  static const Color expenseLight = Color(0xFFFECDD3);

  static const Color debt = Color(0xFFD97706);
  static const Color debtSurface = Color(0xFFFFFBEB);
  static const Color debtLight = Color(0xFFFDE68A);

  static const Color savings = Color(0xFF0891B2);
  static const Color savingsSurface = Color(0xFFECFEFF);
  static const Color savingsLight = Color(0xFFA5F3FC);

  // ─── Semantic: Status ────────────────────────────────
  static const Color success = Color(0xFF149C6D);
  static const Color successSurface = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF5A524);
  static const Color warningSurface = Color(0xFFFFFBEB);
  static const Color danger = Color(0xFFC4483A);
  static const Color dangerSurface = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSurface = Color(0xFFEFF6FF);

  // ─── Neutral: Light Theme ───────────────────────────
  static const Color background = Color(0xFFFAF8F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1C1917);
  static const Color textSecondary = Color(0xFF78716C);
  static const Color textTertiary = Color(0xFFA8A29E);
  static const Color border = Color(0xFFE7E5E4);
  static const Color borderLight = Color(0xFFF5F5F4);
  static const Color divider = Color(0xFFE7E5E4);

  // ─── Neutral: Dark Theme ────────────────────────────
  static const Color darkBackground = Color(0xFF1A1815);
  static const Color darkSurface = Color(0xFF292524);
  static const Color darkCard = Color(0xFF292524);
  static const Color darkTextPrimary = Color(0xFFF5F5F4);
  static const Color darkTextSecondary = Color(0xFFA8A29E);
  static const Color darkTextTertiary = Color(0xFF78716C);
  static const Color darkBorder = Color(0xFF44403C);
  static const Color darkDivider = Color(0xFF44403C);

  // ─── Gradient ────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0A846B), Color(0xFF06A67A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Helpers ─────────────────────────────────────────
  static Color semanticForType(String type, {bool isDark = false}) {
    switch (type) {
      case 'income':
        return income;
      case 'expense':
        return expense;
      case 'debt':
        return debt;
      case 'savings':
        return savings;
      default:
        return primary;
    }
  }

  static Color surfaceForType(String type, {bool isDark = false}) {
    if (isDark) return darkSurface;
    switch (type) {
      case 'income':
        return incomeSurface;
      case 'expense':
        return expenseSurface;
      case 'debt':
        return debtSurface;
      case 'savings':
        return savingsSurface;
      default:
        return surface;
    }
  }
}
