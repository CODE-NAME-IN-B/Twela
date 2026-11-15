import 'package:flutter/material.dart';

import '../design/theme.dart';

/// Legacy number-style helper, now backed by the INB mono style.
///
/// Numbers in this app are always Latin digits in the mono face.
TextStyle daftarNumberStyle(
  BuildContext context, {
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.w700,
  Color? color,
}) =>
    monoStyle(
      context,
      size: fontSize,
      weight: fontWeight,
      color: color,
    );
