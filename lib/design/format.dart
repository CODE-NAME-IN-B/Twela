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
/// Every number in this app is Latin-digit, mono and minus-signed with the
/// real minus (U+2212) — never an ASCII hyphen, which flips to the wrong side
/// of the number in an RTL paragraph. The sign is decided from the *value*,
/// not from the formatted string, so `−100.00` can never become `-,100`.
String formatNumber(double value, {int decimals = 2, bool grouping = true}) {
  final abs = value.abs();
  final fixed = abs.toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final digits = parts.first;
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (grouping && i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  if (parts.length > 1) buffer.write('.${parts[1]}');
  final body = buffer.toString();
  // A value that rounds to zero keeps no sign: `−0.00` is noise.
  if (value < 0 && double.parse(fixed) != 0) return '−$body';
  return body;
}

/// `1500` → `1,500` ; `1500.5` → `1,500.50` ; `-100` → `−100`
String formatMoney(double value, {int decimals = 2}) =>
    formatNumber(value, decimals: decimals);

/// Compact form for tight cells: `1.5K`, `12.3K`, `1.2M`.
String formatCompact(double value) {
  final abs = value.abs();
  final String body;
  if (abs >= 1000000) {
    body = '${(abs / 1000000).toStringAsFixed(1)}M';
  } else if (abs >= 1000) {
    body = '${(abs / 1000).toStringAsFixed(1)}K';
  } else {
    body = formatNumber(abs, decimals: 0);
  }
  if (value < 0 && abs >= 1) return '−$body';
  return body;
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
/// Arabic face.
///
/// Everything sits inside a `Directionality(ltr)` so the number always reads
/// `1,200.00 د.ل` — number first, `د.ل` after it — no matter which direction
/// the screen runs in. That is what kills the trailing-sign and `--` bidi
/// bugs: the sign is part of the number's own LTR run, never a stray glyph
/// the paragraph can reorder.
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

  /// Renders an explicit `+` / `−` in front of the number.
  final bool signed;
  final String currency;

  /// Counts up once on first build ([CountUp] behaviour for amounts).
  final bool animate;

  /// The sign belongs to the value, never to the tween: the animation runs on
  /// the magnitude only, so a negative amount can never flash `+` on the way.
  String _text(double v) {
    final body = formatMoney(v, decimals: decimals);
    // A value that rounds to zero carries no sign — `−0.00` is noise.
    final negative = amount < 0 && double.parse(body) != 0;
    if (signed) return negative ? '−$body' : '+$body';
    return negative ? '−$body' : body;
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.inb.fg;
    final numberStyle =
        monoStyle(context, size: size, weight: weight, color: c);
    final magnitude = amount.abs();
    final number = (animate && !reduceMotion(context))
        ? TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: magnitude),
            duration: Motion.slow * 1.4,
            curve: Motion.emphasized,
            builder: (_, v, __) => Text(_text(v), style: numberStyle),
          )
        : Text(_text(magnitude), style: numberStyle);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
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
      ),
    );
  }
}

/// A signed money delta: `+1,200.00` in green, `−100.00` in ink.
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
    final value = up ? amount.abs() : -amount.abs();
    return Money(
      value,
      size: size,
      color: color ?? (up ? context.sem.income : context.sem.expense),
      signed: true,
    );
  }
}
