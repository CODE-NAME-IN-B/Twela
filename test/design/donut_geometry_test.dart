import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:twela/design/donut.dart';
import 'package:twela/design/tokens.dart';
import 'package:twela/models/transaction.dart';
import 'package:twela/screens/stats/stats_screen.dart';

/// The clay donut is option A of the stats decision. These tests pin the two
/// things a painter cannot be trusted with on its own: the hit test matches
/// the ellipse that is drawn, and the headline total is exactly the sum of the
/// segments it came from.
void main() {
  const size = Size.square(268);
  final geometry = ClayDonutGeometry.of(size);

  /// A point on the ring's mid-line at [angle], in the ring's own circular
  /// space (the painter scales y by [ClayDonutGeometry.tilt]).
  Offset onRing(double angle, ClayDonutGeometry g) {
    final r = (g.outer + g.inner) / 2;
    return Offset(
      g.center.dx + r * math.cos(angle),
      g.center.dy + r * math.sin(angle) * ClayDonutGeometry.tilt,
    );
  }

  const twoSlices = <ClaySlice>[
    ClaySlice(label: 'أ', value: 50, color: Color(0xFF3DDC84)),
    ClaySlice(label: 'ب', value: 50, color: Color(0xFF8B8BFF)),
  ];

  group('ClayDonutGeometry', () {
    test('the ring and its wall fit inside the box', () {
      for (final box in const [
        Size(268, 268),
        Size(200, 200),
        Size(120, 120),
        Size(320, 240),
      ]) {
        final g = ClayDonutGeometry.of(box);
        expect(g.outer, greaterThan(g.inner), reason: '$box');
        expect(g.center.dx - g.outer, greaterThanOrEqualTo(0), reason: '$box');
        expect(g.center.dx + g.outer, lessThanOrEqualTo(box.width),
            reason: '$box');
        expect(g.center.dy + g.outer * ClayDonutGeometry.tilt + g.depth,
            lessThanOrEqualTo(box.height),
            reason: 'wall clipped in $box');
      }
    });

    test('depth is clamped so small donuts still read as solid', () {
      expect(ClayDonutGeometry.depthFor(Size.square(60)), 8);
      expect(ClayDonutGeometry.depthFor(Size.square(268)), closeTo(18, 0.001));
      expect(ClayDonutGeometry.depthFor(Size.square(400)), 18);
      expect(
          ClayDonutGeometry.depthFor(Size.square(150)), closeTo(10.5, 0.001));
    });

    test('the box height matches the drawn ellipse, with no dead bands', () {
      final box = Size(268, ClayDonutGeometry.heightFor(268));
      final g = ClayDonutGeometry.of(box);
      expect(g.center.dy - g.outer * ClayDonutGeometry.tilt,
          closeTo(2 * ClayDonutGeometry.tilt, 0.01));
      expect(g.center.dy + g.outer * ClayDonutGeometry.tilt + g.depth,
          closeTo(box.height - 2 * ClayDonutGeometry.tilt, 0.01));
    });

    test('the top of the ring is the first slice', () {
      expect(
        geometry.sliceAt(onRing(-math.pi / 2, geometry), twoSlices, 0),
        0,
      );
    });

    test('the bottom of the ring is the second slice', () {
      expect(
        geometry.sliceAt(onRing(math.pi / 2 + 0.05, geometry), twoSlices, 0),
        1,
      );
    });

    test('rotation moves the hit test with the drawn ring', () {
      // Half a turn puts the second slice where the first one was.
      expect(
        geometry.sliceAt(onRing(-math.pi / 2, geometry), twoSlices, math.pi),
        1,
      );
    });

    test('a point inside the hole or outside the ring is no slice', () {
      expect(geometry.sliceAt(geometry.center, twoSlices, 0), isNull);
      expect(
        geometry.sliceAt(
          geometry.center.translate(geometry.outer + 20, 0),
          twoSlices,
          0,
        ),
        isNull,
      );
    });

    test('an empty ring has nothing to hit', () {
      expect(
        geometry.sliceAt(onRing(-math.pi / 2, geometry), const [], 0),
        isNull,
      );
    });
  });

  group('buildStatsSegments', () {
    TwelaTransaction expense(String category, double amount) =>
        TwelaTransaction(
          id: '$category-$amount',
          amount: amount,
          type: TransactionType.expense,
          walletType: WalletType.cash,
          categoryId: category,
          date: DateTime(2026, 11, 5),
        );

    // Six categories, one month: 600 + 300 + 100 + 60 + 30 + 10.
    final transactions = [
      expense('food', 600),
      expense('transport', 300),
      expense('bills', 100),
      expense('health', 60),
      expense('fun', 30),
      expense('misc', 10),
    ];
    const ids = ['food', 'transport', 'bills', 'health', 'fun', 'misc'];

    List<StatsSegment> build(List<TwelaTransaction> tx) => buildStatsSegments(
          transactions: tx,
          categoryIds: ids,
          nameOf: (id) => id,
          smallLabel: 'فئات صغيرة',
        );

    test('the total is exactly the sum of the segments', () {
      final segments = build(transactions);
      final total = segments.fold(0.0, (sum, s) => sum + s.value);
      expect(total, 1100);
    });

    test('four majors stay distinct and the rest merge into one bucket', () {
      final segments = build(transactions);
      expect(segments, hasLength(5));

      final majors = segments.take(4).toList();
      final hues = majors.map((s) => s.color).toSet();
      expect(hues, hasLength(4), reason: 'two slices shared a hue');
      for (final s in majors) {
        expect(InbCharts.palette.take(4), contains(s.color));
      }

      expect(segments.last.label, 'فئات صغيرة');
      expect(segments.last.value, 40); // 30 + 10
      expect(segments.last.color, InbCharts.palette.last);
    });

    test('clothing and groceries collide but never share a slice hue', () {
      // Catalogue positions 7 and 3 both land on sage; the later one is
      // shifted to the next free tone instead of duplicating the colour.
      final segments = build([
        expense('clothing', 500),
        expense('groceries', 400),
        expense('bills', 200),
        expense('food', 100),
      ]);
      final hues = segments.map((s) => s.color).toSet();
      expect(hues, hasLength(4));
    });

    test('colour follows the category, not this month’s rank', () {
      final first = build([
        expense('food', 600),
        expense('transport', 300),
        expense('bills', 200),
        expense('groceries', 100),
      ]);
      // Same four categories, inverted amounts: each keeps its hue.
      final second = build([
        expense('food', 10),
        expense('transport', 20),
        expense('bills', 30),
        expense('groceries', 40),
      ]);
      for (final label in ['food', 'transport', 'bills', 'groceries']) {
        Color hueOf(List<StatsSegment> s) =>
            s.firstWhere((segment) => segment.label == label).color;
        expect(hueOf(second), hueOf(first), reason: label);
      }
    });

    test('a single category still fills the ring', () {
      final segments = build([expense('food', 42.5)]);
      expect(segments, hasLength(1));
      expect(segments.single.value, 42.5);
    });

    test('no expenses means no segments', () {
      expect(build(const []), isEmpty);
    });
  });
}
