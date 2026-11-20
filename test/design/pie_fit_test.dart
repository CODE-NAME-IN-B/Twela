import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:twela/design/pie.dart';
import 'package:twela/design/theme.dart';

/// The pie used to place Arabic labels by percentage thresholds and they ran
/// into their neighbours. These tests pin the real contract: a label is only
/// drawn when it fits inside its own wedge.
void main() {
  const nameStyle = TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700);
  const percentStyle = TextStyle(fontSize: 12, fontFamily: 'monospace');

  InbPieLabel fit({
    required String name,
    required double percentage,
    double inner = 40,
    double thickness = 60,
    double textScale = 1,
  }) =>
      fitPieLabel(
        name: name,
        percentage: percentage,
        sweepRadians: percentage / 100 * math.pi * 2,
        innerRadius: inner,
        thickness: thickness,
        nameStyle: nameStyle,
        percentStyle: percentStyle,
        textScale: textScale,
        direction: TextDirection.rtl,
      );

  double width(String text, TextStyle style, {double textScale = 1}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.rtl,
      textScaler: TextScaler.linear(textScale),
      maxLines: 1,
    )..layout();
    final w = painter.width;
    painter.dispose();
    return w;
  }

  test('a wide slice keeps the Arabic name and the percentage', () {
    final label = fit(name: 'طعام', percentage: 40);
    expect(label.kind, PieLabelKind.full);
    expect(label.text, 'طعام 40%');
  });

  test('a narrow slice drops the name but keeps the percentage', () {
    final label = fit(name: 'طعام', percentage: 9);
    expect(label.kind, PieLabelKind.percent);
    expect(label.text, '9%');
  });

  test('a hairline slice gets no label at all', () {
    final label = fit(name: 'طعام', percentage: 2);
    expect(label.kind, PieLabelKind.none);
  });

  test('a long Arabic name never forces a label wider than its wedge', () {
    const longName = 'مواصلات ووقود السيارة';
    for (var pct = 3; pct <= 60; pct++) {
      final label = fit(name: longName, percentage: pct.toDouble());
      if (label.kind == PieLabelKind.none) continue;
      final chord = 2 * (40 + 60 * 0.58) * math.sin(pct / 100 * math.pi) * 0.92;
      final used = width(
        label.text,
        label.kind == PieLabelKind.full ? nameStyle : percentStyle,
      );
      expect(used, lessThanOrEqualTo(chord + 0.01),
          reason: 'label "$label" crosses the wedge at $pct%');
    }
  });

  test('labels stay legible when the user enlarges text', () {
    // At 200% the full label no longer fits, so the slice must fall back to
    // the percentage instead of spilling over.
    final label = fit(name: 'طعام', percentage: 18, textScale: 2);
    expect(label.kind, PieLabelKind.percent);
  });

  test('the extruded wall always fits inside the chart box', () {
    const boxes = <Size>[
      Size(320, 224),
      Size(224, 224),
      Size(200, 224),
      Size(160, 160),
      Size(400, 300),
      Size(60, 60),
    ];
    for (final box in boxes) {
      final geo = inbPieGeometry(box);
      expect(geo.outer, greaterThan(0), reason: '$box');
      expect(geo.outer, greaterThan(geo.inner), reason: '$box');
      expect(geo.center.dy - geo.outer, greaterThanOrEqualTo(0),
          reason: 'top clipped in $box');
      expect(
          geo.center.dy + geo.outer + geo.depth, lessThanOrEqualTo(box.height),
          reason: 'wall clipped in $box');
      expect(geo.center.dx - geo.outer, greaterThanOrEqualTo(0),
          reason: 'left clipped in $box');
      expect(geo.center.dx + geo.outer, lessThanOrEqualTo(box.width),
          reason: 'right clipped in $box');
    }
  });

  testWidgets('InbPie paints a donut with labels, in both themes',
      (tester) async {
    const slices = [
      InbPieSlice(name: 'طعام', value: 400, color: Color(0xFFF59E0B)),
      InbPieSlice(name: 'مواصلات', value: 300, color: Color(0xFF3B82F6)),
      InbPieSlice(name: 'أخرى', value: 40, color: Color(0xFF10B981)),
    ];

    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildInbTheme(brightness),
          home: const Scaffold(
            body: Center(
              child: SizedBox(width: 320, child: InbPie(slices: slices)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
