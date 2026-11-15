import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../design/widgets.dart';

/// Daily-limit bar: ink fill until 80%, then the debt hue, then danger.
class LimitProgressBar extends StatelessWidget {
  const LimitProgressBar(
      {super.key, required this.current, required this.limit});

  final double current;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final sem = context.sem;

    if (limit <= 0) {
      return InbProgress(value: 0, color: c.fg, height: 6);
    }

    final ratio = (current / limit).clamp(0.0, 1.0);
    final tone = ratio >= 1.0 ? sem.danger : (ratio >= 0.8 ? sem.debt : c.fg);

    return InbProgress(value: ratio, color: tone, height: 6);
  }
}
