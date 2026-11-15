import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design/format.dart';
import '../../design/motion.dart';
import '../../design/screen.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../models/savings_entry.dart';
import '../../models/savings_goal.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/savings_provider.dart';

/// The goal detail: everything you can do to one savings goal.
///
/// ادخار · سحب · تحويل إلى دين · تعديل · إيقاف/استئناف · حذف (مع تراجع)
class SavingsDetailScreen extends StatelessWidget {
  const SavingsDetailScreen({super.key, required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SavingsProvider>();
    final goal = provider.goalById(goalId);

    if (goal == null) {
      return InbScreen(
        child: InbErrorState(
          title: 'الحصالة غير موجودة',
          subtitle: 'ربما تم حذفها. عد إلى القائمة لاختيار حصالة أخرى.',
          retryLabel: 'رجوع',
          onRetry: () => Navigator.of(context).maybePop(),
        ),
      );
    }

    final entries = provider.getEntriesForGoal(goalId);

    return InbScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: S.md),
            child: InbPageHeader(
              title: goal.name,
              subtitle: goal.isPaused
                  ? 'موقوفة مؤقتًا'
                  : (goal.isCompleted ? 'اكتملت' : 'نشطة'),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Reveal(child: _Hero(goal: goal)),
                const SizedBox(height: S.md),
                Reveal(index: 1, child: _Stats(goal: goal)),
                const SizedBox(height: S.lg),
                Reveal(index: 2, child: _Actions(goal: goal)),
                const SizedBox(height: S.lg),
                Reveal(
                  index: 3,
                  child: InbSectionHeader(
                    title: 'سجل الحركة',
                    trailing: Text(
                      '${entries.length}',
                      style: monoStyle(context,
                          size: 12, color: context.inb.muted),
                    ),
                  ),
                ),
                if (entries.isEmpty)
                  InbEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'لا توجد حركات بعد',
                    subtitle: 'ابدأ بالادخار اليومي لتظهر الحركات هنا.',
                  )
                else
                  for (final entry in entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: S.sm),
                      child: _EntryRow(entry: entry, goalName: goal.name),
                    ),
                const SizedBox(height: S.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The hero: how much is in the goal, against the target.
class _Hero extends StatelessWidget {
  const _Hero({required this.goal});
  final SavingsGoal goal;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final sem = context.sem;
    final progress = goal.progress;
    final done = goal.isCompleted;

    return Container(
      padding: const EdgeInsets.all(S.lg),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(R.card),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('المُدَّخر', style: microStyle(context))),
              if (done)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: S.md),
                  decoration: BoxDecoration(
                    color: sem.income.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(R.pill),
                  ),
                  child: Text(
                    'مكتمل',
                    style: TextStyle(
                      fontFamily: InbFonts.arabic,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: sem.income,
                    ),
                  ),
                )
              else if (goal.isPaused)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.line,
                    borderRadius: BorderRadius.circular(R.pill),
                  ),
                  child: Text(
                    'موقوف',
                    style: TextStyle(
                      fontFamily: InbFonts.arabic,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: c.muted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: S.sm),
          Money(
            goal.savedAmount,
            size: 40,
            color: c.fg,
          ),
          const SizedBox(height: S.xs),
          Row(
            children: [
              Text(
                'من هدف',
                style: TextStyle(
                  fontFamily: InbFonts.arabic,
                  fontSize: 13,
                  color: c.muted,
                ),
              ),
              const SizedBox(width: S.sm),
              Money(goal.targetAmount,
                  size: 13, color: c.muted, weight: FontWeight.w400),
              const Spacer(),
              Text(
                formatPercent(progress),
                style: monoStyle(context, size: 13, color: sem.savings),
              ),
            ],
          ),
          const SizedBox(height: S.md),
          InbProgress(
            value: progress,
            color: done ? sem.income : sem.savings,
            height: 8,
          ),
        ],
      ),
    );
  }
}

