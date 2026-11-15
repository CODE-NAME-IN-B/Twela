/// IMPORTANT: never reorder or remove existing values — the enum index is
/// persisted in storage as `type.index`.
enum TransactionType {
  income,
  expense,
  debtGiven,
  debtReceived,
  debtPayment,
  savings,

  /// Money that came back out of a savings goal (to a wallet, or straight
  /// into a debt payment). It is a credit on the balance.
  savingsWithdrawal,
}

enum WalletType { cash, bank }

class TwelaTransaction {
  final String id;
  final double amount;
  final TransactionType type;
  final WalletType walletType;
  final String categoryId;
  final String note;
  final DateTime date;
  final String? relatedId;

  /// Links a transaction to the exact savings entry that produced it, so a
  /// single entry can be undone without touching its neighbours.
  final String? relatedEntryId;

  const TwelaTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.walletType,
    required this.categoryId,
    this.note = '',
    required this.date,
    this.relatedId,
    this.relatedEntryId,
  });

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;
  bool get isDebt =>
      type == TransactionType.debtGiven ||
      type == TransactionType.debtReceived ||
      type == TransactionType.debtPayment;
  bool get isSavings => type == TransactionType.savings;

  /// Any movement caused by a savings goal, in either direction.
  bool get isSavingsFlow =>
      type == TransactionType.savings ||
      type == TransactionType.savingsWithdrawal;

  /// Does this movement add to the wallet balance?
  bool get isCredit =>
      type == TransactionType.income ||
      type == TransactionType.debtReceived ||
      type == TransactionType.savingsWithdrawal;

  /// Does this movement take from the wallet balance?
  bool get isDebit =>
      type == TransactionType.expense ||
      type == TransactionType.debtGiven ||
      type == TransactionType.debtPayment ||
      type == TransactionType.savings;

  TwelaTransaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    WalletType? walletType,
    String? categoryId,
    String? note,
    DateTime? date,
    String? relatedId,
    String? relatedEntryId,
  }) {
    return TwelaTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      walletType: walletType ?? this.walletType,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      relatedId: relatedId ?? this.relatedId,
      relatedEntryId: relatedEntryId ?? this.relatedEntryId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.index,
      'walletType': walletType.index,
      'categoryId': categoryId,
      'note': note,
      'date': date.toIso8601String(),
      'relatedId': relatedId,
      'relatedEntryId': relatedEntryId,
    };
  }

  factory TwelaTransaction.fromJson(Map<String, dynamic> json) {
    return TwelaTransaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values[json['type'] as int],
      walletType: WalletType.values[json['walletType'] as int],
      categoryId: json['categoryId'] as String,
      note: json['note'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      relatedId: json['relatedId'] as String?,
      relatedEntryId: json['relatedEntryId'] as String?,
    );
  }
}
