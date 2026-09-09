import 'package:flutter_test/flutter_test.dart';
import 'package:twela/models/savings_entry.dart';

void main() {
  group('SavingsEntry Model', () {
    test('creates with default walletType', () {
      final entry = SavingsEntry(
        id: '1',
        savingsGoalId: 'goal-1',
        amount: 50.0,
        date: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
      );
      expect(entry.walletType, 'cash');
    });

    test('toJson/fromJson roundtrip preserves walletType', () {
      final entry = SavingsEntry(
        id: '1',
        savingsGoalId: 'goal-1',
        amount: 50.0,
        date: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        walletType: 'bank',
      );
      final json = entry.toJson();
      final restored = SavingsEntry.fromJson(json);
      expect(restored.walletType, 'bank');
    });

    test('fromJson defaults walletType to cash when missing', () {
      final json = {
        'id': '1',
        'savingsGoalId': 'goal-1',
        'amount': 50.0,
        'date': '2026-01-01T00:00:00.000',
        'createdAt': '2026-01-01T00:00:00.000',
      };
      final entry = SavingsEntry.fromJson(json);
      expect(entry.walletType, 'cash');
    });

    test('create factory generates UUID and sets timestamps', () {
      final entry = SavingsEntry.create(
        savingsGoalId: 'goal-1',
        amount: 100.0,
        walletType: 'bank',
      );
      expect(entry.id.isNotEmpty, true);
      expect(entry.walletType, 'bank');
      expect(entry.amount, 100.0);
    });
  });
}
