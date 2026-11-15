import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design/format.dart';
import '../../design/motion.dart';
import '../../design/screen.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../models/savings_goal.dart';
import '../../providers/debt_provider.dart';
import '../../providers/savings_provider.dart';

/// Pull money out of a goal — back to a wallet, or straight onto a debt.
///
/// The [toDebt] flag turns the same sheet into a payment: the goal gives the
/// money back and the very same amount is paid to the chosen creditor, so the
/// wallet total never moves.
class SavingsWithdrawScreen extends StatefulWidget {
  const SavingsWithdrawScreen({
    super.key,
    required this.goalId,
    this.toDebt = false,
  });

  final String goalId;
  final bool toDebt;

  @override
  State<SavingsWithdrawScreen> createState() => _SavingsWithdrawScreenState();
}

class _SavingsWithdrawScreenState extends State<SavingsWithdrawScreen> {
  final _amount = TextEditingController();
  String _wallet = 'cash';
  String? _debtId;
  String? _error;

  SavingsGoal? get _goal =>
      context.read<SavingsProvider>().goalById(widget.goalId);

  bool get _toDebt => widget.toDebt;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amount.text.replaceAll(',', ''));
    final goal = _goal;

    if (goal == null ||
        amount == null ||
        amount <= 0 ||
        amount > goal.savedAmount) {
      setState(() => _error = 'أدخل مبلغًا صحيحًا ضمن المتوفر');
      return;
    }
    if (_toDebt && _debtId == null) {
      setState(() => _error = 'اختر الدين المراد سداده');
      return;
    }

    final provider = context.read<SavingsProvider>();
    final Future<bool> done = _toDebt
        ? provider.transferToDebt(
            goalId: goal.id,
            amount: amount,
            debtId: _debtId!,
            walletType: _wallet,
          )
        : provider.withdrawToWallet(
            goalId: goal.id,
            amount: amount,
            walletType: _wallet,
          );

    done.then((ok) {
      if (!mounted) return;
      if (!ok) {
        setState(() => _error = 'تعذّرت العملية، حاول مجددًا');
        return;
      }
      Navigator.of(context).maybePop();
      showInbToast(
        context,
        _toDebt ? 'حوّلت المبلغ إلى الدين' : 'أعدت المبلغ إلى محفظتك',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final sem = context.sem;
    final goal = context.watch<SavingsProvider>().goalById(widget.goalId);
    final debts = context.watch<DebtProvider>().activeDebts;

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

    return InbScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InbPageHeader(
            title: _toDebt ? 'حوّل إلى دين' : 'اسحب من الحصالة',
            subtitle: goal.name,
          ),
          const SizedBox(height: S.lg),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                CellFrame(
                  label: 'المتوفر في الحصالة',
                  child: Money(goal.savedAmount, size: 26, color: sem.savings),
                ),
                const SizedBox(height: S.lg),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: S.md),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(R.inner),
                    border: Border.all(color: c.line),
                  ),
                  child: InbAmountField(
                    controller: _amount,
                    accent: _toDebt ? sem.debt : sem.savings,
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
                      if (w.$1 != 'cash') const SizedBox(width: S.sm),
                      Expanded(
                        child: InbChip(
                          label: w.$2,
                          selected: _wallet == w.$1,
                          onTap: () => setState(() => _wallet = w.$1),
                        ),
                      ),
                    ],
                  ],
                ),
                if (_toDebt) ...[
                  const SizedBox(height: S.lg),
                  InbSectionHeader(title: 'الدين المستحق'),
                  const SizedBox(height: S.sm),
                  if (debts.isEmpty)
                    const InbEmptyState(
                      icon: Icons.handshake_outlined,
                      title: 'لا توجد ديون نشطة',
                      subtitle: 'أضف دينًا أولًا لتتمكن من السداد منه.',
                    )
                  else
                    for (final debt in debts)
                      Padding(
                        padding: const EdgeInsets.only(bottom: S.sm),
                        child: PressScale(
                          onTap: () => setState(() => _debtId = debt.id),
                          child: Container(
                            padding: const EdgeInsets.all(S.md),
                            decoration: BoxDecoration(
                              color: _debtId == debt.id
                                  ? sem.debt.withValues(alpha: 0.10)
                                  : c.surface,
                              borderRadius: BorderRadius.circular(R.inner),
                              border: Border.all(
                                color: _debtId == debt.id ? sem.debt : c.line,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        debt.personName,
                                        style: TextStyle(
                                          fontFamily: InbFonts.arabic,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: c.fg,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'المتبقي: ${formatMoney(debt.remaining)} د.ل',
                                        style: TextStyle(
                                          fontFamily: InbFonts.arabic,
                                          fontSize: 12,
                                          color: c.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_debtId == debt.id)
                                  Icon(Icons.check_circle_rounded,
                                      color: sem.debt, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
                const SizedBox(height: S.sm),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(
                      fontFamily: InbFonts.arabic,
                      fontSize: 13,
                      color: sem.danger,
                    ),
                  ),
              ],
            ),
          ),
          Reveal(
            index: 1,
            child: InbButton(
              label: _toDebt ? 'حوّل إلى الدين' : 'اسحب إلى المحفظة',
              icon:
                  _toDebt ? Icons.handshake_outlined : Icons.north_east_rounded,
              color: _toDebt ? sem.debt : sem.savings,
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}
