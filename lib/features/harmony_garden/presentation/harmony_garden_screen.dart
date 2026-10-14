import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_header.dart';
import '../../../core/design_system/widgets/hikaru_navigation_bar.dart';
import '../../../core/design_system/widgets/hikaru_page_intro.dart';
import '../../../core/design_system/widgets/hikaru_shell.dart';
import '../../../core/router/app_routes.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../crystals/domain/crystal.dart';
import '../../library/domain/library_collection.dart';

class HarmonyGardenScreen extends ConsumerWidget {
  const HarmonyGardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crystal = ref.watch(selectedCrystalProvider).value;
    final accesses = [
      for (final access in _accesses)
        access.isCrystalSlot ? _crystalAccess(crystal) : access,
    ];

    return HikaruShell(
      active: HikaruDestination.home,
      builder: (context, scale) => _Garden(scale: scale, accesses: accesses),
    );
  }
}

/// Diameter of the access circles on Home, in design pixels.
const double homeCircleDiameter = 96;

/// Merkaba crowns the orbit with a slightly smaller circle.
const double merkabaCircleDiameter = 78;

/// Radius of the golden orbit that passes through every circle center.
const double _orbitRadius = 138;

/// Size of [HikaruShell.gardenBackground], drawn with [BoxFit.cover].
const Size _backgroundSize = Size(1024, 1536);

/// Top of her hair and the top of the garden title, as shares of the
/// background height. Merkaba sits just above her head; the title sits just
/// under the light on her chest.
const double _headTopShare = 0.31;
const double _titleTopShare = 0.59;

/// Gap between the Merkaba circle and the top of her head.
const double _crownGap = AppSpacing.s8;

class _Access {
  const _Access({
    required this.semanticsLabel,
    required this.angle,
    required this.imageAsset,
    required this.title,
    required this.route,
    this.diameter = homeCircleDiameter,
    this.isHighlighted = false,
    this.isCrystalSlot = false,
  });

  final String semanticsLabel;

  /// Position on the orbit in degrees, clockwise from three o'clock.
  final double angle;
  final String imageAsset;
  final String title;
  final String route;

  /// Circle diameter in design pixels.
  final double diameter;
  final bool isHighlighted;

  /// Replaced by the selected crystal, see [_crystalAccess].
  final bool isCrystalSlot;
}

/// Clockwise from the top. Each side mirrors the other across the vertical axis.
const List<_Access> _accesses = [
  _Access(
    semanticsLabel: 'Merkaba',
    angle: -90,
    imageAsset: 'assets/images/library_merkaba.png',
    title: 'MERKABA',
    route: AppRoutes.merkaba,
    diameter: merkabaCircleDiameter,
    isHighlighted: true,
  ),
  _Access(
    semanticsLabel: 'Your crystal',
    angle: -25,
    imageAsset: 'assets/images/library_white_quartz.png',
    title: 'YOUR CRYSTAL',
    route: AppRoutes.fourTemples,
    isCrystalSlot: true,
  ),
  _Access(
    semanticsLabel: 'Library',
    angle: 25,
    imageAsset: 'assets/images/harmony_library.png',
    title: 'LIBRARY',
    route: AppRoutes.library,
  ),
  _Access(
    semanticsLabel: 'Hikaru Ritual Body',
    angle: 155,
    imageAsset: 'assets/images/harmony_body.png',
    title: 'HIKARU RITUAL\nBODY',
    route: AppRoutes.ritualBody,
  ),
  _Access(
    semanticsLabel: 'Hikaru Ritual Face',
    angle: 205,
    imageAsset: 'assets/images/harmony_face.png',
    title: 'HIKARU RITUAL\nFACE',
    route: AppRoutes.ritualFace,
  ),
];

/// The selected crystal opens its frequency and cymatics. With no crystal
/// yet, the slot invites the user to choose one in the Four Temples.
_Access _crystalAccess(Crystal? crystal) {
  final slot = _accesses.firstWhere((access) => access.isCrystalSlot);
  final collection = crystalCollections[crystal];
  if (crystal == null || collection == null) return slot;
  return _Access(
    semanticsLabel: 'Your crystal ${crystal.displayName}',
    angle: slot.angle,
    imageAsset: collection.imageAsset,
    title: collection.name,
    diameter: slot.diameter,
    route: AppRoutes.crystalResonanceFor(crystal.name),
    isCrystalSlot: true,
  );
}

/// Light points on the orbit, halfway between neighboring circles.
List<double> get _orbitDotAngles => [
  for (final (index, access) in _accesses.indexed)
    (access.angle +
            (index + 1 < _accesses.length
                ? _accesses[index + 1].angle
                : _accesses.first.angle + 360)) /
        2,
];

Offset _pointOnOrbit(Offset center, double radius, double degrees) {
  final radians = degrees * math.pi / 180;
  return center + Offset(math.cos(radians), math.sin(radians)) * radius;
}

