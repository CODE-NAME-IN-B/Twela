import 'package:test/test.dart';
import 'package:twela/utils/formatters.dart';

void main() {
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
    test('formats date to dd/MM/yyyy', () {
      final date = DateTime(2026, 3, 15);
      expect(formatDate(date), '15/03/2026');
    });

    test('formats single digit day and month with leading zeros', () {
      final date = DateTime(2026, 1, 5);
      expect(formatDate(date), '05/01/2026');
    });
  });

  group('formatMonthYear', () {
    test('formats month and year', () {
      final date = DateTime(2026, 3, 15);
      final result = formatMonthYear(date);
      expect(result, contains('2026'));
      expect(result, contains('March') | contains('مارس'));
    });
  });
}
