import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'motion.dart';
import 'theme.dart';
import 'tokens.dart';

enum BentoTone { surface, rose }

/// Bento tile. `rose` tone is for ONE promo/illustration tile per screen.
class BentoCard extends StatelessWidget {
  const BentoCard(
      {super.key,
      required this.child,
      this.onTap,
      this.tone = BentoTone.surface,
      this.padding = const EdgeInsets.all(S.md)});
  final Widget child;
  final VoidCallback? onTap;
  final BentoTone tone;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final rose = tone == BentoTone.rose;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: rose ? c.rose : c.surface,
        borderRadius: BorderRadius.circular(R.card),
        border: Border.all(color: rose ? Colors.transparent : c.line),
      ),
      child: DefaultTextStyle.merge(
          style: TextStyle(color: rose ? c.onRose : c.fg), child: child),
    );
    return onTap == null ? card : PressScale(onTap: onTap, child: card);
  }
}

/// The dark green "island" that holds a screen's hero. Mint glow lives only here.
/// `onAction` adds the INB notch button in the bottom-start corner.
/// The notch is painted in the paper color, so place islands on a paper background.
class IslandCard extends StatelessWidget {
  const IslandCard(
      {super.key,
      required this.child,
      this.onAction,
      this.onTap,
      this.glow = true,
      this.notchColor,
      this.padding = const EdgeInsets.all(S.md),
      this.height});
  final Widget child;
  final VoidCallback? onAction;
  final VoidCallback? onTap;
  final bool glow;

