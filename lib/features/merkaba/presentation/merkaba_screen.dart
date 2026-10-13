import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/router/app_routes.dart';
import '../data/merkaba_progress_repository.dart';
import '../domain/merkaba_session.dart';
import 'merkaba_painter.dart';
import 'merkaba_soundscape.dart';

const String merkabaStarryNightAsset = 'assets/images/merkaba_starry_night.jpg';

/// Called when the breath phase changes while the session is playing.
///
/// Optional listener. The screen also plays the breath sound and chime.
typedef MerkabaPhaseCue = void Function(BreathPhase phase);

class MerkabaMeditationScreen extends ConsumerStatefulWidget {
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
  ConsumerState<MerkabaMeditationScreen> createState() =>
      _MerkabaMeditationScreenState();
}

class _MerkabaMeditationScreenState
    extends ConsumerState<MerkabaMeditationScreen>
    with SingleTickerProviderStateMixin {
  late Duration _elapsed = widget.initialElapsed >= merkabaDuration
      ? merkabaDuration
      : (widget.initialElapsed.isNegative
            ? Duration.zero
            : widget.initialElapsed);
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  bool _playing = false;
  bool _womanPrecached = false;
  final MerkabaSoundscape _sound = MerkabaSoundscape();

  MerkabaFrame get _frame => merkabaFrameAt(_elapsed);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_handleTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_womanPrecached) return;
    _womanPrecached = true;
    unawaited(precacheImage(const AssetImage(merkabaWomanAsset), context));
  }

  @override
  void dispose() {
    _ticker.dispose();
    unawaited(_sound.dispose());
    super.dispose();
  }

  void _cuePhase(BreathPhase phase, {Duration into = Duration.zero}) {
    widget.onPhaseCue?.call(phase);
    unawaited(_sound.cue(phase, into: into));
  }

  void _handleTick(Duration sinceStart) {
    if (!_playing) return;
    final delta = sinceStart - _lastTick;
    _lastTick = sinceStart;
    final next = _elapsed + delta;
    if (next >= merkabaDuration) {
      _completeSession();
      return;
    }
    final previous = merkabaFrameAt(_elapsed);
    final frame = merkabaFrameAt(next);
    if (previous.phase != frame.phase) {
      _cuePhase(frame.phase);
    }
    setState(() => _elapsed = next);
  }

  void _completeSession() {
    _ticker.stop();
    setState(() {
      _elapsed = merkabaDuration;
      _playing = false;
    });
    unawaited(_sound.finish());
    unawaited(
      ref
          .read(merkabaProgressRepositoryProvider)
          .recordCompletion(DateTime.now()),
    );
  }

  void _handlePlayPause() {
    if (_frame.isFinished) return;
    if (_playing) {
      setState(() => _playing = false);
      _ticker.stop();
      unawaited(_sound.pause());
      return;
    }
    final frame = _frame;
    setState(() => _playing = true);
    unawaited(_sound.startAmbient());
    _cuePhase(frame.phase, into: frame.phaseElapsed);
    _lastTick = Duration.zero;
    _ticker.start();
  }

  void _handleRepeat() {
    setState(() => _elapsed = Duration.zero);
    _handlePlayPause();
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final frame = _frame;
    final visual = widget.replacementVisual?.call(frame);

    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Image(
            image: AssetImage(merkabaStarryNightAsset),
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
          SafeArea(
            child: frame.isFinished
                ? _Finished(onBack: _handleBack, onRepeat: _handleRepeat)
                : Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _TextControl(
                          label: 'BACK',
                          onPressed: _handleBack,
                        ),
                      ),
                      Expanded(
                        child: MerkabaStage(frame: frame, replacement: visual),
                      ),
                      _SessionBand(
                        frame: frame,
                        playing: _playing,
                        onPlayPause: _handlePlayPause,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SessionBand extends StatelessWidget {
  const _SessionBand({
    required this.frame,
    required this.playing,
    required this.onPlayPause,
  });

  final MerkabaFrame frame;
  final bool playing;
  final VoidCallback onPlayPause;

  @override
  Widget build(BuildContext context) {
    final clock =
        '${formatMerkabaClock(frame.elapsed)} / ${formatMerkabaClock(merkabaDuration)}';

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.darkIndigoBlue.withValues(alpha: 0),
            AppColors.darkIndigoBlue.withValues(alpha: 0.82),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s8,
          AppSpacing.s20,
          AppSpacing.s8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Semantics(
                  label: 'Mudra placeholder, ${frame.phaseLabel}',
                  image: true,
                  child: Image.asset(
                    mudraPlaceholderAsset(frame.phase),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        frame.scene.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headline.copyWith(
                          color: AppColors.white,
                          fontSize: AppFontSizes.s16,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        frame.scene.mudra,
                        style: AppTypography.subheadline.copyWith(
                          color: AppColors.champagneGold,
                          fontSize: AppFontSizes.s12,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Cycles ${frame.completedCycles}',
                        style: AppTypography.subheadline.copyWith(
                          color: AppColors.white,
                          fontSize: AppFontSizes.s12,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                _BreathGuide(frame: frame),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),
            Semantics(
              label: 'Breath cycle progress',
              value: '${(frame.cycleProgress * 100).round()} percent',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: frame.cycleProgress,
                  minHeight: 4,
                  backgroundColor: AppColors.champagneGold.withValues(
                    alpha: 0.25,
                  ),
                  color: AppColors.champagneGold,
                ),
              ),
            ),
            Text(
              clock,
              style: AppTypography.subheadline.copyWith(
                color: AppColors.white,
                fontSize: AppFontSizes.s12,
                letterSpacing: 1.2,
              ),
            ),
            _TextControl(
              label: playing ? 'PAUSE' : 'PLAY',
              onPressed: onPlayPause,
            ),
          ],
        ),
      ),
    );
  }
}

class _Finished extends StatelessWidget {
  const _Finished({required this.onBack, required this.onRepeat});

  final VoidCallback onBack;
  final VoidCallback onRepeat;

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
        const SizedBox(height: AppSpacing.s24),
        _TextControl(label: 'REPEAT', onPressed: onRepeat),
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
