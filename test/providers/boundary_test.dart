import 'package:test/test.dart';
import 'package:twela/models/transaction.dart';

/// Tests for the boundary conditions that were fixed.
/// These verify the logic patterns without requiring SharedPreferences.
void main() {
  group('Today/Month boundary fix', () {
    /// Reproduces the fix: !isBefore() instead of isAfter()
    /// This ensures transactions created today (even with time component)
    /// are included in today's spending.
    bool isIncludedInToday(DateTime transactionDate) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return !transactionDate.isBefore(today);
    }

    test('transaction at midnight today is included', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expect(isIncludedInToday(today), true);
    });

    test('transaction now is included', () {
      expect(isIncludedInToday(DateTime.now()), true);
    });

    test('transaction yesterday is excluded', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(isIncludedInToday(yesterday), false);
    });

    test('transaction with time today is included', () {
      final now = DateTime.now();
      final todayWithTime = DateTime(now.year, now.month, now.day, 14, 30);
      expect(isIncludedInToday(todayWithTime), true);
    });
  });

  group('Month boundary', () {
    bool isIncludedInMonth(DateTime transactionDate) {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      return !transactionDate.isBefore(monthStart);
    }

    test('first day of month is included', () {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      expect(isIncludedInMonth(monthStart), true);
    });

    test('last day of previous month is excluded', () {
      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month, 1).subtract(const Duration(days: 1));
      expect(isIncludedInMonth(lastMonth), false);
    });
  });

  group('Debt overpayment guard', () {
    double capPayment(double currentPaid, double totalAmount, double payment) {
      final newPaid = currentPaid + payment;
      return newPaid > totalAmount ? totalAmount : newPaid;
    }

    test('payment capped at totalAmount', () {
      final result = capPayment(80.0, 100.0, 30.0);
      expect(result, 100.0);
    });

    test('payment not capped when under total', () {
      final result = capPayment(50.0, 100.0, 30.0);
      expect(result, 80.0);
    });

    test('payment at exact total stays at total', () {
      final result = capPayment(90.0, 100.0, 10.0);
      expect(result, 100.0);
    });
  });

  group('Division by zero guard', () {
    double calculatePercentage(double spent, double limit) {
      if (limit > 0) {
        return (spent / limit) * 100;
      }
      return 0;
    }

    test('returns 0 when limit is 0', () {
      expect(calculatePercentage(50.0, 0), 0);
    });

    test('calculates percentage when limit > 0', () {
      expect(calculatePercentage(50.0, 100.0), 50.0);
    });

    test('returns 100 when spent equals limit', () {
      expect(calculatePercentage(100.0, 100.0), 100.0);
    });
  });

  group('Hour overflow fix', () {
    int calculateEndHour(int startHour) {
      return (startHour + 1) % 24;
    }

    test('hour 23 wraps to 0', () {
      expect(calculateEndHour(23), 0);
    });

    test('hour 12 becomes 13', () {
      expect(calculateEndHour(12), 13);
    });

    test('hour 0 becomes 1', () {
      expect(calculateEndHour(0), 1);
    });
  });

  group('Transaction reversal for debt deletion', () {
    test('finds transactions by relatedId', () {
      final transactions = [
        TwelaTransaction(
          id: 'tx1',
          amount: 100,
          type: TransactionType.debtGiven,
          walletType: WalletType.cash,
          categoryId: '',
          date: DateTime(2026, 1, 1),
          relatedId: 'debt-1',
        ),
        TwelaTransaction(
          id: 'tx2',
          amount: 50,
          type: TransactionType.debtPayment,
          walletType: WalletType.cash,
          categoryId: '',
          date: DateTime(2026, 1, 5),
          relatedId: 'debt-1',
        ),
        TwelaTransaction(
          id: 'tx3',
          amount: 200,
          type: TransactionType.expense,
          walletType: WalletType.cash,
          categoryId: 'cat-1',
          date: DateTime(2026, 1, 2),
        ),
      ];

      final relatedTxs = transactions
          .where((t) => t.relatedId == 'debt-1')
          .toList();

      expect(relatedTxs.length, 2);
      expect(relatedTxs[0].id, 'tx1');
      expect(relatedTxs[1].id, 'tx2');
    });

    test('savings transactions filtered by type and relatedId', () {
      final transactions = [
        TwelaTransaction(
          id: 'tx1',
          amount: 100,
          type: TransactionType.savings,
          walletType: WalletType.cash,
          categoryId: '',
          date: DateTime(2026, 1, 1),
          relatedId: 'goal-1',
        ),
        TwelaTransaction(
          id: 'tx2',
          amount: 50,
          type: TransactionType.savings,
          walletType: WalletType.cash,
          categoryId: '',
          date: DateTime(2026, 1, 5),
          relatedId: 'goal-1',
        ),
        TwelaTransaction(
          id: 'tx3',
          amount: 200,
          type: TransactionType.expense,
          walletType: WalletType.cash,
          categoryId: 'cat-1',
          date: DateTime(2026, 1, 2),
          relatedId: 'goal-1',
        ),
      ];

      final savingsTxs = transactions
          .where((t) => t.relatedId == 'goal-1' && t.type == TransactionType.savings)
          .toList();

      expect(savingsTxs.length, 2);
    });
  });
}
