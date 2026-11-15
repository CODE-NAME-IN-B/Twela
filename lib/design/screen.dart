import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';
import 'tokens.dart';

/// Every screen in the app goes through this.
///
/// One place owns the system-UI strategy: the app draws edge to edge, the
/// body is inset by [SafeArea] so nothing can enter the status-bar or gesture
/// region, and the status-bar icons flip with the theme.
class InbScreen extends StatelessWidget {
  const InbScreen({
    super.key,
    required this.child,
    this.bottomBarHeight = 0,
    this.padding = const EdgeInsets.fromLTRB(S.md, S.sm, S.md, S.lg),
    this.scroll = false,
    this.controller,
    this.floating,
    this.embedded = false,
  });

  /// The body of the screen.
  final Widget child;

  /// Height reserved at the bottom for the floating glass navigation.
  final double bottomBarHeight;

  /// Outer padding of the body.
  final EdgeInsets padding;

  /// Wrap the child in a scroll view (with the bottom inset for the nav bar).
  final bool scroll;
  final ScrollController? controller;

  /// Optional floating element (used by the action sheet host).
  final Widget? floating;

  /// When true the screen renders only its body — the host scaffold (the tab
  /// shell) owns the Scaffold. Pushed routes use the full scaffold.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final body = SafeArea(
      top: true,
      bottom: false,
      child: Padding(
        padding: padding.copyWith(
          bottom: padding.resolve(TextDirection.ltr).bottom + bottomBarHeight,
        ),
        child: child,
      ),
    );

    final annotated = AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: body,
    );

    if (embedded) return annotated;

    return Scaffold(
      backgroundColor: c.paper,
      extendBody: bottomBarHeight > 0,
      body: annotated,
      floatingActionButton: floating,
    );
  }
}

/// Scroll body with the standard INB gutters and the bottom nav inset.
class InbScrollBody extends StatelessWidget {
  const InbScrollBody({
    super.key,
    required this.children,
    this.bottomBarHeight = 0,
    this.padding = const EdgeInsets.fromLTRB(S.md, S.sm, S.md, S.lg),
    this.controller,
  });

  final List<Widget> children;
  final double bottomBarHeight;
  final EdgeInsets padding;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding.copyWith(
        bottom: padding.resolve(TextDirection.ltr).bottom + bottomBarHeight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// Standard text field.
class InbTextField extends StatelessWidget {
  const InbTextField({
    super.key,
    required this.controller,
    this.hint,
    this.label,
    this.keyboardType,
    this.maxLines = 1,
    this.textInputAction,
    this.onChanged,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixText,
    this.textStyle,
    this.errorText,
  });

  final TextEditingController controller;
  final String? hint;
  final String? label;
  final TextInputType? keyboardType;
  final int maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final IconData? prefixIcon;
  final String? suffixText;
  final TextStyle? textStyle;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontFamily: InbFonts.arabic,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: c.muted,
            ),
          ),
          const SizedBox(height: S.sm),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          textInputAction: textInputAction,
          onChanged: onChanged,
          autofocus: autofocus,
          style: textStyle ??
              TextStyle(
                fontFamily: InbFonts.arabic,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: c.fg,
              ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 18, color: c.muted),
            suffixText: suffixText,
            suffixStyle: TextStyle(
              fontFamily: InbFonts.arabic,
              fontSize: 13,
              color: c.muted,
            ),
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}

/// The amount input: the visual focus of every money screen.
class InbAmountField extends StatelessWidget {
  const InbAmountField({
    super.key,
    required this.controller,
    this.accent,
    this.hint = '0',
    this.onChanged,
    this.autofocus = false,
    this.size = 40,
  });

  final TextEditingController controller;
  final Color? accent;
  final String hint;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final tone = accent ?? c.fg;
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      autofocus: autofocus,
      onChanged: onChanged,
      style: monoStyle(context, size: size, color: tone),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: monoStyle(context,
            size: size, color: c.muted.withValues(alpha: 0.5)),
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: S.sm),
      ),
    );
  }
}

/// Row that separates a label from a value — used across the data screens.
class InbDataRow extends StatelessWidget {
  const InbDataRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.dense = false,
  });
  final String label;
  final Widget value;
  final Color? valueColor;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? S.xs : S.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: InbFonts.arabic,
                fontSize: dense ? 13 : 14,
                color: c.muted,
              ),
            ),
          ),
          const SizedBox(width: S.sm),
          DefaultTextStyle.merge(
            style: TextStyle(
              fontFamily: InbFonts.arabic,
              fontSize: dense ? 13 : 14,
              fontWeight: FontWeight.w700,
              color: valueColor ?? c.fg,
            ),
            child: value,
          ),
        ],
      ),
    );
  }
}
