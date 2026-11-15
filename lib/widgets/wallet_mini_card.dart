import 'package:flutter/material.dart';

import '../design/format.dart';
import '../design/tokens.dart';

/// Wallet balance tile (cash / bank).
class WalletMiniCard extends StatelessWidget {
  const WalletMiniCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;

    return Container(
      padding: const EdgeInsets.all(S.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(R.inner),
        border: Border.all(color: c.line),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(R.inner),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: S.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: InbFonts.arabic,
                    fontSize: 12,
                    color: c.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Money(amount, size: 13, color: c.fg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
