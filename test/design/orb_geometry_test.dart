import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:twela/design/theme.dart';
import 'package:twela/design/widgets.dart';

/// The Debts island's 3D object is a sphere that rests on a seat, not a flat
/// disc. These tests hold the object inside its box at every size the islands
/// ask for, so the volume can never be cropped into a circle.
void main() {
  group('SoftOrbGeometry', () {
    const sizes = [32.0, 40.0, 56.0, 64.0, 96.0];

    test('the sphere and its seat always fit inside the box', () {
      for (final side in sizes) {
        final g = SoftOrbGeometry.forSize(Size(side, side));
        final box = Rect.fromLTWH(0, 0, side, side);
        final sphere = Rect.fromCircle(center: g.center, radius: g.radius);

        expect(box.contains(sphere.topLeft), isTrue,
            reason: 'sphere top-left clipped at $side');
        expect(box.contains(sphere.bottomRight), isTrue,
            reason: 'sphere bottom-right clipped at $side');
        expect(box.contains(g.seat.topLeft), isTrue,
            reason: 'seat top-left clipped at $side');
        expect(box.contains(g.seat.bottomRight), isTrue,
            reason: 'seat bottom-right clipped at $side');
      }
    });

    test('the seat sits under the sphere, not through its centre', () {
      final g = SoftOrbGeometry.forSize(const Size(64, 64));
      expect(g.seat.center.dy, greaterThan(g.center.dy + g.radius * 0.5));
      expect(g.seat.width, greaterThan(g.radius * 1.5));
      expect(g.seat.height, lessThan(g.seat.width));
    });

    test('the object scales with its box', () {
      final small = SoftOrbGeometry.forSize(const Size(40, 40));
      final large = SoftOrbGeometry.forSize(const Size(80, 80));
      expect(large.radius, closeTo(small.radius * 2, 0.001));
      expect(large.center.dy, closeTo(small.center.dy * 2, 0.001));
    });
  });

  testWidgets('SoftOrb paints without throwing and keeps its square',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildInbTheme(Brightness.light),
      home: const Center(child: SoftOrb(size: 64)),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(SoftOrb)), const Size(64, 64));
  });
}
