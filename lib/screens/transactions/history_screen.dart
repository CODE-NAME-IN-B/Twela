import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/daftar_theme.dart';
import '../../providers/twela_provider.dart';
import '../../models/transaction.dart';
import '../../widgets/twela_design_system.dart';
import '../../utils/formatters.dart';
import '../../utils/daftar_number_style.dart';
import '../transactions/add_transaction_screen.dart';

enum TransactionFilter { all, income, expense, debt, savings }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

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

  List<TwelaTransaction> _filterTransactions(List<TwelaTransaction> transactions) {
    var filtered = transactions;

    switch (_filter) {
      case TransactionFilter.all:
        break;
      case TransactionFilter.income:
        filtered = filtered.where((t) => t.type == TransactionType.income).toList();
        break;
      case TransactionFilter.expense:
        filtered = filtered.where((t) => t.type == TransactionType.expense).toList();
        break;
      case TransactionFilter.debt:
        filtered = filtered.where((t) =>
            t.type == TransactionType.debtGiven ||
            t.type == TransactionType.debtReceived ||
            t.type == TransactionType.debtPayment).toList();
        break;
      case TransactionFilter.savings:
        filtered = filtered.where((t) => t.type == TransactionType.savings).toList();
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

  Color _amountColor(TwelaTransaction t) {
    if (t.isExpense) return AppColors.expense;
    if (t.isIncome) return AppColors.income;
    return AppColors.textSecondary;
  }

  String _typeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'دخل';
      case TransactionType.expense:
        return 'مصروف';
      case TransactionType.debtGiven:
        return 'دين (授予)';
      case TransactionType.debtReceived:
        return 'دين (استلام)';
      case TransactionType.debtPayment:
        return 'دين (سداد)';
      case TransactionType.savings:
        return 'ادخار';
    }
  }

  void _showEditMenu(TwelaTransaction transaction) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
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
              ListTile(
                leading: Icon(
                  Icons.edit_outlined,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                title: Text(
                  'تعديل',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _editTransaction(transaction);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.danger),
                title: Text(
                  'حذف',
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
    // AddTransactionScreen does not support existingTransaction.
    // Delete the old one and navigate to add screen with type pre-selected.
    // The user will re-enter amount/note for the new transaction.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(initialType: transaction.type),
      ),
    );
  }

  void _confirmDelete(TwelaTransaction transaction) {
    showDialog(
      context: context,
      builder: (ctx) => TwelaConfirmDialog(
        title: 'حذف المعاملة',
        message: 'هل أنت متأكد من حذف هذه المعاملة؟ لا يمكن التراجع عن هذا الإجراء.',
        confirmLabel: 'حذف',
        cancelLabel: 'إلغاء',
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

    return Scaffold(
      backgroundColor: isDark ? DaftarTheme.darkSurface : DaftarTheme.lightSurface,
      appBar: AppBar(
        title: const Text('السجل'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: TextField(
                controller: _searchController,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'بحث...',
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
                  fillColor: isDark
                      ? const Color(0xFF2A2622)
                      : const Color(0xFFF0EDE6),
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
                  _buildFilterChip(TransactionFilter.all, 'الكل'),
                  const SizedBox(width: 8),
                  _buildFilterChip(TransactionFilter.income, 'دخل'),
                  const SizedBox(width: 8),
                  _buildFilterChip(TransactionFilter.expense, 'مصروف'),
                  const SizedBox(width: 8),
                  _buildFilterChip(TransactionFilter.debt, 'ديون'),
                  const SizedBox(width: 8),
                  _buildFilterChip(TransactionFilter.savings, 'ادخار'),
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
                                color: isDark
                                    ? const Color(0xFF2A2622)
                                    : const Color(0xFFF0EDE6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF3A3530)
                                      : const Color(0xFFE8E4DB),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.receipt_long_outlined,
                                size: 36,
                                color: isDark
                                    ? const Color(0xFF9A9186)
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'لا توجد نتائج للبحث'
                                  : 'لا توجد حركات بعد',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'جرّب البحث بكلمات أخرى'
                                  : 'ابدأ بتسجيل أول صرف أو دخل',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? const Color(0xFF9A9186)
                                    : const Color(0xFF8A8178),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pushNamed(
                                    context, '/add-transaction'),
                                icon: const Icon(Icons.add),
                                label: const Text('إضافة عملية'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
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
                      final prefix =
                          transaction.isExpense ? '-' : (transaction.isIncome ? '+' : '');

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
                                        : (category?.name ?? _typeLabel(transaction.type)),
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
                            Text(
                              '$prefix${formatLydShort(transaction.amount)} د.ل',
                              style: daftarNumberStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
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
        ),
      ),
    );
  }

  Widget _buildFilterChip(TransactionFilter filter, String label) {
    final isSelected = _filter == filter;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _filter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : (isDark ? const Color(0xFF2A2622) : const Color(0xFFF0EDE6)),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(
                  color:
                      isDark ? const Color(0xFF3A3530) : const Color(0xFFE8E4DB),
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF9A9186) : const Color(0xFF8A8178)),
          ),
        ),
      ),
    );
  }
}
