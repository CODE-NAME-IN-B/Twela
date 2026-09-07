import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/wallet_settings.dart';
import '../models/budget_settings.dart';
import '../models/debt.dart';
import '../models/routine_pattern.dart';

class StorageService {
  static const String _categoriesKey = 'categories';
  static const String _transactionsKey = 'transactions';
  static const String _walletSettingsKey = 'wallet_settings';
  static const String _budgetSettingsKey = 'budget_settings';
  static const String _debtsKey = 'debts';
  static const String _patternsKey = 'patterns';
  static const String _onboardingCompleteKey = 'onboarding_complete';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

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
}
