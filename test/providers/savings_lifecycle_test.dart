import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:twela/models/debt.dart';
import 'package:twela/models/savings_entry.dart';
import 'package:twela/models/savings_goal.dart';
import 'package:twela/models/transaction.dart';
import 'package:twela/providers/debt_provider.dart';
import 'package:twela/providers/savings_provider.dart';
import 'package:twela/providers/twela_provider.dart';
import 'package:twela/services/storage_service.dart';

/// The full savings lifecycle the user reported as broken:
/// deposit · withdraw · transfer-to-debt · edit · pause/resume ·
/// delete + undo · net amount never negative.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;
  late TwelaProvider ledger;
  late DebtProvider debts;
  late SavingsProvider savings;

  SavingsGoal makeGoal([String name = 'حصالة']) {
    return SavingsGoal.create(name: name, dailyTarget: 10, durationDays: 30);
  }

  /// Ledger transactions that belong to a goal (deposit + withdrawal rows).
  Iterable<TwelaTransaction> goalTxns(String goalId) =>
      ledger.transactions.where((t) => t.relatedId == goalId);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService();
    await storage.init();
    ledger = TwelaProvider(storage);
    debts = DebtProvider(storage, ledger);
    savings = SavingsProvider(storage, ledger, debts);
  });

  group('deposit', () {
    test('raises the net amount and the cached saved amount', () async {
      final goal = makeGoal();
      await savings.addGoal(goal);

      final ok = await savings.addDeposit(
        goalId: goal.id,
        amount: 50,
        walletType: 'cash',
      );

      expect(ok, isTrue);
      expect(savings.netForGoal(goal.id), 50);
      expect(savings.goalById(goal.id)!.savedAmount, 50);
      expect(goalTxns(goal.id).length, 1);
    });

    test('rejects non-positive amounts', () async {
      final goal = makeGoal();
      await savings.addGoal(goal);

      expect(await savings.addDeposit(goalId: goal.id, amount: 0), isFalse);
      expect(await savings.addDeposit(goalId: goal.id, amount: -5), isFalse);
      expect(savings.netForGoal(goal.id), 0);
    });
  });

  group('withdraw', () {
    test('lowers the net amount', () async {
      final goal = makeGoal();
      await savings.addGoal(goal);
      await savings.addDeposit(goalId: goal.id, amount: 50);

      final ok = await savings.withdrawToWallet(
        goalId: goal.id,
        amount: 30,
        walletType: 'cash',
      );

      expect(ok, isTrue);
      expect(savings.netForGoal(goal.id), 20);
    });

    test('never lets the net go negative', () async {
      final goal = makeGoal();
      await savings.addGoal(goal);
      await savings.addDeposit(goalId: goal.id, amount: 50);

      final ok = await savings.withdrawToWallet(goalId: goal.id, amount: 999);

      expect(ok, isFalse);
      expect(savings.netForGoal(goal.id), 50);
    });

    test('credits the wallet back (savingsWithdrawal transaction)', () async {
      final goal = makeGoal();
      await savings.addGoal(goal);
      await savings.addDeposit(goalId: goal.id, amount: 40);

      await savings.withdrawToWallet(goalId: goal.id, amount: 40);

      final credit = ledger.transactions
          .where((t) =>
              t.type == TransactionType.savingsWithdrawal &&
              t.relatedId == goal.id)
          .toList();
      expect(credit.length, 1);
      expect(credit.first.amount, 40);
    });
  });

  group('transfer to debt', () {
    late Debt debt;

    setUp(() async {
      debt = Debt(
        id: 'debt-1',
        personName: 'أحمد',
        itemDescription: 'قرض',
        totalAmount: 100,
        date: DateTime.now(),
      );
      await debts.addDebt(debt);
      final goal = makeGoal();
      await savings.addGoal(goal);
      await savings.addDeposit(goalId: goal.id, amount: 50);
    });

    test('pays the creditor and empties the goal by the same amount', () async {
      final goalId = savings.goals.first.id;

      final ok = await savings.transferToDebt(
        goalId: goalId,
        amount: 30,
        debtId: debt.id,
      );

      expect(ok, isTrue);
      expect(savings.netForGoal(goalId), 20);
      expect(debts.getDebtById(debt.id)!.paidAmount, 30);
      expect(debts.getDebtById(debt.id)!.remaining, 70);

      // The money left the goal and landed on the debt: one withdrawal and
      // one debt payment of the same amount, both traceable to the entry.
      final withdrawal = ledger.transactions
          .where((t) =>
              t.type == TransactionType.savingsWithdrawal &&
              t.relatedId == goalId)
          .toList();
      final payment = ledger.transactions
          .where((t) =>
              t.type == TransactionType.debtPayment && t.relatedId == debt.id)
          .toList();
      expect(withdrawal.length, 1);
      expect(withdrawal.first.amount, 30);
      expect(payment.length, 1);
      expect(payment.first.amount, 30);
      expect(payment.first.relatedEntryId, withdrawal.first.relatedEntryId);
    });

    test('is capped by what the goal actually holds', () async {
      final goalId = savings.goals.first.id;

      final ok = await savings.transferToDebt(
        goalId: goalId,
        amount: 999,
        debtId: debt.id,
      );

      expect(ok, isFalse);
      expect(savings.netForGoal(goalId), 50);
      expect(debts.getDebtById(debt.id)!.paidAmount, 0);
    });

    test('is refused for an unknown debt', () async {
      final goalId = savings.goals.first.id;

      expect(
        await savings.transferToDebt(
            goalId: goalId, amount: 10, debtId: 'nope'),
        isFalse,
      );
      expect(debts.getDebtById(debt.id)!.paidAmount, 0);
      expect(savings.netForGoal(goalId), 50);
    });
  });

  group('edit goal', () {
    test('recomputes savedAmount from the entries, never from storage',
        () async {
      final goal = makeGoal('الاسم القديم');
      await savings.addGoal(goal);
      await savings.addDeposit(goalId: goal.id, amount: 40);

      await savings.updateGoal(goal.copyWith(name: 'الاسم الجديد'));

      final updated = savings.goalById(goal.id)!;
      expect(updated.name, 'الاسم الجديد');
      expect(updated.savedAmount, 40);
      expect(savings.netForGoal(goal.id), 40);
    });
  });

  group('pause / resume', () {
    test('a paused goal refuses deposits, a resumed one accepts them',
        () async {
      final goal = makeGoal();
      await savings.addGoal(goal);
      await savings.addDeposit(goalId: goal.id, amount: 10);

      await savings.pauseGoal(goal.id);
      expect(savings.goalById(goal.id)!.isPaused, isTrue);
      expect(
        await savings.addDeposit(goalId: goal.id, amount: 10),
        isFalse,
      );
      expect(savings.netForGoal(goal.id), 10);

      await savings.resumeGoal(goal.id);
      expect(savings.goalById(goal.id)!.isActive, isTrue);
      expect(
        await savings.addDeposit(goalId: goal.id, amount: 10),
        isTrue,
      );
      expect(savings.netForGoal(goal.id), 20);
    });
  });

  group('delete + undo', () {
    test(
        'delete hides the goal and removes its ledger rows; undo restores both',
        () async {
      final goal = makeGoal();
      await savings.addGoal(goal);
      await savings.addDeposit(goalId: goal.id, amount: 40);
      expect(goalTxns(goal.id).length, 1);

      await savings.deleteGoal(goal.id);

      expect(savings.visibleGoals.any((g) => g.id == goal.id), isFalse);
      expect(savings.goals.any((g) => g.id == goal.id), isTrue); // soft delete
      expect(goalTxns(goal.id).length, 0);

      await savings.restoreGoal(goal.id);

      expect(savings.visibleGoals.any((g) => g.id == goal.id), isTrue);
      expect(savings.goalById(goal.id)!.savedAmount, 40);
      expect(savings.netForGoal(goal.id), 40);
      expect(goalTxns(goal.id).length, 1);
    });
  });

  group('remove entry (undo a deposit)', () {
    test('reverses the ledger transaction and the net amount', () async {
      final goal = makeGoal();
      await savings.addGoal(goal);
      await savings.addDeposit(goalId: goal.id, amount: 40);
      final entry = savings.getEntriesForGoal(goal.id).single;

      await savings.removeEntry(entry.id);

      expect(savings.getEntriesForGoal(goal.id), isEmpty);
      expect(savings.netForGoal(goal.id), 0);
      expect(goalTxns(goal.id), isEmpty);
    });

    test('keeps the other entries untouched', () async {
      final goal = makeGoal();
      await savings.addGoal(goal);
      await savings.addDeposit(goalId: goal.id, amount: 40);
      await savings.addDeposit(goalId: goal.id, amount: 10);
      final first = savings.getEntriesForGoal(goal.id).last;

      await savings.removeEntry(first.id);

      expect(savings.netForGoal(goal.id), 10);
      expect(goalTxns(goal.id).length, 1);
    });
  });

  group('net amount guard', () {
    test('stays non-negative across mixed operations', () async {
      final goal = makeGoal();
      await savings.addGoal(goal);
      await savings.addDeposit(goalId: goal.id, amount: 100);
      await savings.withdrawToWallet(goalId: goal.id, amount: 60);
      await savings.withdrawToWallet(goalId: goal.id, amount: 40);

      expect(savings.netForGoal(goal.id), 0);
      expect(
        await savings.withdrawToWallet(goalId: goal.id, amount: 1),
        isFalse,
      );
      expect(savings.netForGoal(goal.id), 0);
      expect(savings.goalById(goal.id)!.savedAmount, 0);
    });
  });

  group('backward compatibility', () {
    test('an entry stored without a type field is a deposit', () {
      final legacy = {
        'id': 'old-entry',
        'savingsGoalId': 'g1',
        'amount': 25.0,
        'date': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      final entry = SavingsEntry.fromJson(legacy);

      expect(entry.isDeposit, isTrue);
      expect(entry.amount, 25.0);
      expect(entry.linkedDebtId, isNull);
    });
  });
}
