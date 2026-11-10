import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/merkaba_session.dart';
import 'merkaba_painter.dart';
import 'merkaba_texts.dart';

/// Width / height of the pre-rendered video (720 x 1280).
const double merkabaVideoAspect = 720 / 1280;

/// Where the figure's heart sits inside the video frame, as a share of its
/// width and height. The video spans the full screen width, so the screen
/// position is derived from this.
const Offset merkabaVideoHeartAnchor = Offset(0.5, 0.57);

/// Soft gold circle of light over the heart.
///
/// It grows on the inhale, stays full and shimmers on the hold and shrinks on
/// the exhale. It repaints from [elapsed] alone, so the screen around it is
/// never rebuilt.
class MerkabaBreathOrb extends StatelessWidget {
  const MerkabaBreathOrb({
    super.key,
    required this.elapsed,
    required this.reduceMotion,
  });

  final ValueListenable<Duration> elapsed;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: MerkabaBreathOrbPainter(
            elapsed: elapsed,
            reduceMotion: reduceMotion,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class MerkabaBreathOrbPainter extends CustomPainter {
  MerkabaBreathOrbPainter({required this.elapsed, required this.reduceMotion})
    : super(repaint: elapsed);

  final ValueListenable<Duration> elapsed;
  final bool reduceMotion;

  /// Orb radius at rest and when full, as a share of the screen width.
  /// It stays close to the heart so it reads as light, not as a UI control.
  static const double _minRadius = 0.07;
  static const double _maxRadius = 0.18;

  /// Seconds between very gentle light variations while the breath is held.
  static const double _shimmerSeconds = 3.2;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final frame = merkabaFrameAt(elapsed.value);
    final level = reduceMotion ? merkabaRestingBreath : frame.breathLevel;
    final eased = Curves.easeInOutSine.transform(level.clamp(0.0, 1.0));
    final shimmer = frame.phase == BreathPhase.hold && !reduceMotion
        ? 0.5 +
              0.5 *
                  math.sin(
                    frame.phaseElapsed.inMilliseconds /
                        1000 *
                        2 *
                        math.pi /
                        _shimmerSeconds,
                  )
        : 0.0;

    // The video is as wide as the screen and centered vertically.
    final videoHeight = size.width / merkabaVideoAspect;
    final videoTop = (size.height - videoHeight) / 2;
    final center = Offset(
      size.width * merkabaVideoHeartAnchor.dx,
      videoTop + videoHeight * merkabaVideoHeartAnchor.dy,
    );
    final radius =
        size.width * (_minRadius + (_maxRadius - _minRadius) * eased);
    final alpha = 0.07 + 0.15 * eased + 0.025 * shimmer;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.champagneGold.withValues(alpha: alpha),
            AppColors.champagneGold.withValues(alpha: alpha * 0.4),
            AppColors.champagneGold.withValues(alpha: 0),
          ],
          stops: const [0, 0.55, 1],
        ).createShader(rect),
    );
    canvas.drawCircle(
      center,
      radius * 0.62,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = AppColors.champagneGold.withValues(
          alpha: 0.07 + 0.1 * eased + 0.035 * shimmer,
        ),
    );
  }

  @override
  bool shouldRepaint(covariant MerkabaBreathOrbPainter oldDelegate) =>
      oldDelegate.elapsed != elapsed ||
      oldDelegate.reduceMotion != reduceMotion;
}

/// A light bottom scrim keeps controls legible while leaving the star field
/// open. There are deliberately no border lines around the sanctuary.
class MerkabaSanctuaryFrame extends StatelessWidget {
  const MerkabaSanctuaryFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: RepaintBoundary(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x1F0A0B17),
                AppColors.transparent,
                AppColors.transparent,
                Color(0x8A0A0B17),
              ],
              stops: [0, 0.13, 0.67, 1],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mudra of the current scene, fading when it changes.
class MerkabaMudraTitle extends StatelessWidget {
  const MerkabaMudraTitle({
    super.key,
    required this.sceneIndex,
    required this.reduceMotion,
  });

  final ValueListenable<int> sceneIndex;
  final bool reduceMotion;

