import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/daftar_theme.dart';
import 'daftar_card.dart';
import '../utils/daftar_number_style.dart';

// ─── Spacing Scale ──────────────────────────────────
class TwelaSpacing {
  TwelaSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

// ─── Radius Scale ───────────────────────────────────
class TwelaRadius {
  TwelaRadius._();
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

// ─── Section Header ─────────────────────────────────
class TwelaSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const TwelaSectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: TwelaSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── Primary Button ─────────────────────────────────
class TwelaPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isLoading;
  final IconData? icon;

  const TwelaPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? AppColors.primary;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: btnColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TwelaRadius.md),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: TwelaSpacing.sm),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── Amount Field ───────────────────────────────────
class TwelaAmountField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final Color? accentColor;
  final String? suffixText;

  const TwelaAmountField({
    super.key,
    required this.controller,
    this.hint,
    this.accentColor,
    this.suffixText = 'د.ل',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = accentColor ?? AppColors.primary;

    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: daftarNumberStyle(
        fontSize: 32,
        color: color,
      ),
      decoration: InputDecoration(
        hintText: hint ?? '0',
        hintStyle: daftarNumberStyle(
          fontSize: 32,
          color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
        ),
        suffixText: suffixText,
        suffixStyle: TextStyle(
          fontSize: 16,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: TwelaSpacing.xl),
      ),
    );
  }
}

// ─── Segmented Control ──────────────────────────────
class TwelaSegmentedControl<T> extends StatelessWidget {
  final Map<T, String> segments;
  final T selected;
  final ValueChanged<T> onSelected;
  final Color? activeColor;

  const TwelaSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelected,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = activeColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.borderLight,
        borderRadius: BorderRadius.circular(TwelaRadius.md),
      ),
      child: Row(
        children: segments.entries.map((entry) {
          final isSelected = entry.key == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelected(entry.key);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(TwelaRadius.sm),
                ),
                child: Center(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Setting Tile ───────────────────────────────────
class TwelaSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const TwelaSettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = iconColor ?? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TwelaSpacing.lg,
          vertical: TwelaSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(TwelaRadius.sm),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: TwelaSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && onTap != null)
              Icon(
                Icons.chevron_left,
                color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ────────────────────────────────────
class TwelaEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const TwelaEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TwelaSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? DaftarTheme.darkSurface : DaftarTheme.lightSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Icon(
                icon,
                size: 36,
                color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: TwelaSpacing.xl),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TwelaSpacing.sm),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: TwelaSpacing.xl),
              TwelaPrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Transaction Type Badge ─────────────────────────
class TwelaTypeBadge extends StatelessWidget {
  final String type;
  final bool isSmall;

  const TwelaTypeBadge({super.key, required this.type, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.semanticForType(type);
    final label = _labelFor(type);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TwelaRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isSmall ? 10 : 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _labelFor(String type) {
    switch (type) {
      case 'income':
        return 'دخل';
      case 'expense':
        return 'مصروف';
      case 'debt':
        return 'دين';
      case 'savings':
        return 'ادخار';
      default:
        return type;
    }
  }
}

// ─── Progress Dots (for debt progress) ──────────────
class TwelaProgressDots extends StatelessWidget {
  final int total;
  final int filled;
  final Color? filledColor;
  final Color? emptyColor;

  const TwelaProgressDots({
    super.key,
    required this.total,
    required this.filled,
    this.filledColor,
    this.emptyColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fColor = filledColor ?? AppColors.primary;
    final eColor = emptyColor ?? (isDark ? AppColors.darkBorder : AppColors.border);

    return Row(
      children: List.generate(total, (i) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: i < filled ? fColor : eColor,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

// ─── Confirm Dialog ─────────────────────────────────
class TwelaConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color? confirmColor;
  final VoidCallback onConfirm;

  const TwelaConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'حذف',
    this.cancelLabel = 'إلغاء',
    this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = confirmColor ?? AppColors.danger;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TwelaRadius.lg),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            cancelLabel,
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(
            confirmLabel,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
