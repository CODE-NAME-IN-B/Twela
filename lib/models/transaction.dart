enum TransactionType { income, expense }

enum WalletType { cash, bank }

class TwelaTransaction {
  final String id;
  final double amount;
  final TransactionType type;
  final WalletType walletType;
  final String categoryId;
  final String note;
  final DateTime date;

  const TwelaTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.walletType,
    required this.categoryId,
    this.note = '',
    required this.date,
  });

  TwelaTransaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    WalletType? walletType,
    String? categoryId,
    String? note,
    DateTime? date,
  }) {
    return TwelaTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      walletType: walletType ?? this.walletType,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
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
    );
  }
}
