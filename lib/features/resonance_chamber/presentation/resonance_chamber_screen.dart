import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../core/media/remote_image.dart';
import '../../../core/media/remote_image_prefetch.dart';
import '../../../core/media/remote_image_store.dart';
import '../../../core/router/app_routes.dart';
import '../../splash/data/launch_gate.dart';
import '../../crystals/application/selected_crystal_controller.dart';
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
  static const double _heroScreenRatio = 0.3;
  static const double _minHeroHeight = 200;
  static const double _maxHeroHeight = 300;

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
          SizedBox(height: insets.top + AppSpacing.s16),
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
                    const SizedBox(height: AppSpacing.s20),
                    _RitualTitle(title: l10n.resonanceDailyRitual),
                    const SizedBox(height: AppSpacing.s16),
                    _DailyRitualSteps(recommendation: recommendation),
                  ],
                  const SizedBox(height: AppSpacing.s24),
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
  await LaunchGate(SharedPreferencesAsync()).markCrystalRevealed();
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
            fontSize: AppFontSizes.s25,
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
        fontSize: AppFontSizes.s20,
        letterSpacing: 0.6,
      ),
    );
  }
}

/// 0..1 smooth wave, [speed] cycles per loop, shifted by [offset].
double _wave(double phase, double speed, [double offset = 0]) =>
    0.5 + 0.5 * math.sin(2 * math.pi * (phase * speed + offset));

/// 0..1 position of a light sweep that rests for the second half of the loop.
double _sheenAt(double phase, double offset) => Curves.easeInOut.transform(
  const Interval(0, 0.55).transform((phase + offset) % 1),
);

/// The four daily steps as a vertical timeline on a gold thread that flows.
/// The first step is the featured card, the rest follow as quieter cards.
class _DailyRitualSteps extends StatefulWidget {
  const _DailyRitualSteps({required this.recommendation});

  final JourneyRecommendation recommendation;

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
        offset: Offset(0, 26 * (1 - t)),
        child: Transform.scale(scale: 0.94 + 0.06 * t, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = [
      (
        RitualStep.merkaba,
        l10n.resonanceStepMerkaba,
        l10n.resonanceStepMerkabaDetail,
      ),
      (
        RitualStep.facial,
        l10n.resonanceStepFacial,
        l10n.recommendationFacialRitual(widget.recommendation.facialRitual),
      ),
      (RitualStep.body, l10n.resonanceStepBody, null),
      (RitualStep.crystal, l10n.resonanceStepCrystal, null),
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
  });

  final int index;
  final RitualStep step;
  final String name;
  final String? detail;
  final bool isLast;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final extra = detail;
    final number = index + 1;
    final featured = index == 0;
    final card = featured
        ? _FeaturedStepCard(
            number: number,
            step: step,
            name: name,
            detail: extra,
            phase: phase,
          )
        : _StepCard(
            index: index,
            number: number,
            step: step,
            name: name,
            detail: extra,
            phase: phase,
          );

    return Semantics(
      label: extra == null ? '$number. $name' : '$number. $name, $extra',
      excludeSemantics: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 24,
              child: _TimelineRail(index: index, isLast: isLast, phase: phase),
            ),
            const SizedBox(width: AppSpacing.s10),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.s14),
                child: card,
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
    final featured = index == 0;
    final pulse = (phase * 2 + index * 0.25) % 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 22),
        SizedBox(
          height: 28,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 18 + (featured ? 22 : 12) * pulse,
                height: 18 + (featured ? 22 : 12) * pulse,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.champagneGold.withValues(
                      alpha: (featured ? 0.6 : 0.3) * (1 - pulse),
                    ),
                  ),
                ),
              ),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: featured
                      ? const RadialGradient(
                          colors: [AppColors.goldGlow, AppColors.champagneGold],
                        )
                      : null,
                  color: featured ? null : AppColors.darkIndigoBlue,
                  border: Border.all(
                    color: AppColors.champagneGold.withValues(
                      alpha: featured ? 1 : 0.6,
                    ),
                    width: 1.6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldGlow.withValues(
                        alpha:
                            (featured ? 0.5 : 0.18) *
                            (0.6 + 0.4 * _wave(phase, 2, index * 0.25)),
                      ),
                      blurRadius: featured ? 14 : 8,
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
      ..strokeWidth = 2
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
      5,
      Paint()
        ..color = glow.withValues(alpha: 0.5 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      center,
      2,
      Paint()..color = glow.withValues(alpha: 0.95 * fade),
    );
  }

  @override
  bool shouldRepaint(_FlowingThreadPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.color != color;
}

/// A soft band of light that crosses its parent.
class _Sheen extends StatelessWidget {
  const _Sheen({required this.position, required this.alpha});

