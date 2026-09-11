import 'package:flutter/material.dart';
import '../theme/daftar_theme.dart';

class DaftarCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final bool showDiagonalCut;
  final Color? backgroundColor;
  final bool showShadow;

  const DaftarCard({
    super.key,
    required this.child,
    this.width,
    this.padding,
    this.showDiagonalCut = true,
    this.backgroundColor,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? (isDark ? DaftarTheme.darkSurface : DaftarTheme.lightSurface);
    final shadowColor = isDark ? DaftarTheme.darkShadow : DaftarTheme.lightShadow;

    return SizedBox(
      width: width,
      child: Stack(
        children: [
          if (showShadow)
            Transform.translate(
              offset: const Offset(4, 4),
              child: ClipPath(
                clipper: showDiagonalCut ? _DiagonalCutClipper() : null,
                child: Container(
                  width: width,
                  padding: padding ?? const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: shadowColor,
                    borderRadius: showDiagonalCut
                        ? const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                          )
                        : BorderRadius.circular(12),
                  ),
                  child: Opacity(opacity: 0, child: child),
                ),
              ),
            ),
          ClipPath(
            clipper: showDiagonalCut ? _DiagonalCutClipper() : null,
            child: Container(
              width: width,
              padding: padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: showDiagonalCut
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      )
                    : BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      // ignore: deprecated_member_use
                      ? Colors.white.withOpacity(0.06)
                      // ignore: deprecated_member_use
                      : Colors.black.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagonalCutClipper extends CustomClipper<Path> {
  const _DiagonalCutClipper();

  @override
  Path getClip(Size size) {
    const cut = 18.0;
    const radius = 12.0;
    return Path()
      ..moveTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(size.width - cut, 0)
      ..lineTo(size.width, cut)
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(size.width, size.height, size.width - radius, size.height)
      ..lineTo(radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
