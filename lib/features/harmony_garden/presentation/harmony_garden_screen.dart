import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import '../../journey/application/ritual_cycle_controller.dart';
import '../../massage/data/massage_video_source.dart';
import '../../massage/domain/massage_ritual.dart';
import '../../journey/domain/ritual_cycle.dart';
import '../../journey/presentation/cycle_closure_dialog.dart';
import '../../library/domain/library_collection.dart';
import '../../profile/application/ritual_reminders_controller.dart';
import '../data/home_crystal_glow.dart';
import 'home_progress_card.dart';

class HarmonyGardenScreen extends ConsumerStatefulWidget {
  const HarmonyGardenScreen({super.key});

  @override
  ConsumerState<HarmonyGardenScreen> createState() =>
      _HarmonyGardenScreenState();
}

class _HarmonyGardenScreenState extends ConsumerState<HarmonyGardenScreen> {
  GoRouterDelegate? _delegate;

  @override
  void initState() {
    super.initState();
    // Loading the reminders schedules them on the phone, so they work even
    // if the member never opens Profile.
    ref.read(ritualRemindersControllerProvider.future).ignore();
    ref.read(massageVideoSourceProvider).warm(massageVideoWarmOrder);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final delegate = GoRouter.maybeOf(context)?.routerDelegate;
    if (identical(delegate, _delegate)) return;
    _delegate?.removeListener(_handleRouteChanged);
    _delegate = delegate?..addListener(_handleRouteChanged);
  }

  @override
  void dispose() {
    _delegate?.removeListener(_handleRouteChanged);
    super.dispose();
  }

  /// Leaving Home ends the first-visit glow.
  void _handleRouteChanged() {
    final path = _delegate?.currentConfiguration.uri.path;
    if (path != null && path != AppRoutes.home) unawaited(_markGlowSeen());
  }

  Future<void> _markGlowSeen() async {
    if (ref.read(homeCrystalGlowPendingProvider).value != true) return;
    await HomeCrystalGlow(SharedPreferencesAsync()).markSeen();
    if (mounted) ref.invalidate(homeCrystalGlowPendingProvider);
  }

  /// The cycle the closing offer was shown for, so "Decide later" does not
  /// reopen it on every rebuild. It comes back the next time the app opens.
  String? _closureOfferedFor;

  void _maybeOfferClosure(RitualCycle? awaiting) {
    if (awaiting == null || _closureOfferedFor == awaiting.id) return;
    _closureOfferedFor = awaiting.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(showCycleClosureDialog(context, ref));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _maybeOfferClosure(ref.watch(cycleAwaitingClosureProvider));
    final crystal = ref.watch(selectedCrystalProvider).value;
    final glowPending =
        ref.watch(homeCrystalGlowPendingProvider).value ?? false;
    final baseAccesses = _buildAccesses(l10n);
    final accesses = [
      for (final access in baseAccesses)
        access.isCrystalSlot ? _crystalAccess(access, crystal, l10n) : access,
    ];

    return HikaruShell(
      active: HikaruDestination.home,
      backgroundScale: _homeBackgroundScale,
      backgroundOffsetY: _homeBackgroundOffsetY,
      builder: (context, scale) => _Garden(
        scale: scale,
        accesses: accesses,
        pulseCrystal: glowPending,
        onAccessPressed: (access) {
          if (access.isCrystalSlot) unawaited(_markGlowSeen());
          context.push(access.route);
        },
      ),
    );
  }
}

/// Diameter of the access circles on Home, in design pixels. All five
/// circles share this size, Merkaba included.
const double homeCircleDiameter = 96;

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

  /// Recommended journey order: 1 Merkaba → 2 Ritual → 3 Crystal.
  final int? stepNumber;
}

/// Clockwise from the top: Merkaba, Ritual Face, Ritual Body, Your Crystal,
/// Library. Numbered 1–5 in that same order.
///
/// Merkaba is a proper name and stays the same in every language.
List<_Access> _buildAccesses(AppLocalizations l10n) => [
  const _Access(
    semanticsLabel: 'Merkaba',
    angle: -90,
    imageAsset: 'assets/images/library_merkaba.png',
    title: 'MERKABA',
    route: AppRoutes.merkaba,
    stepNumber: 1,
  ),
  _Access(
    semanticsLabel: l10n.homeRitualFaceSemantics,
    angle: -25,
    imageAsset: 'assets/images/home/home_face.jpg',
    title: l10n.homeRitualFace,
    route: AppRoutes.ritualFace,
    stepNumber: 2,
  ),
  _Access(
    semanticsLabel: l10n.homeRitualBodySemantics,
    angle: 25,
    imageAsset: 'assets/images/home/home_body.jpg',
    title: l10n.homeRitualBody,
    route: AppRoutes.ritualBody,
    stepNumber: 3,
  ),
  _Access(
    semanticsLabel: l10n.homeYourCrystalSemantics,
    angle: 155,
    imageAsset: 'assets/images/library_white_quartz.png',
    title: l10n.homeYourCrystal,
    route: AppRoutes.fourTemples,
    isCrystalSlot: true,
    stepNumber: 4,
  ),
  _Access(
    semanticsLabel: l10n.homeLibrarySemantics,
    angle: 205,
    imageAsset: 'assets/images/harmony_library.png',
    title: l10n.homeLibrary,
    route: AppRoutes.library,
    stepNumber: 5,
  ),
];

