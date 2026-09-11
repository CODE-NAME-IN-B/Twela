import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../theme/daftar_theme.dart';
import '../../widgets/daftar_card.dart';
import '../../utils/daftar_number_style.dart';
import '../../providers/twela_provider.dart';
import '../../models/transaction.dart';
import '../../utils/formatters.dart';
import '../../widgets/twela_design_system.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DaftarTheme.darkSurface : DaftarTheme.lightSurface,
      appBar: AppBar(
        title: const Text('الإحصائيات'),
      ),
      body: SafeArea(
        child: Consumer<TwelaProvider>(
          builder: (context, provider, _) {
            final transactions = provider.transactions;
            final expenses = transactions
                .where((t) => t.type == TransactionType.expense)
                .toList();

            if (expenses.isEmpty) {
              return TwelaEmptyState(
                icon: Icons.bar_chart_outlined,
                title: 'لا توجد بيانات كافية',
                subtitle: 'ابدأ بتسجيل مصاريفك لرؤية الإحصائيات',
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
      ),
    );
  }

  Widget _buildMonthlySummary(
      BuildContext context, TwelaProvider provider, bool isDark, ThemeData theme) {
    return DaftarCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص شهر ${formatMonthYear(DateTime.now())}',
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
                  AppColors.info,
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
                  AppColors.expense,
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
            style: daftarNumberStyle(
              fontSize: 18,
              color: color,
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

    return DaftarCard(
      padding: const EdgeInsets.all(20),
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
                    color: category?.color ?? AppColors.expense,
                    radius: 90,
                    title: '${(percentage * 100).toStringAsFixed(0)}%',
                    titleStyle: daftarNumberStyle(
                      fontSize: 12,
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
                      color: category?.color ?? AppColors.expense,
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

    return DaftarCard(
      padding: const EdgeInsets.all(20),
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
            final catColor = category?.color ?? AppColors.expense;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: catColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      category?.icon ?? Icons.category_outlined,
                      color: catColor,
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
                    style: daftarNumberStyle(
                      fontSize: 14,
                      color: AppColors.expense,
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
