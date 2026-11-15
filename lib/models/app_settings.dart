import 'package:flutter/material.dart';

class AppSettings {
  final bool hapticFeedback;
  final bool glassMode;
  final bool showGlyphBar;
  final bool gpsCurrency;

  /// Tint of the dark island. Curation lives in `InbAccents`; this list is a
  /// mirror of it so the settings screen and the theme never disagree.
  final Color accentColor;

  const AppSettings({
    this.hapticFeedback = true,
    this.glassMode = false,
    this.showGlyphBar = true,
    this.gpsCurrency = false,
    this.accentColor = const Color(0xFF0E2A21),
  });

  static const List<Color> accentOptions = <Color>[
    Color(0xFF0E2A21),
    Color(0xFF2A2A6B),
    Color(0xFF3A2A27),
  ];

  static const List<String> accentNames = <String>[
    'زيتوني (افتراضي)',
    'نيلي',
    'طيني',
  ];

  AppSettings copyWith({
    bool? hapticFeedback,
    bool? glassMode,
    bool? showGlyphBar,
    bool? gpsCurrency,
    Color? accentColor,
  }) {
    return AppSettings(
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      glassMode: glassMode ?? this.glassMode,
      showGlyphBar: showGlyphBar ?? this.showGlyphBar,
      gpsCurrency: gpsCurrency ?? this.gpsCurrency,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hapticFeedback': hapticFeedback,
      'glassMode': glassMode,
      'showGlyphBar': showGlyphBar,
      'gpsCurrency': gpsCurrency,
      'accentColor': accentColor.value,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final stored = Color(json['accentColor'] ?? 0xFF0E2A21);
    // Legacy accents were free-form; snap anything unknown to the default.
    final accent =
        accentOptions.contains(stored) ? stored : accentOptions.first;
    return AppSettings(
      hapticFeedback: json['hapticFeedback'] ?? true,
      glassMode: json['glassMode'] ?? false,
      showGlyphBar: json['showGlyphBar'] ?? true,
      gpsCurrency: json['gpsCurrency'] ?? false,
      accentColor: accent,
    );
  }
}
