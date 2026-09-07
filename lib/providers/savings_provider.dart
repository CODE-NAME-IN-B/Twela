import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../models/savings_entry.dart';
import '../services/storage_service.dart';

class SavingsProvider extends ChangeNotifier {
  final StorageService _storage;

  List<SavingsGoal> _goals = [];
  List<SavingsEntry> _entries = [];

  SavingsProvider(this._storage) {
    _goals = _storage.getSavingsGoals();
    _entries = _storage.getSavingsEntries();
  }

  List<SavingsGoal> get goals => _goals;
  List<SavingsEntry> get entries => _entries;
  List<SavingsGoal> get activeGoals => _goals.where((g) => g.status == SavingsStatus.active).toList();
  List<SavingsGoal> get completedGoals => _goals.where((g) => g.status == SavingsStatus.completed).toList();

  double get totalSaved => _entries.fold(0.0, (sum, e) => sum + e.amount);

  List<SavingsEntry> getEntriesForGoal(String goalId) {
    return _entries.where((e) => e.savingsGoalId == goalId).toList();
  }

  double getTotalForGoal(String goalId) {
    return _entries
        .where((e) => e.savingsGoalId == goalId)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Future<void> addGoal(SavingsGoal goal) async {
    _goals.insert(0, goal);
    await _storage.saveSavingsGoals(_goals);
    notifyListeners();
  }

  Future<void> updateGoal(SavingsGoal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      await _storage.saveSavingsGoals(_goals);
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    _entries.removeWhere((e) => e.savingsGoalId == id);
    await _storage.saveSavingsGoals(_goals);
    await _storage.saveSavingsEntries(_entries);
    notifyListeners();
  }

  Future<void> addEntry(SavingsEntry entry) async {
    _entries.insert(0, entry);
    await _storage.saveSavingsEntries(_entries);

    final goalIndex = _goals.indexWhere((g) => g.id == entry.savingsGoalId);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];
      final newTotal = getTotalForGoal(entry.savingsGoalId);
      _goals[goalIndex] = goal.copyWith(
        savedAmount: newTotal,
        status: newTotal >= goal.targetAmount
            ? SavingsStatus.completed
            : goal.status,
      );
      await _storage.saveSavingsGoals(_goals);
    }

    notifyListeners();
  }

  Future<void> pauseGoal(String id) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      _goals[index] = _goals[index].copyWith(status: SavingsStatus.paused);
      await _storage.saveSavingsGoals(_goals);
      notifyListeners();
    }
  }

  Future<void> resumeGoal(String id) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      _goals[index] = _goals[index].copyWith(status: SavingsStatus.active);
      await _storage.saveSavingsGoals(_goals);
      notifyListeners();
    }
  }
}
