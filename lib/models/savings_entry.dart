import 'package:uuid/uuid.dart';

/// What a savings entry did to the goal.
///
/// - [deposit]    : money moved from a wallet into the goal
/// - [withdrawal] : money moved out of the goal, either back to a wallet or
///                  straight into a debt payment
enum SavingsEntryType { deposit, withdrawal }

class SavingsEntry {
  final String id;
  final String savingsGoalId;
  final double amount;
  final DateTime date;
  final String note;
  final DateTime createdAt;
  final String walletType;
  final SavingsEntryType type;

  /// Set when the withdrawal paid a debt instead of returning to a wallet.
  final String? linkedDebtId;
  final String? linkedDebtName;

  const SavingsEntry({
    required this.id,
    required this.savingsGoalId,
    required this.amount,
    required this.date,
    this.note = '',
    required this.createdAt,
    this.walletType = 'cash',
    this.type = SavingsEntryType.deposit,
    this.linkedDebtId,
    this.linkedDebtName,
  });

  bool get isDeposit => type == SavingsEntryType.deposit;
  bool get isWithdrawal => type == SavingsEntryType.withdrawal;
  bool get paysDebt => linkedDebtId != null && linkedDebtId!.isNotEmpty;

  factory SavingsEntry.create({
    required String savingsGoalId,
    required double amount,
    String? note,
    String walletType = 'cash',
    SavingsEntryType type = SavingsEntryType.deposit,
    String? linkedDebtId,
    String? linkedDebtName,
  }) {
    final now = DateTime.now();
    return SavingsEntry(
      id: const Uuid().v4(),
      savingsGoalId: savingsGoalId,
      amount: amount,
      date: now,
      note: note ?? '',
      createdAt: now,
      walletType: walletType,
      type: type,
      linkedDebtId: linkedDebtId,
      linkedDebtName: linkedDebtName,
    );
  }

  SavingsEntry copyWith({
    String? id,
    String? savingsGoalId,
    double? amount,
    DateTime? date,
    String? note,
    String? walletType,
    SavingsEntryType? type,
    String? linkedDebtId,
    String? linkedDebtName,
  }) {
    return SavingsEntry(
      id: id ?? this.id,
      savingsGoalId: savingsGoalId ?? this.savingsGoalId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt,
      walletType: walletType ?? this.walletType,
      type: type ?? this.type,
      linkedDebtId: linkedDebtId ?? this.linkedDebtId,
      linkedDebtName: linkedDebtName ?? this.linkedDebtName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'savingsGoalId': savingsGoalId,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'walletType': walletType,
      'type': type.index,
      'linkedDebtId': linkedDebtId,
      'linkedDebtName': linkedDebtName,
    };
  }

  factory SavingsEntry.fromJson(Map<String, dynamic> json) {
    return SavingsEntry(
      id: json['id'] as String,
      savingsGoalId: json['savingsGoalId'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      walletType: json['walletType'] as String? ?? 'cash',
      // Entries written before withdrawals existed are always deposits.
      type: SavingsEntryType.values[json['type'] as int? ?? 0],
      linkedDebtId: json['linkedDebtId'] as String?,
      linkedDebtName: json['linkedDebtName'] as String?,
    );
  }
}
