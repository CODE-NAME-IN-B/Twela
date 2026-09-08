import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/debt_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../models/debt.dart';
import '../../utils/formatters.dart';

class DebtDetailScreen extends StatefulWidget {
  final Debt debt;

  const DebtDetailScreen({super.key, required this.debt});

  @override
  State<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends State<DebtDetailScreen> {
  final _paymentController = TextEditingController();

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  void _addPayment() {
    final amount = double.tryParse(_paymentController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')),
      );
      return;
    }

    if (amount > widget.debt.remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('المبلغ أكبر من المتبقي')),
      );
      return;
    }

    context.read<DebtProvider>().addPayment(widget.debt.id, amount);

    if (context.read<AppSettingsProvider>().hapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    _paymentController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إضافة الدفعة')),
    );
  }

  void _confirmDelete(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('حذف الدين'),
        content: const Text('هل أنت متأكد من حذف هذا الدين؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<DebtProvider>().removeDebt(widget.debt.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.debt.personName),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFFE5484D).withOpacity(0.1)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                onPressed: () {
                  _confirmDelete(context);
                },
              ),
            ),
          ),
        ],
      ),
      body: Consumer<DebtProvider>(
        builder: (context, provider, _) {
          final debt = provider.getDebtById(widget.debt.id) ?? widget.debt;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDebtSummary(context, debt, isDark, theme),
                const SizedBox(height: 24),
                _buildPaymentSection(context, debt, isDark, theme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDebtSummary(
      BuildContext context, Debt debt, bool isDark, ThemeData theme) {
    final progress = debt.totalAmount > 0 ? debt.paidAmount / debt.totalAmount : 0.0;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt.personName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: debt.isGiven
                            ? (isDark
                                ? const Color(0xFFE5484D).withOpacity(0.1)
                                : const Color(0xFFFEF2F2))
                            : (isDark
                                ? const Color(0xFF149C6D).withOpacity(0.1)
                                : const Color(0xFFECFDF5)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        debt.isGiven ? 'أنا أديت له' : 'هو أديت لي',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: debt.isGiven ? AppColors.danger : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: debt.isPaidOff
                      ? (isDark
                          ? const Color(0xFF149C6D).withOpacity(0.1)
                          : const Color(0xFFECFDF5))
                      : (isDark
                          ? const Color(0xFFF5A524).withOpacity(0.1)
                          : const Color(0xFFFFFBEB)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  debt.isPaidOff ? 'تم السداد' : 'نشط',
                  style: TextStyle(
                    color: debt.isPaidOff ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            debt.itemDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildAmountCard(
                  context,
                  'الإجمالي',
                  debt.totalAmount,
                  theme.colorScheme.onSurface,
                  isDark,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAmountCard(
                  context,
                  'المدفوع',
                  debt.paidAmount,
                  AppColors.success,
                  isDark,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAmountCard(
                  context,
                  'المتبقي',
                  debt.remaining,
                  AppColors.danger,
                  isDark,
                  theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                debt.isPaidOff ? AppColors.success : AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% مكتمل',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                formatDate(debt.date),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(
    BuildContext context,
    String label,
    double amount,
    Color color,
    bool isDark,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            formatLydShort(amount),
            style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(
      BuildContext context, Debt debt, bool isDark, ThemeData theme) {
    if (debt.isPaidOff) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF149C6D).withOpacity(0.1)
              : const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.success.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.success),
            const SizedBox(width: 8),
            Text(
              'تم سداد الدين بالكامل',
              style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    }

    return Container(
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
          Text(
            'إضافة دفعة',
            style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _paymentController,
                  keyboardType: TextInputType.number,
                  style: theme.textTheme.bodyMedium,
                  decoration: const InputDecoration(
                    hintText: 'المبلغ',
                    suffixText: 'د.ل',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _addPayment,
                child: const Text('إضافة'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
