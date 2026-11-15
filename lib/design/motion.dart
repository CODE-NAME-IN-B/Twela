import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium feel = few motions, all with the same easing, all answering a touch.
class Motion {
  static const fast = Duration(milliseconds: 140);
  static const base = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 520);

  /// Fast start, long soft landing. Use for almost everything.
  static const emphasized = Cubic(0.05, 0.7, 0.1, 1.0);

  /// Tiny overshoot on release (press feedback only).
  static const settle = Cubic(0.34, 1.25, 0.64, 1.0);
}

bool reduceMotion(BuildContext c) => MediaQuery.of(c).disableAnimations;

/// Press feedback: shrinks slightly, springs back, light haptic.
class PressScale extends StatefulWidget {
  const PressScale(
      {super.key,
      required this.child,
      this.onTap,
      this.scale = 0.97,
      this.haptic = true});
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;
  void _set(bool v) {
    if (widget.onTap != null) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.haptic) HapticFeedback.selectionClick();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: _down ? Motion.fast : Motion.base,
        curve: _down ? Curves.easeOut : Motion.settle,
        child: widget.child,
      ),
    );
  }
}

/// One orchestrated entrance: wrap each top-level block with an increasing index.
/// Use it once per screen load, not on every card.
class Reveal extends StatefulWidget {
  const Reveal(
      {super.key,
      required this.child,
      this.index = 0,
      this.step = const Duration(milliseconds: 55)});
  final Widget child;
  final int index;
  final Duration step;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: Motion.slow);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.step * widget.index, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return widget.child;
    final a = CurvedAnimation(parent: _c, curve: Motion.emphasized);
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position:
            Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(a),
        child: widget.child,
      ),
    );
  }
}

/// Numbers (prices, stats) count up once instead of popping in.
class CountUp extends StatelessWidget {
  const CountUp(
      {super.key, required this.value, required this.style, this.format});
  final double value;
  final TextStyle style;
  final String Function(double)? format;

  @override
  Widget build(BuildContext context) {
    final f = format ?? (double v) => v.toStringAsFixed(0);
    if (reduceMotion(context)) return Text(f(value), style: style);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: Motion.slow * 1.4,
      curve: Motion.emphasized,
      builder: (_, v, __) => Text(f(v), style: style),
    );
  }
}

/// Screen transition: new page fades and rises 5%, old page recedes a little.
class InbPageTransition extends PageTransitionsBuilder {
  const InbPageTransition();

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    if (reduceMotion(context)) return child;
    final enter = CurvedAnimation(parent: animation, curve: Motion.emphasized);
    final exit =
        CurvedAnimation(parent: secondaryAnimation, curve: Motion.emphasized);
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 0.97).animate(exit),
      child: FadeTransition(
        opacity: enter,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.05), end: Offset.zero)
              .animate(enter),
          child: child,
        ),
      ),
    );
  }
}
