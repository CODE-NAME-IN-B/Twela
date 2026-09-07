import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/savings_provider.dart';
import '../../models/savings_goal.dart';
import '../../models/savings_entry.dart';
import '../../utils/formatters.dart';
import 'add_savings_goal_screen.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('الحصالة'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.primary.withOpacity(0.15)
                    : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Icon(Icons.add, color: theme.colorScheme.primary),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddSavingsGoalScreen()),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<SavingsProvider>(
        builder: (context, provider, _) {
          final activeGoals = provider.activeGoals;
          final completedGoals = provider.completedGoals;

          if (activeGoals.isEmpty && completedGoals.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.primary.withOpacity(0.15)
                            : const Color(0xFFECFDF5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.savings_outlined,
                        size: 36,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'لم تنشئ حصالة بعد',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أنشئ حصالة لادخار المال بشكل يومي',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddSavingsGoalScreen()),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('إنشاء حصالة'),
                    ),
                  ],
                ),
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
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
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
    );
  }

  Widget _buildGoalCard(BuildContext context, dynamic goal, ThemeData theme, bool isDark) {
    final provider = context.read<SavingsProvider>();
    final progress = goal.progress.clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => _showGoalDetails(context, goal, theme, isDark),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          ),
        ),
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
                        ? (isDark ? const Color(0xFF149C6D).withOpacity(0.1) : const Color(0xFFECFDF5))
                        : (isDark ? theme.colorScheme.primary.withOpacity(0.15) : const Color(0xFFECFDF5)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    goal.isCompleted ? 'مكتمل' : 'نشط',
                    style: TextStyle(
                      fontSize: 11,
                      color: goal.isCompleted ? AppColors.success : theme.colorScheme.primary,
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(
                  goal.isCompleted ? AppColors.success : theme.colorScheme.primary,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${formatLyd(goal.dailyTarget)} / يوم',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  '${goal.daysElapsed} من ${goal.durationDays} يوم',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalDetails(BuildContext context, dynamic goal, ThemeData theme, bool isDark) {
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
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
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
                    label: Text('ادخر ${formatLyd(goal.dailyTarget)}'),
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
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                )
              else
                ...entries.map((entry) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
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
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
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

  void _showSaveDialog(BuildContext context, dynamic goal, ThemeData theme, bool isDark) {
    final controller = TextEditingController(text: goal.dailyTarget.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('ادخار - ${goal.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'المبلغ',
            suffixText: 'LYD',
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
