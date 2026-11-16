import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/daftar_theme.dart';
import '../../widgets/daftar_card.dart';
import '../../utils/daftar_number_style.dart';
import '../../providers/savings_provider.dart';
import '../../models/savings_goal.dart';
import '../../widgets/twela_design_system.dart';
import 'add_savings_goal_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design/format.dart';
import '../../design/motion.dart';
import '../../design/tokens.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? DaftarTheme.darkSurface : DaftarTheme.lightSurface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.savingsGoal),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.savingsSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Icon(Icons.add, color: AppColors.savings),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddSavingsGoalScreen()),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Reveal(child: SafeArea(
        child: Consumer<SavingsProvider>(
          builder: (context, provider, _) {
            final activeGoals = provider.activeGoals;
            final completedGoals = provider.completedGoals;

            if (activeGoals.isEmpty && completedGoals.isEmpty) {
              return TwelaEmptyState(
                icon: Icons.savings_outlined,
                title: AppLocalizations.of(context)!.noGoalsYet,
                subtitle: AppLocalizations.of(context)!.noGoalsYetBody,
                actionLabel: AppLocalizations.of(context)!.createSavingsGoal,
                onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddSavingsGoalScreen()),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsetsDirectional.only(
                  start: 20, top: 16, end: 20, bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activeGoals.isNotEmpty) ...[
                    Text(
                      AppLocalizations.of(context)!.active,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    ...activeGoals.map(
                        (goal) => _buildGoalCard(context, goal, theme, isDark)),
                  ],
                  if (completedGoals.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      AppLocalizations.of(context)!.completed,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...completedGoals.map(
                        (goal) => _buildGoalCard(context, goal, theme, isDark)),
                  ],
                ],
              ),
            );
          },
        ),
      )),
    );
  }

  Widget _buildGoalCard(
      BuildContext context, SavingsGoal goal, ThemeData theme, bool isDark) {
    final progress = goal.progress.clamp(0.0, 1.0);

    return PressScale(
      onTap: () => Navigator.pushNamed(
        context,
        '/savings-detail',
        arguments: {'goalId': goal.id},
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DaftarCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Hero(
                      tag: 'goal-${goal.id}',
                      child: Text(
                        goal.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: goal.isCompleted
                          ? AppColors.incomeSurface
                          : AppColors.savingsSurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      goal.isCompleted
                          ? AppLocalizations.of(context)!.completedShort
                          : AppLocalizations.of(context)!.activeShort,
                      style: TextStyle(
                        fontSize: 11,
                        color: goal.isCompleted
                            ? AppColors.income
                            : AppColors.savings,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Money(
                        goal.savedAmount,
                        size: 18,
                        weight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        showCurrency: false,
                      ),
                      Text(
                        ' / ',
                        style: daftarNumberStyle(
                          context,
                          fontSize: 18,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Money(
                        goal.targetAmount,
                        size: 18,
                        weight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        showCurrency: false,
                      ),
                    ],
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: daftarNumberStyle(
                      context,
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(S.xs),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: Motion.slow,
                  curve: Motion.emphasized,
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v,
                    backgroundColor:
                        isDark ? AppColors.darkBorder : AppColors.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      goal.isCompleted ? AppColors.income : AppColors.savings,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Money(
                        goal.dailyTarget,
                        size: 13,
                        weight: FontWeight.w400,
                        showCurrency: false,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      Text(
                        ' / ${AppLocalizations.of(context)!.daily}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    AppLocalizations.of(context)!
                        .daysOfTotal(goal.daysElapsed, goal.durationDays),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