  /// Color of the notch cutout. Defaults to paper; use `c.rose` when the island sits inside a [RoseFrame].
  final Color? notchColor;
  final EdgeInsetsGeometry padding;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final body = ClipRRect(
      borderRadius: BorderRadius.circular(R.card),
      child: Container(
        height: height,
        color: c.island,
        child: Stack(
          children: [
            if (glow)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.7, -0.6),
                      radius: 0.9,
                      colors: [
                        c.mint.withValues(alpha: 0.22),
                        Colors.transparent
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: padding,
              child: DefaultTextStyle.merge(
                  style: TextStyle(color: c.onIsland), child: child),
            ),
            if (onAction != null)
              PositionedDirectional(
                start: 0,
                bottom: 0,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: notchColor ?? c.paper,
                    borderRadius: const BorderRadiusDirectional.only(
                        topEnd: Radius.circular(R.card)),
                  ),
                  alignment: Alignment.center,
                  child: PressScale(
                    onTap: onAction,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration:
                          BoxDecoration(color: c.mint, shape: BoxShape.circle),
                      child: Icon(Icons.add_rounded, color: c.island, size: 24),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    return onTap == null ? body : PressScale(onTap: onTap, child: body);
  }
}

/// Cell frame: 1px outline plus corner brackets. Use for data and overview surfaces.
class CellFrame extends StatelessWidget {
  const CellFrame(
      {super.key,
      required this.child,
      this.label,
      this.padding = const EdgeInsets.all(S.md)});
  final Widget child;
  final String? label;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return CustomPaint(
      foregroundPainter: _Brackets(c.fg.withValues(alpha: 0.55), rtl),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(R.card),
          border: Border.all(color: c.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Text(label!.toUpperCase(), style: microStyle(context)),
              const SizedBox(height: S.sm),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _Brackets extends CustomPainter {
  _Brackets(this.color, this.rtl);
  final Color color;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square;
    const o = 10.0, l = 9.0;
    final sx = rtl ? s.width - o : o;
    final sd = rtl ? -l : l;
    final ex = rtl ? o : s.width - o;
    final ed = rtl ? l : -l;
    final by = s.height - o;
    canvas.drawPath(
        Path()
          ..moveTo(sx + sd, o)
          ..lineTo(sx, o)
          ..lineTo(sx, o + l),
        p);
    canvas.drawPath(
        Path()
          ..moveTo(ex + ed, by)
          ..lineTo(ex, by)
          ..lineTo(ex, by - l),
        p);
  }

  @override
  bool shouldRepaint(_Brackets old) => old.color != color || old.rtl != rtl;
}

/// The only filled button on a screen: ink pill. `color` exists for the rare
/// full-bleed confirm inside a sheet — keep it on-brand and semantic.
class InbButton extends StatelessWidget {
  const InbButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.color,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final tone = color ?? c.fg;
    final disabled = onPressed == null && !loading;
    return PressScale(
      onTap: loading ? null : onPressed,
      child: AnimatedContainer(
        duration: Motion.base,
        curve: Motion.emphasized,
        height: 52,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: disabled ? c.line : tone,
          borderRadius: BorderRadius.circular(R.pill),
        ),
        child: AnimatedSwitcher(
          duration: Motion.fast,
          child: loading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: c.paper),
                )
              : Row(
                  key: ValueKey(label),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: c.paper),
                      const SizedBox(width: S.sm),
                    ],
                    Text(label,
                        style: TextStyle(
                            color: c.paper,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Secondary action: same silhouette, no fill.
class InbGhostButton extends StatelessWidget {
  const InbGhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final tone = color ?? c.fg;
    final disabled = onPressed == null;
    return PressScale(
      onTap: disabled ? null : onPressed,
      child: AnimatedContainer(
        duration: Motion.base,
        curve: Motion.emphasized,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: S.md),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(R.pill),
          border: Border.all(
            color: disabled ? c.line : tone.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 17, color: disabled ? c.muted : tone),
              const SizedBox(width: S.sm),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: InbFonts.arabic,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: disabled ? c.muted : tone,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Indigo badge: counts and steps ("3/5"). Indigo is used nowhere else except links and focus.
class InbBadge extends StatelessWidget {
  const InbBadge(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
          color: c.indigo, borderRadius: BorderRadius.circular(R.pill)),
      child: Text(text, style: monoStyle(context, size: 11, color: c.onIndigo)),
    );
  }
}

/// Floating glass pill (navigation or action bar) with blurred content behind it.
class GlassBar extends StatelessWidget {
  const GlassBar({super.key, required this.child, this.height = 56});
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return ClipRRect(
      borderRadius: BorderRadius.circular(R.pill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: c.glass,
            borderRadius: BorderRadius.circular(R.pill),
            border: Border.all(color: c.line),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Soft rose frame around the hero island (Detailed Illustrations).
/// Pass `notchColor: c.rose` to the island inside.
class RoseFrame extends StatelessWidget {
  const RoseFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration:
          BoxDecoration(color: c.rose, borderRadius: BorderRadius.circular(36)),
      child: child,
    );
  }
}

/// Progressive blur: stacked blur layers, each masked in further, so the blur ramps up smoothly.
class ProgressiveBlur extends StatelessWidget {
  const ProgressiveBlur(
      {super.key,
      required this.height,
      this.maxSigma = 14,
      this.layers = 4,
      this.fromTop = false});
  final double height, maxSigma;
  final int layers;
  final bool fromTop;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            for (var i = 0; i < layers; i++)
              Positioned.fill(
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (r) => LinearGradient(
                    begin:
                        fromTop ? Alignment.bottomCenter : Alignment.topCenter,
                    end: fromTop ? Alignment.topCenter : Alignment.bottomCenter,
                    colors: const [Colors.transparent, Colors.black],
                    stops: [
                      i / layers,
                      ((i + 1) / layers + 0.2).clamp(0.0, 1.0)
                    ],
                  ).createShader(r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: maxSigma * (i + 1) / layers,
                        sigmaY: maxSigma * (i + 1) / layers),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ─── Page furniture ──────────────────────────────────────────────────────

/// The top of every pushed page: big Arabic display title, one-line subtitle.
class InbPageHeader extends StatelessWidget {
  const InbPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: arabicDisplay(context, size: 26)),
              if (subtitle != null) ...[
                const SizedBox(height: S.xs),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontFamily: InbFonts.arabic,
                    fontSize: 13,
                    color: c.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Small-caps mono label with optional trailing content, above a list.
class InbSectionHeader extends StatelessWidget {
  const InbSectionHeader({super.key, required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: InbFonts.arabic,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: c.fg,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Sheet container for bottom sheets: paper surface, rounded top.
class InbSheet extends StatelessWidget {
  const InbSheet({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
  });
  final String? title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(S.lg, S.lg, S.lg, S.lg),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(R.card)),
          border: Border.all(color: c.line),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Text(title!, style: arabicDisplay(context, size: 22)),
            if (subtitle != null) ...[
              const SizedBox(height: S.xs),
              Text(
                subtitle!,
                style: TextStyle(
                  fontFamily: InbFonts.arabic,
                  fontSize: 13,
                  color: c.muted,
                ),
              ),
            ],
            if (title != null || subtitle != null) const SizedBox(height: S.lg),
            child,
          ],
        ),
      ),
    );
  }
}

/// The friendly nothing-here state.
class InbEmptyState extends StatelessWidget {
  const InbEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: S.xl),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.paper,
              borderRadius: BorderRadius.circular(R.card),
              border: Border.all(color: c.line),
            ),
            child: Icon(icon, size: 30, color: c.muted),
          ),
          const SizedBox(height: S.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: InbFonts.arabic,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: c.fg,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: S.xs),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: InbFonts.arabic,
                fontSize: 13,
                color: c.muted,
              ),
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: S.md),
            InbButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}

/// Something went wrong, with a way back.
class InbErrorState extends StatelessWidget {
  const InbErrorState({
    super.key,
    required this.title,
    this.subtitle,
    this.retryLabel = 'رجوع',
    this.onRetry,
  });
  final String title;
  final String? subtitle;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final sem = context.sem;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(S.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sem.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(R.card),
              ),
              child: Icon(Icons.error_outline_rounded,
                  size: 28, color: sem.danger),
            ),
            const SizedBox(height: S.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: InbFonts.arabic,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: c.fg,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: S.xs),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: InbFonts.arabic,
                  fontSize: 13,
                  color: c.muted,
                ),
              ),
            ],
            const SizedBox(height: S.lg),
            InbGhostButton(label: retryLabel, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

/// Thin progress line. The single allowed visual for ratios.
class InbProgress extends StatelessWidget {
  const InbProgress({
    super.key,
    required this.value,
    this.color,
    this.height = 8,
  });
  final double value;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final clamped = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(R.pill),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: clamped,
          backgroundColor: c.line,
          color: color ?? c.fg,
        ),
      ),
    );
  }
}

