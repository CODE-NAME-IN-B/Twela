import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/wallet_settings.dart';
import '../models/budget_settings.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/routine_detection_service.dart';
import '../models/routine_pattern.dart';

class TwelaProvider extends ChangeNotifier {
  final StorageService _storage;
  static const _uuid = Uuid();

  List<ExpenseCategory> _categories = [];
  List<TwelaTransaction> _transactions = [];
  WalletSettings _walletSettings = const WalletSettings();
  BudgetSettings _budgetSettings = const BudgetSettings();
  List<RoutinePattern> _patterns = [];

  TwelaProvider(this._storage) {
    _loadData();
  }

  void _loadData() {
    _categories = _storage.getCategories();
    _transactions = _storage.getTransactions();
    _walletSettings = _storage.getWalletSettings();
    _budgetSettings = _storage.getBudgetSettings();
    _patterns = _storage.getPatterns();
    notifyListeners();
  }

  // Getters
  List<ExpenseCategory> get categories => _categories;
  List<TwelaTransaction> get transactions => _transactions;
  WalletSettings get walletSettings => _walletSettings;
  BudgetSettings get budgetSettings => _budgetSettings;
  List<RoutinePattern> get patterns => _patterns;

  double get cashBalance {
    final income = _transactions
        .where((t) => t.type == TransactionType.income && t.walletType == WalletType.cash)
        .fold(0.0, (sum, t) => sum + t.amount);
    final expense = _transactions
        .where((t) => t.type == TransactionType.expense && t.walletType == WalletType.cash)
        .fold(0.0, (sum, t) => sum + t.amount);
    return _walletSettings.initialCashBalance + income - expense;
  }

  double get bankBalance {
    final income = _transactions
        .where((t) => t.type == TransactionType.income && t.walletType == WalletType.bank)
        .fold(0.0, (sum, t) => sum + t.amount);
    final expense = _transactions
        .where((t) => t.type == TransactionType.expense && t.walletType == WalletType.bank)
        .fold(0.0, (sum, t) => sum + t.amount);
    return _walletSettings.initialBankBalance + income - expense;
  }

  double get totalBalance => cashBalance + bankBalance;

  double get todaySpent {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.isAfter(today))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthSpent {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.isAfter(monthStart))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getCategoryMonthSpent(String categoryId) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.categoryId == categoryId &&
            t.date.isAfter(monthStart))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  ExpenseCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // Category operations
  Future<void> addCategory(ExpenseCategory category) async {
    _categories.add(category);
    await _storage.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> updateCategory(ExpenseCategory category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      await _storage.saveCategories(_categories);
      notifyListeners();
    }
  }

  Future<void> removeCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    await _storage.saveCategories(_categories);
    notifyListeners();
  }

  // Transaction operations
  Future<void> addTransaction(TwelaTransaction transaction) async {
    _transactions.insert(0, transaction);
    await _storage.saveTransactions(_transactions);

    // Check budget limits
    await _checkBudgetLimits(transaction);

    // Detect routine patterns
    _patterns = RoutineDetectionService.detectPatterns(
      transactions: _transactions,
      existingPatterns: _patterns,
    );
    await _storage.savePatterns(_patterns);

    notifyListeners();
  }

  Future<void> updateTransaction(TwelaTransaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      await _storage.saveTransactions(_transactions);
      notifyListeners();
    }
  }

  Future<void> removeTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  // Wallet Settings
  Future<void> updateWalletSettings(WalletSettings settings) async {
    _walletSettings = settings;
    await _storage.saveWalletSettings(settings);
    notifyListeners();
  }

  // Budget Settings
  Future<void> updateBudgetSettings(BudgetSettings settings) async {
    _budgetSettings = settings;
    await _storage.saveBudgetSettings(settings);
    notifyListeners();
  }

  // Budget checking
  Future<void> _checkBudgetLimits(TwelaTransaction transaction) async {
    if (transaction.type != TransactionType.expense) return;

    // Check category monthly limit
    final category = getCategoryById(transaction.categoryId);
    if (category?.monthlyLimit != null) {
      final spent = getCategoryMonthSpent(transaction.categoryId);
      final limit = category!.monthlyLimit!;
      final percentage = spent / limit;

      if (percentage >= 1.0) {
        await NotificationService.showBudgetWarning(
          title: 'تجاوز سقف التصنيف',
          body: 'لقد تجاوزت سقف ${category.name} الشهري (${(percentage * 100).toStringAsFixed(0)}%)',
        );
      } else if (percentage >= 0.8) {
        await NotificationService.showBudgetWarning(
          title: 'قريب من سقف التصنيف',
          body: 'لقد وصلت ${category.name} إلى ${(percentage * 100).toStringAsFixed(0)}% من السقف الشهري',
        );
      }
    }

    // Check daily limit
    if (_budgetSettings.dailySpendingLimit != null) {
      if (todaySpent > _budgetSettings.dailySpendingLimit!) {
        await NotificationService.showDailyLimitWarning(
          'لقد تجاوزت الحد اليومي (${formatLyd(todaySpent)} / ${formatLyd(_budgetSettings.dailySpendingLimit!)})',
        );
      }
    }

    // Check monthly budget
    if (_budgetSettings.monthlyBudgetTotal != null) {
      final percentage = monthSpent / _budgetSettings.monthlyBudgetTotal!;
      if (percentage >= 1.0) {
        await NotificationService.showBudgetWarning(
          title: 'تجاوز الميزانية الشهرية',
          body: 'لقد تجاوزت الميزانية الشهرية (${(percentage * 100).toStringAsFixed(0)}%)',
        );
      } else if (percentage >= 0.8) {
        await NotificationService.showBudgetWarning(
          title: 'قريب من الميزانية الشهرية',
          body: 'لقد وصلت إلى ${(percentage * 100).toStringAsFixed(0)}% من الميزانية الشهرية',
        );
      }
    }

    // Check low balance
    if (_budgetSettings.lowBalanceThreshold != null) {
      if (totalBalance < _budgetSettings.lowBalanceThreshold!) {
        await NotificationService.showLowBalanceWarning(
          'الرصيد الإجمالي منخفض (${formatLyd(totalBalance)})',
        );
      }
    }
  }

  String formatLyd(double amount) {
    return '${amount.toStringAsFixed(2)} د.ل';
  }
}
