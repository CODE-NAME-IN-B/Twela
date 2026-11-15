import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/savings_goal.dart';
import '../models/savings_entry.dart';
import '../models/transaction.dart';
import '../providers/twela_provider.dart';
import '../providers/debt_provider.dart';
import '../services/storage_service.dart';

/// Owns every savings goal and the money inside it.
///
/// Money rules of this app, in one place:
///
/// - A deposit moves money **out of** a wallet **into** a goal.
/// - A withdrawal moves money **out of** a goal **into** a wallet.
/// - A transfer moves money **out of** a goal **into** a debt payment. The
///   money leaves the wallet exactly once (when it was deposited); the
///   `savingsWithdrawal` credit and the `debtPayment` debit cancel out.
/// - A goal's saved amount is always derived from its entries, never trusted
///   from storage, so it can never drift.
class SavingsProvider extends ChangeNotifier {
  final StorageService _storage;
  static const _uuid = Uuid();

  List<SavingsGoal> _goals = [];
  List<SavingsEntry> _entries = [];
  final TwelaProvider ledger;

  /// Needed to settle a debt from a goal. Optional so the provider can be
  /// built without debts (tests).
  final DebtProvider? debts;

  SavingsProvider(this._storage, this.ledger, [this.debts]) {
    _goals = _storage.getSavingsGoals();
    _entries = _storage.getSavingsEntries();
    _syncGoalAmounts();
  }

  /// Reload savings data from storage. Call after import to refresh in-memory state.
  void reloadData() {
    _goals = _storage.getSavingsGoals();
    _entries = _storage.getSavingsEntries();
    _syncGoalAmounts();
    notifyListeners();
  }

  // ─── Getters ───────────────────────────────────────────────────────────
  List<SavingsGoal> get goals => _goals;
  List<SavingsEntry> get entries => _entries;

  List<SavingsGoal> get visibleGoals =>
      _goals.where((g) => !g.isDeleted).toList();
  List<SavingsGoal> get activeGoals =>
      visibleGoals.where((g) => g.isActive).toList();
  List<SavingsGoal> get pausedGoals =>
      visibleGoals.where((g) => g.isPaused).toList();
  List<SavingsGoal> get completedGoals =>
      visibleGoals.where((g) => g.isCompleted).toList();

  /// Money currently locked inside goals.
  double get totalSaved =>
      visibleGoals.fold(0.0, (sum, g) => sum + netForGoal(g.id));

  /// Sum of every goal's target.
  double get totalTarget =>
      visibleGoals.fold(0.0, (sum, g) => sum + g.targetAmount);

  List<SavingsEntry> getEntriesForGoal(String goalId) {
    final list = _entries.where((e) => e.savingsGoalId == goalId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Net amount held by a goal: deposits minus withdrawals.
  double netForGoal(String goalId) {
    return _entries.where((e) => e.savingsGoalId == goalId).fold(0.0, (sum, e) {
      return e.isDeposit ? sum + e.amount : sum - e.amount;
    });
  }

  SavingsGoal? goalById(String id) {
    for (final g in _goals) {
      if (g.id == id) return g;
    }
    return null;
  }

  SavingsEntry? entryById(String id) {
    for (final e in _entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  // ─── Goal lifecycle ────────────────────────────────────────────────────
  Future<void> addGoal(SavingsGoal goal) async {
    _goals.insert(0, goal);
    await _storage.saveSavingsGoals(_goals);
    notifyListeners();
  }

  /// Edit a goal: name, daily target, duration, start date.
  /// The saved amount and the status are always recomputed from the entries.
  Future<void> updateGoal(SavingsGoal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index == -1) return;
    final current = _goals[index];
    final net = netForGoal(goal.id);
    _goals[index] = goal.copyWith(
      savedAmount: net,
      status: _resolveStatus(current.status, net, goal),
    );
    await _storage.saveSavingsGoals(_goals);
    notifyListeners();
  }

  Future<void> pauseGoal(String id) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return;
    _goals[index] = _goals[index].copyWith(status: SavingsStatus.paused);
    await _storage.saveSavingsGoals(_goals);
    notifyListeners();
  }

  Future<void> resumeGoal(String id) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return;
    final goal = _goals[index];
    final net = netForGoal(id);
    _goals[index] = goal.copyWith(
      savedAmount: net,
      status: net >= goal.targetAmount
          ? SavingsStatus.completed
          : SavingsStatus.active,
    );
    await _storage.saveSavingsGoals(_goals);
    notifyListeners();
  }

  /// Cancel a goal.
  ///
  /// The money still inside the goal comes back to the wallet: every
  /// transaction of the goal is removed from the ledger, which returns the
  /// un-spent part to the wallet. Money that was already transferred to a debt
  /// stays paid — its `debtPayment` belongs to the debt, not to the goal.
  ///
  /// The goal and its entries are kept with `status = deleted` so the action
  /// can be undone.
  Future<void> deleteGoal(String id) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return;

    await _removeGoalTransactions(id);

    _goals[index] = _goals[index].copyWith(
      status: SavingsStatus.deleted,
      savedAmount: 0,
    );
    await _storage.saveSavingsGoals(_goals);
    notifyListeners();
  }

