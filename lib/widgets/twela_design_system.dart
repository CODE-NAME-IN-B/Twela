import 'package:flutter/material.dart';

import '../design/motion.dart';
import '../design/screen.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';

/// Compatibility layer: legacy `TwelaX` widget APIs mapped to INB components.
/// The design system stays the single source of truth.
class TwelaRadius {
  TwelaRadius._();
  static const double lg = R.card;
  static const double sm = R.inner;
}

class TwelaPrimaryButton extends StatelessWidget {
  const TwelaPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) =>
      InbButton(label: label, onPressed: onPressed, icon: icon, color: color);
}

class TwelaAmountField extends StatelessWidget {
  const TwelaAmountField({
    super.key,
    required this.controller,
    this.accentColor,
    this.suffixText,
  });

  final TextEditingController controller;
  final Color? accentColor;
  final String? suffixText;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return Row(
      children: [
        Expanded(
          child: InbAmountField(
            controller: controller,
            accent: accentColor,
            size: 34,
          ),
        ),
        if (suffixText != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: S.md),
            child: Text(
              suffixText!,
              style: TextStyle(
                fontFamily: InbFonts.arabic,
                fontSize: 14,
                color: c.muted,
              ),
            ),
          ),
      ],
    );
  }
}

class TwelaEmptyState extends StatelessWidget {
  const TwelaEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => InbEmptyState(
        icon: icon,
        title: title,
        subtitle: subtitle,
        actionLabel: actionLabel,
        onAction: onAction,
      );
}

class TwelaSectionHeader extends StatelessWidget {
  const TwelaSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) =>
      InbSectionHeader(title: title, trailing: trailing);
}

class TwelaSegmentedControl<T> extends StatelessWidget {
  const TwelaSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelected,
    this.activeColor,
  });

  final Map<T, String> segments;
  final T selected;
  final ValueChanged<T> onSelected;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final entry in segments.entries) ...[
          if (entry.key != segments.keys.first) const SizedBox(width: S.sm),
          Expanded(
            child: InbChip(
              label: entry.value,
              selected: entry.key == selected,
              onTap: () => onSelected(entry.key),
            ),
          ),
        ],
      ],
    );
  }
}

class TwelaConfirmDialog extends StatelessWidget {
  const TwelaConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmLabel = 'تأكيد',
    this.cancelLabel = 'إلغاء',
    this.isDestructive = true,
  });

  final String title;
  final String message;
  final VoidCallback? onConfirm;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final sem = context.sem;

    return AlertDialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(R.card),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: InbFonts.arabic,
          fontWeight: FontWeight.w700,
          color: c.fg,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          fontFamily: InbFonts.arabic,
          fontSize: 14,
          color: c.muted,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            cancelLabel,
            style: TextStyle(fontFamily: InbFonts.arabic, color: c.muted),
          ),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm?.call();
          },
          style: FilledButton.styleFrom(
            backgroundColor: isDestructive ? sem.danger : c.fg,
            foregroundColor: c.paper,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(R.pill),
            ),
          ),
          child: Text(
            confirmLabel,
            style: TextStyle(
              fontFamily: InbFonts.arabic,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class TwelaSettingTile extends StatelessWidget {
  const TwelaSettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final tone = iconColor ?? c.fg;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(R.inner),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: S.md, horizontal: S.sm),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(R.inner),
                ),
                child: Icon(icon, size: 18, color: tone),
              ),
              const SizedBox(width: S.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: InbFonts.arabic,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: c.fg,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontFamily: InbFonts.arabic,
                          fontSize: 12,
                          color: c.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class TwelaProgressDots extends StatelessWidget {
  const TwelaProgressDots({
    super.key,
    required this.total,
    required this.filled,
    required this.filledColor,
  });

  final int total;
  final int filled;
  final Color filledColor;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: S.xs),
          AnimatedContainer(
            duration: Motion.base,
            curve: Motion.emphasized,
            width: i < filled ? 18 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i < filled ? filledColor : c.line,
              borderRadius: BorderRadius.circular(R.pill),
            ),
          ),
        ],
      ],
    );
  }
}
