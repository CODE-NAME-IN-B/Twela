import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/routine_pattern.dart';

class RoutineDetectionService {
  static const _uuid = Uuid();

  static List<RoutinePattern> detectPatterns({
    required List<TwelaTransaction> transactions,
    required List<RoutinePattern> existingPatterns,
  }) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentExpenses = transactions
        .where((t) => t.type == TransactionType.expense && t.date.isAfter(thirtyDaysAgo))
        .toList();

    final patterns = List<RoutinePattern>.from(existingPatterns);

    // Group by category
    final categoryGroups = <String, List<TwelaTransaction>>{};
    for (final t in recentExpenses) {
      categoryGroups.putIfAbsent(t.categoryId, () => []).add(t);
    }

    for (final entry in categoryGroups.entries) {
      final categoryId = entry.key;
      final categoryTransactions = entry.value;

      // Find potential patterns based on amount and time
      for (final transaction in categoryTransactions) {
        final matches = categoryTransactions.where((t) {
          final amountDiff = (t.amount - transaction.amount).abs();
          final timeDiff = t.date.difference(transaction.date).abs();
          return amountDiff <= transaction.amount * 0.2 &&
              timeDiff.inMinutes.abs() % (24 * 60) < 45; // Same time window
        }).toList();

        if (matches.length >= 3) {
          final existingPattern = patterns.where((p) =>
              p.categoryId == categoryId &&
              (p.approxAmount - transaction.amount).abs() <= transaction.amount * 0.2);

          if (existingPattern.isNotEmpty) {
            final pattern = existingPattern.first;
            pattern.occurrenceCount = matches.length;
            if (pattern.occurrenceCount >= 4 && pattern.status == PatternStatus.learning) {
              pattern.status = PatternStatus.suggesting;
            }
          } else {
            final newPattern = RoutinePattern(
              id: _uuid.v4(),
              categoryId: categoryId,
              approxAmount: transaction.amount,
              amountTolerance: transaction.amount * 0.2,
              timeWindowStart: TimeOfDay(
                hour: transaction.date.hour,
                minute: transaction.date.minute,
              ),
              timeWindowEnd: TimeOfDay(
                hour: (transaction.date.hour + 1) % 24,
                minute: transaction.date.minute,
              ),
              occurrenceCount: matches.length,
              status: matches.length >= 4 ? PatternStatus.suggesting : PatternStatus.learning,
            );
            patterns.add(newPattern);
          }
        }
      }
    }

    return patterns;
  }
}
