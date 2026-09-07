import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/debt.dart';
import '../utils/formatters.dart';

class DebtTile extends StatelessWidget {
  final Debt debt;

  const DebtTile({super.key, required this.debt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress =
        debt.totalAmount > 0 ? debt.paidAmount / debt.totalAmount : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: debt.isPaidOff
                            ? (isDark
                                ? const Color(0xFF149C6D).withOpacity(0.1)
                                : const Color(0xFFECFDF5))
                            : (isDark
                                ? const Color(0xFFF5A524).withOpacity(0.1)
                                : const Color(0xFFFFFBEB)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        debt.isPaidOff
                            ? Icons.check_circle_outline
                            : Icons.person_outline,
                        color: debt.isPaidOff
                            ? AppColors.success
                            : AppColors.warning,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            debt.personName,
                            style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            debt.itemDescription,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: debt.isPaidOff
                      ? (isDark
                          ? const Color(0xFF149C6D).withOpacity(0.1)
                          : const Color(0xFFECFDF5))
                      : (isDark
                          ? const Color(0xFFF5A524).withOpacity(0.1)
                          : const Color(0xFFFFFBEB)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  debt.isPaidOff ? 'تم' : 'متبقي',
                  style: TextStyle(
                    fontSize: 11,
                    color: debt.isPaidOff
                        ? AppColors.success
                        : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
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
                style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: debt.isPaidOff
                          ? AppColors.success
                          : theme.colorScheme.onSurface,
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
              backgroundColor:
                  isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                debt.isPaidOff ? AppColors.success : AppColors.primary,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
