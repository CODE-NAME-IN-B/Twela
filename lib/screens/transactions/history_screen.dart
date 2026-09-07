import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/twela_provider.dart';
import '../../models/transaction.dart';
import '../../widgets/transaction_tile.dart';
import '../../utils/formatters.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('السجل'),
      ),
      body: Column(
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
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
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFECFDF5),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.receipt_long_outlined,
                              size: 36,
                              color: isDark
                                  ? const Color(0xFF64748B)
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
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/add-transaction'),
                              icon: const Icon(Icons.add),
                              label: const Text('إضافة عملية'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return TransactionTile(transaction: transaction);
                  },
                );
              },
            ),
          ),
        ],
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
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }
}
