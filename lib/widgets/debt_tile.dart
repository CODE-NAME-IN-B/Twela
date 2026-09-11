import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/daftar_theme.dart';
import '../providers/debt_provider.dart';
import '../models/debt.dart';
import '../utils/formatters.dart';
import '../utils/daftar_number_style.dart';
import 'daftar_card.dart';

class DebtTile extends StatelessWidget {
  final Debt debt;

  const DebtTile({super.key, required this.debt});

  void _showPayBottomSheet(BuildContext context) {
    final controller = TextEditingController();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? DaftarTheme.darkSurface : DaftarTheme.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3D3830)
                        : const Color(0xFFD4C5B0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'سداد دين - ${debt.personName}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'المتبقي: ${formatLyd(debt.remaining)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? const Color(0xFF9C8E7E)
                      : const Color(0xFF8A7E72),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  suffixText: 'د.ل',
                  suffixStyle: theme.textTheme.titleMedium?.copyWith(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(controller.text);
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('يرجى إدخال مبلغ صحيح')),
                      );
                      return;
                    }
                    if (amount > debt.remaining) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('المبلغ أكبر من المتبقي')),
                      );
                      return;
                    }
                    context.read<DebtProvider>().addPayment(debt.id, amount);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إضافة الدفعة')),
                    );
                  },
                  child: const Text('إضافة الدفعة'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress =
        debt.totalAmount > 0 ? debt.paidAmount / debt.totalAmount : 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/debt-detail', arguments: debt);
      },
      child: DaftarCard(
        padding: const EdgeInsets.all(16),
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
                                  ? const Color(0xFF0A846B).withOpacity(0.1)
                                  : const Color(0xFFF0FAF5))
                              : (isDark
                                  ? const Color(0xFFD4A574).withOpacity(0.1)
                                  : const Color(0xFFFDF8F0)),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: debt.isGiven
                                        ? (isDark
                                            ? const Color(0xFFC4483A).withOpacity(0.1)
                                            : const Color(0xFFFDF2F0))
                                        : (isDark
                                            ? const Color(0xFF0A846B).withOpacity(0.1)
                                            : const Color(0xFFF0FAF5)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    debt.isGiven ? 'أديت له' : 'أديت لي',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: debt.isGiven ? AppColors.danger : AppColors.success,
                                    ),
                                  ),
                                ),
                              ],
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
                if (!debt.isPaidOff)
                  GestureDetector(
                    onTap: () => _showPayBottomSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2A2520)
                            : const Color(0xFFF5F0E8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.payment_outlined,
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'سداد',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0A846B).withOpacity(0.1)
                          : const Color(0xFFF0FAF5),
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
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatLyd(debt.remaining),
                  style: daftarNumberStyle(
                        fontSize: 16,
                        color: debt.isPaidOff
                            ? AppColors.success
                            : null,
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
                    ? (isPaidOff ? AppColors.success : DaftarTheme.accent)
                    : (isDark
                        ? const Color(0xFF3D3830)
                        : const Color(0xFFE8E0D4)),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}
