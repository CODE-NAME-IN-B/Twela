import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'motion.dart';

/// One segment of the clay donut.
class ClaySlice {
  const ClaySlice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

/// Pure geometry for the clay donut, so the hit test can be tested without
/// rendering anything.
///
/// The donut is a real ring seen from above at a fixed angle: the top face is
/// an ellipse ([tilt] = vertical scale), the ring has a real thickness
/// ([depth]) extruded downward, and the whole thing rotates around its own
/// centre. Depth is tone, never a glossy gradient, so the numbers stay true.
class ClayDonutGeometry {
  const ClayDonutGeometry({
    required this.center,
    required this.outer,
    required this.inner,
    required this.depth,
  });

  /// Vertical scale of the ellipse: the viewing angle of the clay ring.
  static const double tilt = 0.56;

  static const double _innerRatio = 0.58;

  final Offset center;
  final double outer;
  final double inner;
  final double depth;

  factory ClayDonutGeometry.of(Size size) {
    final depth = depthFor(size);
    final outer = math.min(
          size.width / 2,
          (size.height - depth) / (2 * tilt),
        ) -
        2;
    final center = Offset(size.width / 2, (size.height - depth) / 2);
    return ClayDonutGeometry(
      center: center,
      outer: math.max(outer, 1),
      inner: math.max(outer * _innerRatio, 0.5),
      depth: depth,
    );
  }

  static double depthFor(Size size) => (size.width * 0.07).clamp(8.0, 18.0);

  /// Height of the box the ring actually needs: the flattened ellipse plus
  /// its extruded wall. A square box would leave two dead bands and make the
  /// donut look smaller than the island allows.
  static double heightFor(double width) {
    final box = Size(width, width);
    return width * tilt + depthFor(box);
  }

  /// Where the top face's centre sits, so the centre text can be aligned to
  /// it instead of to the widget's box.
  static Offset topCenterOf(Size size) =>
      Offset(size.width / 2, (size.height - depthFor(size)) / 2);

  /// Which slice is under [point], or null if the point is outside the ring.
  ///
  /// The vertical distance is divided by [tilt] so the hit test happens in the
  /// ring's own circular space; `atan2` then gives the angle, and the rotation
  /// offset is removed before the segment is looked up by value.
  int? sliceAt(
    Offset point,
    List<ClaySlice> slices,
    double rotation,
  ) {
    final dx = point.dx - center.dx;
    final dy = (point.dy - center.dy) / tilt;
    final radius = math.sqrt(dx * dx + dy * dy);
    if (radius < inner || radius > outer) return null;

    final total = slices.fold(0.0, (sum, s) => sum + s.value);
    if (total <= 0) return null;

    const start = -math.pi / 2;
    final angle = math.atan2(dy, dx);
    var relative = (angle - start - rotation) % (2 * math.pi);
    if (relative < 0) relative += 2 * math.pi;

    var walked = 0.0;
    for (var i = 0; i < slices.length; i++) {
      walked += slices[i].value / total * 2 * math.pi;
      if (relative < walked) return i;
    }
    return slices.isEmpty ? null : slices.length - 1;
  }
}

/// The clay donut — option A of the owner's stats decision.
///
/// A single `CustomPainter`: extruded ring (front outer wall, inner back wall,
/// flat top faces), 900 ms sweep with a soft pop, drag to rotate, and
/// tap-to-lift with the centre handed to the screen.
class ClayDonut extends StatefulWidget {
  const ClayDonut({
    super.key,
    required this.slices,
    this.size = 260,
    this.selected,
    this.onSelected,
    this.rotation = 0,
    this.onRotation,
    this.center,
    this.cutColor,
    this.bevelColor,
    this.animate = true,
  });

  final List<ClaySlice> slices;
  final double size;
  final int? selected;
  final ValueChanged<int?>? onSelected;

  /// Controlled rotation, owned by the screen with [onRotation].
  final double rotation;
  final ValueChanged<double>? onRotation;
  final Widget? center;

  /// The gap line between slices — the island colour, so the cuts read as air.
  final Color? cutColor;
  final Color? bevelColor;
  final bool animate;

  @override
  State<ClayDonut> createState() => _ClayDonutState();
}

class _ClayDonutState extends State<ClayDonut>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  bool _started = false;
  double _dragFrom = 0;
  double _dragSum = 0;

