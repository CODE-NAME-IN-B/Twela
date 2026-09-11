import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/daftar_theme.dart';
import '../../providers/debt_provider.dart';
import '../../widgets/debt_tile.dart';

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
                color: isDark
                    ? const Color(0xFF2A2520)
                    : const Color(0xFFF5F0E8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: AppColors.primary),
                onPressed: () => Navigator.pushNamed(context, '/add-debt'),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<DebtProvider>(
        builder: (context, provider, _) {
          final activeDebts = provider.activeDebts;
          final paidDebts = provider.paidDebts;

          if (activeDebts.isEmpty && paidDebts.isEmpty) {
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
                            ? const Color(0xFF2A2520)
                            : const Color(0xFFF5F0E8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF3D3830)
                              : const Color(0xFFE8E0D4),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.people_outline,
                        size: 36,
                        color: isDark
                            ? const Color(0xFF9C8E7E)
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'لا توجد ديون',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أضف دين جديد للبدء في التتبع',
                      style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? const Color(0xFF9C8E7E)
                                : const Color(0xFF8A7E72),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/add-debt'),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('إضافة دين'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activeDebts.isNotEmpty) ...[
                  Text(
                    'نشطة',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  ...activeDebts.map((debt) => DebtTile(debt: debt)),
                ],
                if (paidDebts.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Text(
                    'تم السداد',
                    style: theme.textTheme.headlineSmall?.copyWith(
                          color: isDark
                              ? const Color(0xFF9C8E7E)
                              : const Color(0xFF8A7E72),
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...paidDebts.map((debt) => DebtTile(debt: debt)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
