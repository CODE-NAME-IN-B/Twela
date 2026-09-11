import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/daftar_theme.dart';
import '../../providers/debt_provider.dart';
import '../../models/debt.dart';
import '../../widgets/twela_design_system.dart';
import '../../widgets/daftar_card.dart';
import '../../utils/formatters.dart';
import '../../utils/daftar_number_style.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DaftarTheme.darkSurface : DaftarTheme.lightSurface,
      appBar: AppBar(
        title: const Text('الديون'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.card,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: AppColors.debt),
                onPressed: () => Navigator.pushNamed(context, '/add-debt'),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<DebtProvider>(
          builder: (context, provider, _) {
            final activeDebts = provider.activeDebts;
            final paidDebts = provider.paidDebts;

            if (activeDebts.isEmpty && paidDebts.isEmpty) {
              return TwelaEmptyState(
                icon: Icons.handshake_outlined,
                title: 'لا توجد ديون',
                subtitle: 'أضف دين جديد للبدء في التتبع',
                actionLabel: 'إضافة دين',
                onAction: () => Navigator.pushNamed(context, '/add-debt'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activeDebts.isNotEmpty) ...[
                    TwelaSectionHeader(title: 'نشطة'),
                    ...activeDebts.map((debt) => _DebtTile(debt: debt)),
                  ],
                  if (paidDebts.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    TwelaSectionHeader(
                      title: 'تم السداد',
                      trailing: Text(
                        '${paidDebts.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                        ),
                      ),
                    ),
                    ...paidDebts.map((debt) => _DebtTile(debt: debt)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  final Debt debt;

  const _DebtTile({required this.debt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = debt.totalAmount > 0 ? debt.paidAmount / debt.totalAmount : 0.0;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/debt-detail', arguments: debt),
      child: DaftarCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: debt.isGiven
                        ? (isDark ? AppColors.debt.withOpacity(0.15) : AppColors.debtSurface)
                        : (isDark ? AppColors.income.withOpacity(0.15) : AppColors.incomeSurface),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    debt.isGiven ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    color: debt.isGiven ? AppColors.debt : AppColors.income,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              debt.personName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: debt.isGiven
                                  ? (isDark ? AppColors.debt.withOpacity(0.12) : AppColors.debtSurface)
                                  : (isDark ? AppColors.income.withOpacity(0.12) : AppColors.incomeSurface),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              debt.isGiven ? 'أنا أعطيت' : 'أنا استلمت',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: debt.isGiven ? AppColors.debt : AppColors.income,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        debt.itemDescription,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatLyd(debt.remaining),
                  style: daftarNumberStyle(
                    fontSize: 16,
                    color: debt.isPaidOff ? AppColors.success : AppColors.debt,
                  ),
                ),
                Row(
                  children: [
                    if (!debt.isPaidOff)
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.debt,
                        ),
                      ),
                    if (debt.isPaidOff)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.success.withOpacity(0.12) : AppColors.successSurface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'تم',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SegmentedProgress(
              progress: progress,
              isPaidOff: debt.isPaidOff,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedProgress extends StatelessWidget {
  final double progress;
  final bool isPaidOff;
  final bool isDark;

  const _SegmentedProgress({
    required this.progress,
    required this.isPaidOff,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const totalSegments = 20;
    final filledSegments = (progress * totalSegments).round().clamp(0, totalSegments);

    return Row(
      children: List.generate(totalSegments, (index) {
        final isFilled = index < filledSegments;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: isFilled
                    ? (isPaidOff ? AppColors.success : AppColors.debt)
                    : (isDark ? AppColors.darkBorder : AppColors.border),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}