/// Selectable chip — the only allowed segmented control surface.
class InbChip extends StatelessWidget {
  const InbChip(
      {super.key, required this.label, this.selected = false, this.onTap});
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Motion.emphasized,
        padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.sm),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? c.island : c.surface,
          borderRadius: BorderRadius.circular(R.pill),
          border: Border.all(color: selected ? Colors.transparent : c.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: InbFonts.arabic,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? c.onIsland : c.muted,
          ),
        ),
      ),
    );
  }
}

/// The one segmented control: a row of [InbChip]s, selected chip = island fill.
class InbSegmentedControl<T> extends StatelessWidget {
  const InbSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelected,
  });

  final Map<T, String> segments;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final entry in segments.entries) ...[
          if (entry.key != segments.keys.first) const SizedBox(width: S.sm),
          Expanded(
            child: InbChip(
              label: entry.value,
              selected: entry.key == selected,
              onTap: () => onSelected(entry.key),
            ),
          ),
        ],
      ],
    );
  }
}

/// Soft 3D coin stack (3D Soft Realism). The coins rise once on first build —
/// one shot, no loop — and hold still under reduced motion.
class CoinStack extends StatelessWidget {
  const CoinStack({
    super.key,
    this.coins = 3,
    this.size = 88,
    this.animate = true,
  });

  final int coins;
  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    Widget paint(double progress) => CustomPaint(
          size: Size(size, size),
          painter: _CoinStackPainter(
            coins: coins.clamp(1, 5),
            body: c.mint,
            highlight: c.surface,
            rim: c.island,
            progress: progress,
          ),
        );

    if (!animate || reduceMotion(context)) return paint(1);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Motion.slow,
      curve: Motion.emphasized,
      builder: (_, v, __) => paint(v),
    );
  }
}

class _CoinStackPainter extends CustomPainter {
  _CoinStackPainter({
    required this.coins,
    required this.body,
    required this.highlight,
    required this.rim,
    required this.progress,
  });

  final int coins;
  final Color body, highlight, rim;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final d = w * 0.6;
    final r = d / 2;
    final step = coins > 1 ? (h - d) / (coins - 1) : 0.0;

