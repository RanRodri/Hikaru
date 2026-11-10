import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../core/media/remote_image.dart';
import '../../../core/media/remote_image_prefetch.dart';
import '../../../core/media/remote_image_store.dart';
import '../../../core/router/app_routes.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../massage/domain/massage_ritual.dart';
import '../../merkaba/domain/merkaba_session.dart';
import '../../profile/data/user_profile_gateway.dart';
import '../application/crystal_track_duration.dart';
import '../../listening_room/application/journey_recommendation_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../crystals/presentation/crystal_texts.dart';
import '../../listening_room/domain/journey_recommendation.dart';
import '../../journey/domain/ritual_cycle.dart' show RitualStep;
import '../../journey/presentation/ritual_step_texts.dart';
import 'crystal_cymatic_portrait.dart';
import 'crystal_scene_photo.dart';
import 'resonance_sections.dart';

/// Post-quiz revelation: the 30-day protocol, the crystal surrounded by its
/// moving cymatics (touch makes the light swell), and the daily ritual.
///
/// No frequency audio plays on this screen.
class ResonanceChamberScreen extends ConsumerWidget {
  const ResonanceChamberScreen({super.key});

  static const double _horizontalPadding = 24;
  static const double _heroScreenRatio = 0.46;
  static const double _minHeroHeight = 280;
  static const double _maxHeroHeight = 440;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final insets = mediaQuery.padding;
    final heroHeight = (mediaQuery.size.height * _heroScreenRatio).clamp(
      _minHeroHeight,
      _maxHeroHeight,
    );
    final recommendation = _resolveRecommendation(ref);
    warmRemoteImages(ref.read(remoteImageCacheProvider), RemoteImages.homeTabs);

    final crystal = recommendation?.crystal;

