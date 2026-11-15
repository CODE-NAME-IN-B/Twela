import '../design/format.dart';

/// Legacy entry points, now backed by the INB design system.
/// Kept for the screens that predate the unified format API.
String formatLyd(double amount) => '${formatMoney(amount)} د.ل';

String formatLydShort(double amount) => formatMoney(amount);

String formatDate(DateTime date) => formatDateShort(date);

String formatDateTime(DateTime date) => formatDateTimeShort(date);

String formatMonthYear(DateTime date) =>
    '${kArabicMonths[date.month - 1]} ${latn('${date.year}')}';
