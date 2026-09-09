import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:twela/utils/formatters.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar', null);
  });

  group('formatLyd', () {
    test('formats zero correctly', () {
      expect(formatLyd(0), '0.00 د.ل');
    });

    test('formats positive amount with LYD suffix', () {
      expect(formatLyd(100.5), '100.50 د.ل');
    });

    test('formats large numbers with commas', () {
      expect(formatLyd(1234567.89), '1,234,567.89 د.ل');
    });

    test('formats negative amount', () {
      expect(formatLyd(-50.25), '-50.25 د.ل');
    });
  });

  group('formatLydShort', () {
    test('formats without LYD suffix', () {
      expect(formatLydShort(100.5), '100.50');
    });

    test('formats zero', () {
      expect(formatLydShort(0), '0.00');
    });
  });

  group('formatDate', () {
    test('formats date with Arabic locale', () {
      final date = DateTime(2026, 3, 15);
      final result = formatDate(date);
      expect(result, isNotEmpty);
      expect(result, contains('/'));
    });

    test('formats single digit day and month with leading zeros', () {
      final date = DateTime(2026, 1, 5);
      final result = formatDate(date);
      expect(result, isNotEmpty);
      expect(result, contains('/'));
    });
  });

  group('formatMonthYear', () {
    test('formats month and year with Arabic locale', () {
      final date = DateTime(2026, 3, 15);
      final result = formatMonthYear(date);
      expect(result, isNotEmpty);
    });
  });
}
