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

/// The extruded donut's geometry, resolved for a given box.
///
/// The wall is drawn downward from the top face, so the face is lifted by
/// half the depth and the radius shrinks by it — otherwise the bottom of the
/// wall would be clipped by the chart's own height.
@visibleForTesting
class InbPieGeometry {
  const InbPieGeometry({
    required this.center,
    required this.outer,
    required this.inner,
    required this.depth,
  });

  final Offset center;
  final double outer;
  final double inner;
  final double depth;

  double get thickness => outer - inner;
}

InbPieGeometry inbPieGeometry(Size size, {double centerFactor = 0.34}) {
  final minSide = math.min(size.width, size.height);
  final depth = (minSide * 0.07).clamp(6.0, 14.0);
  final outer = (minSide - depth) / 2 - 2;
  final center = Offset(size.width / 2, (size.height - depth) / 2);
  return InbPieGeometry(
    center: center,
    outer: outer,
    inner: outer * centerFactor,
    depth: depth,
  );
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
    if (size.width <= 0 || size.height <= 0) return;
    final geo = inbPieGeometry(size, centerFactor: centerFactor);
    final outer = geo.outer;
    final inner = geo.inner;
    final depth = geo.depth;
    final center = geo.center;
    if (outer <= 0 || outer <= inner) return;
    // One pixel of air between top slices, converted to radians at the rim.
    final gap = 1 / outer;

    // Pass 1: the extruded walls (3D Soft Realism — depth from a darker
    // tone of the slice itself, never a gradient), drawn as one continuous
    // base so the slices sit on a solid ring instead of floating slabs.
    var angle = -math.pi / 2;
    final sweeps = <double>[];
    for (final slice in slices) {
      final sweep = (slice.value / total) * math.pi * 2 * progress;
      sweeps.add(sweep);
      if (sweep > 2 * gap) {
        canvas.drawPath(
            _ring(center + Offset(0, depth), outer, inner, angle, sweep),
            Paint()..color = _shade(slice.color));
      }
      angle += sweep;
    }

    // Pass 2: the top faces, then the labels that belong to them.
    angle = -math.pi / 2;
    for (var i = 0; i < slices.length; i++) {
      final slice = slices[i];
      final sweep = sweeps[i];
      if (sweep > 2 * gap) {
        final face = _ring(center, outer, inner, angle + gap, sweep - 2 * gap);
        canvas.drawPath(face, Paint()..color = slice.color);
        // Bevel: a hairline of light on the edge reads as thickness.
        canvas.drawPath(
            face,
            Paint()
              ..color = Color.lerp(slice.color, InbColors.light.paper, 0.35)!
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2);
      }

      if (progress > 0.999) {
        _paintLabel(canvas, center, inner, outer - inner, slice, sweep, angle);
      }
      angle += sweep;
    }
  }

  /// A donut slice between [inner] and [outer], starting at [start] and
  /// sweeping [sweep] radians.
  Path _ring(Offset center, double outer, double inner, double start,
          double sweep) =>
      Path()
        ..arcTo(
            Rect.fromCircle(center: center, radius: outer), start, sweep, true)
        ..arcTo(Rect.fromCircle(center: center, radius: inner), start + sweep,
            -sweep, false)
        ..close();

  /// The extruded wall tone: the slice colour sunk toward the app's ink.
  Color _shade(Color base) =>
      Color.lerp(base, InbColors.dark.paper, 0.38) ?? base;

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
