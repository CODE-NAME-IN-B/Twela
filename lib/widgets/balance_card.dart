import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../design/format.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../models/transaction.dart';
import '../providers/twela_provider.dart';

/// The hero of the home screen: total balance on a dark island, framed in
/// rose, with the `+` notch (movement sheet) and a doodle arrow pointing at it.
class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, this.onAction});

  /// Opens the movement sheet from the island's notch button.
  final VoidCallback? onAction;

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TwelaProvider>();
    final sem = context.sem;

    final todayIncome = provider.transactions
        .where(
          (t) =>
              _isToday(t.date) &&
              (t.type == TransactionType.income ||
                  t.type == TransactionType.savingsWithdrawal),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    return RoseFrame(
      child: IslandCard(
        padding: EdgeInsetsDirectional.fromSTEB(S.lg, S.lg, S.lg, S.lg),
        notchColor: context.inb.rose,
        onAction: onAction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الرصيد الكلي', style: microStyle(context)),
            const SizedBox(height: S.sm),
            Money(
              provider.totalBalance,
              size: 40,
              color: context.inb.onIsland,
              animate: true,
            ),
            const SizedBox(height: S.md),
            Row(
              children: [
                Expanded(
                    child:
                        _IslandStat(label: 'كاش', value: provider.cashBalance)),
                const SizedBox(width: S.sm),
                Expanded(
                    child: _IslandStat(
                        label: 'مصرف', value: provider.bankBalance)),
              ],
            ),
            const SizedBox(height: S.sm),
            Row(
              children: [
                Expanded(
                  child: _IslandStat(
                    label: 'دخل اليوم',
                    value: todayIncome,
                    tone: sem.income,
                  ),
                ),
                const SizedBox(width: S.sm),
                Expanded(
                  child: _IslandStat(
                    label: 'صرف اليوم',
                    value: provider.todaySpent,
                    tone: sem.expense,
                  ),
                ),
              ],
            ),
            // Space the notch (bottom-start) needs, and the doodle arrow
            // rising from the end side toward it.
            const SizedBox(height: S.lg + S.sm),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: DoodleArrow(color: context.inb.mint),
            ),
          ],
        ),
      ),
    );
  }
}

class _IslandStat extends StatelessWidget {
  const _IslandStat({required this.label, required this.value, this.tone});

  final String label;
  final double value;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: microStyle(context, color: c.onIsland.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 2),
        Money(value, size: 15, color: tone ?? c.onIsland),
      ],
    );
  }
}