/// Shows the recommended crystal and opens the Four Temples map so the user
/// can explore all four, with theirs highlighted.
_Access _crystalAccess(_Access slot, Crystal? crystal, AppLocalizations l10n) {
  final collection = crystalCollections[crystal];
  if (crystal == null || collection == null) return slot;
  final name = crystal.localizedName(l10n);
  return _Access(
    semanticsLabel: l10n.homeYourCrystalNamedSemantics(name),
    angle: slot.angle,
    imageAsset: collection.imageAsset,
    title: name,
    diameter: slot.diameter,
    route: AppRoutes.fourTemples,
    isCrystalSlot: true,
    stepNumber: slot.stepNumber,
    isHighlighted: true,
  );
}

/// Midpoint and tangent direction of each clockwise arc between neighboring
/// circles. There is no arrow from Library back to Merkaba: Library is last,
/// so that gap keeps the plain light point.
List<({double angle, double heading})> _orbitArrows(List<_Access> accesses) => [
  for (var index = 0; index < accesses.length - 1; index++)
    (
      angle: (accesses[index].angle + accesses[index + 1].angle) / 2,
      heading: (accesses[index].angle + accesses[index + 1].angle) / 2 + 90,
    ),
];

/// Plain light point between Library and Merkaba, where the orbit has no
/// arrow because Library is the last stop.
double _finalOrbitDotAngle(List<_Access> accesses) =>
    (accesses.last.angle + (accesses.first.angle + 360)) / 2;

Offset _pointOnOrbit(Offset center, double radius, double degrees) {
  final radians = degrees * math.pi / 180;
  return center + Offset(math.cos(radians), math.sin(radians)) * radius;
}

/// Where the shell draws the garden background on a screen of [size].
const double _homeBackgroundScale = 1.06;
const double _homeBackgroundOffsetY = -18;

Rect _backgroundRect(Size size, double scale) {
  final fit = math.max(
    size.width / _backgroundSize.width,
    size.height / _backgroundSize.height,
  );
  final width = _backgroundSize.width * fit;
  final height = _backgroundSize.height * fit;
  final base = Rect.fromLTWH(
    (size.width - width) / 2,
    (size.height - height) / 2,
    width,
    height,
  );
  return Rect.fromCenter(
    center: base.center + Offset(0, _homeBackgroundOffsetY * scale),
    width: base.width * _homeBackgroundScale,
    height: base.height * _homeBackgroundScale,
  );
}

class _Garden extends StatelessWidget {
  const _Garden({
    required this.scale,
    required this.accesses,
    required this.pulseCrystal,
    required this.onAccessPressed,
  });

  final double scale;
  final List<_Access> accesses;

