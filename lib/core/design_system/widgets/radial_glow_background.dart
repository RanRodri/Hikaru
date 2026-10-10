import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

/// Dark indigo background with a soft blue glow that fades from the center
/// to every edge, as used on the splash screen.
class RadialGlowBackground extends StatelessWidget {
  const RadialGlowBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.darkIndigoBlue,
        gradient: RadialGradient(
          colors: [
            Color.fromRGBO(20, 40, 90, 0.5),
            Color.fromRGBO(9, 26, 56, 0.3),
            Color.fromRGBO(10, 11, 23, 0),
          ],
          stops: [0, 0.5, 1],
          transform: _StretchToBoundsTransform(),
        ),
      ),
      child: child,
    );
  }
}

/// Stretches a circular [RadialGradient] into an ellipse that touches every
/// edge of its bounds.
class _StretchToBoundsTransform extends GradientTransform {
  const _StretchToBoundsTransform();

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    if (bounds.isEmpty) return null;

    final shortestSide = bounds.shortestSide;
    final center = bounds.center;

    return Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByDouble(
        bounds.width / shortestSide,
        bounds.height / shortestSide,
        1,
        1,
      )
      ..translateByDouble(-center.dx, -center.dy, 0, 1);
  }
}
