import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/debt.dart';
import '../models/transaction.dart';
import '../providers/twela_provider.dart';
import '../services/storage_service.dart';

class DebtProvider extends ChangeNotifier {
  final StorageService _storage;
  static const _uuid = Uuid();

  List<Debt> _debts = [];
  final TwelaProvider ledger;

  DebtProvider(this._storage, this.ledger) {
    _debts = _storage.getDebts();
  }

  /// Reload debts from storage. Call after import to refresh in-memory state.
  void reloadData() {
    _debts = _storage.getDebts();
    notifyListeners();
  }

  List<Debt> get debts => _debts;
  List<Debt> get activeDebts => _debts.where((d) => !d.isPaidOff).toList();
  List<Debt> get paidDebts => _debts.where((d) => d.isPaidOff).toList();

  /// Debts the user can collect money for (the user is the lender).
  List<Debt> get collectibleDebts => _debts
      .where((d) => d.isGiven && !d.isPaidOff && d.remaining > 0)
      .toList();

  double get totalOwed => activeDebts.fold(0.0, (sum, d) => sum + d.remaining);
  double get totalPaid => _debts.fold(0.0, (sum, d) => sum + d.paidAmount);

  WalletType _walletFromString(String walletType) {
    return walletType == 'bank' ? WalletType.bank : WalletType.cash;
  }

  Future<void> addDebt(Debt debt) async {
    _debts.insert(0, debt);
    await _storage.saveDebts(_debts);

    // Record transaction on the balance using the debt's wallet type
    await ledger.addTransaction(TwelaTransaction(
      id: _uuid.v4(),
      amount: debt.totalAmount,
      type: debt.isGiven
          ? TransactionType.debtGiven
          : TransactionType.debtReceived,
      walletType: _walletFromString(debt.walletType),
      categoryId: '',
      note: '${debt.personName} - ${debt.itemDescription}',
      date: debt.date,
      relatedId: debt.id,
    ));

    notifyListeners();
  }

  Future<void> addPayment(String debtId, double amount) async {
    await applyPayment(debtId, amount);
  }

  /// Record a payment against a debt.
  ///
  /// [walletType] overrides the wallet the money leaves from — a payment made
  /// out of a savings goal must leave the wallet the goal was funded from.
  /// [relatedEntryId] links the movement to a savings entry so it can be undone.
  Future<void> applyPayment(
    String debtId,
    double amount, {
    String? walletType,
    String? note,
    String? relatedEntryId,
  }) async {
    if (amount <= 0) return;
    final index = _debts.indexWhere((d) => d.id == debtId);
    if (index == -1) return;
    final debt = _debts[index];
    final newPaidAmount = debt.paidAmount + amount;
    _debts[index] = debt.copyWith(
      paidAmount:
          newPaidAmount > debt.totalAmount ? debt.totalAmount : newPaidAmount,
    );
    await _storage.saveDebts(_debts);

    // Record payment transaction on the balance
    await ledger.addTransaction(TwelaTransaction(
      id: _uuid.v4(),
      amount: amount,
      type: TransactionType.debtPayment,
      walletType: _walletFromString(walletType ?? debt.walletType),
      categoryId: '',
      note: note ?? 'سداد: ${debt.personName}',
      date: DateTime.now(),
      relatedId: debt.id,
      relatedEntryId: relatedEntryId,
    ));

    notifyListeners();
  }

  /// Undo a payment that was linked to a savings entry: removes the movement
  /// and gives the paid amount back to the debt.
  Future<void> reversePayment(String debtId, double amount,
      {String? relatedEntryId}) async {
    final index = _debts.indexWhere((d) => d.id == debtId);
    if (index == -1) return;
    final debt = _debts[index];
    _debts[index] = debt.copyWith(
      paidAmount: (debt.paidAmount - amount).clamp(0.0, debt.totalAmount),
    );
    await _storage.saveDebts(_debts);

    final txs = ledger.transactions
        .where((t) =>
            t.relatedId == debtId &&
            t.type == TransactionType.debtPayment &&
            (relatedEntryId == null || t.relatedEntryId == relatedEntryId))
        .toList();
    for (final tx in txs) {
      await ledger.removeTransaction(tx.id);
    }

    notifyListeners();
  }

  Future<void> removeDebt(String id) async {
    final debt = getDebtById(id);
    if (debt == null) return;

    // Reverse all transactions associated with this debt
    final txsToRemove =
        ledger.transactions.where((t) => t.relatedId == id).toList();
    for (final tx in txsToRemove) {
      await ledger.removeTransaction(tx.id);
    }

    _debts.removeWhere((d) => d.id == id);
    await _storage.saveDebts(_debts);
    notifyListeners();
  }

  /// Undo for [removeDebt]: rebuilds the debt where it was and puts its
  /// ledger transactions back. Pass the [index] the screen captured before
  /// deleting. Guarded against duplicate ids.
  Future<void> restoreDebt(Debt debt, List<TwelaTransaction> txs,
      {int? index}) async {
    if (_debts.any((d) => d.id == debt.id)) return;
    if (index == null || index > _debts.length) {
      _debts.insert(0, debt);
    } else {
      _debts.insert(index.clamp(0, _debts.length), debt);
    }
    await _storage.saveDebts(_debts);
    for (final tx in txs) {
      await ledger.restoreTransaction(tx);
    }
    notifyListeners();
  }

  Debt? getDebtById(String id) {
    try {
      return _debts.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
