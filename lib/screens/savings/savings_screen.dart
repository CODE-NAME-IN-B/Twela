import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/daftar_theme.dart';
import '../../widgets/daftar_card.dart';
import '../../utils/daftar_number_style.dart';
import '../../providers/savings_provider.dart';
import '../../models/savings_goal.dart';
import '../../models/savings_entry.dart';
import '../../utils/formatters.dart';
import '../../widgets/twela_design_system.dart';
import 'add_savings_goal_screen.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DaftarTheme.darkSurface : DaftarTheme.lightSurface,
      appBar: AppBar(
        title: const Text('الحصالة'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.savingsSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: AppColors.savings),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddSavingsGoalScreen()),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<SavingsProvider>(
          builder: (context, provider, _) {
            final activeGoals = provider.activeGoals;
            final completedGoals = provider.completedGoals;

            if (activeGoals.isEmpty && completedGoals.isEmpty) {
              return TwelaEmptyState(
                icon: Icons.savings_outlined,
                title: 'لم تنشئ حصالة بعد',
                subtitle: 'أنشئ حصالة لادخار المال بشكل يومي',
                actionLabel: 'إنشاء حصالة',
                onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddSavingsGoalScreen()),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activeGoals.isNotEmpty) ...[
                    Text(
                      'نشطة',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    ...activeGoals.map((goal) => _buildGoalCard(context, goal, theme, isDark)),
                  ],
                  if (completedGoals.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      'مكتملة',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...completedGoals.map((goal) => _buildGoalCard(context, goal, theme, isDark)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, SavingsGoal goal, ThemeData theme, bool isDark) {
    final progress = goal.progress.clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => _showGoalDetails(context, goal, theme, isDark),
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
                    child: Text(
                      goal.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: goal.isCompleted
                          ? AppColors.incomeSurface
                          : AppColors.savingsSurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      goal.isCompleted ? 'مكتمل' : 'نشط',
                      style: TextStyle(
                        fontSize: 11,
                        color: goal.isCompleted ? AppColors.income : AppColors.savings,
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
                  Text(
                    '${formatLydShort(goal.savedAmount)} / ${formatLydShort(goal.targetAmount)}',
                    style: daftarNumberStyle(
                      fontSize: 18,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: daftarNumberStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: isDark ? AppColors.darkBorder : AppColors.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    goal.isCompleted ? AppColors.income : AppColors.savings,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${formatLydShort(goal.dailyTarget)} / يوم',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${goal.daysElapsed} من ${goal.durationDays} يوم',
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

  void _showGoalDetails(BuildContext context, SavingsGoal goal, ThemeData theme, bool isDark) {
    final provider = context.read<SavingsProvider>();
    final entries = provider.getEntriesForGoal(goal.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? DaftarTheme.darkSurface : DaftarTheme.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                goal.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              if (!goal.isCompleted) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showSaveDialog(context, goal, theme, isDark);
                    },
                    icon: const Icon(Icons.savings_outlined),
                    label: Text.rich(TextSpan(
                      children: [
                        const TextSpan(text: 'ادخر '),
                        TextSpan(
                          text: formatLyd(goal.dailyTarget),
                          style: daftarNumberStyle(fontSize: 14),
                        ),
                      ],
                    )),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'سجل الادخار',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (entries.isEmpty)
                Text(
                  'لا توجد عمليات ادخار بعد',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                )
              else
                ...entries.map((entry) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDate(entry.date),
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        formatLyd(entry.amount),
                        style: daftarNumberStyle(
                          fontSize: 14,
                          color: AppColors.income,
                        ),
                      ),
                    ],
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }

  void _showSaveDialog(BuildContext context, SavingsGoal goal, ThemeData theme, bool isDark) {
    final controller = TextEditingController(text: goal.dailyTarget.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? DaftarTheme.darkSurface : DaftarTheme.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('ادخار - ${goal.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'المبلغ',
            suffixText: 'د.ل',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                final entry = SavingsEntry.create(
                  savingsGoalId: goal.id,
                  amount: amount,
                );
                context.read<SavingsProvider>().addEntry(entry);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تسجيل الادخار')),
                );
              }
            },
            child: const Text('ادخر'),
          ),
        ],
      ),
    );
  }
}