/// The three numbers that explain the goal.
class _Stats extends StatelessWidget {
  const _Stats({required this.goal});
  final SavingsGoal goal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CellFrame(
            label: 'المتبقي',
            padding: const EdgeInsets.all(S.md),
            child: Money(goal.remainingAmount, size: 16, color: context.inb.fg),
          ),
        ),
        const SizedBox(width: S.sm),
        Expanded(
          child: CellFrame(
            label: 'يومي',
            padding: const EdgeInsets.all(S.md),
            child: Money(goal.dailyTarget, size: 16, color: context.inb.fg),
          ),
        ),
        const SizedBox(width: S.sm),
        Expanded(
          child: CellFrame(
            label: 'الأيام',
            padding: const EdgeInsets.all(S.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${goal.daysRemaining}',
                  style: monoStyle(context, size: 16),
                ),
                const SizedBox(width: 4),
                Text(
                  'من ${goal.durationDays}',
                  style: TextStyle(
                    fontFamily: InbFonts.arabic,
                    fontSize: 11,
                    color: context.inb.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The six actions.
class _Actions extends StatelessWidget {
  const _Actions({required this.goal});
  final SavingsGoal goal;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final sem = context.sem;
    final paused = goal.isPaused;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // One filled button per screen: ادخار.
        InbButton(
          label: paused ? 'الحصالة موقوفة' : 'ادخِر',
          icon: paused ? Icons.pause_circle_outline : Icons.savings_outlined,
          color: paused ? c.muted : sem.savings,
          onPressed: paused ? null : () => showDepositSheet(context, goal),
        ),
        const SizedBox(height: S.sm),
        Row(
          children: [
            Expanded(
              child: InbGhostButton(
                label: 'اسحب',
                icon: Icons.north_east_rounded,
                color: sem.savings,
                onPressed: goal.savedAmount <= 0
                    ? null
                    : () => Navigator.pushNamed(
                          context,
                          '/savings-withdraw',
                          arguments: {'goalId': goal.id},
                        ),
              ),
            ),
            const SizedBox(width: S.sm),
            Expanded(
              child: InbGhostButton(
                label: 'حوّل إلى دين',
                icon: Icons.handshake_outlined,
                color: sem.debt,
                onPressed: goal.savedAmount <= 0
                    ? null
                    : () => Navigator.pushNamed(
                          context,
                          '/savings-withdraw',
                          arguments: {'goalId': goal.id, 'toDebt': true},
                        ),
              ),
            ),
          ],
        ),
        const SizedBox(height: S.sm),
        Row(
          children: [
            Expanded(
              child: InbGhostButton(
                label: 'تعديل',
                icon: Icons.edit_outlined,
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/savings-edit',
                  arguments: {'goalId': goal.id},
                ),
              ),
            ),
            const SizedBox(width: S.sm),
            Expanded(
              child: InbGhostButton(
                label: paused ? 'استأنف' : 'أوقف مؤقتًا',
                icon: paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                onPressed: () => _togglePause(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: S.sm),
        InbGhostButton(
          label: 'احذف الحصالة',
          icon: Icons.delete_outline,
          color: sem.danger,
          onPressed: () => _deleteGoal(context),
        ),
      ],
    );
  }

  void _togglePause(BuildContext context) {
    final provider = context.read<SavingsProvider>();
    final goalId = goal.id;
    if (goal.isPaused) {
      provider.resumeGoal(goalId);
      showInbToast(context, 'تم استئناف الحصالة');
    } else {
      provider.pauseGoal(goalId);
      showInbToast(context, 'تم إيقاف الحصالة مؤقتًا');
    }
  }

  /// Deleting a goal returns the money still inside it to the wallet. The
  /// action is undoable, so no confirmation dialog is needed.
  void _deleteGoal(BuildContext context) {
    final provider = context.read<SavingsProvider>();
    final goalId = goal.id;
    final hadMoney = goal.savedAmount > 0;

    provider.deleteGoal(goalId);
    Navigator.of(context).maybePop();

    showInbToast(
      context,
      hadMoney ? 'حُذفت الحصالة ورجع المبلغ إلى محفظتك' : 'حُذفت الحصالة',
      undoLabel: 'تراجع',
      onUndo: () => provider.restoreGoal(goalId),
    );
  }
}

/// One movement inside the goal.
class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.goalName});
  final SavingsEntry entry;
  final String goalName;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final sem = context.sem;

    final Color tone;
    final String label;
    final IconData icon;
    if (entry.isDeposit) {
      tone = sem.savings;
      label = 'ادخار';
      icon = Icons.south_west_rounded;
    } else if (entry.paysDebt) {
      tone = sem.debt;
      label = 'سداد دين ${entry.linkedDebtName ?? ''}';
      icon = Icons.handshake_outlined;
    } else {
      tone = sem.income;
      label = 'سحب';
      icon = Icons.north_east_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(S.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(R.inner),
        border: Border.all(color: c.line),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(R.inner),
            ),
            child: Icon(icon, size: 18, color: tone),
          ),
          const SizedBox(width: S.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: InbFonts.arabic,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: c.fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatDateShort(entry.date)} · ${entry.walletType == 'bank' ? 'مصرف' : 'كاش'}',
                  style: TextStyle(
                    fontFamily: InbFonts.arabic,
                    fontSize: 12,
                    color: c.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: S.sm),
          Money(
            entry.amount,
            size: 15,
            color: tone,
          ),
          const SizedBox(width: S.xs),
          InbIconButton(
            icon: Icons.close_rounded,
            size: 36,
            color: c.muted,
            tooltip: 'حذف الحركة',
            onPressed: () => _removeEntry(context),
          ),
        ],
      ),
    );
  }

  void _removeEntry(BuildContext context) {
    final provider = context.read<SavingsProvider>();
    final entryId = entry.id;
    final debtId = entry.linkedDebtId;
    final amount = entry.amount;

    provider.removeEntry(entryId);

    showInbToast(
      context,
      'حُذفت الحركة',
      undoLabel: 'تراجع',
      onUndo: () async {
        // Rebuild the entry and its movements.
        final restored = SavingsEntry.create(
          savingsGoalId: entry.savingsGoalId,
          amount: amount,
          walletType: entry.walletType,
          note: entry.note,
          type: entry.type,
          linkedDebtId: debtId,
          linkedDebtName: entry.linkedDebtName,
        );
        await provider.restoreEntry(restored);
      },
    );
  }
}

