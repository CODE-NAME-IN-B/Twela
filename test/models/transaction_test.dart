import 'package:flutter_test/flutter_test.dart';
import 'package:twela/models/transaction.dart';

void main() {
  group('TwelaTransaction Model', () {
    test('isExpense returns true for expense type', () {
      final tx = TwelaTransaction(
        id: '1',
        amount: 10.0,
        type: TransactionType.expense,
        walletType: WalletType.cash,
        categoryId: 'cat-1',
        date: DateTime(2026, 1, 1),
      );
      expect(tx.isExpense, true);
      expect(tx.isIncome, false);
      expect(tx.isDebt, false);
      expect(tx.isSavings, false);
    });

    test('isDebt returns true for debt types', () {
      final given = TwelaTransaction(
        id: '1',
        amount: 10.0,
        type: TransactionType.debtGiven,
        walletType: WalletType.cash,
        categoryId: '',
        date: DateTime(2026, 1, 1),
      );
      final received = TwelaTransaction(
        id: '2',
        amount: 10.0,
        type: TransactionType.debtReceived,
        walletType: WalletType.cash,
        categoryId: '',
        date: DateTime(2026, 1, 1),
      );
      final payment = TwelaTransaction(
        id: '3',
        amount: 10.0,
        type: TransactionType.debtPayment,
        walletType: WalletType.cash,
        categoryId: '',
        date: DateTime(2026, 1, 1),
      );
      expect(given.isDebt, true);
      expect(received.isDebt, true);
      expect(payment.isDebt, true);
    });

    test('isSavings returns true for savings type', () {
      final tx = TwelaTransaction(
        id: '1',
        amount: 10.0,
        type: TransactionType.savings,
        walletType: WalletType.cash,
        categoryId: '',
        date: DateTime(2026, 1, 1),
      );
      expect(tx.isSavings, true);
    });

    test('toJson/fromJson roundtrip preserves all fields', () {
      final tx = TwelaTransaction(
        id: '1',
        amount: 10.5,
        type: TransactionType.expense,
        walletType: WalletType.bank,
        categoryId: 'cat-1',
        note: 'Test note',
        date: DateTime(2026, 1, 1),
        relatedId: 'related-1',
      );
      final json = tx.toJson();
      final restored = TwelaTransaction.fromJson(json);
      expect(restored.id, tx.id);
      expect(restored.amount, tx.amount);
      expect(restored.type, tx.type);
      expect(restored.walletType, tx.walletType);
      expect(restored.categoryId, tx.categoryId);
      expect(restored.note, tx.note);
      expect(restored.relatedId, tx.relatedId);
    });

    test('copyWith preserves all fields', () {
      final tx = TwelaTransaction(
        id: '1',
        amount: 10.0,
        type: TransactionType.expense,
        walletType: WalletType.cash,
        categoryId: 'cat-1',
        date: DateTime(2026, 1, 1),
      );
      final updated = tx.copyWith(amount: 20.0);
      expect(updated.amount, 20.0);
      expect(updated.walletType, WalletType.cash);
      expect(updated.categoryId, 'cat-1');
    });
  });
}