  static const Duration fade = Duration(milliseconds: 900);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: sceneIndex,
      builder: (context, index, _) {
        final scene = merkabaScenes[index.clamp(0, merkabaScenes.length - 1)];
        return _FadeSwitch<String>(
          value: scene.mudra,
          duration: reduceMotion ? Duration.zero : fade,
          child: Semantics(
            header: true,
            label: '${scene.mudra}. ${l10n.merkabaScenePurpose(scene)}',
            excludeSemantics: true,
            child: Text(
              scene.mudra.replaceFirst(' Mudra', ''),
              textAlign: TextAlign.center,
              style: AppTypography.headline.copyWith(
                color: AppColors.champagneGold.withValues(alpha: 0.88),
                fontSize: AppFontSizes.s16,
                letterSpacing: 4,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// "Inhale", "Hold" or "Exhale", fading between phases.
class MerkabaPhaseText extends StatelessWidget {
  const MerkabaPhaseText({
    super.key,
    required this.phase,
    required this.reduceMotion,
  });

  final ValueListenable<BreathPhase> phase;
  final bool reduceMotion;

  static const Duration fade = Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<BreathPhase>(
      valueListenable: phase,
      builder: (context, value, _) => _FadeSwitch<BreathPhase>(
        value: value,
        duration: reduceMotion ? Duration.zero : fade,
        child: Text(
          l10n.merkabaPhaseLabel(value),
          style: AppTypography.headline.copyWith(
            color: AppColors.white.withValues(alpha: 0.92),
            fontSize: AppFontSizes.s20,
            letterSpacing: 4.4,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}

/// Cross-fades [child] each time [value] changes.
///
/// Every change gets a fresh key. Keying by [value] itself breaks when the
/// seek bar is dragged back and forth quickly: A → B → A lands within one
/// fade, the old A is still fading out when the new A arrives, and two
/// children share a key in the switcher's stack. Flutter then fails with
/// `'_dependents.isEmpty': is not true`.
class _FadeSwitch<T> extends StatefulWidget {
  const _FadeSwitch({
    super.key,
    required this.value,
    required this.duration,
    required this.child,
  });

  final T value;
  final Duration duration;
  final Widget child;

  @override
  State<_FadeSwitch<T>> createState() => _FadeSwitchState<T>();
}

class _FadeSwitchState<T> extends State<_FadeSwitch<T>> {
  int _generation = 0;

  @override
  void didUpdateWidget(_FadeSwitch<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _generation++;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.duration,
      child: KeyedSubtree(key: ValueKey<int>(_generation), child: widget.child),
    );
  }
}

final TextStyle _panelValueStyle = AppTypography.headline.copyWith(
  color: AppColors.white.withValues(alpha: 0.9),
  fontSize: AppFontSizes.s16,
  letterSpacing: 1.6,
  fontWeight: FontWeight.w300,
  fontFeatures: const [FontFeature.tabularFigures()],
);

final TextStyle _panelLabelStyle = AppTypography.subheadline.copyWith(
  color: AppColors.champagneGold.withValues(alpha: 0.78),
  fontSize: AppFontSizes.s9,
  letterSpacing: 2.2,
);

/// Quiet glass panel at the foot of the session: the breath phase with a
/// hairline that fills across it, then breaths done and time left side by
/// side. It never fades, so the guide stays readable while the controls
/// above it come and go.
class MerkabaBreathPanel extends StatelessWidget {
  const MerkabaBreathPanel({
    super.key,
    required this.phase,
    required this.elapsed,
    required this.cycles,
    required this.remainingSeconds,
    required this.reduceMotion,
    this.sceneIndex,
  });

  final ValueListenable<BreathPhase> phase;
  final ValueListenable<Duration> elapsed;
  final ValueListenable<int> cycles;
  final ValueListenable<int> remainingSeconds;
  final bool reduceMotion;

  /// Current scene. When set, its mudra is drawn beside the breath guide so
  /// the hand position is visible while breathing.
  final ValueListenable<int>? sceneIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkIndigoBlue.withValues(alpha: 0.55),
              AppColors.darkIndigoBlue.withValues(alpha: 0.8),
            ],
          ),
          border: Border.all(
            color: AppColors.champagneGold.withValues(alpha: 0.32),
            width: 0.7,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s16,
            AppSpacing.s20,
            AppSpacing.s16,
          ),
          child: _withMudra(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MerkabaPhaseText(phase: phase, reduceMotion: reduceMotion),
                const SizedBox(height: AppSpacing.s10),
                SizedBox(
                  width: 120,
                  height: 2,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _PhaseLinePainter(elapsed: elapsed),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s14),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _PanelStat(
                          label: l10n.merkabaBreaths,
                          value: MerkabaBreathCounter(cycles: cycles),
                        ),
                      ),
                      Container(
                        width: 0.7,
                        margin: const EdgeInsets.symmetric(
                          vertical: AppSpacing.s2,
                        ),
                        color: AppColors.champagneGold.withValues(alpha: 0.28),
                      ),
                      Expanded(
                        child: _PanelStat(
                          label: l10n.merkabaRemaining,
                          value: MerkabaRemainingTime(
                            seconds: remainingSeconds,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Puts the mudra on the left of [guide], split by a gold hairline.
  Widget _withMudra(Widget guide) {
    final scene = sceneIndex;
    if (scene == null) return guide;
    return IntrinsicHeight(
      child: Row(
        children: [
          MerkabaMudraIcon(sceneIndex: scene, reduceMotion: reduceMotion),
          Container(
            width: 0.7,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s14),
            color: AppColors.champagneGold.withValues(alpha: 0.28),
          ),
          Expanded(child: guide),
        ],
      ),
    );
  }
}

/// The hand position of the current scene, as a gold line icon in a soft
/// ring. Cross-fades when the scene changes, like the mudra title.
class MerkabaMudraIcon extends StatelessWidget {
  const MerkabaMudraIcon({
    super.key,
    required this.sceneIndex,
    required this.reduceMotion,
  });

  final ValueListenable<int> sceneIndex;
  final bool reduceMotion;

  static const double size = 64;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: sceneIndex,
      builder: (context, index, _) {
        final scene = merkabaScenes[index.clamp(0, merkabaScenes.length - 1)];
        return _FadeSwitch<String>(
          value: scene.mudra,
          duration: reduceMotion ? Duration.zero : MerkabaMudraTitle.fade,
          child: Semantics(
            image: true,
            label: '${scene.mudra}. ${l10n.merkabaScenePurpose(scene)}',
            excludeSemantics: true,
            child: Container(
              width: size,
              height: size,
              padding: const EdgeInsets.all(AppSpacing.s10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.champagneGold.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppColors.champagneGold.withValues(alpha: 0.55),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.champagneGold.withValues(alpha: 0.18),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: SvgPicture.asset(scene.mudraAsset),
            ),
          ),
        );
      },
    );
  }
}

class _PanelStat extends StatelessWidget {
  const _PanelStat({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _panelLabelStyle,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        value,
      ],
    );
  }
}

/// Hairline that fills over the current inhale, hold or exhale. It repaints
/// from [elapsed] alone, so the panel around it never rebuilds.
class _PhaseLinePainter extends CustomPainter {
  _PhaseLinePainter({required this.elapsed}) : super(repaint: elapsed);

  final ValueListenable<Duration> elapsed;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = merkabaFrameAt(elapsed.value).phaseProgress;
    final y = size.height / 2;
    final track = Paint()
      ..color = AppColors.champagneGold.withValues(alpha: 0.18)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), track);
    if (progress <= 0) return;
    final fill = Paint()
      ..color = AppColors.champagneGold.withValues(alpha: 0.85)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, y), Offset(size.width * progress, y), fill);
  }

  @override
  bool shouldRepaint(_PhaseLinePainter oldDelegate) =>
      oldDelegate.elapsed != elapsed;
}

/// Drawn and dragged by hand, with no overlay. [fraction] is 0–1.
class _SeekTrack extends StatefulWidget {
  const _SeekTrack({
    required this.fraction,
    required this.onStart,
    required this.onChanged,
    required this.onEnd,
    required this.increasedValue,
    required this.decreasedValue,
    required this.onStep,
  });

  final double fraction;
  final VoidCallback onStart;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onEnd;

  /// Values announced for a screen reader step forward or back.
  final String increasedValue;
  final String decreasedValue;

  /// Screen reader increase (true) or decrease (false).
  final ValueChanged<bool> onStep;

  @override
  State<_SeekTrack> createState() => _SeekTrackState();
}

class _SeekTrackState extends State<_SeekTrack> {
  /// Touch area height; the line itself stays thin.
  static const double _height = 32;
  static const double _thumbRadius = 4.5;

  double? _drag;

  double _fractionAt(Offset local, double width) {
    final usable = width - 2 * _thumbRadius;
    if (usable <= 0) return 0;
    return ((local.dx - _thumbRadius) / usable).clamp(0.0, 1.0);
  }

  void _start(Offset local, double width) {
    final value = _fractionAt(local, width);
    setState(() => _drag = value);
    widget.onStart();
    widget.onChanged(value);
  }

  void _update(Offset local, double width) {
    final value = _fractionAt(local, width);
    setState(() => _drag = value);
    widget.onChanged(value);
  }

  void _end() {
    final value = _drag ?? widget.fraction;
    setState(() => _drag = null);
    widget.onEnd(value);
  }

  @override
  Widget build(BuildContext context) {
    final fraction = (_drag ?? widget.fraction).clamp(0.0, 1.0);
    return Semantics(
      slider: true,
      increasedValue: widget.increasedValue,
      decreasedValue: widget.decreasedValue,
      onIncrease: () => widget.onStep(true),
      onDecrease: () => widget.onStep(false),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (details) =>
                _start(details.localPosition, width),
            onHorizontalDragUpdate: (details) =>
                _update(details.localPosition, width),
            onHorizontalDragEnd: (_) => _end(),
            onHorizontalDragCancel: _end,
            onTapDown: (details) => _start(details.localPosition, width),
            onTapUp: (_) => _end(),
            onTapCancel: () {
              if (_drag != null) _end();
            },
            child: SizedBox(
              width: width,
              height: _height,
              child: CustomPaint(
                painter: _SeekTrackPainter(
                  fraction: fraction,
                  thumbRadius: _thumbRadius,
                  dragging: _drag != null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SeekTrackPainter extends CustomPainter {
  const _SeekTrackPainter({
    required this.fraction,
    required this.thumbRadius,
    required this.dragging,
  });

  final double fraction;
  final double thumbRadius;
  final bool dragging;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final start = thumbRadius;
    final end = size.width - thumbRadius;
    final thumbX = start + (end - start) * fraction;
    final line = Paint()
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(thumbX, y),
      Offset(end, y),
      line..color = AppColors.champagneGold.withValues(alpha: 0.22),
    );
    canvas.drawLine(
      Offset(start, y),
      Offset(thumbX, y),
      line..color = AppColors.champagneGold.withValues(alpha: 0.85),
    );
    if (dragging) {
      canvas.drawCircle(
        Offset(thumbX, y),
        16,
        Paint()..color = AppColors.champagneGold.withValues(alpha: 0.12),
      );
    }
    canvas.drawCircle(
      Offset(thumbX, y),
      thumbRadius,
      Paint()..color = AppColors.champagneGold,
    );
  }

  @override
  bool shouldRepaint(_SeekTrackPainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.dragging != dragging;
}

/// Breaths done out of the total, e.g. `7 / 21`.
class MerkabaBreathCounter extends StatelessWidget {
  const MerkabaBreathCounter({super.key, required this.cycles});

  final ValueListenable<int> cycles;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: cycles,
      builder: (context, done, _) => Semantics(
        label: l10n.merkabaBreathsSemantics(done, merkabaTotalBreaths, 0),
        excludeSemantics: true,
        child: Text('$done / $merkabaTotalBreaths', style: _panelValueStyle),
      ),
    );
  }
}

/// Time left in the session. It changes once per second.
class MerkabaRemainingTime extends StatelessWidget {
  const MerkabaRemainingTime({super.key, required this.seconds});

  final ValueListenable<int> seconds;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: seconds,
      builder: (context, value, _) {
        final clock = formatMerkabaClock(Duration(seconds: value));
        return Semantics(
          label: l10n.merkabaTimeRemaining(clock),
          excludeSemantics: true,
          child: Text(clock, style: _panelValueStyle),
        );
      },
    );
  }
}

/// Thin gold bar to move forward or back in the session. Moving it moves the
/// session clock; the video and the breath follow.
class MerkabaSeekBar extends StatelessWidget {
  const MerkabaSeekBar({
    super.key,
    required this.elapsed,
    required this.onSeekStart,
    required this.onSeek,
    required this.onSeekEnd,
  });

  final ValueListenable<Duration> elapsed;
  final VoidCallback onSeekStart;
  final ValueChanged<Duration> onSeek;
  final ValueChanged<Duration> onSeekEnd;

  /// The last second stays out of reach: finishing the session means
  /// reaching its end by playing, not by dragging.
  static final double _max = (merkabaDuration - const Duration(seconds: 1))
      .inMilliseconds
      .toDouble();

  /// Screen reader step: five seconds forward or back.
  static double _stepped(double ms, bool forward) =>
      (ms + (forward ? 5000 : -5000)).clamp(0.0, _max);

  static String _percentLabel(AppLocalizations l10n, double ms) => l10n
      .merkabaPercentValue((ms * 100 / merkabaDuration.inMilliseconds).round());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RepaintBoundary(
      child: ValueListenableBuilder<Duration>(
        valueListenable: elapsed,
        builder: (context, value, _) {
          final ms = value.inMilliseconds.toDouble().clamp(0.0, _max);
          return Semantics(
            label: l10n.merkabaSessionProgress,
            value: l10n.merkabaPercentValue(
              (value.inMilliseconds * 100 / merkabaDuration.inMilliseconds)
                  .round(),
            ),
            // Not a Material Slider: it keeps an OverlayPortal always open
            // in the navigator's overlay. Dragging fast, or leaving the
            // session while the bar sits in an Offstage, tore that overlay
            // down with live dependents ('_dependents.isEmpty').
            child: _SeekTrack(
              fraction: ms / _max,
              onStart: onSeekStart,
              onChanged: (fraction) =>
                  onSeek(Duration(milliseconds: (fraction * _max).round())),
              onEnd: (fraction) =>
                  onSeekEnd(Duration(milliseconds: (fraction * _max).round())),
              increasedValue: _percentLabel(l10n, _stepped(ms, true)),
              decreasedValue: _percentLabel(l10n, _stepped(ms, false)),
              onStep: (forward) {
                onSeekStart();
                onSeekEnd(
                  Duration(milliseconds: _stepped(ms, forward).round()),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Controls that fade away after a few seconds without touch.
class MerkabaControls extends StatelessWidget {
  const MerkabaControls({
    super.key,
    required this.visible,
    required this.playing,
    required this.elapsed,
    required this.onPlayPause,
    required this.onSeekStart,
    required this.onSeek,
    required this.onSeekEnd,
    required this.reduceMotion,
  });

  final ValueListenable<bool> visible;
  final ValueListenable<bool> playing;
  final ValueListenable<Duration> elapsed;
  final VoidCallback onPlayPause;
  final VoidCallback onSeekStart;
  final ValueChanged<Duration> onSeek;
  final ValueChanged<Duration> onSeekEnd;
  final bool reduceMotion;

  static const Duration fade = Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: visible,
      builder: (context, shown, child) => IgnorePointer(
        ignoring: !shown,
        child: AnimatedOpacity(
          opacity: shown ? 1 : 0,
          duration: reduceMotion ? Duration.zero : fade,
          child: child,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
            child: MerkabaSeekBar(
              elapsed: elapsed,
              onSeekStart: onSeekStart,
              onSeek: onSeek,
              onSeekEnd: onSeekEnd,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: playing,
                builder: (context, isPlaying, _) => MerkabaTextControl(
                  label: isPlaying ? l10n.merkabaPause : l10n.merkabaPlay,
                  onPressed: onPlayPause,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MerkabaTextControl extends StatelessWidget {
  const MerkabaTextControl({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      child: Text(
        label,
        style: AppTypography.subheadline.copyWith(
          color: AppColors.champagneGold,
          fontSize: AppFontSizes.s12,
          letterSpacing: 2.4,
        ),
      ),
    );
  }
}