  /// Whether the crystal circle should pulse: the first Home visit after
  /// the crystal reveal, until tapped or Home is left.
  final bool pulseCrystal;
  final ValueChanged<_Access> onAccessPressed;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = HikaruShell.designWidth * scale;
    final radius = _orbitRadius * scale;
    final background = _backgroundRect(media.size, scale);
    final contentTop = media.padding.top + HikaruHeader.height * scale;
    final merkabaRadius = homeCircleDiameter * scale / 2;
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
    final titleCandidate = math.max(
      background.top + background.height * _titleTopShare,
      lowestCircleBottom,
    );
    final navTop =
        media.size.height - HikaruNavigationBar.height - media.padding.bottom;
    final compact = media.size.height < 700;
    final estimatedCardHeight = (compact ? 112 : 122) * scale;
    final estimatedTitleHeight = (compact ? 54 : 66) * scale;
    final titleTop = math.min(
      titleCandidate,
      navTop - estimatedCardHeight - estimatedTitleHeight - AppSpacing.s16,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _OrbitPainter(
                center: center,
                radius: radius,
                arrows: _orbitArrows(accesses),
                dotAngle: _finalOrbitDotAngle(accesses),
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
              pulsing:
                  pulseCrystal && access.isCrystalSlot && access.isHighlighted,
              onPressed: () => onAccessPressed(access),
            ),
          ),
        Positioned(
          left: AppSpacing.s20 * scale,
          right: AppSpacing.s20 * scale,
          top: titleTop,
          child: _GardenTitle(compact: compact),
        ),
        Positioned(
          left: AppSpacing.s12 * scale,
          right: AppSpacing.s12 * scale,
          bottom:
              HikaruNavigationBar.height +
              media.padding.bottom +
              AppSpacing.s10 * scale,
          child: HomeProgressCard(scale: scale, compact: compact),
        ),
      ],
    );
  }
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({
    required this.center,
    required this.radius,
    required this.arrows,
    required this.dotAngle,
    required this.scale,
  });

  /// Midpoint and tangent heading of each clockwise arc that gets an arrow.
  final Offset center;
  final double radius;
  final List<({double angle, double heading})> arrows;

  /// The one remaining gap, marked with a plain light point instead of an
  /// arrow (Library is the last stop; there is no arrow back to Merkaba).
  final double dotAngle;
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
    final dotPoint = _pointOnOrbit(center, radius, dotAngle);
    canvas.drawCircle(dotPoint, 3.2 * scale, glow);
    canvas.drawCircle(dotPoint, 1.3 * scale, core);

    final arrowFill = Paint()..color = AppColors.champagneGold;
    for (final arrow in arrows) {
      _drawArrow(canvas, arrowFill, arrow.angle, arrow.heading);
    }
  }

  /// A small gold chevron at the arc midpoint, pointing clockwise along the
  /// orbit's tangent.
  void _drawArrow(Canvas canvas, Paint paint, double angle, double heading) {
    const double length = 5;
    const double halfWidth = 3.4;
    final point = _pointOnOrbit(center, radius, angle);
    final direction = heading * math.pi / 180;
    final forward =
        Offset(math.cos(direction), math.sin(direction)) * length * scale;
    final side =
        Offset(
          math.cos(direction + math.pi / 2),
          math.sin(direction + math.pi / 2),
        ) *
        halfWidth *
        scale;

    final path = Path()
      ..moveTo(point.dx + forward.dx, point.dy + forward.dy)
      ..lineTo(point.dx - forward.dx + side.dx, point.dy - forward.dy + side.dy)
      ..lineTo(point.dx - forward.dx - side.dx, point.dy - forward.dy - side.dy)
      ..close();
    canvas.drawPath(path, paint);
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
    required this.pulsing,
    required this.onPressed,
  });

  /// Share of the circle height covered by the image before it fades into
  /// the indigo base. Same for every circle, artwork and photographs alike.
  static const double _photoShare = 0.62;

  final _Access access;
  final double scale;

  /// First-visit pulse, drawn on top of the usual highlighted glow.
  final bool pulsing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _GlowPulse(
      active: pulsing,
      scale: scale,
      child: _buildCircle(context),
    );
  }

  Widget _buildCircle(BuildContext context) {
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
            color: AppColors.indigoBlue,
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
                        colors: [AppColors.transparent, AppColors.indigoBlue],
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

/// Soft breathing halo behind a circle. With reduce motion it stays still at
/// a steady, brighter glow instead of pulsing.
class _GlowPulse extends StatefulWidget {
  const _GlowPulse({
    required this.active,
    required this.scale,
    required this.child,
  });

  static const Duration _period = Duration(milliseconds: 1800);

  /// Finite breaths so the animation settles on its own (and so
  /// `pumpAndSettle` never waits on it) instead of pulsing forever until the
  /// user happens to tap or leave.
  static const int _breaths = 4;

  final bool active;
  final double scale;
  final Widget child;

  @override
  State<_GlowPulse> createState() => _GlowPulseState();
}

class _GlowPulseState extends State<_GlowPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _GlowPulse._period,
  );
  bool _reduceMotion = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _sync();
  }

  @override
  void didUpdateWidget(_GlowPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.active && !_reduceMotion) {
      if (!_started) {
        _started = true;
        unawaited(
          _controller.repeat(reverse: true, count: _GlowPulse._breaths * 2),
        );
      }
    } else {
      if (!widget.active) _started = false;
      _controller
        ..stop()
        ..value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    final scale = widget.scale;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.splashHighlight.withValues(
                  alpha: 0.3 + 0.5 * t,
                ),
                blurRadius: (16 + 16 * t) * scale,
                spreadRadius: (1 + 4 * t) * scale,
              ),
            ],
          ),
          child: child,
        );
      },
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

class _GardenTitle extends StatelessWidget {
  const _GardenTitle({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 0.9,
          colors: [
            AppColors.indigoBlue.withValues(alpha: 0.5),
            AppColors.indigoBlue.withValues(alpha: 0),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: compact ? AppSpacing.s8 : AppSpacing.s14,
        ),
        child: HikaruPageIntro(
          title: l10n.homeGardenTitle,
          subtitle: l10n.homeGardenSubtitle,
        ),
      ),
    );
  }
}
