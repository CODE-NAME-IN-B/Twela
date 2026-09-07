import 'package:intl/intl.dart';

String formatLyd(double amount) {
  final formatter = NumberFormat('#,##0.00', 'en_US');
  return '${formatter.format(amount)} د.ل';
}

String formatLydShort(double amount) {
  final formatter = NumberFormat('#,##0.00', 'en_US');
  return formatter.format(amount);
}

String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy', 'ar').format(date);
}

String formatDateTime(DateTime date) {
  return DateFormat('dd/MM/yyyy hh:mm a', 'ar').format(date);
}

String formatMonthYear(DateTime date) {
  return DateFormat('MMMM yyyy', 'ar').format(date);
}
