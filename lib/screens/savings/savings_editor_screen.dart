import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design/format.dart';
import '../../design/motion.dart';
import '../../design/screen.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../models/savings_goal.dart';
import '../../providers/savings_provider.dart';
import '../../l10n/generated/app_localizations.dart';

/// Create a goal, or edit an existing one.
///
/// One name field, one amount field, one duration field — and a single
/// filled button. Everything else is the system's own voice.
class SavingsEditorScreen extends StatefulWidget {
  const SavingsEditorScreen({super.key, this.goalId});

  /// Null means "create a new goal".
  final String? goalId;

  @override
  State<SavingsEditorScreen> createState() => _SavingsEditorScreenState();
}

class _SavingsEditorScreenState extends State<SavingsEditorScreen> {
  final _name = TextEditingController();
  final _daily = TextEditingController();
  final _days = TextEditingController();
  bool _valid = true;

  @override
  void initState() {
    super.initState();
    final goal = widget.goalId == null
        ? null
        : context.read<SavingsProvider>().goalById(widget.goalId!);
    if (goal != null) {
      _name.text = goal.name;
      _daily.text = goal.dailyTarget.toStringAsFixed(2);
      _days.text = '${goal.durationDays}';
    } else {
      _days.text = '30';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _daily.dispose();
    _days.dispose();
    super.dispose();
  }

  bool get _editing => widget.goalId != null;

  void _save() {
    final name = _name.text.trim();
    final daily = double.tryParse(_daily.text.replaceAll(',', ''));
    final days = int.tryParse(_days.text);

    if (name.isEmpty ||
        daily == null ||
        daily <= 0 ||
        days == null ||
        days <= 0) {
      setState(() => _valid = false);
      return;
    }

    final provider = context.read<SavingsProvider>();

    if (_editing) {
      final goal = provider.goalById(widget.goalId!)!;
      provider.updateGoal(
        goal.copyWith(
          name: name,
          dailyTarget: daily,
          durationDays: days,
        ),
      );
    } else {
      provider.addGoal(
        SavingsGoal.create(
          name: name,
          dailyTarget: daily,
          durationDays: days,
        ),
      );
    }

    Navigator.of(context).maybePop();
    showInbToast(
        context,
        _editing
            ? AppLocalizations.of(context)!.changesSaved
            : AppLocalizations.of(context)!.goalWasCreated);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final goal = _editing
        ? context.watch<SavingsProvider>().goalById(widget.goalId!)
        : null;
    final target = goal?.targetAmount ?? 0;

    return InbScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InbPageHeader(
            title: _editing
                ? AppLocalizations.of(context)!.editGoal
                : AppLocalizations.of(context)!.newGoal,
            subtitle: _editing
                ? goal?.name
                : AppLocalizations.of(context)!.setAmountAndTime,
          ),
          const SizedBox(height: S.lg),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                InbTextField(
                  controller: _name,
                  label: AppLocalizations.of(context)!.name,
                  hint: AppLocalizations.of(context)!.nameExample,
                ),
                const SizedBox(height: S.lg),
                InbTextField(
                  controller: _daily,
                  label: AppLocalizations.of(context)!.dailyAmount,
                  hint: '0.00',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: S.lg),
                InbTextField(
                  controller: _days,
                  label: AppLocalizations.of(context)!.durationLabel,
                  hint: '30',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: S.lg),
                if (target > 0)
                  CellFrame(
                    label: AppLocalizations.of(context)!.totalTarget,
                    child: Money(target, size: 22, color: c.fg),
                  ),
                if (!_valid) ...[
                  const SizedBox(height: S.sm),
                  Text(
                    AppLocalizations.of(context)!.fillThreeFields,
                    style: TextStyle(
                      fontFamily: InbFonts.arabic,
                      fontSize: 13,
                      color: context.sem.danger,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Reveal(
            index: 1,
            child: InbButton(
              label: _editing
                  ? AppLocalizations.of(context)!.saveChanges
                  : AppLocalizations.of(context)!.createGoalAction,
              icon: Icons.check_rounded,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }
}
