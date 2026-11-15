import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Compatibility layer: maps legacy `AppColors` names to INB tokens.
///
/// Every value is sourced from [InbColors] / [InbSemantics] so the design
/// system stays the single source of truth.
class AppColors {
  AppColors._();

  // ── Base (light INB values; screens pick dark variants via context.inb) ──
  static Color get primary => InbColors.light.fg;
  static Color get income => InbSemantics.light.income;
  static Color get expense => InbSemantics.light.expense;
  static Color get debt => InbSemantics.light.debt;
  static Color get savings => InbSemantics.light.savings;
  static Color get success => InbSemantics.light.income;
  static Color get danger => InbSemantics.light.danger;
  static Color get warning => InbSemantics.light.warning;
  static Color get info => InbColors.light.indigo;

  // ── Surfaces ──
  static Color get surface => InbColors.light.surface;
  static Color get card => InbColors.light.surface;
  static Color get darkSurface => InbColors.dark.surface;
  static Color get darkCard => InbColors.dark.surface;
  static Color get darkBackground => InbColors.dark.paper;

  // ── Lines ──
  static Color get border => InbColors.light.line;
  static Color get borderLight => InbColors.light.line;
  static Color get darkBorder => InbColors.dark.line;
  static Color get divider => InbColors.light.line;

  // ── Text ──
  static Color get textPrimary => InbColors.light.fg;
  static Color get textSecondary => InbColors.light.muted;
  static Color get textTertiary => InbColors.light.muted;
  static Color get darkTextPrimary => InbColors.dark.fg;
  static Color get darkTextSecondary => InbColors.dark.muted;
  static Color get darkTextTertiary => InbColors.dark.muted;

  // ── Semantic surfaces (tinted) ──
  static Color get primarySurface =>
      InbSemantics.light.income.withValues(alpha: 0.12);
  static Color get incomeSurface =>
      InbSemantics.light.income.withValues(alpha: 0.12);
  static Color get expenseSurface =>
      InbSemantics.light.expense.withValues(alpha: 0.12);
  static Color get debtSurface =>
      InbSemantics.light.debt.withValues(alpha: 0.12);
  static Color get successSurface =>
      InbSemantics.light.income.withValues(alpha: 0.12);
  static Color get savingsSurface =>
      InbSemantics.light.savings.withValues(alpha: 0.12);
  static Color get dangerSurface =>
      InbSemantics.light.danger.withValues(alpha: 0.12);
}
