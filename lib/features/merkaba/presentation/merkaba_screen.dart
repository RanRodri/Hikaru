import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../domain/merkaba_session.dart';
import 'merkaba_painter.dart';

/// Called when the breath phase changes while the session is playing.
///
/// Optional listener. The screen also plays the synthesized phase chime.
typedef MerkabaPhaseCue = void Function(BreathPhase phase);

class MerkabaMeditationScreen extends StatefulWidget {
  const MerkabaMeditationScreen({
    super.key,
    this.initialElapsed = Duration.zero,
    this.onPhaseCue,
    this.replacementVisual,
  });

  final Duration initialElapsed;
  final MerkabaPhaseCue? onPhaseCue;

  /// When set, replaces [MerkabaStage]'s painter. Intended for a pre-rendered
  /// video of the same breath and scene timing.
  final Widget Function(MerkabaFrame frame)? replacementVisual;

  @override
  State<MerkabaMeditationScreen> createState() =>
      _MerkabaMeditationScreenState();
}

class _MerkabaMeditationScreenState extends State<MerkabaMeditationScreen>
    with SingleTickerProviderStateMixin {
  late Duration _elapsed = widget.initialElapsed >= merkabaDuration
      ? merkabaDuration
      : (widget.initialElapsed.isNegative
            ? Duration.zero
            : widget.initialElapsed);
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  bool _playing = false;
  AudioPlayer? _chime;

  static const double _chimeVolume = 0.22;
  static const Map<BreathPhase, String> _chimeAssets = {
    BreathPhase.inhale: 'audio/merkaba_inhale.wav',
    BreathPhase.hold: 'audio/merkaba_hold.wav',
    BreathPhase.exhale: 'audio/merkaba_exhale.wav',
  };

  MerkabaFrame get _frame => merkabaFrameAt(_elapsed);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_handleTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    unawaited(_chime?.dispose() ?? Future<void>.value());
    super.dispose();
  }

  void _cuePhase(BreathPhase phase) {
    widget.onPhaseCue?.call(phase);
    unawaited(_playChime(phase));
  }

  Future<void> _playChime(BreathPhase phase) async {
    final asset = _chimeAssets[phase];
    if (asset == null) return;
    try {
      final player = _chime ??= AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(_chimeVolume);
      await player.stop();
      await player.play(AssetSource(asset));
    } catch (_) {
      // Widget tests have no audio backend. A missing chime stays silent.
    }
  }

  void _handleTick(Duration sinceStart) {
    if (!_playing) return;
    final delta = sinceStart - _lastTick;
    _lastTick = sinceStart;
    final next = _elapsed + delta;
    final previous = merkabaFrameAt(_elapsed);
    if (next >= merkabaDuration) {
      final finished = merkabaFrameAt(merkabaDuration);
      if (previous.phase != finished.phase) {
        _cuePhase(finished.phase);
      }
      setState(() {
        _elapsed = merkabaDuration;
        _playing = false;
      });
      _ticker.stop();
      return;
    }
    final frame = merkabaFrameAt(next);
    if (previous.phase != frame.phase) {
      _cuePhase(frame.phase);
    }
    setState(() => _elapsed = next);
  }

  void _handlePlayPause() {
    if (_frame.isFinished) return;
    if (_playing) {
      setState(() => _playing = false);
      _ticker.stop();
      return;
    }
    final frame = _frame;
    setState(() => _playing = true);
    _cuePhase(frame.phase);
    _lastTick = Duration.zero;
    _ticker.start();
  }

  @override
  Widget build(BuildContext context) {
    final frame = _frame;
    final visual = widget.replacementVisual?.call(frame);

    return Scaffold(
      backgroundColor: AppColors.indigoBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s24,
            AppSpacing.s8,
            AppSpacing.s24,
            AppSpacing.s16,
          ),
          child: frame.isFinished
              ? _Finished(onBack: () => context.pop())
              : Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _TextControl(
                        label: 'BACK',
                        onPressed: () => context.pop(),
                      ),
                    ),
                    Text(
                      frame.scene.title,
                      textAlign: TextAlign.center,
                      style: AppTypography.headline.copyWith(
                        color: AppColors.white,
                        fontSize: AppFontSizes.s22,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Expanded(
                      child: MerkabaStage(frame: frame, replacement: visual),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Text(
                      frame.scene.mudra,
                      textAlign: TextAlign.center,
                      style: AppTypography.subheadline.copyWith(
                        color: AppColors.champagneGold,
                        fontSize: AppFontSizes.s12,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      frame.scene.mudraPurpose,
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: AppColors.fog,
                        fontSize: AppFontSizes.s12,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    _BreathGuide(frame: frame),
                    const SizedBox(height: AppSpacing.s12),
                    Text(
                      '${formatMerkabaClock(frame.elapsed)} / ${formatMerkabaClock(merkabaDuration)}',
                      style: AppTypography.subheadline.copyWith(
                        color: AppColors.white,
                        fontSize: AppFontSizes.s12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    _TextControl(
                      label: _playing ? 'PAUSE' : 'PLAY',
                      onPressed: _handlePlayPause,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Finished extends StatelessWidget {
  const _Finished({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _TextControl(label: 'BACK', onPressed: onBack),
        ),
        const Spacer(),
        Text(
          'Silence.',
          textAlign: TextAlign.center,
          style: AppTypography.title.copyWith(
            color: AppColors.white,
            fontSize: AppFontSizes.s32,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Text(
          formatMerkabaClock(merkabaDuration),
          style: AppTypography.subheadline.copyWith(
            color: AppColors.champagneGold,
            fontSize: AppFontSizes.s12,
            letterSpacing: 1.4,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _BreathGuide extends StatelessWidget {
  const _BreathGuide({required this.frame});

  final MerkabaFrame frame;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.s96,
      height: 96,
      child: CustomPaint(
        painter: _RingPainter(progress: 1 - frame.phaseProgress),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                frame.phaseLabel,
                style: AppTypography.subheadline.copyWith(
                  color: AppColors.champagneGold,
                  fontSize: AppFontSizes.s10,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                '${frame.phaseSecondsRemaining}',
                style: AppTypography.title.copyWith(
                  color: AppColors.white,
                  fontSize: AppFontSizes.s28,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2 - 4;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.champagneGold.withValues(alpha: 0.25);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = AppColors.champagneGold;
    canvas.drawCircle(center, radius, base);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress.clamp(0.0, 1.0) * math.pi * 2,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _TextControl extends StatelessWidget {
  const _TextControl({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: AppTypography.subheadline.copyWith(
          color: AppColors.champagneGold,
          fontSize: AppFontSizes.s12,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}
