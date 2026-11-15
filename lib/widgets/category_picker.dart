import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../design/motion.dart';
import '../design/tokens.dart';
import '../providers/twela_provider.dart';

/// Legacy category picker → INB selectable icon chips.
class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
    required this.selectedId,
    required this.onSelect,
  });

  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final categories = context.watch<TwelaProvider>().categories;

    return Wrap(
      spacing: S.sm,
      runSpacing: S.sm,
      children: [
        for (final category in categories)
          PressScale(
            onTap: () => onSelect(category.id),
            child: AnimatedContainer(
              duration: Motion.fast,
              curve: Motion.emphasized,
              padding:
                  const EdgeInsets.symmetric(horizontal: S.md, vertical: S.sm),
              decoration: BoxDecoration(
                color: selectedId == category.id ? c.island : c.surface,
                borderRadius: BorderRadius.circular(R.pill),
                border: Border.all(
                  color:
                      selectedId == category.id ? Colors.transparent : c.line,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category.icon,
                    size: 16,
                    color: selectedId == category.id ? c.onIsland : c.muted,
                  ),
                  const SizedBox(width: S.xs),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontFamily: InbFonts.arabic,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selectedId == category.id ? c.onIsland : c.fg,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
