import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:twela/models/debt.dart';
import 'package:twela/models/transaction.dart';
import 'package:twela/providers/debt_provider.dart';
import 'package:twela/providers/twela_provider.dart';
import 'package:twela/services/storage_service.dart';
import 'package:uuid/uuid.dart';

/// Undo for destructive actions (plan box: destructive actions are undoable):
/// transaction delete + debt delete (with its ledger rows).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;
  late TwelaProvider ledger;
  late DebtProvider debts;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService();
    await storage.init();
    ledger = TwelaProvider(storage);
    debts = DebtProvider(storage, ledger);
  });

  TwelaTransaction expense({DateTime? date}) => TwelaTransaction(
        id: const Uuid().v4(),
        amount: 12,
        type: TransactionType.expense,
        walletType: WalletType.cash,
        categoryId: 'food',
        note: '',
        date: date ?? DateTime(2026, 1, 5),
      );

  test('remove + undo transaction puts it back in place', () async {
    final older = expense(date: DateTime(2026, 1, 1));
    final newer = expense(date: DateTime(2026, 3, 1));
    await ledger.addTransaction(newer);
    await ledger.addTransaction(older); // add-ordered: older ends up first
    expect(ledger.transactions.first.id, older.id);

    final index = ledger.transactions.indexOf(older);
    await ledger.removeTransaction(older.id);
    expect(ledger.transactions.any((t) => t.id == older.id), isFalse);

    await ledger.restoreTransaction(older, index: index);
    expect(ledger.transactions.first.id, older.id,
        reason: 'restored at its former index, not appended');
  });

  test('restoreTransaction without an index goes to the top', () async {
    final older = expense(date: DateTime(2026, 1, 1));
    final newer = expense(date: DateTime(2026, 3, 1));
    await ledger.addTransaction(newer);
    await ledger.addTransaction(older);
    await ledger.removeTransaction(older.id);

    await ledger.restoreTransaction(older);
    expect(ledger.transactions.first.id, older.id);
  });

  test('restoreTransaction ignores a duplicate id', () async {
    final t = expense();
    await ledger.addTransaction(t);
    await ledger.restoreTransaction(t);
    expect(ledger.transactions.where((x) => x.id == t.id).length, 1);
  });

  test('remove + undo debt rebuilds the debt and its ledger rows', () async {
    final debt = Debt(
      id: 'd1',
      personName: 'أحمد',
      itemDescription: 'دين',
      totalAmount: 300,
      isGiven: true,
      date: DateTime(2026, 1, 10),
    );
    await debts.addDebt(debt);
    await debts.applyPayment('d1', 100, relatedEntryId: 'e1');
    expect(debts.debts.length, 1);
    // addDebt records the debt-given movement + applyPayment the payment.
    expect(ledger.transactions.where((t) => t.relatedId == 'd1').length, 2);

    final index = debts.debts.indexOf(debt);
    // applyPayment replaces the debt via copyWith — capture the CURRENT
    // instance from the provider, not the original.
    final current = debts.debts.first;
    final txs = ledger.transactions.where((t) => t.relatedId == 'd1').toList();
    await debts.removeDebt('d1');
    expect(debts.debts, isEmpty);
    expect(ledger.transactions.where((t) => t.relatedId == 'd1'), isEmpty);

    await debts.restoreDebt(current, txs, index: index);
    expect(debts.debts.length, 1);
    expect(debts.debts.first.paidAmount, 100);
    expect(ledger.transactions.where((t) => t.relatedId == 'd1').length, 2);
  });
}
