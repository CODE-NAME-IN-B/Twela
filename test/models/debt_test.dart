import 'package:test/test.dart';
import 'package:twela/models/debt.dart';

void main() {
  group('Debt Model', () {
    test('creates with default walletType', () {
      final debt = Debt(
        id: '1',
        personName: 'Ahmed',
        itemDescription: 'Loan',
        totalAmount: 100.0,
        date: DateTime(2026, 1, 1),
      );
      expect(debt.walletType, 'cash');
    });

    test('remaining calculates correctly', () {
      final debt = Debt(
        id: '1',
        personName: 'Ahmed',
        itemDescription: 'Loan',
        totalAmount: 100.0,
        paidAmount: 30.0,
        date: DateTime(2026, 1, 1),
      );
      expect(debt.remaining, 70.0);
    });

    test('isPaidOff returns true when fully paid', () {
      final debt = Debt(
        id: '1',
        personName: 'Ahmed',
        itemDescription: 'Loan',
        totalAmount: 100.0,
        paidAmount: 100.0,
        date: DateTime(2026, 1, 1),
      );
      expect(debt.isPaidOff, true);
    });

    test('isPaidOff returns false when partially paid', () {
      final debt = Debt(
        id: '1',
        personName: 'Ahmed',
        itemDescription: 'Loan',
        totalAmount: 100.0,
        paidAmount: 50.0,
        date: DateTime(2026, 1, 1),
      );
      expect(debt.isPaidOff, false);
    });

    test('toJson/fromJson roundtrip preserves walletType', () {
      final debt = Debt(
        id: '1',
        personName: 'Ahmed',
        itemDescription: 'Loan',
        totalAmount: 100.0,
        paidAmount: 30.0,
        date: DateTime(2026, 1, 1),
        walletType: 'bank',
      );
      final json = debt.toJson();
      final restored = Debt.fromJson(json);
      expect(restored.walletType, 'bank');
    });

    test('fromJson defaults walletType to cash when missing', () {
      final json = {
        'id': '1',
        'personName': 'Ahmed',
        'itemDescription': 'Loan',
        'totalAmount': 100.0,
        'date': '2026-01-01T00:00:00.000',
      };
      final debt = Debt.fromJson(json);
      expect(debt.walletType, 'cash');
    });

    test('copyWith preserves walletType', () {
      final debt = Debt(
        id: '1',
        personName: 'Ahmed',
        itemDescription: 'Loan',
        totalAmount: 100.0,
        date: DateTime(2026, 1, 1),
        walletType: 'bank',
      );
      final updated = debt.copyWith(paidAmount: 50.0);
      expect(updated.walletType, 'bank');
    });
  });
}
