import 'package:flutter/material.dart';
import 'motion.dart';
import 'tokens.dart';

/// The single source of the app's look. Light and dark share every token.
ThemeData buildInbTheme(Brightness b, {Color? accent}) {
  final base0 = b == Brightness.light ? InbColors.light : InbColors.dark;
  final c = accent == null
      ? base0
      : base0.copyWith(
          island: b == Brightness.light
              ? InbAccents.normalize(accent)
              : InbAccents.darkFor(InbAccents.normalize(accent)),
        );
  final sem = b == Brightness.light ? InbSemantics.light : InbSemantics.dark;
  final base = ThemeData(
    brightness: b,
    useMaterial3: true,
    fontFamily: InbFonts.arabic,
  );

  final tt = _arabicTextTheme(base.textTheme, c.fg);

  return base.copyWith(
    scaffoldBackgroundColor: c.paper,
    canvasColor: c.paper,
    colorScheme:
        ColorScheme.fromSeed(seedColor: c.island, brightness: b).copyWith(
      primary: c.fg,
      onPrimary: c.paper,
      secondary: c.mint,
      onSecondary: c.island,
      tertiary: c.rose,
      onTertiary: c.onRose,
      surface: c.surface,
      onSurface: c.fg,
      surfaceContainerHighest: c.surface,
      outline: c.line,
      outlineVariant: c.line,
      error: sem.danger,
      onError: c.paper,
    ),
    textTheme: tt,
    appBarTheme: AppBarTheme(
      backgroundColor: c.paper,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: InbFonts.arabic,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: c.fg,
      ),
      iconTheme: IconThemeData(color: c.fg, size: 22),
    ),
    dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
    dividerColor: c.line,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    focusColor: c.indigo.withValues(alpha: 0.10),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      hintStyle: TextStyle(
        fontFamily: InbFonts.arabic,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: c.muted,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: S.md, vertical: S.md),
      border: _fieldBorder(c.line),
      enabledBorder: _fieldBorder(c.line),
      focusedBorder: _fieldBorder(c.indigo, width: 1.6),
      errorBorder: _fieldBorder(sem.danger),
      focusedErrorBorder: _fieldBorder(sem.danger, width: 1.6),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.island,
      contentTextStyle: TextStyle(
        fontFamily: InbFonts.arabic,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: c.onIsland,
      ),
      actionTextColor: c.mint,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.inner)),
      insetPadding: const EdgeInsets.all(S.md),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.card)),
      titleTextStyle: TextStyle(
        fontFamily: InbFonts.arabic,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: c.fg,
      ),
      contentTextStyle: TextStyle(
        fontFamily: InbFonts.arabic,
        fontSize: 14,
        height: 1.6,
        color: c.muted,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.paper,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: c.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.card)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.paper : c.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.fg : c.line,
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: c.fg,
      inactiveTrackColor: c.line,
      thumbColor: c.fg,
      overlayColor: c.indigo.withValues(alpha: 0.12),
      trackHeight: 4,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: c.island,
        borderRadius: BorderRadius.circular(R.inner),
      ),
      textStyle: TextStyle(
          fontFamily: InbFonts.arabic, fontSize: 12, color: c.onIsland),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: InbPageTransition(),
      TargetPlatform.iOS: InbPageTransition(),
    }),
    extensions: [c, sem],
  );
}

OutlineInputBorder _fieldBorder(Color color, {double width = 1}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(R.inner),
      borderSide: BorderSide(color: color, width: width),
    );

TextTheme _arabicTextTheme(TextTheme base, Color fg) {
  TextStyle s(double size, FontWeight w, {double height = 1.5, Color? color}) =>
      TextStyle(
        fontFamily: InbFonts.arabic,
        fontSize: size,
        fontWeight: w,
        height: height,
        // Arabic must never be tightened: negative tracking breaks the joins.
        letterSpacing: 0,
        color: color ?? fg,
      );

  return base.copyWith(
    displayLarge: s(40, FontWeight.w700, height: 1.15),
    displayMedium: s(34, FontWeight.w700, height: 1.15),
    displaySmall: s(28, FontWeight.w700, height: 1.2),
    headlineLarge: s(26, FontWeight.w700, height: 1.2),
    headlineMedium: s(22, FontWeight.w700, height: 1.25),
    headlineSmall: s(19, FontWeight.w700, height: 1.3),
    titleLarge: s(17, FontWeight.w700, height: 1.35),
    titleMedium: s(15, FontWeight.w700, height: 1.4),
    titleSmall: s(13, FontWeight.w700, height: 1.4),
    bodyLarge: s(15, FontWeight.w400),
    bodyMedium: s(14, FontWeight.w400),
    bodySmall: s(12, FontWeight.w400, height: 1.45),
    labelLarge: s(14, FontWeight.w700, height: 1.2),
    labelMedium: s(12, FontWeight.w700, height: 1.2),
    labelSmall: s(11, FontWeight.w700, height: 1.2),
  );
}

/// Every number (price, time, distance, count) uses this.
TextStyle monoStyle(
  BuildContext context, {
  double size = 16,
  FontWeight weight = FontWeight.w700,
  Color? color,
}) =>
    TextStyle(
      fontFamily: InbFonts.mono,
      fontSize: size,
      fontWeight: weight,
      height: 1.1,
      color: color ?? context.inb.fg,
    );

/// Giant Latin display type for brand words and numbers-as-art (tight tracking).
/// Never use it for Arabic — Arabic display is [arabicDisplay].
TextStyle displayStyle(BuildContext context,
        {double size = 44, Color? color}) =>
    TextStyle(
      fontFamily: InbFonts.display,
      fontSize: size,
      fontWeight: FontWeight.w700,
      letterSpacing: -size * 0.04,
      height: 1,
      color: color ?? context.inb.fg,
    );

/// Giant Arabic headline: 700 weight, line-height ~1, NO negative tracking.
TextStyle arabicDisplay(
  BuildContext context, {
  double size = 56,
  FontWeight weight = FontWeight.w700,
  Color? color,
  double height = 1.0,
}) =>
    TextStyle(
      fontFamily: InbFonts.arabic,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: 0,
      height: height,
      color: color ?? context.inb.fg,
    );

/// Tiny uppercase mono label used above data and inside cells.
TextStyle microStyle(BuildContext context, {Color? color, double size = 11}) =>
    TextStyle(
      fontFamily: InbFonts.mono,
      fontSize: size,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.66,
      height: 1.2,
      color: color ?? context.inb.muted,
    );

/// Pixel wordmark style — only for the wordmark and tiny marks.
TextStyle pixelStyle(BuildContext context, {double size = 11, Color? color}) =>
    TextStyle(
      fontFamily: InbFonts.pixel,
      fontSize: size,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.04,
      height: 1.2,
      color: color ?? context.inb.fg,
    );
