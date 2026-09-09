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
      type: debt.isGiven ? TransactionType.debtGiven : TransactionType.debtReceived,
      walletType: _walletFromString(debt.walletType),
      categoryId: '',
      note: '${debt.personName} - ${debt.itemDescription}',
      date: debt.date,
      relatedId: debt.id,
    ));

    notifyListeners();
  }

  Future<void> addPayment(String debtId, double amount) async {
    final index = _debts.indexWhere((d) => d.id == debtId);
    if (index == -1) return;
    final debt = _debts[index];
    final newPaidAmount = debt.paidAmount + amount;
    _debts[index] = debt.copyWith(
      paidAmount: newPaidAmount > debt.totalAmount ? debt.totalAmount : newPaidAmount,
    );
    await _storage.saveDebts(_debts);

    // Record payment transaction on the balance using the debt's wallet type
    await ledger.addTransaction(TwelaTransaction(
      id: _uuid.v4(),
      amount: amount,
      type: TransactionType.debtPayment,
      walletType: _walletFromString(debt.walletType),
      categoryId: '',
      note: 'سداد: ${debt.personName}',
      date: DateTime.now(),
      relatedId: debt.id,
    ));

    notifyListeners();
  }

  Future<void> removeDebt(String id) async {
    final debt = getDebtById(id);
    if (debt == null) return;

    // Reverse all transactions associated with this debt
    final txsToRemove = ledger.transactions
        .where((t) => t.relatedId == id)
        .toList();
    for (final tx in txsToRemove) {
      await ledger.removeTransaction(tx.id);
    }

    _debts.removeWhere((d) => d.id == id);
    await _storage.saveDebts(_debts);
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
