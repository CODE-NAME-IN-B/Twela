import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'motion.dart';
import 'theme.dart';
import 'tokens.dart';

/// One slice of [InbPie].
class InbPieSlice {
  const InbPieSlice({
    required this.name,
    required this.value,
    required this.color,
  });

  final String name;
  final double value;
  final Color color;
}

enum PieLabelKind { full, percent, none }

/// The label a slice can hold.
class InbPieLabel {
  const InbPieLabel(this.kind, this.text);
  final PieLabelKind kind;
  final String text;

  static const none = InbPieLabel(PieLabelKind.none, '');
}

/// Picks the richest label that fits **inside its own wedge**.
///
/// A label is drawn horizontally and centred on the slice's mid-angle, so it
/// may only be as wide as the wedge's chord at that radius (minus a safety
/// margin) and no taller than the band. Measuring with the real font is the
/// only way Arabic labels stop crossing into the neighbouring slice — an
/// approximate "big slice gets a name" rule failed exactly there.
InbPieLabel fitPieLabel({
  required String name,
  required double percentage,
  required double sweepRadians,
  required double innerRadius,
  required double thickness,
  required TextStyle nameStyle,
  required TextStyle percentStyle,
  required double textScale,
  required TextDirection direction,
}) {
  final sweep = math.min(sweepRadians, math.pi);
  if (sweep <= 0 || thickness <= 0) return InbPieLabel.none;

  final radius = innerRadius + thickness * 0.58;
  // 0.92 keeps a hairline gap between neighbours.
  final maxWidth = 2 * radius * math.sin(sweep / 2) * 0.92;
  final maxHeight = thickness * 0.72;

  Size measure(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: TextAlign.center,
      textDirection: direction,
      textScaler: TextScaler.linear(textScale),
      maxLines: 1,
    )..layout();
    final size = Size(painter.width, painter.height);
    painter.dispose();
    return size;
  }

  final percentText = '${percentage.round()}%';
  final fullSize = measure('$name $percentText', nameStyle);
  if (fullSize.width <= maxWidth && fullSize.height <= maxHeight) {
    return InbPieLabel(PieLabelKind.full, '$name $percentText');
  }

  final percentSize = measure(percentText, percentStyle);
  if (percentSize.width <= maxWidth && percentSize.height <= maxHeight) {
    return InbPieLabel(PieLabelKind.percent, percentText);
  }

  return InbPieLabel.none;
}

/// A donut chart that labels its slices from the inside and never lets a
/// label cross a slice border.
class InbPie extends StatefulWidget {
  const InbPie({
    super.key,
    required this.slices,
    this.height = 224,
    this.centerFactor = 0.34,
  });

  final List<InbPieSlice> slices;
  final double height;

  /// Centre hole as a fraction of the outer radius.
  final double centerFactor;

  @override
  State<InbPie> createState() => _InbPieState();
}

class _InbPieState extends State<InbPie> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: Motion.slow);

  @override
  void initState() {
    super.initState();
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final total = widget.slices.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) return SizedBox(height: widget.height);

    final dark = Theme.of(context).brightness == Brightness.dark;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final direction = Directionality.of(context);

    CustomPainter painter(double progress) => _InbPiePainter(
          slices: widget.slices,
          total: total,
          progress: progress,
          centerFactor: widget.centerFactor,
          nameStyle: const TextStyle(
            fontFamily: InbFonts.arabic,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          percentStyle: monoStyle(context, size: 12),
          light: dark ? c.onIsland : c.surface,
          ink: InbColors.light.fg,
          textScale: textScale,
          direction: direction,
        );

    final chart = reduceMotion(context)
        ? CustomPaint(painter: painter(1))
        : AnimatedBuilder(
            animation: _c,
            builder: (_, __) => CustomPaint(
              painter: painter(Motion.emphasized.transform(_c.value)),
            ),
          );

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: RepaintBoundary(child: chart),
    );
  }
}

class _InbPiePainter extends CustomPainter {
  _InbPiePainter({
    required this.slices,
    required this.total,
    required this.progress,
    required this.centerFactor,
    required this.nameStyle,
    required this.percentStyle,
    required this.light,
    required this.ink,
    required this.textScale,
    required this.direction,
  });

  final List<InbPieSlice> slices;
  final double total;
  final double progress;
  final double centerFactor;
  final TextStyle nameStyle;
  final TextStyle percentStyle;

  /// Text colour for dark slices (near-white in both themes).
  final Color light;

  /// Text colour for light slices (ink in both themes).
  final Color ink;
  final double textScale;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = math.min(size.width, size.height) / 2 - 2;
    if (outer <= 0) return;
    final inner = outer * centerFactor;
    final thickness = outer - inner;
    final outerRect = Rect.fromCircle(center: center, radius: outer);
    final innerRect = Rect.fromCircle(center: center, radius: inner);
    // One pixel of air between slices, converted to radians at the rim.
    final gap = 1 / outer;

    var angle = -math.pi / 2;
    for (final slice in slices) {
      final fullSweep = (slice.value / total) * math.pi * 2;
      final sweep = fullSweep * progress;
      final start = angle + gap;
      final end = angle + sweep - gap;
      if (end > start) {
        final path = Path()
          ..arcTo(outerRect, start, end - start, true)
          ..arcTo(innerRect, end, start - end, false)
          ..close();
        canvas.drawPath(path, Paint()..color = slice.color);
      }

      if (progress > 0.999) {
        _paintLabel(canvas, center, inner, thickness, slice, fullSweep, angle);
      }
      angle += sweep;
    }
  }

  void _paintLabel(Canvas canvas, Offset center, double inner, double thickness,
      InbPieSlice slice, double sweep, double startAngle) {
    final percentage = slice.value / total * 100;
    final label = fitPieLabel(
      name: slice.name,
      percentage: percentage,
      sweepRadians: sweep,
      innerRadius: inner,
      thickness: thickness,
      nameStyle: nameStyle,
      percentStyle: percentStyle,
      textScale: textScale,
      direction: direction,
    );
    if (label.kind == PieLabelKind.none) return;

    // Ink on light slices, near-white on dark ones: white text on amber (or
    // ink on navy) is unreadable. Both tones come from tokens.
    final color = slice.color.computeLuminance() > 0.42 ? ink : light;
    final style = (label.kind == PieLabelKind.full ? nameStyle : percentStyle)
        .copyWith(color: color);

    final painter = TextPainter(
      text: TextSpan(text: label.text, style: style),
      textAlign: TextAlign.center,
      textDirection: direction,
      textScaler: TextScaler.linear(textScale),
      maxLines: 1,
    )..layout();

    final mid = startAngle + sweep / 2;
    final radius = inner + thickness * 0.58;
    final offset = center +
        Offset(math.cos(mid) * radius, math.sin(mid) * radius) -
        Offset(painter.width / 2, painter.height / 2);
    painter.paint(canvas, offset);
    painter.dispose();
  }

  @override
  bool shouldRepaint(covariant _InbPiePainter old) =>
      old.progress != progress ||
      old.total != total ||
      old.slices != slices ||
      old.light != light;
}
