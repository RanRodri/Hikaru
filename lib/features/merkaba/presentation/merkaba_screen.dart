import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../journey/application/ritual_cycle_controller.dart';
import '../data/merkaba_progress_repository.dart';
import '../domain/merkaba_session.dart';
import 'merkaba_painter.dart';
import 'merkaba_soundscape.dart';
import 'merkaba_texts.dart';

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
    this.inCycle = false,
  });

  final Duration initialElapsed;

  /// When true, finishing the session continues into the face ritual.
  final bool inCycle;
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const Duration _sceneFade = Duration(milliseconds: 700);

  late Duration _elapsed = widget.initialElapsed >= merkabaDuration
      ? merkabaDuration
      : (widget.initialElapsed.isNegative
            ? Duration.zero
            : widget.initialElapsed);
  late final Ticker _ticker;
  late final MerkabaProgressRepository _progress;
  Duration _lastTick = Duration.zero;
  bool _playing = false;
  bool _started = false;
  bool _recorded = false;
  bool _womanPrecached = false;
  Duration _lastResumeSave = Duration.zero;
  final MerkabaSoundscape _sound = MerkabaSoundscape();

  MerkabaFrame get _frame => merkabaFrameAt(_elapsed);

  @override
  void initState() {
    super.initState();
    _progress = ref.read(merkabaProgressRepositoryProvider);
    _ticker = createTicker(_handleTick);
    WidgetsBinding.instance.addObserver(this);
    unawaited(_restoreResume());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.inactive &&
        state != AppLifecycleState.paused) {
      return;
    }
    unawaited(_rememberPlace());
  }

  Future<void> _restoreResume() async {
    if (widget.initialElapsed > Duration.zero) return;
    final elapsed = await _progress.readResume();
    if (!mounted || elapsed == null || _started || _recorded) return;
    if (elapsed <= Duration.zero || elapsed >= merkabaDuration) return;
    setState(() => _elapsed = elapsed);
  }

  Future<void> _rememberPlace() async {
    if (!_started || _recorded || _frame.isFinished) return;
    if (_elapsed <= Duration.zero) return;
    _lastResumeSave = _elapsed;
    try {
      await _progress.saveResume(_elapsed);
    } catch (error, stackTrace) {
      log(
        'Merkaba resume point was not saved',
        name: 'hikaru.merkaba',
        error: error,
        stackTrace: stackTrace,
      );
    }
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
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_saveSession(completed: false));
    _ticker.dispose();
    unawaited(_sound.dispose());
    super.dispose();
  }

  Future<void> _saveSession({required bool completed}) async {
    if (_recorded) return;
    if (!completed && !_started) return;
    _recorded = true;
    final frame = merkabaFrameAt(_elapsed);
    try {
      if (completed) {
        await _progress.clearResume();
      } else {
        await _progress.saveResume(_elapsed);
      }
      await _progress.recordSession(
        MerkabaSessionRecord(
          date: DateTime.now(),
          completedCycles: frame.completedCycles,
          completed: completed,
          elapsed: _elapsed,
        ),
      );
    } catch (error, stackTrace) {
      log(
        'Merkaba session history was not saved',
        name: 'hikaru.merkaba',
        error: error,
        stackTrace: stackTrace,
      );
    }
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
    if (next - _lastResumeSave >= const Duration(seconds: 5)) {
      unawaited(_rememberPlace());
    }
  }

  void _completeSession() {
    _ticker.stop();
    setState(() {
      _elapsed = merkabaDuration;
      _playing = false;
    });
    unawaited(_sound.finish());
    unawaited(_saveSession(completed: true));
    unawaited(ref.read(ritualCycleControllerProvider.notifier).markMerkaba());
  }

  void _handlePlayPause() {
    if (_frame.isFinished) return;
    _started = true;
    if (_playing) {
      setState(() => _playing = false);
      _ticker.stop();
      unawaited(_sound.pause());
      unawaited(_rememberPlace());
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
    _recorded = false;
    _lastResumeSave = Duration.zero;
    unawaited(_progress.clearResume());
    setState(() => _elapsed = Duration.zero);
    _handlePlayPause();
  }

  void _handleBack() {
    unawaited(_saveSession(completed: false));
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.home);
  }

  void _handleCycleContinue() {
    context.go(AppRoutes.cycle(AppRoutes.ritualFace));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final frame = _frame;
    final visual = widget.replacementVisual?.call(frame);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final breath = reduceMotion ? merkabaRestingBreath : frame.breathLevel;
    final sceneFade = reduceMotion ? Duration.zero : _sceneFade;

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
                ? _Finished(
                    onBack: _handleBack,
                    onRepeat: _handleRepeat,
                    onContinue: widget.inCycle ? _handleCycleContinue : null,
                  )
                : Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _TextControl(
                          label: l10n.commonBack,
                          onPressed: _handleBack,
                        ),
                      ),
                      _SceneTitle(scene: frame.scene, fade: sceneFade),
                      Expanded(
                        child: MerkabaStage(frame: frame, replacement: visual),
                      ),
                      _BreathPanel(
                        frame: frame,
                        breath: breath,
                        sceneFade: sceneFade,
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

/// Title of the current scene, at the top of the screen.
class _SceneTitle extends StatelessWidget {
  const _SceneTitle({required this.scene, required this.fade});

  final MerkabaScene scene;
  final Duration fade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final number = merkabaScenes.indexOf(scene) + 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      child: AnimatedSwitcher(
        duration: fade,
        child: Semantics(
          key: ValueKey(scene.title),
          header: true,
          child: Column(
            children: [
              Text(
                l10n.merkabaSceneOf(number, merkabaScenes.length),
                style: AppTypography.subheadline.copyWith(
                  color: AppColors.champagneGold,
                  fontSize: AppFontSizes.s10,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                l10n.merkabaSceneTitle(scene),
                textAlign: TextAlign.center,
                maxLines: 2,
                style: AppTypography.headline.copyWith(
                  color: AppColors.white,
                  fontSize: AppFontSizes.s20,
                  height: 1.2,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom card: breathing mudra, breath count, cycle progress, phase ring,
/// session bar and the play control.
class _BreathPanel extends StatelessWidget {
  const _BreathPanel({
    required this.frame,
    required this.breath,
    required this.sceneFade,
    required this.playing,
    required this.onPlayPause,
  });

  final MerkabaFrame frame;
  final double breath;
  final Duration sceneFade;
  final bool playing;
  final VoidCallback onPlayPause;

  @override
  Widget build(BuildContext context) {
    final clock =
        '${formatMerkabaClock(frame.elapsed)} / ${formatMerkabaClock(merkabaDuration)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s8,
        AppSpacing.s16,
        AppSpacing.s8,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.r20),
          border: Border.all(
            color: AppColors.champagneGold.withValues(alpha: 0.45),
            width: 0.75,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s16,
            AppSpacing.s14,
            AppSpacing.s16,
            AppSpacing.s4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _BreathingMudra(
                    scene: frame.scene,
                    breath: breath,
                    fade: sceneFade,
                  ),
                  const SizedBox(width: AppSpacing.s14),
                  Expanded(child: _BreathCount(frame: frame)),
                  _BreathGuide(frame: frame),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              _SessionProgressBar(progress: frame.sessionProgress),
              Row(
                children: [
                  Text(
                    clock,
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.white,
                      fontSize: AppFontSizes.s12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  _TextControl(
                    label: playing
                        ? AppLocalizations.of(context).merkabaPause
                        : AppLocalizations.of(context).merkabaPlay,
                    onPressed: onPlayPause,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mudra of the scene. It swells and glows with each inhale, stays full on
/// the hold and settles on the exhale; a new scene fades in its mudra.
class _BreathingMudra extends StatelessWidget {
  const _BreathingMudra({
    required this.scene,
    required this.breath,
    required this.fade,
  });

  static const double _haloSize = 72;
  static const double _iconSize = 44;

  final MerkabaScene scene;
  final double breath;
  final Duration fade;

  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeInOut.transform(breath.clamp(0.0, 1.0));
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: '${scene.mudra}. ${l10n.merkabaScenePurpose(scene)}',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: _haloSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.champagneGold.withValues(
                      alpha: 0.08 + 0.3 * eased,
                    ),
                    AppColors.champagneGold.withValues(alpha: 0),
                  ],
                ),
              ),
              child: Center(
                child: Transform.scale(
                  scale: 0.88 + 0.16 * eased,
                  child: AnimatedSwitcher(
                    duration: fade,
                    child: SvgPicture.asset(
                      scene.mudraAsset,
                      key: ValueKey(scene.mudraAsset),
                      width: _iconSize,
                      height: _iconSize,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          AnimatedSwitcher(
            duration: fade,
            child: Text(
              scene.mudra,
              key: ValueKey(scene.mudra),
              style: AppTypography.subheadline.copyWith(
                color: AppColors.champagneGold,
                fontSize: AppFontSizes.s10,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Breaths done so far out of the session total, and how far into the
/// current 4-4-6 cycle the user is.
class _BreathCount extends StatelessWidget {
  const _BreathCount({required this.frame});

  final MerkabaFrame frame;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cyclePercent = (frame.cycleProgress * 100).floor();

    return Semantics(
      label: l10n.merkabaBreathsSemantics(
        frame.completedCycles,
        merkabaTotalBreaths,
        cyclePercent,
      ),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.merkabaBreaths,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.champagneGold,
              fontSize: AppFontSizes.s10,
              letterSpacing: 2,
            ),
          ),
          Text(
            '${frame.completedCycles} / $merkabaTotalBreaths',
            style: AppTypography.title.copyWith(
              color: AppColors.white,
              fontSize: AppFontSizes.s26,
              height: 1.2,
            ),
          ),
          Text(
            l10n.merkabaCycle(cyclePercent),
            style: AppTypography.subheadline.copyWith(
              color: AppColors.fog,
              fontSize: AppFontSizes.s11,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionProgressBar extends StatelessWidget {
  const _SessionProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.merkabaSessionProgress,
      value: l10n.merkabaPercentValue((progress * 100).round()),
      child: SizedBox(
        height: 8,
        width: double.infinity,
        child: CustomPaint(
          painter: _SessionBarPainter(progress: progress),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _SessionBarPainter extends CustomPainter {
  const _SessionBarPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final total = merkabaDuration.inMilliseconds;
    if (total == 0 || size.width <= 0) return;
    const gap = 3.0;
    final usable = size.width - gap * (merkabaScenes.length - 1);
    final radius = Radius.circular(size.height / 2);
    final track = Paint()
      ..color = AppColors.champagneGold.withValues(alpha: 0.28);
    final fill = Paint()..color = AppColors.champagneGold;
    var x = 0.0;
    final clamped = progress.clamp(0.0, 1.0);
    for (final scene in merkabaScenes) {
      final span = (scene.end - scene.start).inMilliseconds / total;
      final width = usable * span;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, width, size.height),
        radius,
      );
      canvas.drawRRect(rect, track);
      final start = scene.start.inMilliseconds / total;
      final local = span == 0
          ? 0.0
          : ((clamped - start) / span).clamp(0.0, 1.0);
      if (local > 0) {
        canvas.save();
        canvas.clipRRect(rect);
        canvas.drawRect(Rect.fromLTWH(x, 0, width * local, size.height), fill);
        canvas.restore();
      }
      x += width + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _SessionBarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Finished extends StatelessWidget {
  const _Finished({
    required this.onBack,
    required this.onRepeat,
    this.onContinue,
  });

  final VoidCallback onBack;
  final VoidCallback onRepeat;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _TextControl(label: l10n.commonBack, onPressed: onBack),
        ),
        const Spacer(),
        Text(
          l10n.merkabaSilence,
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
        if (onContinue != null) ...[
          _TextControl(label: l10n.commonContinue, onPressed: onContinue!),
          const SizedBox(height: AppSpacing.s12),
        ],
        _TextControl(label: l10n.merkabaRepeat, onPressed: onRepeat),
        const Spacer(),
      ],
    );
  }
}

class _BreathGuide extends StatelessWidget {
  const _BreathGuide({required this.frame});

  static const double _size = 84;

  final MerkabaFrame frame;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _size,
      child: CustomPaint(
        painter: _RingPainter(progress: 1 - frame.phaseProgress),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).merkabaPhaseLabel(frame.phase),
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
