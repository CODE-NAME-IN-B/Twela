import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design/screen.dart';
import '../../design/pie.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../theme/app_colors.dart';
import '../../theme/daftar_theme.dart';
import '../../widgets/daftar_card.dart';
import '../../utils/daftar_number_style.dart';
import '../../providers/twela_provider.dart';
import '../../models/transaction.dart';
import '../../widgets/twela_design_system.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design/format.dart' show Money, formatPercent;
import '../../design/motion.dart';
import 'package:intl/intl.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({
    super.key,
    this.embedded = false,
    this.bottomBarHeight = 0,
  });

  final bool embedded;
  final double bottomBarHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final content = Consumer<TwelaProvider>(
      builder: (context, provider, _) {
        final transactions = provider.transactions;
        final expenses = transactions
            .where((t) => t.type == TransactionType.expense)
            .toList();

        if (expenses.isEmpty) {
          return TwelaEmptyState(
            icon: Icons.bar_chart_outlined,
            title: AppLocalizations.of(context)!.emptyStats,
            subtitle: AppLocalizations.of(context)!.startTrackingExpenses,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsetsDirectional.only(
              start: 20, top: 16, end: 20, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthlySummary(context, provider, isDark, theme),
              const SizedBox(height: 20),
              _buildCategoryChart(context, provider, expenses, isDark, theme),
              const SizedBox(height: 20),
              _buildTopCategories(context, provider, expenses, isDark, theme),
            ],
          ),
        );
      },
    );

    if (embedded) {
      return InbScreen(embedded: true, child: Reveal(child: content));
    }

    return Scaffold(
      backgroundColor:
          isDark ? DaftarTheme.darkSurface : DaftarTheme.lightSurface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.stats),
      ),
      body: SafeArea(child: content),
    );
  }

  Widget _buildMonthlySummary(BuildContext context, TwelaProvider provider,
      bool isDark, ThemeData theme) {
    return DaftarCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Latin brand display for the month word, English month name.
          SizedBox(
            width: double.infinity,
            child: Text(
              DateFormat('MMMM yyyy', 'en').format(DateTime.now()),
              textAlign: TextAlign.center,
              style: displayStyle(context, size: 22),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  AppLocalizations.of(context)!.total,
                  Money(
                    provider.totalBalance,
                    size: 18,
                    weight: FontWeight.w700,
                    color: AppColors.info,
                  ),
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
                  AppLocalizations.of(context)!.spent,
                  Money(
                    provider.monthSpent,
                    size: 18,
                    weight: FontWeight.w700,
                    color: AppColors.expense,
                  ),
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
    Widget value,
    Color color,
    IconData icon,
    bool isDark,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
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
          value,
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

    // Largest slice first so the ring reads stable.
    final sorted = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return DaftarCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.distributionByCategory,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          // Labels live inside each slice and are measured against that
          // slice's own width, so Arabic names can never run into a
          // neighbour (see lib/design/pie.dart).
          InbPie(
            height: 224,
            slices: sorted.map((entry) {
              final category = provider.getCategoryById(entry.key);
              return InbPieSlice(
                name: category?.name ?? AppLocalizations.of(context)!.unknown,
                value: entry.value,
                color: category?.color ?? AppColors.expense,
              );
            }).toList(),
          ),
          const SizedBox(height: S.md),
          // Two aligned columns: dot + name at the column's start, the
          // percentage pinned to its end. A `Wrap` of fixed-width items
          // scattered the percentages into a fourth column.
          Builder(builder: (context) {
            final mid = (sorted.length + 1) ~/ 2;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      for (final entry in sorted.take(mid))
                        _legendRow(context, provider, entry, totalSpent, theme),
                    ],
                  ),
                ),
                const SizedBox(width: S.md),
                Expanded(
                  child: Column(
                    children: [
                      for (final entry in sorted.skip(mid))
                        _legendRow(context, provider, entry, totalSpent, theme),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _legendRow(BuildContext context, TwelaProvider provider,
      MapEntry<String, double> entry, double totalSpent, ThemeData theme) {
    final category = provider.getCategoryById(entry.key);
    final percentage = totalSpent > 0 ? entry.value / totalSpent : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: S.sm),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: category?.color ?? AppColors.expense,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: S.xs + 2),
          Expanded(
            child: Text(
              category?.name ?? AppLocalizations.of(context)!.unknown,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: S.xs),
          Text(
            formatPercent(percentage),
            style: daftarNumberStyle(
              context,
              fontSize: 12,
              color: theme.colorScheme.onSurface,
            ),
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
            AppLocalizations.of(context)!.biggestExpenses,
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
                      color: catColor.withValues(alpha: 0.1),
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
                      category?.name ?? AppLocalizations.of(context)!.unknown,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  Money(
                    entry.value,
                    size: 14,
                    weight: FontWeight.w600,
                    color: AppColors.expense,
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
