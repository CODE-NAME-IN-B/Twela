import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/wallet_settings.dart';
import '../models/budget_settings.dart';
import '../models/debt.dart';
import '../models/person.dart';
import '../models/savings_goal.dart';
import '../models/savings_entry.dart';
import '../models/routine_pattern.dart';
import '../models/app_settings.dart';

class StorageService {
  static const String _categoriesKey = 'categories';
  static const String _transactionsKey = 'transactions';
  static const String _walletSettingsKey = 'wallet_settings';
  static const String _budgetSettingsKey = 'budget_settings';
  static const String _debtsKey = 'debts';
  static const String _personsKey = 'persons';
  static const String _savingsGoalsKey = 'savings_goals';
  static const String _savingsEntriesKey = 'savings_entries';
  static const String _patternsKey = 'patterns';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _dbVersionKey = 'db_version';
  static const String _appSettingsKey = 'app_settings';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _runMigrations();
  }

  Future<void> _runMigrations() async {
    final currentVersion = _prefs.getInt(_dbVersionKey) ?? 1;
    if (currentVersion < 2) {
      await _prefs.setInt(_dbVersionKey, 2);
    }
  }

  int get dbVersion => _prefs.getInt(_dbVersionKey) ?? 1;

  // Onboarding
  bool getOnboardingComplete() {
    return _prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_onboardingCompleteKey, value);
  }

  // Categories
  List<ExpenseCategory> getCategories() {
    final data = _prefs.getString(_categoriesKey);
    if (data == null) return ExpenseCategory.defaultCategories();
    final list = jsonDecode(data) as List;
    return list.map((e) => ExpenseCategory.fromJson(e)).toList();
  }

  Future<void> saveCategories(List<ExpenseCategory> categories) async {
    final data = categories.map((e) => e.toJson()).toList();
    await _prefs.setString(_categoriesKey, jsonEncode(data));
  }

  // Transactions
  List<TwelaTransaction> getTransactions() {
    final data = _prefs.getString(_transactionsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => TwelaTransaction.fromJson(e)).toList();
  }

  Future<void> saveTransactions(List<TwelaTransaction> transactions) async {
    final data = transactions.map((e) => e.toJson()).toList();
    await _prefs.setString(_transactionsKey, jsonEncode(data));
  }

  // Wallet Settings
  WalletSettings getWalletSettings() {
    final data = _prefs.getString(_walletSettingsKey);
    if (data == null) return const WalletSettings();
    return WalletSettings.fromJson(jsonDecode(data));
  }

  Future<void> saveWalletSettings(WalletSettings settings) async {
    await _prefs.setString(_walletSettingsKey, jsonEncode(settings.toJson()));
  }

  // Budget Settings
  BudgetSettings getBudgetSettings() {
    final data = _prefs.getString(_budgetSettingsKey);
    if (data == null) return const BudgetSettings();
    return BudgetSettings.fromJson(jsonDecode(data));
  }

  Future<void> saveBudgetSettings(BudgetSettings settings) async {
    await _prefs.setString(_budgetSettingsKey, jsonEncode(settings.toJson()));
  }

  // Debts
  List<Debt> getDebts() {
    final data = _prefs.getString(_debtsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Debt.fromJson(e)).toList();
  }

  Future<void> saveDebts(List<Debt> debts) async {
    final data = debts.map((e) => e.toJson()).toList();
    await _prefs.setString(_debtsKey, jsonEncode(data));
  }

  // Persons
  List<Person> getPersons() {
    final data = _prefs.getString(_personsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Person.fromJson(e)).toList();
  }

  Future<void> savePersons(List<Person> persons) async {
    final data = persons.map((e) => e.toJson()).toList();
    await _prefs.setString(_personsKey, jsonEncode(data));
  }

  // Savings Goals
  List<SavingsGoal> getSavingsGoals() {
    final data = _prefs.getString(_savingsGoalsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => SavingsGoal.fromJson(e)).toList();
  }

  Future<void> saveSavingsGoals(List<SavingsGoal> goals) async {
    final data = goals.map((e) => e.toJson()).toList();
    await _prefs.setString(_savingsGoalsKey, jsonEncode(data));
  }

  // Savings Entries
  List<SavingsEntry> getSavingsEntries() {
    final data = _prefs.getString(_savingsEntriesKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => SavingsEntry.fromJson(e)).toList();
  }

  Future<void> saveSavingsEntries(List<SavingsEntry> entries) async {
    final data = entries.map((e) => e.toJson()).toList();
    await _prefs.setString(_savingsEntriesKey, jsonEncode(data));
  }

  // Routine Patterns
  List<RoutinePattern> getPatterns() {
    final data = _prefs.getString(_patternsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => RoutinePattern.fromJson(e)).toList();
  }

  Future<void> savePatterns(List<RoutinePattern> patterns) async {
    final data = patterns.map((e) => e.toJson()).toList();
    await _prefs.setString(_patternsKey, jsonEncode(data));
  }

  // App Settings
  AppSettings getAppSettings() {
    final data = _prefs.getString(_appSettingsKey);
    if (data == null) return const AppSettings();
    return AppSettings.fromJson(jsonDecode(data));
  }

  Future<void> saveAppSettings(AppSettings settings) async {
    await _prefs.setString(_appSettingsKey, jsonEncode(settings.toJson()));
  }

  // Export all data as JSON
  Map<String, dynamic> exportAllData() {
    return {
      'version': dbVersion,
      'exportDate': DateTime.now().toIso8601String(),
      'categories': getCategories().map((e) => e.toJson()).toList(),
      'transactions': getTransactions().map((e) => e.toJson()).toList(),
      'walletSettings': getWalletSettings().toJson(),
      'budgetSettings': getBudgetSettings().toJson(),
      'debts': getDebts().map((e) => e.toJson()).toList(),
      'persons': getPersons().map((e) => e.toJson()).toList(),
      'savingsGoals': getSavingsGoals().map((e) => e.toJson()).toList(),
      'savingsEntries': getSavingsEntries().map((e) => e.toJson()).toList(),
      'patterns': getPatterns().map((e) => e.toJson()).toList(),
      'appSettings': getAppSettings().toJson(),
      'onboardingComplete': getOnboardingComplete(),
    };
  }

  // Import data from JSON
  Future<void> importAllData(Map<String, dynamic> data) async {
    if (data.containsKey('categories')) {
      final cats = (data['categories'] as List).map((e) => ExpenseCategory.fromJson(e)).toList();
      await saveCategories(cats);
    }
    if (data.containsKey('transactions')) {
      final txs = (data['transactions'] as List).map((e) => TwelaTransaction.fromJson(e)).toList();
      await saveTransactions(txs);
    }
    if (data.containsKey('walletSettings')) {
      await saveWalletSettings(WalletSettings.fromJson(data['walletSettings']));
    }
    if (data.containsKey('budgetSettings')) {
      await saveBudgetSettings(BudgetSettings.fromJson(data['budgetSettings']));
    }
    if (data.containsKey('debts')) {
      final debts = (data['debts'] as List).map((e) => Debt.fromJson(e)).toList();
      await saveDebts(debts);
    }
    if (data.containsKey('persons')) {
      final persons = (data['persons'] as List).map((e) => Person.fromJson(e)).toList();
      await savePersons(persons);
    }
    if (data.containsKey('savingsGoals')) {
      final goals = (data['savingsGoals'] as List).map((e) => SavingsGoal.fromJson(e)).toList();
      await saveSavingsGoals(goals);
    }
    if (data.containsKey('savingsEntries')) {
      final entries = (data['savingsEntries'] as List).map((e) => SavingsEntry.fromJson(e)).toList();
      await saveSavingsEntries(entries);
    }
    if (data.containsKey('patterns')) {
      final patterns = (data['patterns'] as List).map((e) => RoutinePattern.fromJson(e)).toList();
      await savePatterns(patterns);
    }
    if (data.containsKey('appSettings')) {
      await saveAppSettings(AppSettings.fromJson(data['appSettings']));
    }
    if (data.containsKey('onboardingComplete')) {
      await setOnboardingComplete(data['onboardingComplete'] as bool);
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _prefs.remove(_categoriesKey);
    await _prefs.remove(_transactionsKey);
    await _prefs.remove(_walletSettingsKey);
    await _prefs.remove(_budgetSettingsKey);
    await _prefs.remove(_debtsKey);
    await _prefs.remove(_personsKey);
    await _prefs.remove(_savingsGoalsKey);
    await _prefs.remove(_savingsEntriesKey);
    await _prefs.remove(_patternsKey);
    await _prefs.remove(_appSettingsKey);
    await _prefs.remove(_onboardingCompleteKey);
  }
}
