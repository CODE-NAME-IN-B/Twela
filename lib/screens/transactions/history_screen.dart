import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design/screen.dart';
import '../../design/tokens.dart';
import '../../theme/app_colors.dart';
import '../../theme/daftar_theme.dart';
import '../../providers/twela_provider.dart';
import '../../models/transaction.dart';
import '../../widgets/twela_design_system.dart';
import '../../utils/formatters.dart';
import '../transactions/add_transaction_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design/format.dart';
import '../../design/motion.dart';

enum TransactionFilter { all, income, expense, debt, savings }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    this.embedded = false,
    this.bottomBarHeight = 0,
  });

  final bool embedded;
  final double bottomBarHeight;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TransactionFilter _filter = TransactionFilter.all;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TwelaTransaction> _filterTransactions(
      List<TwelaTransaction> transactions) {
    var filtered = transactions;

    switch (_filter) {
      case TransactionFilter.all:
        break;
      case TransactionFilter.income:
        filtered =
            filtered.where((t) => t.type == TransactionType.income).toList();
        break;
      case TransactionFilter.expense:
        filtered =
            filtered.where((t) => t.type == TransactionType.expense).toList();
        break;
      case TransactionFilter.debt:
        filtered = filtered
            .where((t) =>
                t.type == TransactionType.debtGiven ||
                t.type == TransactionType.debtReceived ||
                t.type == TransactionType.debtPayment)
            .toList();
        break;
      case TransactionFilter.savings:
        filtered = filtered
            .where((t) =>
                t.type == TransactionType.savings ||
                t.type == TransactionType.savingsWithdrawal)
            .toList();
        break;
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        final provider = context.read<TwelaProvider>();
        final category = provider.getCategoryById(t.categoryId);
        return t.note.toLowerCase().contains(query) ||
            (category?.name.toLowerCase().contains(query) ?? false) ||
            formatLydShort(t.amount).contains(query);
      }).toList();
    }

    return filtered;
  }

  bool _isOutflow(TwelaTransaction t) =>
      t.isExpense || t.type == TransactionType.savings;

  bool _isInflow(TwelaTransaction t) =>
      t.isIncome || t.type == TransactionType.savingsWithdrawal;

  Color _amountColor(TwelaTransaction t) {
    if (_isOutflow(t)) return AppColors.expense;
    if (_isInflow(t)) return AppColors.income;
    return AppColors.textSecondary;
  }

  String _typeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return AppLocalizations.of(context)!.income;
      case TransactionType.expense:
        return AppLocalizations.of(context)!.expenseShort;
      case TransactionType.debtGiven:
        return AppLocalizations.of(context)!.debtGiven;
      case TransactionType.debtReceived:
        return AppLocalizations.of(context)!.debtReceived;
      case TransactionType.debtPayment:
        return AppLocalizations.of(context)!.debtRepayment;
      case TransactionType.savings:
        return AppLocalizations.of(context)!.savings;
      case TransactionType.savingsWithdrawal:
        return AppLocalizations.of(context)!.withdrawFromSavings;
    }
  }

  void _showEditMenu(TwelaTransaction transaction) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // AddTransactionScreen handles income and expense only.
    final editable = transaction.isExpense || transaction.isIncome;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              if (editable)
                ListTile(
                  leading: Icon(
                    Icons.edit_outlined,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.edit,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _editTransaction(transaction);
                  },
                ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: AppColors.danger),
                title: Text(
                  AppLocalizations.of(context)!.delete,
                  style: TextStyle(color: AppColors.danger),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(transaction);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _editTransaction(TwelaTransaction transaction) {
    // Real editing: the screen prefills the fields and updates in place.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(existingTransaction: transaction),
      ),
    );
  }

  void _confirmDelete(TwelaTransaction transaction) {
    showDialog(
      context: context,
      builder: (ctx) => TwelaConfirmDialog(
        title: AppLocalizations.of(context)!.deleteTransaction,
        message: AppLocalizations.of(context)!.deleteTransactionBody,
        confirmLabel: AppLocalizations.of(context)!.delete,
        cancelLabel: AppLocalizations.of(context)!.cancel,
        onConfirm: () async {
          await context.read<TwelaProvider>().removeTransaction(transaction.id);
          if (mounted) setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final c = context.inb;

    final content = Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
              start: 20, top: 8, end: 20, bottom: 0),
          child: TextField(
            controller: _searchController,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchHint,
              prefixIcon: const Icon(Icons.search_outlined, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: c.surface,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildFilterChip(
                  TransactionFilter.all, AppLocalizations.of(context)!.all),
              const SizedBox(width: 8),
              _buildFilterChip(TransactionFilter.income,
                  AppLocalizations.of(context)!.income),
              const SizedBox(width: 8),
              _buildFilterChip(TransactionFilter.expense,
                  AppLocalizations.of(context)!.expenseShort),
              const SizedBox(width: 8),
              _buildFilterChip(TransactionFilter.debt,
                  AppLocalizations.of(context)!.debtsShort),
              const SizedBox(width: 8),
              _buildFilterChip(TransactionFilter.savings,
                  AppLocalizations.of(context)!.savings),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Consumer<TwelaProvider>(
            builder: (context, provider, _) {
              final transactions = _filterTransactions(provider.transactions);

              if (transactions.isEmpty) {
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
                            color: c.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: c.line,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.receipt_long_outlined,
                            size: 36,
                            color: c.muted,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _searchQuery.isNotEmpty
                              ? AppLocalizations.of(context)!.noSearchResults
                              : AppLocalizations.of(context)!.noEntriesYet,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? AppLocalizations.of(context)!.tryOtherKeywords
                              : AppLocalizations.of(context)!
                                  .recordFirstTransaction,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: c.muted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                                context, '/add-transaction'),
                            icon: const Icon(Icons.add),
                            label: Text(
                                AppLocalizations.of(context)!.addTransaction),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsetsDirectional.only(
                    start: 20, top: 8, end: 20, bottom: 100),
                itemCount: transactions.length,
                separatorBuilder: (_, __) => Container(
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.borderLight,
                ),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final category =
                      provider.getCategoryById(transaction.categoryId);
                  final color = _amountColor(transaction);
                  final prefix = _isOutflow(transaction)
                      ? '-'
                      : (_isInflow(transaction) ? '+' : '');
                  final value =
                      prefix == '-' ? -transaction.amount : transaction.amount;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction.note.isNotEmpty
                                    ? transaction.note
                                    : (category?.name ??
                                        _typeLabel(transaction.type)),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatDate(transaction.date),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextTertiary
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Money(
                          value,
                          signed: prefix.isNotEmpty,
                          size: 15,
                          weight: FontWeight.w600,
                          color: color,
                          decimals: 2,
                        ),
                        const SizedBox(width: 4),
                        PressScale(
                          onTap: () => _showEditMenu(transaction),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.more_vert,
                              size: 20,
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return InbScreen(embedded: true, child: Reveal(child: content));
    }

    return Scaffold(
      backgroundColor:
          isDark ? DaftarTheme.darkSurface : DaftarTheme.lightSurface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.history),
      ),
      body: SafeArea(child: content),
    );
  }

  Widget _buildFilterChip(TransactionFilter filter, String label) {
    final isSelected = _filter == filter;
    final theme = Theme.of(context);
    final c = context.inb;

    return PressScale(
      onTap: () => setState(() => _filter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : (c.surface),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(
                  color: c.line,
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? c.onIsland : (c.muted),
          ),
        ),
      ),
    );
  }
}
