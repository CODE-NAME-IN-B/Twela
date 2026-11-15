import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../design/widgets.dart';
import '../models/transaction.dart';

/// Legacy cash/bank toggle → INB chips.
class WalletToggle extends StatelessWidget {
  const WalletToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final WalletType selected;
  final ValueChanged<WalletType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final entry in const <(WalletType, String)>[
          (WalletType.cash, 'كاش'),
          (WalletType.bank, 'مصرف'),
        ]) ...[
          if (entry.$1 != WalletType.cash) const SizedBox(width: S.sm),
          Expanded(
            child: InbChip(
              label: entry.$2,
              selected: selected == entry.$1,
              onTap: () => onChanged(entry.$1),
            ),
          ),
        ],
      ],
    );
  }
}
