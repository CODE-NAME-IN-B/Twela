import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/debt.dart';
import '../services/storage_service.dart';

class DebtProvider extends ChangeNotifier {
  final StorageService _storage;
  static const _uuid = Uuid();

  List<Debt> _debts = [];

  DebtProvider(this._storage) {
    _debts = _storage.getDebts();
  }

  List<Debt> get debts => _debts;
  List<Debt> get activeDebts => _debts.where((d) => !d.isPaidOff).toList();
  List<Debt> get paidDebts => _debts.where((d) => d.isPaidOff).toList();

  double get totalOwed => activeDebts.fold(0.0, (sum, d) => sum + d.remaining);
  double get totalPaid => _debts.fold(0.0, (sum, d) => sum + d.paidAmount);

  Future<void> addDebt(Debt debt) async {
    _debts.insert(0, debt);
    await _storage.saveDebts(_debts);
    notifyListeners();
  }

  Future<void> addPayment(String debtId, double amount) async {
    final index = _debts.indexWhere((d) => d.id == debtId);
    if (index != -1) {
      final debt = _debts[index];
      _debts[index] = debt.copyWith(
        paidAmount: debt.paidAmount + amount,
      );
      await _storage.saveDebts(_debts);
      notifyListeners();
    }
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
