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
    final progress = limit > 0 ? current / limit : 0.0;
    final clampedProgress = progress.clamp(0.0, 1.0);

    Color getColor() {
      if (clampedProgress >= 1.0) return AppColors.danger;
      if (clampedProgress >= 0.8) return AppColors.warning;
      return AppColors.primary;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: clampedProgress,
        backgroundColor: AppColors.borderLight,
        valueColor: AlwaysStoppedAnimation<Color>(getColor()),
        minHeight: 6,
      ),
    );
  }
}
