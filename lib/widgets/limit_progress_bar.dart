import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LimitProgressBar extends StatelessWidget {
  final double current;
  final double limit;

  const LimitProgressBar({
    super.key,
    required this.current,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = limit > 0 ? current / limit : 0.0;
    final clampedProgress = progress.clamp(0.0, 1.0);
    final totalDots = 10;
    final filledDots = (clampedProgress * totalDots).ceil();

    Color getColor(int dotIndex) {
      if (dotIndex < filledDots) {
        if (clampedProgress >= 1.0) return AppColors.danger;
        if (clampedProgress >= 0.8) return AppColors.warning;
        return AppColors.primary;
      }
      return isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(totalDots, (index) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: getColor(index),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