    for (var i = 0; i < coins; i++) {
      final t = ((progress - i * 0.12) / 0.55).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final rise = (1 - Curves.easeOut.transform(t)) * 16;
      final cy = h - r - i * step + rise;
      final cx = w / 2;
      final opacity = t;

      // Soft ground shadow under the whole stack (bottom coin only).
      if (i == 0) {
        canvas.drawCircle(
          Offset(cx, cy + r * 0.9),
          r * 0.95,
          Paint()..color = rim.withValues(alpha: 0.12 * opacity),
        );
      }

      // Coin edge: a slightly lower dark circle gives the 3D thickness.
      canvas.drawCircle(
        Offset(cx, cy + d * 0.09),
        r,
        Paint()..color = rim.withValues(alpha: 0.85 * opacity),
      );

      // Top face: soft radial (highlight centre → body edge).
      final face = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 1.2,
          colors: [highlight, body],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
        ..colorFilter = ColorFilter.mode(
            body.withValues(alpha: 1 - opacity), BlendMode.srcATop);
      canvas.drawCircle(Offset(cx, cy), r, face);

      // Hairline rim.
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = rim.withValues(alpha: 0.5 * opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_CoinStackPainter old) =>
      old.progress != progress ||
      old.coins != coins ||
      old.body != body ||
      old.highlight != highlight ||
      old.rim != rim;
}

/// Hand-drawn doodle arrow (Detailed Illustrations). The head points toward
/// the start edge and upward — toward a notch action. Drawn once, no animation.
class DoodleArrow extends StatelessWidget {
  const DoodleArrow({super.key, this.color, this.width = 76, this.height = 44});

  final Color? color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return CustomPaint(
      size: Size(width, height),
      painter: _DoodleArrowPainter(color ?? c.fg, rtl),
    );
  }
}

class _DoodleArrowPainter extends CustomPainter {
  _DoodleArrowPainter(this.color, this.rtl);

  final Color color;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Tail near the end edge (bottom), head near the start edge (top).
    final tail = Offset(rtl ? w - 4 : 4, h - 4);
    final head = Offset(rtl ? 6 : w - 6, 8);
    final control = Offset(w * 0.55, h - 2);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(tail.dx, tail.dy)
        ..quadraticBezierTo(control.dx, control.dy, head.dx, head.dy),
      stroke,
    );

    // Arrow head: two short strokes around the incoming direction.
    final dir = head - control;
    final a = math.atan2(dir.dy, dir.dx);
    for (final spread in const [-0.55, 0.55]) {
      final tip =
          head - Offset(math.cos(a + spread), math.sin(a + spread)) * 12;
      canvas.drawLine(head, tip, stroke);
    }
  }

  @override
  bool shouldRepaint(_DoodleArrowPainter old) =>
      old.color != color || old.rtl != rtl;
}

/// Square icon-only button, muted by default.
class InbIconButton extends StatelessWidget {
  const InbIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 40,
    this.color,
    this.tooltip,
  });
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final tone = color ?? c.muted;
    return PressScale(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.paper,
          borderRadius: BorderRadius.circular(R.inner),
          border: Border.all(color: c.line),
        ),
        child: Icon(icon, size: size * 0.45, color: tone),
      ),
    );
  }
}

/// The one toast in the app: ink pill at the bottom, optional undo.
/// Loading placeholder: a soft pulsing block in the line color.
///
/// One shape covers every loading state (rows, cards, headline numbers).
/// When `MediaQuery.disableAnimations` is on, it renders as a static block —
/// no motion without consent.
class InbSkeleton extends StatefulWidget {
  const InbSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.radius = R.inner,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<InbSkeleton> createState() => _InbSkeletonState();
}

class _InbSkeletonState extends State<InbSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.base,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final box = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: c.line,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
    );
    if (MediaQuery.disableAnimationsOf(context)) return box;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Motion.emphasized),
      ),
      child: box,
    );
  }
}

Future<void> showInbToast(
  BuildContext context,
  String message, {
  String? undoLabel,
  VoidCallback? onUndo,
}) {
  final c = context.inb;
  final sem = context.sem;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontFamily: InbFonts.arabic,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: c.onIsland,
          ),
        ),
        action: undoLabel == null
            ? null
            : SnackBarAction(
                label: undoLabel,
                textColor: sem.income,
                onPressed: onUndo ?? () {},
              ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.island,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(R.pill),
        ),
        showCloseIcon: false,
        duration: const Duration(seconds: 4),
      ),
    );
  return Future.value();
}
