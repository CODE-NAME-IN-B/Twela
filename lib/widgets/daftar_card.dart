import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../design/widgets.dart';

/// Legacy `DaftarCard` → INB [BentoCard]. The diagonal cut is dropped:
/// the bento tile is the only card surface in v2.
class DaftarCard extends StatelessWidget {
  const DaftarCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(S.md),
    this.showDiagonalCut = false,
    this.backgroundColor,
    this.showShadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool showDiagonalCut;

  /// When set, the tile uses this tone instead of the default surface —
  /// for semantic banners (success / danger) that must keep their hue.
  final Color? backgroundColor;

  /// Compatibility no-op: the bento tile has no shadow.
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    if (backgroundColor == null) {
      return BentoCard(padding: padding, child: child);
    }
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(R.card),
        border: Border.all(color: context.inb.line),
      ),
      child: child,
    );
  }
}