/// Where the shell draws the garden background on a screen of [size].
Rect _backgroundRect(Size size) {
  final fit = math.max(
    size.width / _backgroundSize.width,
    size.height / _backgroundSize.height,
  );
  final width = _backgroundSize.width * fit;
  final height = _backgroundSize.height * fit;
  return Rect.fromLTWH(
    (size.width - width) / 2,
    (size.height - height) / 2,
    width,
    height,
  );
}

class _Garden extends StatelessWidget {
  const _Garden({required this.scale, required this.accesses});

  final double scale;
  final List<_Access> accesses;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = HikaruShell.designWidth * scale;
    final radius = _orbitRadius * scale;
    final background = _backgroundRect(media.size);
    final contentTop = media.padding.top + HikaruHeader.height * scale;
    final merkabaRadius = merkabaCircleDiameter * scale / 2;
    final headTop = background.top + background.height * _headTopShare;
    final merkabaY = math.max(
      contentTop + merkabaRadius,
      headTop - _crownGap * scale - merkabaRadius,
    );
    final center = Offset(width / 2, merkabaY + radius);
    final lowestCircleBottom = accesses
        .map(
          (access) =>
              _pointOnOrbit(center, radius, access.angle).dy +
              access.diameter * scale / 2,
        )
        .reduce(math.max);
    final titleTop = math.max(
      background.top + background.height * _titleTopShare,
      lowestCircleBottom,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _OrbitPainter(
                center: center,
                radius: radius,
                dotAngles: _orbitDotAngles,
                scale: scale,
              ),
            ),
          ),
        ),
        for (final access in accesses)
          Positioned.fromRect(
            rect: Rect.fromCircle(
              center: _pointOnOrbit(center, radius, access.angle),
              radius: access.diameter * scale / 2,
            ),
            child: _AccessCircle(
              access: access,
              scale: scale,
              onPressed: () => context.push(access.route),
            ),
          ),
        Positioned(
          left: 20 * scale,
          right: 20 * scale,
          top: titleTop,
          child: const _GardenTitle(),
        ),
      ],
    );
  }
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({
    required this.center,
    required this.radius,
    required this.dotAngles,
    required this.scale,
  });

  final Offset center;
  final double radius;
  final List<double> dotAngles;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1 * scale
        ..color = AppColors.champagneGold.withValues(alpha: 0.85),
    );
    final glow = Paint()
      ..color = AppColors.splashHighlight.withValues(alpha: 0.8)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * scale);
    final core = Paint()..color = AppColors.white;
    for (final angle in dotAngles) {
      final point = _pointOnOrbit(center, radius, angle);
      canvas.drawCircle(point, 3.2 * scale, glow);
      canvas.drawCircle(point, 1.3 * scale, core);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.center != center ||
      oldDelegate.radius != radius ||
      oldDelegate.scale != scale;
}

class _AccessCircle extends StatelessWidget {
  const _AccessCircle({
    required this.access,
    required this.scale,
    required this.onPressed,
  });

  /// Share of the circle height covered by the photo before it fades to black.
  static const double _photoShare = 0.62;

  final _Access access;
  final double scale;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final diameter = access.diameter * scale;
    final glowAlpha = access.isHighlighted ? 0.75 : 0.45;
    final glowBlur = (access.isHighlighted ? 10 : 6) * scale;

    return Semantics(
      button: true,
      label: access.semanticsLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.black,
            boxShadow: [
              BoxShadow(
                color: AppColors.champagneGold.withValues(alpha: glowAlpha),
                blurRadius: glowBlur,
              ),
            ],
          ),
          foregroundDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.champagneGold80,
              width: 0.9 * scale,
            ),
          ),
          child: ClipOval(
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: diameter * _photoShare,
                  child: Image.asset(
                    access.imageAsset,
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
                ),
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.transparent, AppColors.black],
                        stops: [0.34, 0.6],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: AppSpacing.s8 * scale,
                  right: AppSpacing.s8 * scale,
                  top: diameter * 0.5,
                  bottom: diameter * 0.08,
                  child: _AccessCaption(access: access, scale: scale),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccessCaption extends StatelessWidget {
  const _AccessCaption({required this.access, required this.scale});

  final _Access access;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        access.title,
        textAlign: TextAlign.center,
        softWrap: false,
        style: AppTypography.headline.copyWith(
          color: AppColors.white,
          fontSize: AppFontSizes.s9 * scale,
          height: 1.2,
          letterSpacing: 1.3 * scale,
        ),
      ),
    );
  }
}

class _GardenTitle extends StatelessWidget {
  const _GardenTitle();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 0.9,
          colors: [
            AppColors.black.withValues(alpha: 0.38),
            AppColors.black.withValues(alpha: 0),
          ],
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: HikaruPageIntro(
          title: 'THE HARMONY GARDEN',
          subtitle: 'Your Journey Begins Within',
        ),
      ),
    );
  }
}