  @override
  void initState() {
    super.initState();
    _c.value = 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Entrance runs once, after the first real size is known; reduced motion
    // keeps the donut drawn and still.
    if (!_started) {
      _started = true;
      if (widget.animate && !reduceMotion(context)) {
        _c.value = 0;
        _c.forward();
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ClayDonut old) {
    super.didUpdateWidget(old);
    if (widget.slices.length != old.slices.length && _c.value == 1) {
      // A month change replays the sweep once — the only entrance allowed.
      if (widget.animate) _c.forward(from: 0);
    }
  }

  bool reducedMotionOf(BuildContext context) => reduceMotion(context);

  @override
  Widget build(BuildContext context) {
    final size = Size(
      widget.size,
      ClayDonutGeometry.heightFor(widget.size),
    );
    return SizedBox(
      width: size.width,
      height: size.height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) {
          final geometry = ClayDonutGeometry.of(size);
          final index = geometry.sliceAt(
            details.localPosition,
            widget.slices,
            widget.rotation,
          );
          final selected = widget.selected;
          widget.onSelected?.call(index == selected ? null : index);
        },
        onHorizontalDragStart: (_) {
          // Several move events can arrive between frames, all still reading
          // the same widget.rotation. Accumulate them here or only the last
          // delta of each frame would survive.
          _dragFrom = widget.rotation;
          _dragSum = 0;
        },
        onHorizontalDragUpdate: (details) {
          _dragSum += details.delta.dx * 0.012;
          widget.onRotation?.call(_dragFrom + _dragSum);
        },
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final scale = 0.94 + 0.06 * Curves.easeOutBack.transform(t);
            return Transform.scale(
              scale: scale.clamp(0.9, 1.06),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _ClayDonutPainter(
                          slices: widget.slices,
                          rotation: widget.rotation,
                          selected: widget.selected,
                          progress: t,
                          cutColor: widget.cutColor ?? Colors.transparent,
                          bevelColor: widget.bevelColor ??
                              Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                    ),
                  ),
                  if (widget.center != null)
                    Transform.translate(
                      offset: Offset(
                        0,
                        -ClayDonutGeometry.depthFor(
                              Size.square(widget.size),
                            ) /
                            2,
                      ),
                      child: widget.center,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ClayDonutPainter extends CustomPainter {
  _ClayDonutPainter({
    required this.slices,
    required this.rotation,
    required this.selected,
    required this.progress,
    required this.cutColor,
    required this.bevelColor,
  });

  final List<ClaySlice> slices;
  final double rotation;
  final int? selected;
  final double progress;
  final Color cutColor;
  final Color bevelColor;

  static const _start = -math.pi / 2;
  static const _clipSteps = 36;

  @override
  void paint(Canvas canvas, Size size) {
    final g = ClayDonutGeometry.of(size);
    final total = slices.fold(0.0, (sum, s) => sum + s.value);
    if (total <= 0 || progress <= 0) return;

    // The sweep reveal: everything up to `2π * progress`, clockwise.
    final revealed = 2 * math.pi * progress;

    final walls = <int>[];
    final tops = <int>[];
    for (var i = 0; i < slices.length; i++) {
      walls.add(i);
      tops.add(i);
    }

    // Front outer walls, then the inner wall seen through the hole at the
    // back. Each wall clips itself to its own half, so a lifted slice can be
    // painted last without a curtain bleeding over a neighbour's top face.
    for (final i in walls) {
      _paintOuterWall(canvas, size, g, i, total, revealed);
    }
    for (final i in walls) {
      _paintInnerWall(canvas, size, g, i, total, revealed);
    }

    for (final i in tops) {
      if (i == selected) continue;
      _paintTop(canvas, g, i, total, revealed, false);
    }
    if (selected != null && selected! < slices.length) {
      // The lifted slice is drawn last, above its neighbours.
      _paintOuterWall(canvas, size, g, selected!, total, revealed);
      _paintInnerWall(canvas, size, g, selected!, total, revealed);
      _paintTop(canvas, g, selected!, total, revealed, true);
    }
  }

  /// The angular span of slice [i] that is actually revealed.
  (double, double)? _span(int i, double total, double revealed) {
    var from = 0.0;
    for (var j = 0; j < i; j++) {
      from += slices[j].value / total * 2 * math.pi;
    }
    final sweep = slices[i].value / total * 2 * math.pi;
    final start = math.min(from, revealed);
    final end = math.min(from + sweep, revealed);
    if (end - start <= 0.0001) return null;
    return (_start + start, _start + end);
  }

  Offset _lift(int i, ClayDonutGeometry g, double total, {bool lifted = true}) {
    if (!lifted) return Offset.zero;
    var from = 0.0;
    for (var j = 0; j < i; j++) {
      from += slices[j].value / total * 2 * math.pi;
    }
    final sweep = slices[i].value / total * 2 * math.pi;
    final mid = _start + from + sweep / 2 + rotation;
    final lift = g.outer * 0.06;
    return Offset(
        math.cos(mid) * lift, math.sin(mid) * lift * ClayDonutGeometry.tilt);
  }

  Color _wall(ClaySlice slice) =>
      Color.lerp(slice.color, const Color(0xFF04100A), 0.42)!;

  void _paintOuterWall(Canvas canvas, Size size, ClayDonutGeometry g, int i,
      double total, double revealed) {
    final span = _span(i, total, revealed);
    if (span == null) return;
    final (a0, a1) = span;
    final shift = _lift(i, g, total, lifted: i == selected);
    final path = _curtain(
      g.center + shift,
      g.outer,
      a0 + rotation,
      a1 + rotation,
      g.depth,
    );
    canvas.save();
    canvas.clipRect(
        Rect.fromLTWH(0, g.center.dy, size.width, size.height - g.center.dy));
    canvas.drawPath(path, Paint()..color = _wall(slices[i]));
    canvas.restore();
  }

  void _paintInnerWall(Canvas canvas, Size size, ClayDonutGeometry g, int i,
      double total, double revealed) {
    final span = _span(i, total, revealed);
    if (span == null) return;
    final (a0, a1) = span;
    final shift = _lift(i, g, total, lifted: i == selected);
    final path = _curtain(
      g.center + shift,
      g.inner,
      a0 + rotation,
      a1 + rotation,
      g.depth,
    );
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, g.center.dy));
    canvas.drawPath(
      path,
      Paint()..color = Color.lerp(_wall(slices[i]), Colors.black, 0.10)!,
    );
    canvas.restore();
  }

  void _paintTop(Canvas canvas, ClayDonutGeometry g, int i, double total,
      double revealed, bool lifted) {
    final span = _span(i, total, revealed);
    if (span == null) return;
    final (a0, a1) = span;
    final shift = _lift(i, g, total, lifted: lifted);
    final center = g.center + shift;
    final path = _ring(center, g.outer, g.inner, a0 + rotation, a1 + rotation);
    canvas.drawPath(path, Paint()..color = slices[i].color);

    // The cut between slices: a 1.2 px line in the island colour, so the clay
    // reads as separate pieces rather than one painted ring.
    final edge = Paint()..color = cutColor;
    final p0 = Offset(
      center.dx + g.outer * math.cos(a0 + rotation),
      center.dy + g.outer * math.sin(a0 + rotation) * ClayDonutGeometry.tilt,
    );
    final p1 = Offset(
      center.dx + g.inner * math.cos(a0 + rotation),
      center.dy + g.inner * math.sin(a0 + rotation) * ClayDonutGeometry.tilt,
    );
    canvas.drawLine(
      p0,
      p1,
      edge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // A light bevel along the outer top edge: thickness, not gloss.
    canvas.drawArc(
      Rect.fromCenter(
        center: center,
        width: g.outer * 2,
        height: g.outer * 2 * ClayDonutGeometry.tilt,
      ),
      a0 + rotation,
      a1 - a0,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = bevelColor,
    );
  }

  Path _ring(Offset c, double outer, double inner, double a0, double a1) {
    final p = Path();
    _arc(p, c, outer, a0, a1, 0, move: true);
    _arc(p, c, inner, a1, a0, 0, move: false);
    p.close();
    return p;
  }

  /// A vertical curtain following an ellipse arc: the side of the ring.
  Path _curtain(Offset c, double r, double a0, double a1, double depth) {
    final p = Path();
    _arc(p, c, r, a0, a1, 0, move: true);
    _arc(p, c, r, a1, a0, depth, move: false);
    p.close();
    return p;
  }

  void _arc(Path p, Offset c, double r, double a0, double a1, double dy,
      {required bool move}) {
    for (var i = 0; i <= _clipSteps; i++) {
      final a = a0 + (a1 - a0) * i / _clipSteps;
      final x = c.dx + r * math.cos(a);
      final y = c.dy + r * math.sin(a) * ClayDonutGeometry.tilt + dy;
      if (i == 0 && move) {
        p.moveTo(x, y);
      } else {
        p.lineTo(x, y);
      }
    }
  }

  @override
  bool shouldRepaint(_ClayDonutPainter old) =>
      old.rotation != rotation ||
      old.selected != selected ||
      old.progress != progress ||
      old.slices != slices ||
      old.cutColor != cutColor;
}
