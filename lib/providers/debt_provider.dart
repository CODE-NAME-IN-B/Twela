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
  TwelaProvider? _ledger;

  DebtProvider(this._storage) {
    _debts = _storage.getDebts();
  }

  void attachLedger(TwelaProvider ledger) => _ledger = ledger;

  List<Debt> get debts => _debts;
  List<Debt> get activeDebts => _debts.where((d) => !d.isPaidOff).toList();
  List<Debt> get paidDebts => _debts.where((d) => d.isPaidOff).toList();

  double get totalOwed => activeDebts.fold(0.0, (sum, d) => sum + d.remaining);
  double get totalPaid => _debts.fold(0.0, (sum, d) => sum + d.paidAmount);

  Future<void> addDebt(Debt debt) async {
    _debts.insert(0, debt);
    await _storage.saveDebts(_debts);

    // Record transaction on the balance
    await _ledger?.addTransaction(TwelaTransaction(
      id: _uuid.v4(),
      amount: debt.totalAmount,
      type: debt.isGiven ? TransactionType.debtGiven : TransactionType.debtReceived,
      walletType: WalletType.cash,
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
    _debts[index] = debt.copyWith(paidAmount: debt.paidAmount + amount);
    await _storage.saveDebts(_debts);

    // Record payment transaction on the balance
    await _ledger?.addTransaction(TwelaTransaction(
      id: _uuid.v4(),
      amount: amount,
      type: TransactionType.debtPayment,
      walletType: WalletType.cash,
      categoryId: '',
      note: 'سداد: ${debt.personName}',
      date: DateTime.now(),
      relatedId: debt.id,
    ));

    notifyListeners();
  }

  Future<void> removeDebt(String id) async {
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
