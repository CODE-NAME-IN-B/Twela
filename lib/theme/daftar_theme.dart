import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Compatibility layer: legacy `DaftarTheme` names mapped to INB tokens.
class DaftarTheme {
  DaftarTheme._();

  static Color get lightSurface => InbColors.light.surface;
  static Color get darkSurface => InbColors.dark.surface;
  static Color get accent => InbColors.light.island;
  static Color get mint => InbColors.light.mint;
  static Color get rose => InbColors.light.rose;
  static Color get danger => InbSemantics.light.danger;
}
