import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/daftar_theme.dart';
import '../providers/twela_provider.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';
import '../utils/daftar_number_style.dart';

class TransactionTile extends StatelessWidget {
  final TwelaTransaction transaction;

  const TransactionTile({super.key, required this.transaction});

  void _showOptionsSheet(BuildContext context) {
    final provider = context.read<TwelaProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? DaftarTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF4A443C) : const Color(0xFFD4CFC6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'خيارات المعاملة',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildOptionTile(
              context,
              theme: theme,
              isDark: isDark,
              icon: Icons.edit_outlined,
              label: 'تعديل الملاحظة',
              onTap: () {
                Navigator.pop(ctx);
                _showEditDialog(context);
              },
            ),
            const SizedBox(height: 4),
            _buildOptionTile(
              context,
              theme: theme,
              isDark: isDark,
              icon: Icons.delete_outline,
              label: 'حذف المعاملة',
              color: DaftarTheme.danger,
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, provider);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final itemColor = color ?? (isDark ? const Color(0xFF9A9186) : const Color(0xFF8A8178));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252220) : const Color(0xFFF5F2EB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: itemColor, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: itemColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, TwelaProvider provider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? DaftarTheme.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('حذف المعاملة'),
        content: const Text('هل أنت متأكد من حذف هذه المعاملة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              provider.removeTransaction(transaction.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف المعاملة')),
              );
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: DaftarTheme.danger),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final provider = context.read<TwelaProvider>();
    final noteController = TextEditingController(text: transaction.note);
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
              color: isDark ? DaftarTheme.darkSurface : Colors.white,
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
                  color: isDark ? const Color(0xFF4A443C) : const Color(0xFFD4CFC6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'تعديل المعاملة',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: noteController,
                style: theme.textTheme.bodyMedium,
                decoration: const InputDecoration(
                  labelText: 'ملاحظة',
                  hintText: 'أضف ملاحظة...',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final updated = transaction.copyWith(
                          note: noteController.text,
                        );
                        provider.updateTransaction(updated);
                        Navigator.pop(ctx);
                      },
                      child: const Text('حفظ'),
                    ),
                  ),
                ],
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
    final provider = context.read<TwelaProvider>();
    final category = provider.getCategoryById(transaction.categoryId);
    final isExpense = transaction.type == TransactionType.expense;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: isDark ? DaftarTheme.darkSurface : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('حذف المعاملة'),
            content: const Text('هل أنت متأكد من حذف هذه المعاملة؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'حذف',
                  style: TextStyle(color: DaftarTheme.danger),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        provider.removeTransaction(transaction.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف المعاملة')),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.only(left: 20),
        decoration: const BoxDecoration(
          color: DaftarTheme.danger,
        ),
        child: Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: GestureDetector(
        onLongPress: () => _showEditDialog(context),
        child: Container(
          margin: const EdgeInsets.only(bottom: 1),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF252220) : const Color(0xFFF5F2EB),
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF3A3530) : const Color(0xFFE8E4DB),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                category?.icon ?? Icons.receipt_outlined,
                color: category?.color ??
                    (isDark
                        ? const Color(0xFF9A9186)
                        : const Color(0xFF8A8178)),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category?.name ?? 'حركة',
                      style: theme.textTheme.titleSmall,
                    ),
                    if (transaction.note.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        transaction.note,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isExpense ? '-' : '+'}${formatLydShort(transaction.amount)}',
                    style: daftarNumberStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isExpense ? DaftarTheme.danger : AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDate(transaction.date),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _showOptionsSheet(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3A3530)
                        : const Color(0xFFE8E4DB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.more_vert,
                    size: 16,
                    color: isDark ? const Color(0xFF9A9186) : const Color(0xFF8A8178),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