  final double position;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment(-1.8 + 3.6 * position, 0),
          child: FractionallySizedBox(
            widthFactor: 0.35,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.white.withValues(alpha: 0),
                    AppColors.white.withValues(alpha: alpha),
                    AppColors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EqualizerBars extends StatelessWidget {
  const _EqualizerBars({required this.phase, required this.color});

  final double phase;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var bar = 0; bar < 4; bar++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Container(
                width: 3.5,
                height: 6 + 14 * _wave(phase, 4, bar * 0.23),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The step to do first: a warm gold card with drifting light, floating
/// sparkles and a live sound-wave badge.
class _FeaturedStepCard extends StatelessWidget {
  const _FeaturedStepCard({
    required this.number,
    required this.step,
    required this.name,
    required this.phase,
    this.detail,
  });

  final int number;
  final RitualStep step;
  final String name;
  final String? detail;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final extra = detail;
    const ink = AppColors.darkIndigoBlue;
    final bob = math.sin(2 * math.pi * phase * 2);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldGlow.withValues(
              alpha: 0.12 + 0.16 * _wave(phase, 2),
            ),
            blurRadius: 26,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(0.5 * math.sin(2 * math.pi * phase)),
              colors: const [
                AppColors.champagneGold40,
                AppColors.champagneGold,
                AppColors.matteChampagne60,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -6 + 4 * bob,
                bottom: -20 + 6 * bob,
                child: Transform.rotate(
                  angle: 0.07 * bob,
                  child: RitualStepIcon(
                    step: step,
                    size: 130,
                    color: ink.withValues(alpha: 0.14),
                  ),
                ),
              ),
              for (var k = 0; k < 5; k++)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Builder(
                      builder: (context) {
                        final p = (phase * 2 + k * 0.2) % 1;
                        return Align(
                          alignment: Alignment(-0.7 + k * 0.38, 0.95 - 1.9 * p),
                          child: Container(
                            width: 3 + (k % 2) * 2.0,
                            height: 3 + (k % 2) * 2.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white.withValues(
                                alpha: 0.75 * math.sin(math.pi * p),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.white.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              _Sheen(position: _sheenAt(phase, 0), alpha: 0.32),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s20,
                  AppSpacing.s20,
                  64,
                  AppSpacing.s24,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s12,
                          vertical: AppSpacing.s4,
                        ),
                        decoration: BoxDecoration(
                          color: ink.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '0$number',
                          style: AppTypography.subheadline.copyWith(
                            color: ink,
                            fontSize: AppFontSizes.s11,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s14),
                      Text(
                        name,
                        style: AppTypography.title.copyWith(
                          color: ink,
                          fontSize: AppFontSizes.s25,
                          height: 1.05,
                        ),
                      ),
                      if (extra != null) ...[
                        const SizedBox(height: AppSpacing.s10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule, size: 16, color: ink),
                            const SizedBox(width: AppSpacing.s6),
                            Text(
                              extra,
                              style: AppTypography.body.copyWith(
                                color: ink,
                                fontSize: AppFontSizes.s13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.s16,
                right: AppSpacing.s16,
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ink.withValues(alpha: 0.14),
                  ),
                  child: _EqualizerBars(phase: phase, color: ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.number,
    required this.step,
    required this.name,
    required this.phase,
    this.detail,
  });

  final int index;
  final int number;
  final RitualStep step;
  final String name;
  final String? detail;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final extra = detail;
    final glow = _wave(phase, 2, index * 0.25);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s16,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.champagneGold.withValues(alpha: 0.12),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.65),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.champagneGold.withValues(
                  alpha: 0.28 + 0.14 * glow,
                ),
                width: 0.9,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.champagneGold.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.champagneGold.withValues(alpha: 0.75),
                      width: 0.9,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldGlow.withValues(
                          alpha: 0.08 + 0.22 * glow,
                        ),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Transform.scale(
                    scale: 0.94 + 0.12 * glow,
                    child: RitualStepIcon(step: step, size: 24),
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.headline.copyWith(
                          color: AppColors.white,
                          fontSize: AppFontSizes.s16,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (extra != null) ...[
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          extra,
                          style: AppTypography.body.copyWith(
                            color: AppColors.fog.withValues(alpha: 0.85),
                            fontSize: AppFontSizes.s12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  '0$number',
                  style: AppTypography.title.copyWith(
                    color: AppColors.champagneGold.withValues(alpha: 0.85),
                    fontSize: AppFontSizes.s20,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          _Sheen(position: _sheenAt(phase, index * 0.18), alpha: 0.1),
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
            fontSize: AppFontSizes.s28,
            letterSpacing: 2.4,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
