import 'package:flutter/material.dart';

class AppSettings {
  final bool hapticFeedback;
  final bool glassMode;
  final bool showGlyphBar;
  final bool gpsCurrency;
  final Color accentColor;

  const AppSettings({
    this.hapticFeedback = true,
    this.glassMode = false,
    this.showGlyphBar = true,
    this.gpsCurrency = false,
    this.accentColor = const Color(0xFF0A846B),
  });

  static const List<Color> accentOptions = [
    Color(0xFF0A846B),
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFFDC2626),
    Color(0xFFD97706),
    Color(0xFF0891B2),
  ];

  static const List<String> accentNames = [
    'أخضر (افتراضي)',
    'أزرق',
    'بنفسجي',
    'أحمر',
    'برتقالي',
    'سماوي',
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
    return AppSettings(
      hapticFeedback: json['hapticFeedback'] ?? true,
      glassMode: json['glassMode'] ?? false,
      showGlyphBar: json['showGlyphBar'] ?? true,
      gpsCurrency: json['gpsCurrency'] ?? false,
      accentColor: Color(json['accentColor'] ?? 0xFF0A846B),
    );
  }
}