    return Scaffold(
      backgroundColor: resonanceChamberColor,
      body: Column(
        children: [
          SizedBox(height: insets.top + AppSpacing.s8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: _ProtocolHeadline(),
          ),
          const SizedBox(height: AppSpacing.s8),
          SizedBox(
            width: double.infinity,
            height: heroHeight,
            child: crystal == null
                ? const CrystalScenePhoto(crystal: null)
                : CrystalCymaticPortrait(
                    crystal: crystal,
                    interactive: true,
                    touchSemanticLabel: l10n.resonanceCrystalTouchHint,
                  ),
          ),
          if (crystal != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s4),
              child: ExcludeSemantics(
                child: Text(
                  l10n.resonanceCrystalTouchHint,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.fog.withValues(alpha: 0.75),
                    fontSize: AppFontSizes.s11,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s12,
                AppSpacing.s8,
                AppSpacing.s12,
                math.max(AppSpacing.s16, insets.bottom + AppSpacing.s8),
              ),
              child: Column(
                children: [
                  if (recommendation != null)
                    _CrystalName(recommendation: recommendation)
                  else
                    const _MissingCrystal(),
                  if (recommendation != null) ...[
                    const SizedBox(height: AppSpacing.s12),
                    _RitualTitle(title: l10n.resonanceDailyRitual),
                    const SizedBox(height: AppSpacing.s10),
                    _DailyRitualSteps(
                      recommendation: recommendation,
                      crystalTrack: ref
                          .watch(
                            crystalTrackDurationProvider(
                              recommendation.crystal,
                            ),
                          )
                          .value,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s12,
                    ),
                    child: HikaruPillButton(
                      label: l10n.resonanceEnterSanctuary,
                      onPressed: () => _enterSanctuary(context, ref),
                      buttonHeight: AppSpacing.s56,
                      blurRadius: 8,
                      shadowAlpha: 0.25,
                      borderAlpha: 0.3,
                      labelStyle: AppTypography.journeyLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _enterSanctuary(BuildContext context, WidgetRef ref) async {
  await prepareHomeBackground(ref.read(remoteImageCacheProvider));
  // The form is already saved. Seeing this screen and entering is the reveal.
  await ref.read(userProfileGatewayProvider).markCrystalRevealed();
  if (!context.mounted) return;
  context.go(AppRoutes.home);
}

JourneyRecommendation? _resolveRecommendation(WidgetRef ref) {
  final saved = ref.watch(journeyRecommendationControllerProvider).value;
  if (saved != null) return saved;

  final crystal = ref.watch(selectedCrystalProvider).value;
  if (crystal == null) return null;
  return fallbackRecommendation(crystal);
}

/// The announcement at the top: this is the plan for the next 30 days, with
/// the reveal as a gold line under it.
class _ProtocolHeadline extends StatelessWidget {
  const _ProtocolHeadline();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Text(
          l10n.resonanceProtocolHeadline,
          textAlign: TextAlign.center,
          style: AppTypography.title.copyWith(
            color: AppColors.white,
            fontSize: AppFontSizes.s18,
            fontWeight: FontWeight.w500,
            height: 1.15,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${l10n.resonanceRevealTitle} ${l10n.resonanceRevealSubtitle}',
            maxLines: 1,
            style: AppTypography.headline.copyWith(
              color: AppColors.champagneGold,
              fontSize: AppFontSizes.s11,
              letterSpacing: 2.2,
            ),
          ),
        ),
      ],
    );
  }
}

/// Centered section title.
class _RitualTitle extends StatelessWidget {
  const _RitualTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: AppTypography.title.copyWith(
        color: AppColors.champagneGold,
        fontSize: AppFontSizes.s15,
        letterSpacing: 0.8,
      ),
    );
  }
}

/// 0..1 smooth wave, [speed] cycles per loop, shifted by [offset].
double _wave(double phase, double speed, [double offset = 0]) =>
    0.5 + 0.5 * math.sin(2 * math.pi * (phase * speed + offset));

/// The four daily steps as a fine vertical timeline. Each card carries the
/// length of that practice so the protocol reads as a light list under the
/// crystal.
class _DailyRitualSteps extends StatefulWidget {
  const _DailyRitualSteps({
    required this.recommendation,
    required this.crystalTrack,
  });

  final JourneyRecommendation recommendation;
  final Duration? crystalTrack;

  @override
  State<_DailyRitualSteps> createState() => _DailyRitualStepsState();
}

class _DailyRitualStepsState extends State<_DailyRitualSteps>
    with TickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 6000),
  );
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _enter.value = 1;
      return;
    }
    _enter.forward();
    _loop.repeat();
  }

  @override
  void dispose() {
    _enter.dispose();
    _loop.dispose();
    super.dispose();
  }

  Widget _appear(int index, Widget child) {
    final start = index * 0.15;
    final t = Curves.easeOutBack.transform(
      Interval(start, start + 0.5).transform(_enter.value),
    );
    return Opacity(
      opacity: t.clamp(0, 1),
      child: Transform.translate(
        offset: Offset(0, 12 * (1 - t)),
        child: Transform.scale(scale: 0.94 + 0.06 * t, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final track = widget.crystalTrack;
    final steps = [
      (
        RitualStep.merkaba,
        l10n.resonanceStepMerkaba,
        null,
        formatTrackDuration(merkabaDuration),
      ),
      (
        RitualStep.facial,
        l10n.resonanceStepFacial,
        l10n.recommendationFacialRitual(widget.recommendation.facialRitual),
        formatTrackDuration(faceRitual.videoDuration),
      ),
      (
        RitualStep.body,
        l10n.resonanceStepBody,
        null,
        formatTrackDuration(bodyRitual.videoDuration),
      ),
      (
        RitualStep.crystal,
        l10n.resonanceStepCrystal,
        null,
        track == null ? null : formatTrackDuration(track),
      ),
    ];

    return AnimatedBuilder(
      animation: Listenable.merge([_enter, _loop]),
      builder: (context, _) => Column(
        children: [
          for (final (index, step) in steps.indexed)
            _appear(
              index,
              _TimelineRow(
                index: index,
                step: step.$1,
                name: step.$2,
                detail: step.$3,
                duration: step.$4,
                isLast: index == steps.length - 1,
                phase: _loop.value,
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.index,
    required this.step,
    required this.name,
    required this.isLast,
    required this.phase,
    this.detail,
    this.duration,
  });

  final int index;
  final RitualStep step;
  final String name;
  final String? detail;
  final String? duration;
  final bool isLast;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final extra = detail;
    final length = duration;
    final number = index + 1;
    final spoken = [
      '$number. $name',
      if (extra != null) extra,
      if (length != null) length,
    ].join(', ');

    return Semantics(
      label: spoken,
      excludeSemantics: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 16,
              child: _TimelineRail(index: index, isLast: isLast, phase: phase),
            ),
            const SizedBox(width: AppSpacing.s8),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.s8),
                child: _StepCard(
                  index: index,
                  step: step,
                  name: name,
                  detail: extra,
                  duration: length,
                  phase: phase,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineRail extends StatelessWidget {
  const _TimelineRail({
    required this.index,
    required this.isLast,
    required this.phase,
  });

  final int index;
  final bool isLast;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final pulse = (phase * 2 + index * 0.25) % 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 16,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 8 + 8 * pulse,
                height: 8 + 8 * pulse,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.champagneGold.withValues(
                      alpha: 0.28 * (1 - pulse),
                    ),
                  ),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkIndigoBlue,
                  border: Border.all(
                    color: AppColors.champagneGold.withValues(alpha: 0.7),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldGlow.withValues(
                        alpha:
                            0.16 * (0.6 + 0.4 * _wave(phase, 2, index * 0.25)),
                      ),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: CustomPaint(
                painter: _FlowingThreadPainter(
                  color: AppColors.champagneGold.withValues(alpha: 0.4),
                  glow: AppColors.goldGlow,
                  phase: phase,
                  index: index,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Dashed gold thread whose dashes drift downwards, with a small light
/// travelling along it from one step to the next.
class _FlowingThreadPainter extends CustomPainter {
  const _FlowingThreadPainter({
    required this.color,
    required this.glow,
    required this.phase,
    required this.index,
  });

  final Color color;
  final Color glow;
  final double phase;
  final int index;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    final x = size.width / 2;
    var y = -10 + 10 * ((phase * 6) % 1);
    while (y < size.height) {
      final from = math.max(y, 0.0);
      final to = math.min(y + 4, size.height);
      if (to > from) canvas.drawLine(Offset(x, from), Offset(x, to), paint);
      y += 10;
    }

    final travel = (phase * 2 + index * 0.2) % 1;
    final center = Offset(x, size.height * travel);
    final fade = math.sin(math.pi * travel);
    canvas.drawCircle(
      center,
      3,
      Paint()
        ..color = glow.withValues(alpha: 0.45 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      center,
      1.4,
      Paint()..color = glow.withValues(alpha: 0.9 * fade),
    );
  }

  @override
  bool shouldRepaint(_FlowingThreadPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.color != color;
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.step,
    required this.name,
    required this.phase,
    this.detail,
    this.duration,
  });

  final int index;
  final RitualStep step;
  final String name;
  final String? detail;
  final String? duration;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final extra = detail;
    final length = duration;
    final glow = _wave(phase, 2, index * 0.25);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkIndigoBlue.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.22 + 0.12 * glow),
          width: 0.6,
        ),
      ),
      child: Row(
        children: [
          RitualStepIcon(
            step: step,
            size: 16,
            color: AppColors.champagneGold.withValues(alpha: 0.9),
          ),
          const SizedBox(width: AppSpacing.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.headline.copyWith(
                    color: AppColors.white,
                    fontSize: AppFontSizes.s13,
                    letterSpacing: 0.2,
                    height: 1.15,
                  ),
                ),
                if (extra != null) ...[
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    extra,
                    style: AppTypography.body.copyWith(
                      color: AppColors.fog.withValues(alpha: 0.75),
                      fontSize: AppFontSizes.s11,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (length != null) ...[
            const SizedBox(width: AppSpacing.s8),
            Text(
              length,
              style: AppTypography.subheadline.copyWith(
                color: AppColors.champagneGold.withValues(alpha: 0.9),
                fontSize: AppFontSizes.s11,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MissingCrystal extends StatelessWidget {
  const _MissingCrystal();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context).resonanceMissingCrystal,
      textAlign: TextAlign.center,
      style: AppTypography.headline.copyWith(
        color: AppColors.fog,
        fontSize: AppFontSizes.s12,
        height: 1.5,
        letterSpacing: 0,
      ),
    );
  }
}

/// "YOUR CRYSTAL" and its name. The crystal theory lives in the Library.
class _CrystalName extends StatelessWidget {
  const _CrystalName({required this.recommendation});

  final JourneyRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final crystal = recommendation.crystal;

    return Column(
      children: [
        Text(
          l10n.resonanceYourCrystal,
          textAlign: TextAlign.center,
          style: AppTypography.subheadline.copyWith(
            color: AppColors.fog,
            fontSize: AppFontSizes.s11,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: AppSpacing.s6),
        Text(
          crystal.localizedName(l10n),
          textAlign: TextAlign.center,
          semanticsLabel: l10n.resonanceAssignedCrystalSemantics(
            crystal.localizedName(l10n),
          ),
          style: AppTypography.title.copyWith(
            color: AppColors.champagneGold,
            fontSize: AppFontSizes.s22,
            letterSpacing: 1.8,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
