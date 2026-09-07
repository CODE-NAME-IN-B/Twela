import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../providers/twela_provider.dart';
import '../../models/transaction.dart';
import '../../utils/formatters.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('الإحصائيات'),
      ),
      body: Consumer<TwelaProvider>(
        builder: (context, provider, _) {
          final transactions = provider.transactions;
          final expenses = transactions
              .where((t) => t.type == TransactionType.expense)
              .toList();

          if (expenses.isEmpty) {
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
                        Icons.bar_chart_outlined,
                        size: 36,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'لا توجد بيانات كافية',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ابدأ بتسجيل مصاريفك لرؤية الإحصائيات',
                      style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                      textAlign: TextAlign.center,
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
                _buildMonthlySummary(context, provider, isDark, theme),
                const SizedBox(height: 20),
                _buildCategoryChart(
                    context, provider, expenses, isDark, theme),
                const SizedBox(height: 20),
                _buildTopCategories(
                    context, provider, expenses, isDark, theme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthlySummary(
      BuildContext context, TwelaProvider provider, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الشهر',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'الإجمالي',
                  formatLyd(provider.totalBalance),
                  AppColors.primary,
                  Icons.account_balance_wallet_outlined,
                  isDark,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'المصروفات',
                  formatLyd(provider.monthSpent),
                  AppColors.danger,
                  Icons.arrow_upward_rounded,
                  isDark,
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
    bool isDark,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                      color: color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(
    BuildContext context,
    TwelaProvider provider,
    List<TwelaTransaction> expenses,
    bool isDark,
    ThemeData theme,
  ) {
    final categorySpending = <String, double>{};
    for (final expense in expenses) {
      categorySpending[expense.categoryId] =
          (categorySpending[expense.categoryId] ?? 0) + expense.amount;
    }

    final totalSpent = categorySpending.values.fold(0.0, (sum, v) => sum + v);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التوزيع حسب التصنيف',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: categorySpending.entries.map((entry) {
                  final category = provider.getCategoryById(entry.key);
                  final percentage =
                      totalSpent > 0 ? entry.value / totalSpent : 0.0;

                  return PieChartSectionData(
                    value: entry.value,
                    color: category?.color ??
                        (isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8)),
                    radius: 90,
                    title: '${(percentage * 100).toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 45,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: categorySpending.entries.map((entry) {
              final category = provider.getCategoryById(entry.key);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: category?.color ??
                          (isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8)),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category?.name ?? 'غير معروف',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategories(
    BuildContext context,
    TwelaProvider provider,
    List<TwelaTransaction> expenses,
    bool isDark,
    ThemeData theme,
  ) {
    final categorySpending = <String, double>{};
    for (final expense in expenses) {
      categorySpending[expense.categoryId] =
          (categorySpending[expense.categoryId] ?? 0) + expense.amount;
    }

    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أكبر المصروفات',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...sortedCategories.take(5).map((entry) {
            final category = provider.getCategoryById(entry.key);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (category?.color ??
                              (isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8)))
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      category?.icon ?? Icons.category_outlined,
                      color: category?.color ??
                          (isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8)),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category?.name ?? 'غير معروف',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    formatLyd(entry.value),
                    style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
