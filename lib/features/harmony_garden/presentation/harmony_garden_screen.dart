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
import '../../../l10n/app_localizations.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../crystals/domain/crystal.dart';
import '../../crystals/presentation/crystal_texts.dart';
import '../../library/domain/library_collection.dart';
import 'home_tour.dart';

class HarmonyGardenScreen extends ConsumerWidget {
  const HarmonyGardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final crystal = ref.watch(selectedCrystalProvider).value;
    final anchors = ref.watch(homeTourAnchorsProvider);
    final baseAccesses = _buildAccesses(l10n);
    final accesses = [
      for (final access in baseAccesses)
        access.isCrystalSlot ? _crystalAccess(access, crystal, l10n) : access,
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        HikaruShell(
          active: HikaruDestination.home,
          sanctuaryKey: anchors.sanctuary,
          navigationBarKey: anchors.bar,
          builder: (context, scale) =>
              _Garden(scale: scale, accesses: accesses, anchors: anchors),
        ),
        const HomeTour(),
      ],
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
    this.stepNumber,
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

  /// Clockwise protocol order, starting at Merkaba.
  final int? stepNumber;
}

/// Evenly spaced, clockwise from Merkaba at the top.
///
/// Figma crowns the ring with Merkaba and does not pin Fernanda's notes to a
/// circle, so the ritual order continues clockwise: face and neck, body,
/// the assigned crystal, then the library. Merkaba is a proper name.
const double _orbitStep = 72;

List<_Access> _buildAccesses(AppLocalizations l10n) => [
  const _Access(
    semanticsLabel: 'Merkaba',
    angle: -90,
    imageAsset: 'assets/images/library_merkaba.png',
    title: 'MERKABA',
    route: AppRoutes.merkaba,
    diameter: merkabaCircleDiameter,
    isHighlighted: true,
    stepNumber: 1,
  ),
  _Access(
    semanticsLabel: l10n.homeRitualFaceSemantics,
    angle: -90 + _orbitStep,
    imageAsset: 'assets/images/harmony_face.png',
    title: l10n.homeRitualFace,
    route: AppRoutes.ritualFace,
    stepNumber: 2,
  ),
  _Access(
    semanticsLabel: l10n.homeRitualBodySemantics,
    angle: -90 + _orbitStep * 2,
    imageAsset: 'assets/images/harmony_body.png',
    title: l10n.homeRitualBody,
    route: AppRoutes.ritualBody,
    stepNumber: 3,
  ),
  _Access(
    semanticsLabel: l10n.homeYourCrystalSemantics,
    angle: -90 + _orbitStep * 3,
    imageAsset: 'assets/images/library_white_quartz.png',
    title: l10n.homeYourCrystal,
    route: AppRoutes.fourTemples,
    isCrystalSlot: true,
    stepNumber: 4,
  ),
  _Access(
    semanticsLabel: l10n.homeLibrarySemantics,
    angle: -90 + _orbitStep * 4,
    imageAsset: 'assets/images/harmony_library.png',
    title: l10n.homeLibrary,
    route: AppRoutes.library,
    stepNumber: 5,
  ),
];

/// Shows the assigned crystal for the 30-day protocol and opens the Four
/// Temples map. The caption stays "YOUR CRYSTAL"; the photo and glow change.
_Access _crystalAccess(_Access slot, Crystal? crystal, AppLocalizations l10n) {
  final collection = crystalCollections[crystal];
  if (crystal == null || collection == null) return slot;
  final name = crystal.localizedName(l10n);
  return _Access(
    semanticsLabel: l10n.homeYourCrystalNamedSemantics(name),
    angle: slot.angle,
    imageAsset: collection.imageAsset,
    title: slot.title,
    diameter: slot.diameter,
    route: AppRoutes.fourTemples,
    isCrystalSlot: true,
    stepNumber: slot.stepNumber,
    isHighlighted: true,
  );
}

/// Midpoints of the clockwise arcs between neighboring circles.
List<double> _orbitDotAngles(List<_Access> accesses) => [
  for (final (index, access) in accesses.indexed)
    (access.angle +
            (index + 1 < accesses.length
                ? accesses[index + 1].angle
                : accesses.first.angle + 360)) /
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
  const _Garden({
    required this.scale,
    required this.accesses,
    required this.anchors,
  });

  final double scale;
  final List<_Access> accesses;
  final HomeTourAnchors anchors;

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
                dotAngles: _orbitDotAngles(accesses),
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
              key: _anchorFor(access, anchors),
              access: access,
              scale: scale,
              onPressed: () => context.push(access.route),
            ),
          ),
        Positioned(
          left: 20 * scale,
          right: 20 * scale,
          top: titleTop,
          child: _GardenTitle(anchorKey: anchors.title),
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
    for (final angle in dotAngles) {
      _paintClockwiseArrow(
        canvas,
        _pointOnOrbit(center, radius, angle),
        angle,
        scale,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.center != center ||
      oldDelegate.radius != radius ||
      oldDelegate.scale != scale;
}

/// Gold arrow on the orbit, pointing clockwise (increasing [angle]).
void _paintClockwiseArrow(
  Canvas canvas,
  Offset point,
  double angle,
  double scale,
) {
  final radians = angle * math.pi / 180;
  final direction = Offset(-math.sin(radians), math.cos(radians));
  final normal = Offset(-direction.dy, direction.dx);
  final length = 11 * scale;
  final halfWidth = 4.5 * scale;
  final tip = point + direction * (length * 0.55);
  final tail = point - direction * (length * 0.45);
  final path = Path()
    ..moveTo(tip.dx, tip.dy)
    ..lineTo(tail.dx + normal.dx * halfWidth, tail.dy + normal.dy * halfWidth)
    ..lineTo(tail.dx - normal.dx * halfWidth, tail.dy - normal.dy * halfWidth)
    ..close();
  canvas.drawPath(
    path,
    Paint()
      ..color = AppColors.champagneGold
      ..style = PaintingStyle.fill,
  );
}

class _AccessCircle extends StatelessWidget {
  const _AccessCircle({
    super.key,
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
    final step = access.stepNumber;
    final label = step == null ? access.title : '$step\n${access.title}';

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        textAlign: TextAlign.center,
        softWrap: false,
        style: AppTypography.headline.copyWith(
          color: AppColors.white,
          fontSize: AppFontSizes.s9 * scale,
          height: 1.15,
          letterSpacing: 1.3 * scale,
        ),
      ),
    );
  }
}

Key? _anchorFor(_Access access, HomeTourAnchors anchors) {
  if (access.route == AppRoutes.merkaba) return anchors.merkaba;
  if (access.route == AppRoutes.ritualFace) return anchors.face;
  if (access.route == AppRoutes.ritualBody) return anchors.body;
  if (access.isCrystalSlot) return anchors.crystal;
  if (access.route == AppRoutes.library) return anchors.library;
  return null;
}

class _GardenTitle extends StatelessWidget {
  const _GardenTitle({required this.anchorKey});

  final Key anchorKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return KeyedSubtree(
      key: anchorKey,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 0.9,
            colors: [
              AppColors.black.withValues(alpha: 0.38),
              AppColors.black.withValues(alpha: 0),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: HikaruPageIntro(
            title: l10n.homeGardenTitle,
            subtitle: l10n.homeGardenSubtitle,
          ),
        ),
      ),
    );
  }
}