  /// Undo [deleteGoal]: the goal comes back with its money.
  Future<void> restoreGoal(String id) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return;
    final goal = _goals[index];

    _goals[index] = goal.copyWith(
      status: SavingsStatus.active,
      savedAmount: netForGoal(id),
    );
    await _storage.saveSavingsGoals(_goals);
    await _recreateGoalTransactions(id);
    notifyListeners();
  }

  // ─── Entries ───────────────────────────────────────────────────────────
  /// Put money into a goal.
  Future<bool> addDeposit({
    required String goalId,
    required double amount,
    String walletType = 'cash',
    String note = '',
  }) async {
    if (amount <= 0) return false;
    final goal = goalById(goalId);
    if (goal == null || goal.isDeleted || goal.isPaused) return false;

    final entry = SavingsEntry.create(
      savingsGoalId: goalId,
      amount: amount,
      walletType: walletType,
      note: note,
      type: SavingsEntryType.deposit,
    );
    await _insertEntry(entry);

    await ledger.addTransaction(TwelaTransaction(
      id: _uuid.v4(),
      amount: amount,
      type: TransactionType.savings,
      walletType: _walletFromString(walletType),
      categoryId: '',
      note: 'ادخار: ${goal.name}',
      date: entry.date,
      relatedId: goalId,
      relatedEntryId: entry.id,
    ));

    notifyListeners();
    return true;
  }

  /// Take money back out of a goal into a wallet.
  Future<bool> withdrawToWallet({
    required String goalId,
    required double amount,
    String walletType = 'cash',
    String note = '',
  }) async {
    if (amount <= 0) return false;
    final goal = goalById(goalId);
    if (goal == null || goal.isDeleted) return false;
    if (amount > netForGoal(goalId)) return false;

    final entry = SavingsEntry.create(
      savingsGoalId: goalId,
      amount: amount,
      walletType: walletType,
      note: note,
      type: SavingsEntryType.withdrawal,
    );
    await _insertEntry(entry);

    await ledger.addTransaction(TwelaTransaction(
      id: _uuid.v4(),
      amount: amount,
      type: TransactionType.savingsWithdrawal,
      walletType: _walletFromString(walletType),
      categoryId: '',
      note: 'سحب من ادخار: ${goal.name}',
      date: entry.date,
      relatedId: goalId,
      relatedEntryId: entry.id,
    ));

    notifyListeners();
    return true;
  }

  /// Pay a debt straight out of a goal.
  ///
  /// The goal gives the money back to the wallet (`savingsWithdrawal`) and the
  /// very same amount is paid to the creditor (`debtPayment`), so the wallet
  /// total does not change: the money only moved from one pot to another.
  Future<bool> transferToDebt({
    required String goalId,
    required double amount,
    required String debtId,
    String? debtName,
    String walletType = 'cash',
  }) async {
    if (amount <= 0) return false;
    final goal = goalById(goalId);
    final debtProvider = debts;
    if (goal == null || goal.isDeleted || debtProvider == null) return false;

    final debt = debtProvider.getDebtById(debtId);
    if (debt == null || debt.remaining <= 0) return false;
    if (amount > netForGoal(goalId)) return false;

    final payable = amount > debt.remaining ? debt.remaining : amount;
    final name = debtName ?? debt.personName;

    final entry = SavingsEntry.create(
      savingsGoalId: goalId,
      amount: payable,
      walletType: walletType,
      note: 'سداد دين $name',
      type: SavingsEntryType.withdrawal,
      linkedDebtId: debtId,
      linkedDebtName: name,
    );
    await _insertEntry(entry);

    // Money leaves the goal …
    await ledger.addTransaction(TwelaTransaction(
      id: _uuid.v4(),
      amount: payable,
      type: TransactionType.savingsWithdrawal,
      walletType: _walletFromString(walletType),
      categoryId: '',
      note: 'سحب من ادخار: ${goal.name}',
      date: entry.date,
      relatedId: goalId,
      relatedEntryId: entry.id,
    ));

    // … and goes straight to the creditor.
    await debtProvider.applyPayment(
      debtId,
      payable,
      walletType: walletType,
      note: 'سداد من ادخار: ${goal.name}',
      relatedEntryId: entry.id,
    );

    notifyListeners();
    return true;
  }

  /// Remove a single entry and reverse its movement. Undoable by the caller.
  Future<void> removeEntry(String entryId) async {
    final entry = entryById(entryId);
    if (entry == null) return;

    if (entry.paysDebt && debts != null) {
      await debts!.reversePayment(
        entry.linkedDebtId!,
        entry.amount,
        relatedEntryId: entry.id,
      );
    }

    final txs =
        ledger.transactions.where((t) => t.relatedEntryId == entry.id).toList();
    for (final tx in txs) {
      await ledger.removeTransaction(tx.id);
    }

    _entries.removeWhere((e) => e.id == entryId);
    await _storage.saveSavingsEntries(_entries);
    await _syncAndSaveGoals();
    notifyListeners();
  }

  /// Put a previously removed entry back, with its movements.
  Future<bool> restoreEntry(SavingsEntry entry) async {
    if (entryById(entry.id) != null) return false;
    final goal = goalById(entry.savingsGoalId);
    if (goal == null || goal.isDeleted) return false;

    await _insertEntry(entry);

    if (entry.isDeposit) {
      await ledger.addTransaction(TwelaTransaction(
        id: _uuid.v4(),
        amount: entry.amount,
        type: TransactionType.savings,
        walletType: _walletFromString(entry.walletType),
        categoryId: '',
        note: 'ادخار: ${goal.name}',
        date: entry.date,
        relatedId: goal.id,
        relatedEntryId: entry.id,
      ));
    } else {
      await ledger.addTransaction(TwelaTransaction(
        id: _uuid.v4(),
        amount: entry.amount,
        type: TransactionType.savingsWithdrawal,
        walletType: _walletFromString(entry.walletType),
        categoryId: '',
        note: 'سحب من ادخار: ${goal.name}',
        date: entry.date,
        relatedId: goal.id,
        relatedEntryId: entry.id,
      ));
      if (entry.paysDebt && debts != null) {
        await debts!.applyPayment(
          entry.linkedDebtId!,
          entry.amount,
          walletType: entry.walletType,
          note: 'سداد من ادخار: ${goal.name}',
          relatedEntryId: entry.id,
        );
      }
    }

    notifyListeners();
    return true;
  }

  // ─── Internals ─────────────────────────────────────────────────────────
  Future<void> _insertEntry(SavingsEntry entry) async {
    _entries.insert(0, entry);
    await _storage.saveSavingsEntries(_entries);
    await _syncAndSaveGoals();
  }

  /// Keeps every goal's cached amount and status in step with its entries.
  Future<void> _syncAndSaveGoals() async {
    for (var i = 0; i < _goals.length; i++) {
      final goal = _goals[i];
      if (goal.isDeleted) continue;
      final net = netForGoal(goal.id);
      final status = _resolveStatus(goal.status, net, goal);
      if (goal.savedAmount != net || goal.status != status) {
        _goals[i] = goal.copyWith(savedAmount: net, status: status);
      }
    }
    await _storage.saveSavingsGoals(_goals);
  }

  void _syncGoalAmounts() {
    for (var i = 0; i < _goals.length; i++) {
      final goal = _goals[i];
      if (goal.isDeleted) continue;
      final net = netForGoal(goal.id);
      _goals[i] = goal.copyWith(
          savedAmount: net, status: _resolveStatus(goal.status, net, goal));
    }
  }

  /// A paused goal stays paused. A goal that reached its target is completed;
  /// a withdrawal that drops it below the target brings it back to active.
  SavingsStatus _resolveStatus(
      SavingsStatus current, double net, SavingsGoal goal) {
    if (current == SavingsStatus.paused || current == SavingsStatus.deleted)
      return current;
    return net >= goal.targetAmount
        ? SavingsStatus.completed
        : SavingsStatus.active;
  }

  Future<void> _removeGoalTransactions(String goalId) async {
    final txs = ledger.transactions
        .where((t) =>
            t.relatedId == goalId && t.type != TransactionType.debtPayment)
        .toList();
    for (final tx in txs) {
      await ledger.removeTransaction(tx.id);
    }
  }

  Future<void> _recreateGoalTransactions(String goalId) async {
    final goal = goalById(goalId);
    if (goal == null) return;
    for (final entry in getEntriesForGoal(goalId)) {
      final type = entry.isDeposit
          ? TransactionType.savings
          : TransactionType.savingsWithdrawal;
      final note = entry.isDeposit
          ? 'ادخار: ${goal.name}'
          : (entry.paysDebt
              ? 'سحب من ادخار: ${goal.name}'
              : 'سحب من ادخار: ${goal.name}');
      await ledger.addTransaction(TwelaTransaction(
        id: _uuid.v4(),
        amount: entry.amount,
        type: type,
        walletType: _walletFromString(entry.walletType),
        categoryId: '',
        note: note,
        date: entry.date,
        relatedId: goalId,
        relatedEntryId: entry.id,
      ));
    }
  }

  WalletType _walletFromString(String walletType) {
    return walletType == 'bank' ? WalletType.bank : WalletType.cash;
  }
}
