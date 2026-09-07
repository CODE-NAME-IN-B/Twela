class BudgetSettings {
  final double? monthlyBudgetTotal;
  final double? dailySpendingLimit;
  final double? lowBalanceThreshold;

  const BudgetSettings({
    this.monthlyBudgetTotal,
    this.dailySpendingLimit,
    this.lowBalanceThreshold,
  });

  BudgetSettings copyWith({
    double? monthlyBudgetTotal,
    double? dailySpendingLimit,
    double? lowBalanceThreshold,
    bool clearMonthly = false,
    bool clearDaily = false,
    bool clearLowBalance = false,
  }) {
    return BudgetSettings(
      monthlyBudgetTotal: clearMonthly ? null : (monthlyBudgetTotal ?? this.monthlyBudgetTotal),
      dailySpendingLimit: clearDaily ? null : (dailySpendingLimit ?? this.dailySpendingLimit),
      lowBalanceThreshold: clearLowBalance ? null : (lowBalanceThreshold ?? this.lowBalanceThreshold),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthlyBudgetTotal': monthlyBudgetTotal,
      'dailySpendingLimit': dailySpendingLimit,
      'lowBalanceThreshold': lowBalanceThreshold,
    };
  }

  factory BudgetSettings.fromJson(Map<String, dynamic> json) {
    return BudgetSettings(
      monthlyBudgetTotal: (json['monthlyBudgetTotal'] as num?)?.toDouble(),
      dailySpendingLimit: (json['dailySpendingLimit'] as num?)?.toDouble(),
      lowBalanceThreshold: (json['lowBalanceThreshold'] as num?)?.toDouble(),
    );
  }
}
