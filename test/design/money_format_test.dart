import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:twela/design/format.dart';
import 'package:twela/design/theme.dart';

/// The number line of the whole app. Two failures used to live here: an ASCII
/// hyphen (which RTL paragraphs reorder around) and a sign that leaked into
/// the grouping loop and produced `-,100`.
void main() {
  group('formatNumber', () {
    test('groups thousands without touching the sign', () {
      expect(formatNumber(-100), '−100.00');
      expect(formatNumber(-1234567.89), '−1,234,567.89');
      expect(formatNumber(1234567.89), '1,234,567.89');
      expect(formatNumber(100), '100.00');
    });

    test('uses U+2212, never an ASCII hyphen', () {
      expect(formatNumber(-50), isNot(contains('-')));
      expect(formatNumber(-50), contains('\u2212'));
    });

    test('drops the sign when the value rounds to zero', () {
      expect(formatNumber(-0.001), '0.00');
      expect(formatNumber(-0.004, decimals: 2), '0.00');
    });

    test('compact form keeps its sign on the outside', () {
      expect(formatCompact(-1500), '−1.5K');
      expect(formatCompact(1500), '1.5K');
    });
  });

  group('Money', () {
    Widget wrap(Widget child) => MaterialApp(
          theme: buildInbTheme(Brightness.light),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Center(child: child),
          ),
        );

    testWidgets('renders an explicit sign in its own LTR run', (tester) async {
      await tester.pumpWidget(wrap(const Money(1200, signed: true)));
      await tester.pumpAndSettle();
      expect(find.text('+1,200.00'), findsOneWidget);
      // The text must sit in an LTR run, or the paragraph reorders `د.ل`
      // around the digits.
      final text = tester.element(find.text('+1,200.00'));
      expect(Directionality.of(text), TextDirection.ltr);
    });

    testWidgets('negative amounts carry U+2212 and no trailing sign',
        (tester) async {
      await tester.pumpWidget(wrap(const Money(-100, signed: true)));
      await tester.pumpAndSettle();
      expect(find.text('\u2212100.00'), findsOneWidget);
      expect(find.textContaining('-'), findsNothing);
    });

    testWidgets('unsigned money still shows its minus', (tester) async {
      await tester.pumpWidget(wrap(const Money(-42.5)));
      await tester.pumpAndSettle();
      expect(find.text('\u221242.50'), findsOneWidget);
    });

    testWidgets('a value that rounds to zero carries no sign', (tester) async {
      await tester.pumpWidget(wrap(const Money(-0.004, signed: true)));
      await tester.pumpAndSettle();
      expect(find.text('+0.00'), findsOneWidget);
    });

    testWidgets('keeps the currency after the number in LTR', (tester) async {
      await tester.pumpWidget(wrap(const Money(1200)));
      await tester.pumpAndSettle();
      expect(find.text('د.ل'), findsOneWidget);
      final number = tester.getTopLeft(find.text('1,200.00'));
      final currency = tester.getTopLeft(find.text('د.ل'));
      expect(currency.dx, greaterThan(number.dx),
          reason: 'د.ل must follow the number, not lead it');
    });
  });

  group('MoneyDelta', () {
    Widget wrap(Widget child) => MaterialApp(
          theme: buildInbTheme(Brightness.light),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Center(child: child),
          ),
        );

    testWidgets('shows the sign of the value, not a forced plus',
        (tester) async {
      await tester.pumpWidget(wrap(const MoneyDelta(-100)));
      await tester.pumpAndSettle();
      expect(find.text('\u2212100.00'), findsOneWidget);
    });
  });
}