/// The deposit sheet: amount + wallet + one confirm.
Future<void> showDepositSheet(BuildContext context, SavingsGoal goal) async {
  final provider = context.read<SavingsProvider>();
  final controller =
      TextEditingController(text: goal.dailyTarget.toStringAsFixed(2));
  var wallet = 'cash';
  String? error;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) => InbSheet(
        title: 'ادخار',
        subtitle: goal.name,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            S.md,
            0,
            S.md,
            S.md + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: S.md),
                decoration: BoxDecoration(
                  color: context.inb.surface,
                  borderRadius: BorderRadius.circular(R.inner),
                  border: Border.all(color: context.inb.line),
                ),
                child: InbAmountField(
                  controller: controller,
                  accent: context.sem.savings,
                  autofocus: true,
                ),
              ),
              const SizedBox(height: S.md),
              Row(
                children: [
                  for (final w in const [
                    ('cash', 'كاش'),
                    ('bank', 'مصرف')
                  ]) ...[
                    if (w != ('cash', 'كاش')) const SizedBox(width: S.sm),
                    Expanded(
                      child: InbChip(
                        label: w.$2,
                        selected: wallet == w.$1,
                        onTap: () => setSheetState(() => wallet = w.$1),
                      ),
                    ),
                  ],
                ],
              ),
              if (error != null) ...[
                const SizedBox(height: S.sm),
                Text(
                  error!,
                  style: TextStyle(
                    fontFamily: InbFonts.arabic,
                    fontSize: 13,
                    color: context.sem.danger,
                  ),
                ),
              ],
              const SizedBox(height: S.md),
              InbButton(
                label: 'ادخِر',
                icon: Icons.savings_outlined,
                color: context.sem.savings,
                onPressed: () async {
                  final amount =
                      double.tryParse(controller.text.replaceAll(',', ''));
                  if (amount == null || amount <= 0) {
                    setSheetState(() => error = 'أدخل مبلغًا أكبر من صفر');
                    return;
                  }
                  await provider.addDeposit(
                    goalId: goal.id,
                    amount: amount,
                    walletType: wallet,
                  );
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  showInbToast(context, 'تم تسجيل الادخار');
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );

  controller.dispose();
}

/// Re-exported so the list screen can reuse the same delete/undo wording.
String savingsUndoLabel() => 'تراجع';

/// Convenience for the haptic setting used across the savings flow.
bool savingsHapticsOn(BuildContext context) =>
    context.read<AppSettingsProvider>().hapticFeedback;
