import 'package:flutter/material.dart';

enum PatternStatus { learning, suggesting, autoConfirmed, dismissed }

class RoutinePattern {
  final String id;
  final String categoryId;
  final double approxAmount;
  final double amountTolerance;
  final TimeOfDay timeWindowStart;
  final TimeOfDay timeWindowEnd;
  final List<int> daysOfWeek;
  int occurrenceCount;
  PatternStatus status;
  DateTime? lastTriggeredDate;
  final String note;

  RoutinePattern({
    required this.id,
    required this.categoryId,
    required this.approxAmount,
    this.amountTolerance = 5.0,
    required this.timeWindowStart,
    required this.timeWindowEnd,
    this.daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
    this.occurrenceCount = 1,
    this.status = PatternStatus.learning,
    this.lastTriggeredDate,
    this.note = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'approxAmount': approxAmount,
      'amountTolerance': amountTolerance,
      'timeWindowStartHour': timeWindowStart.hour,
      'timeWindowStartMinute': timeWindowStart.minute,
      'timeWindowEndHour': timeWindowEnd.hour,
      'timeWindowEndMinute': timeWindowEnd.minute,
      'daysOfWeek': daysOfWeek,
      'occurrenceCount': occurrenceCount,
      'status': status.index,
      'lastTriggeredDate': lastTriggeredDate?.toIso8601String(),
      'note': note,
    };
  }

  factory RoutinePattern.fromJson(Map<String, dynamic> json) {
    return RoutinePattern(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      approxAmount: (json['approxAmount'] as num).toDouble(),
      amountTolerance: (json['amountTolerance'] as num?)?.toDouble() ?? 5.0,
      timeWindowStart: TimeOfDay(
        hour: json['timeWindowStartHour'] as int,
        minute: json['timeWindowStartMinute'] as int,
      ),
      timeWindowEnd: TimeOfDay(
        hour: json['timeWindowEndHour'] as int,
        minute: json['timeWindowEndMinute'] as int,
      ),
      daysOfWeek: List<int>.from(json['daysOfWeek'] as List),
      occurrenceCount: json['occurrenceCount'] as int? ?? 1,
      status: PatternStatus.values[json['status'] as int? ?? 0],
      lastTriggeredDate: json['lastTriggeredDate'] != null
          ? DateTime.parse(json['lastTriggeredDate'] as String)
          : null,
      note: json['note'] as String? ?? '',
    );
  }
}
