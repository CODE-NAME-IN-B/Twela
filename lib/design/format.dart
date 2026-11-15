import 'package:flutter/material.dart';

import 'motion.dart';
import 'theme.dart';
import 'tokens.dart';

/// ─── Latin-digit guard ────────────────────────────────────────────────────
/// `intl`'s Arabic locales emit Arabic-Indic digits (٢٠٢٦) which fight the
/// mono Latin numerals used everywhere else in this app. Every formatter here
/// produces Latin digits, and [latn] is the safety net for any string that
/// still carries Arabic-Indic digits.
final RegExp _arabicIndicDigits = RegExp(r'[\u0660-\u0669\u06F0-\u06F9]');

String latn(String input) => input.replaceAllMapped(
      _arabicIndicDigits,
      (m) => String.fromCharCode(m[0]!.codeUnitAt(0) - 0x0660 + 0x30),
    );

const List<String> kArabicMonths = <String>[
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

const List<String> kArabicWeekdays = <String>[
  'الإثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
  'الأحد',
];

/// ─── Numbers ─────────────────────────────────────────────────────────────
String formatNumber(double value, {int decimals = 2, bool grouping = true}) {
  final fixed = value.toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final digits = parts.first;
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (grouping && i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  if (parts.length > 1) buffer.write('.${parts[1]}');
  return buffer.toString();
}

/// `1500` → `1,500` ; `1500.5` → `1,500.50`
String formatMoney(double value, {int decimals = 2}) =>
    formatNumber(value, decimals: decimals);

/// Compact form for tight cells: `1.5K`, `12.3K`, `1.2M`.
String formatCompact(double value) {
  final abs = value.abs();
  if (abs >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (abs >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
  return formatNumber(value, decimals: 0);
}

String formatPercent(double ratio, {int decimals = 0}) =>
    '${(ratio * 100).toStringAsFixed(decimals)}%';

/// ─── Dates ───────────────────────────────────────────────────────────────
String formatDateShort(DateTime d) =>
    '${_two(d.day)}/${_two(d.month)}/${d.year}';

String formatDateLong(DateTime d) =>
    '${d.day} ${kArabicMonths[d.month - 1]} ${d.year}';

String formatMonthYear(DateTime d) => '${kArabicMonths[d.month - 1]} ${d.year}';

String formatWeekday(DateTime d) => kArabicWeekdays[d.weekday - 1];

String formatTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

String formatDateTimeShort(DateTime d) =>
    '${formatDateShort(d)} · ${formatTime(d)}';

String _two(int n) => n.toString().padLeft(2, '0');

/// ─── Money widget ────────────────────────────────────────────────────────
/// One atomic unit: the number in mono Latin digits and the currency in the
/// Arabic face. Building this as a [Row] instead of a string keeps the visual
/// order stable in RTL and removes every bidi edge case from the screens.
class Money extends StatelessWidget {
  const Money(
    this.amount, {
    super.key,
    this.size = 16,
    this.color,
    this.weight = FontWeight.w700,
    this.decimals = 2,
    this.showCurrency = true,
    this.signed = false,
    this.currency = 'د.ل',
    this.animate = false,
  });

  final double amount;
  final double size;
  final Color? color;
  final FontWeight weight;
  final int decimals;
  final bool showCurrency;
  final bool signed;
  final String currency;

  /// Counts up once on first build ([CountUp] behaviour for amounts).
  final bool animate;

  String _text(BuildContext context, double v) {
    final prefix = signed ? (v < 0 ? '−' : '+') : '';
    return '$prefix${formatMoney(v, decimals: decimals)}';
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.inb.fg;
    final numberStyle =
        monoStyle(context, size: size, weight: weight, color: c);
    final number = (animate && !reduceMotion(context))
        ? TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: amount),
            duration: Motion.slow * 1.4,
            curve: Motion.emphasized,
            builder: (_, v, __) => Text(_text(context, v), style: numberStyle),
          )
        : Text(_text(context, amount), style: numberStyle);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        number,
        if (showCurrency) ...[
          const SizedBox(width: 4),
          Text(
            currency,
            style: TextStyle(
              fontFamily: InbFonts.arabic,
              fontSize: size * 0.72,
              fontWeight: FontWeight.w400,
              height: 1.1,
              color: c,
            ),
          ),
        ],
      ],
    );
  }
}

/// A signed money delta with an explicit direction word, used in lists.
class MoneyDelta extends StatelessWidget {
  const MoneyDelta(
    this.amount, {
    super.key,
    this.positive,
    this.size = 15,
    this.color,
  });

  final double amount;
  final bool? positive;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final up = positive ?? amount >= 0;
    return Money(
      amount.abs(),
      size: size,
      color: color ?? (up ? context.sem.income : context.sem.expense),
      signed: true,
    );
  }
}
