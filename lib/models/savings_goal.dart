import 'package:uuid/uuid.dart';

enum SavingsStatus { active, paused, completed, deleted }

class SavingsGoal {
  final String id;
  final String name;
  final double dailyTarget;
  final int durationDays;
  final DateTime startDate;
  final double savedAmount;
  final SavingsStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.dailyTarget,
    required this.durationDays,
    required this.startDate,
    this.savedAmount = 0,
    this.status = SavingsStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  double get targetAmount => dailyTarget * durationDays;
  double get progress => targetAmount > 0 ? savedAmount / targetAmount : 0;
  bool get isCompleted => savedAmount >= targetAmount;
  int get daysElapsed => DateTime.now().difference(startDate).inDays;
  int get daysRemaining => (durationDays - daysElapsed).clamp(0, durationDays);
  double get remainingAmount => (targetAmount - savedAmount).clamp(0, targetAmount);

  factory SavingsGoal.create({
    required String name,
    required double dailyTarget,
    required int durationDays,
    DateTime? startDate,
  }) {
    final now = DateTime.now();
    return SavingsGoal(
      id: const Uuid().v4(),
      name: name,
      dailyTarget: dailyTarget,
      durationDays: durationDays,
      startDate: startDate ?? now,
      createdAt: now,
      updatedAt: now,
    );
  }

  SavingsGoal copyWith({
    String? name,
    double? dailyTarget,
    int? durationDays,
    double? savedAmount,
    SavingsStatus? status,
  }) {
    return SavingsGoal(
      id: id,
      name: name ?? this.name,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      durationDays: durationDays ?? this.durationDays,
      startDate: startDate,
      savedAmount: savedAmount ?? this.savedAmount,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dailyTarget': dailyTarget,
      'durationDays': durationDays,
      'startDate': startDate.toIso8601String(),
      'savedAmount': savedAmount,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as String,
      name: json['name'] as String,
      dailyTarget: (json['dailyTarget'] as num).toDouble(),
      durationDays: json['durationDays'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0,
      status: SavingsStatus.values[json['status'] as int? ?? 0],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
