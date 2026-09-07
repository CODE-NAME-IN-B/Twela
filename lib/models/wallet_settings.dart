class WalletSettings {
  final double initialCashBalance;
  final double initialBankBalance;

  const WalletSettings({
    this.initialCashBalance = 0,
    this.initialBankBalance = 0,
  });

  WalletSettings copyWith({
    double? initialCashBalance,
    double? initialBankBalance,
  }) {
    return WalletSettings(
      initialCashBalance: initialCashBalance ?? this.initialCashBalance,
      initialBankBalance: initialBankBalance ?? this.initialBankBalance,
    );
  }

  double get totalBalance => initialCashBalance + initialBankBalance;

  Map<String, dynamic> toJson() {
    return {
      'initialCashBalance': initialCashBalance,
      'initialBankBalance': initialBankBalance,
    };
  }

  factory WalletSettings.fromJson(Map<String, dynamic> json) {
    return WalletSettings(
      initialCashBalance: (json['initialCashBalance'] as num?)?.toDouble() ?? 0,
      initialBankBalance: (json['initialBankBalance'] as num?)?.toDouble() ?? 0,
    );
  }
}
