import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/daftar_theme.dart';
import '../../providers/debt_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../models/debt.dart';
import '../../models/transaction.dart';
import '../../utils/formatters.dart';
import '../../utils/daftar_number_style.dart';
import '../../widgets/twela_design_system.dart';
import '../../widgets/daftar_card.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design/format.dart';

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
        SnackBar(content: Text(AppLocalizations.of(context)!.enterValidAmount)),
      );
      return;
    }

    if (amount > widget.debt.remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context)!.amountExceedsRemaining)),
      );
      return;
    }

    context.read<DebtProvider>().addPayment(widget.debt.id, amount);

    if (context.read<AppSettingsProvider>().hapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    _paymentController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.paymentAdded)),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => TwelaConfirmDialog(
        title: AppLocalizations.of(context)!.deleteDebt,
        message: AppLocalizations.of(context)!.deleteDebtBody,
        confirmLabel: AppLocalizations.of(context)!.delete,
        onConfirm: () {
          context.read<DebtProvider>().removeDebt(widget.debt.id);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? DaftarTheme.darkSurface : DaftarTheme.lightSurface,
      appBar: AppBar(
        title: Text(widget.debt.personName),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.danger.withOpacity(0.12)
                    : AppColors.dangerSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Icon(Icons.delete_outline, color: AppColors.danger),
                onPressed: () => _confirmDelete(context),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<DebtProvider>(
          builder: (context, provider, _) {
            final debt = provider.getDebtById(widget.debt.id) ?? widget.debt;

            return SingleChildScrollView(
              padding: const EdgeInsetsDirectional.only(
                  start: 20, top: 0, end: 20, bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDebtSummary(context, debt, isDark, theme),
                  const SizedBox(height: 24),
                  _buildPaymentSection(context, debt, isDark, theme),
                  if (debt.paidAmount > 0) ...[
                    const SizedBox(height: 24),
                    _buildPaymentHistory(
                        context, debt, provider, isDark, theme),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDebtSummary(
      BuildContext context, Debt debt, bool isDark, ThemeData theme) {
    final progress =
        debt.totalAmount > 0 ? debt.paidAmount / debt.totalAmount : 0.0;
    final totalDots = 10;
    final filledDots = (progress * totalDots).round().clamp(0, totalDots);

    return DaftarCard(
      padding: const EdgeInsets.all(20),
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
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: debt.isGiven
                            ? (isDark
                                ? AppColors.debt.withOpacity(0.12)
                                : AppColors.debtSurface)
                            : (isDark
                                ? AppColors.income.withOpacity(0.12)
                                : AppColors.incomeSurface),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        debt.isGiven
                            ? AppLocalizations.of(context)!.iGave
                            : AppLocalizations.of(context)!.iReceived,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              debt.isGiven ? AppColors.debt : AppColors.income,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: debt.isPaidOff
                      ? (isDark
                          ? AppColors.success.withOpacity(0.12)
                          : AppColors.successSurface)
                      : (isDark
                          ? AppColors.debt.withOpacity(0.12)
                          : AppColors.debtSurface),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  debt.isPaidOff
                      ? AppLocalizations.of(context)!.paid
                      : AppLocalizations.of(context)!.activeShort,
                  style: TextStyle(
                    color: debt.isPaidOff ? AppColors.success : AppColors.debt,
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
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildAmountCard(
                  context,
                  AppLocalizations.of(context)!.total,
                  debt.totalAmount,
                  AppColors.debt,
                  isDark,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAmountCard(
                  context,
                  AppLocalizations.of(context)!.paidAmount,
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
                  AppLocalizations.of(context)!.remaining,
                  debt.remaining,
                  debt.isPaidOff ? AppColors.success : AppColors.debt,
                  isDark,
                  theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TwelaProgressDots(
            total: totalDots,
            filled: filledDots,
            filledColor: debt.isPaidOff ? AppColors.success : AppColors.debt,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!
                    .percentComplete((progress * 100).toStringAsFixed(0)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              Text(
                formatDate(debt.date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary,
                ),
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
        color: isDark ? color.withOpacity(0.08) : color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Money(
            amount,
            size: 14,
            weight: FontWeight.w700,
            color: color,
            showCurrency: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(
      BuildContext context, Debt debt, bool isDark, ThemeData theme) {
    if (debt.isPaidOff) {
      return DaftarCard(
        padding: const EdgeInsets.all(24),
        backgroundColor: isDark
            ? AppColors.success.withOpacity(0.08)
            : AppColors.successSurface,
        showShadow: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                color: AppColors.success, size: 28),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context)!.debtFullyPaid,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return DaftarCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.debt.withOpacity(0.12)
                      : AppColors.debtSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.payment_outlined,
                    color: AppColors.debt, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.recordPayment,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _paymentController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: daftarNumberStyle(
              context,
              fontSize: 28,
              color: AppColors.debt,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: daftarNumberStyle(
                context,
                fontSize: 28,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.textTertiary,
              ),
              suffixText: AppLocalizations.of(context)!.currencyLyd,
              suffixStyle: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          TwelaPrimaryButton(
            label: AppLocalizations.of(context)!.recordPayment,
            icon: Icons.check_circle_outline,
            color: AppColors.debt,
            onPressed: _addPayment,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory(BuildContext context, Debt debt,
      DebtProvider provider, bool isDark, ThemeData theme) {
    final payments = provider.ledger.transactions
        .where((t) =>
            t.relatedId == debt.id && t.type == TransactionType.debtPayment)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (payments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TwelaSectionHeader(title: AppLocalizations.of(context)!.paymentHistory),
        const SizedBox(height: 8),
        ...payments.map((tx) => DaftarCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              showShadow: false,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.success.withOpacity(0.12)
                          : AppColors.successSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Icon(Icons.check, color: AppColors.success, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.payment,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          formatDateTime(tx.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Money(
                    tx.amount,
                    size: 14,
                    weight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
