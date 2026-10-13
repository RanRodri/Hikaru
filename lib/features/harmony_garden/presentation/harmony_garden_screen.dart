import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_navigation_bar.dart';
import '../../../core/design_system/widgets/hikaru_shell.dart';
import '../../../core/router/app_routes.dart';

class HarmonyGardenScreen extends StatelessWidget {
  const HarmonyGardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HikaruShell(
      active: HikaruDestination.home,
      builder: (context, scale) => _Garden(scale: scale),
    );
  }
}

/// Diameter of the Merkaba circle already on Home. Every access uses it.
const double homeCircleDiameter = 110;

const double _captionBand = 32;

class _Access {
  const _Access({
    required this.semanticsLabel,
    required this.left,
    required this.top,
    required this.imageAsset,
    required this.label,
    required this.route,
  });

  final String semanticsLabel;
  final double left;
  final double top;
  final String imageAsset;
  final String label;
  final String route;
}

const List<_Access> _accesses = [
  _Access(
    semanticsLabel: 'Merkaba',
    left: (HikaruShell.designWidth - homeCircleDiameter) / 2,
    top: 22,
    imageAsset: 'assets/images/library_merkaba.png',
    label: 'MERKABA\nGeometry & Energy',
    route: AppRoutes.merkaba,
  ),
  _Access(
    semanticsLabel: 'Hikaru Ritual Face',
    left: 266,
    top: 238,
    imageAsset: 'assets/images/harmony_face.png',
    label: 'Hikaru Ritual\nFace',
    route: AppRoutes.ritualFace,
  ),
  _Access(
    semanticsLabel: 'Hikaru Ritual Body',
    left: 266,
    top: 402,
    imageAsset: 'assets/images/harmony_body.png',
    label: 'Hikaru Ritual\nBody',
    route: AppRoutes.ritualBody,
  ),
  _Access(
    semanticsLabel: 'Red Jasper',
    left: 14,
    top: 402,
    imageAsset: 'assets/images/library_red_jasper.png',
    label: 'Red Jasper',
    route: AppRoutes.fourTemples,
  ),
  _Access(
    semanticsLabel: 'Library',
    left: 14,
    top: 238,
    imageAsset: 'assets/images/harmony_library.png',
    label: 'Library',
    route: AppRoutes.library,
  ),
];

const List<Offset> _glowDots = [
  Offset(195, 214),
  Offset(186, 292),
  Offset(204, 292),
  Offset(195, 372),
  Offset(150, 430),
  Offset(240, 430),
];

class _Garden extends StatelessWidget {
  const _Garden({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _scaled(
          const Rect.fromLTWH(24, 88, 342, 400),
          SvgPicture.asset(
            'assets/images/harmony_orbit.svg',
            fit: BoxFit.fill,
            excludeFromSemantics: true,
          ),
        ),
        for (final dot in _glowDots)
          _scaled(
            Rect.fromLTWH(dot.dx, dot.dy, 7, 7),
            SvgPicture.asset(
              'assets/images/harmony_orbit_glow.svg',
              fit: BoxFit.fill,
              excludeFromSemantics: true,
            ),
          ),
        for (final access in _accesses)
          _AccessCircle(
            access: access,
            scale: scale,
            onPressed: () => context.push(access.route),
          ),
        _Title(scale: scale),
      ],
    );
  }

  Widget _scaled(Rect rect, Widget child) {
    return Positioned(
      left: rect.left * scale,
      top: rect.top * scale,
      width: rect.width * scale,
      height: rect.height * scale,
      child: child,
    );
  }
}

class _AccessCircle extends StatelessWidget {
  const _AccessCircle({
    required this.access,
    required this.scale,
    required this.onPressed,
  });

  final _Access access;
  final double scale;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final diameter = homeCircleDiameter * scale;

    return Positioned(
      left: access.left * scale,
      top: access.top * scale,
      width: diameter,
      height: diameter,
      child: Semantics(
        button: true,
        label: access.semanticsLabel,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onPressed,
          behavior: HitTestBehavior.opaque,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.black,
              border: Border.all(color: AppColors.champagneGold80),
              boxShadow: [
                BoxShadow(
                  color: AppColors.champagneGold.withValues(alpha: 0.7),
                  blurRadius: 2 * scale,
                ),
              ],
            ),
            child: ClipOval(
              child: Column(
                children: [
                  Expanded(
                    child: Image.asset(
                      access.imageAsset,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                  ),
                  SizedBox(
                    height: _captionBand * scale,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.s8 * scale,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          access.label,
                          textAlign: TextAlign.center,
                          style: AppTypography.subheadline.copyWith(
                            color: AppColors.white,
                            fontSize: AppFontSizes.s8_2 * scale,
                            height: 1.15,
                            letterSpacing: 0.4 * scale,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.headline.copyWith(color: AppColors.white);

    return Positioned(
      left: 100 * scale,
      top: 560 * scale,
      width: 190 * scale,
      child: Column(
        children: [
          Text(
            'The',
            style: style.copyWith(
              fontSize: AppFontSizes.s10 * scale,
              height: 1.1,
              letterSpacing: 1.6 * scale,
            ),
          ),
          SizedBox(height: AppSpacing.s4 * scale),
          Text(
            'Harmony Garden',
            style: style.copyWith(
              fontSize: AppFontSizes.s20 * scale,
              height: 1.1,
              letterSpacing: 1.6 * scale,
            ),
          ),
          SizedBox(height: AppSpacing.s4 * scale),
          _rule(34),
          SizedBox(height: AppSpacing.s4 * scale),
          Text(
            'Your Journey Begins Within',
            textAlign: TextAlign.center,
            style: style.copyWith(
              fontSize: AppFontSizes.s10 * scale,
              height: 1.2,
              letterSpacing: 0.6 * scale,
            ),
          ),
          SizedBox(height: AppSpacing.s4 * scale),
          _rule(30),
        ],
      ),
    );
  }

  Widget _rule(double width) {
    return Container(
      width: width * scale,
      height: 0.8,
      color: AppColors.champagneGold,
    );
  }
}
