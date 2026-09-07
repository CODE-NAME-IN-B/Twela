import 'package:uuid/uuid.dart';

class SavingsEntry {
  final String id;
  final String savingsGoalId;
  final double amount;
  final DateTime date;
  final String note;
  final DateTime createdAt;

  const SavingsEntry({
    required this.id,
    required this.savingsGoalId,
    required this.amount,
    required this.date,
    this.note = '',
    required this.createdAt,
  });

  factory SavingsEntry.create({
    required String savingsGoalId,
    required double amount,
    String? note,
  }) {
    final now = DateTime.now();
    return SavingsEntry(
      id: const Uuid().v4(),
      savingsGoalId: savingsGoalId,
      amount: amount,
      date: now,
      note: note ?? '',
      createdAt: now,
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
    );
  }
}
