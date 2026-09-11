import 'package:flutter/material.dart';
import '../utils/formatters.dart';
import '../utils/daftar_number_style.dart';
import '../widgets/daftar_card.dart';

class WalletMiniCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const WalletMiniCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return DaftarCard(
      showDiagonalCut: false,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatLydShort(amount),
            style: daftarNumberStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'د.ل',
            style: theme.textTheme.labelSmall?.copyWith(
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
