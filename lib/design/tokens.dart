import 'package:flutter/material.dart';

/// INB identity colors: warm paper + ink, dark green "islands" with mint glow,
/// a soft rose for promo tiles, indigo only for badges/links/focus.
///
/// The base palette never carries meaning on its own. Money meanings live in
/// [InbSemantics] so this palette stays exactly as the identity defines it.
class InbColors extends ThemeExtension<InbColors> {
  const InbColors({
    required this.paper,
    required this.surface,
    required this.fg,
    required this.muted,
    required this.line,
    required this.island,
    required this.onIsland,
    required this.mint,
    required this.rose,
    required this.onRose,
    required this.indigo,
    required this.onIndigo,
    required this.glass,
  });

  final Color paper,
      surface,
      fg,
      muted,
      line,
      island,
      onIsland,
      mint,
      rose,
      onRose,
      indigo,
      onIndigo,
      glass;

  static const light = InbColors(
    paper: Color(0xFFF2ECE1),
    surface: Color(0xFFFBF7EF),
    fg: Color(0xFF15130F),
    muted: Color(0xFF5E574B),
    line: Color(0x2615130F),
    island: Color(0xFF0E2A21),
    onIsland: Color(0xFFEAF4EE),
    mint: Color(0xFF3DDC84),
    rose: Color(0xFFE3BDB4),
    onRose: Color(0xFF15130F),
    indigo: Color(0xFF4747E0),
    onIndigo: Color(0xFFFFFFFF),
    glass: Color(0x8CFBF7EF),
  );

  static const dark = InbColors(
    paper: Color(0xFF0C1612),
    surface: Color(0xFF12241C),
    fg: Color(0xFFF2ECE1),
    muted: Color(0xFFA9C0B2),
    line: Color(0x33F2ECE1),
    island: Color(0xFF17382B),
    onIsland: Color(0xFFEAF4EE),
    mint: Color(0xFF3DDC84),
    rose: Color(0xFF3A2A27),
    onRose: Color(0xFFF0CFC8),
    indigo: Color(0xFF8B8BFF),
    onIndigo: Color(0xFF0C1612),
    glass: Color(0x8012241C),
  );

  @override
  InbColors copyWith({Color? island, Color? rose}) => InbColors(
        paper: paper,
        surface: surface,
        fg: fg,
        muted: muted,
        line: line,
        island: island ?? this.island,
        onIsland: onIsland,
        mint: mint,
        rose: rose ?? this.rose,
        onRose: onRose,
        indigo: indigo,
        onIndigo: onIndigo,
        glass: glass,
      );

  @override
  InbColors lerp(ThemeExtension<InbColors>? other, double t) {
    if (other is! InbColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return InbColors(
      paper: l(paper, other.paper),
      surface: l(surface, other.surface),
      fg: l(fg, other.fg),
      muted: l(muted, other.muted),
      line: l(line, other.line),
      island: l(island, other.island),
      onIsland: l(onIsland, other.onIsland),
      mint: l(mint, other.mint),
      rose: l(rose, other.rose),
      onRose: l(onRose, other.onRose),
      indigo: l(indigo, other.indigo),
      onIndigo: l(onIndigo, other.onIndigo),
      glass: l(glass, other.glass),
    );
  }
}

/// Money-only semantic hues.
///
/// Deliberately a separate extension: the INB base palette stays pure, and
/// these colours never paint a surface, never fill a card and never become a
/// gradient. They mark an amount, a badge or a chart series — nothing else.
///
/// - income  : money came in
/// - expense : money went out
/// - debt    : money somebody owes the user (and budget warnings)
/// - savings : money locked in a goal
/// - danger  : destructive action only
class InbSemantics extends ThemeExtension<InbSemantics> {
  const InbSemantics({
    required this.income,
    required this.expense,
    required this.debt,
    required this.savings,
    required this.danger,
    required this.warning,
  });

  final Color income, expense, debt, savings, danger, warning;

  static const light = InbSemantics(
    income: Color(0xFF0E6B43),
    expense: Color(0xFFB33A2E),
    debt: Color(0xFF9A6A06),
    savings: Color(0xFF0E7683),
    danger: Color(0xFFA32E22),
    warning: Color(0xFF9A6A06),
  );

  static const dark = InbSemantics(
    income: Color(0xFF4FD68B),
    expense: Color(0xFFFF8F7E),
    debt: Color(0xFFE5B54A),
    savings: Color(0xFF55CEDA),
    danger: Color(0xFFFF8F7E),
    warning: Color(0xFFE5B54A),
  );

  @override
  InbSemantics copyWith() => this;

  @override
  InbSemantics lerp(ThemeExtension<InbSemantics>? other, double t) {
    if (other is! InbSemantics) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return InbSemantics(
      income: l(income, other.income),
      expense: l(expense, other.expense),
      debt: l(debt, other.debt),
      savings: l(savings, other.savings),
      danger: l(danger, other.danger),
      warning: l(warning, other.warning),
    );
  }
}

extension InbContext on BuildContext {
  InbColors get inb => Theme.of(this).extension<InbColors>()!;
  InbSemantics get sem => Theme.of(this).extension<InbSemantics>()!;
}

/// Border radii. Only these three values are allowed.
class R {
  static const card = 28.0;
  static const inner = 18.0;
  static const pill = 999.0;
}

/// Spacing scale. Only these five values are allowed.
class S {
  static const xs = 4.0, sm = 8.0, md = 16.0, lg = 24.0, xl = 32.0;
}

/// Bundled font families (see `assets/fonts/`). Never fetched at runtime.
class InbFonts {
  static const arabic = 'IBM Plex Sans Arabic';
  static const mono = 'Space Mono';
  static const display = 'Unbounded';
  static const pixel = 'Silkscreen';
}

/// The only thing the user may re-colour: the tint of the dark island.
///
/// The paper, the ink, the mint, the rose, the indigo and the four money
/// hues are fixed by the identity. A free-form accent colour would break the
/// system and blur the difference between the brand and the semantics, so the
/// choice is limited to three curated tints.
class InbAccents {
  static const List<Color> options = <Color>[
    Color(0xFF0E2A21), // زيتوني — default
    Color(0xFF2A2A6B), // نيلي
    Color(0xFF3A2A27), // طيني
  ];

  static const List<String> names = <String>[
    'زيتوني',
    'نيلي',
    'طيني',
  ];

  static final Map<Color, Color> _dark = <Color, Color>{
    Color(0xFF0E2A21): Color(0xFF17382B),
    Color(0xFF2A2A6B): Color(0xFF23234F),
    Color(0xFF3A2A27): Color(0xFF33231F),
  };

  static Color darkFor(Color accent) => _dark[accent] ?? _dark[options.first]!;

  /// Snap an unknown (legacy) colour to the default tint.
  static Color normalize(Color accent) =>
      options.contains(accent) ? accent : options.first;
}
