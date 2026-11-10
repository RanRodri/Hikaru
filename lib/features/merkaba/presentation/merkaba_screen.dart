import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/design_system/widgets/hikaru_back_button.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../journey/application/ritual_cycle_controller.dart';
import '../../journey/data/ritual_cycle_gateway.dart'
    show merkabaPracticedDaysReaderProvider;
import '../../journey/data/ritual_cycle_repository.dart';
import '../../journey/domain/ritual_cycle.dart'
    show RitualStep, dateOnly, ritualCycleLength;
import '../../journey/presentation/ritual_celebration_dialog.dart';
import '../../journey/presentation/ritual_cycle_routes.dart';
import '../data/merkaba_progress_repository.dart';
import '../data/merkaba_video_source.dart';
import '../domain/merkaba_session.dart';
import 'merkaba_painter.dart';
import '../../../core/media/starry_night.dart';
import 'merkaba_sanctuary.dart';
import 'merkaba_soundscape.dart';
import 'merkaba_video.dart';

/// Called when the breath phase changes while the session is playing.
///
/// Optional listener. The screen also plays the breath sound.
typedef MerkabaPhaseCue = void Function(BreathPhase phase);

class MerkabaMeditationScreen extends ConsumerStatefulWidget {
  const MerkabaMeditationScreen({
    super.key,
    this.initialElapsed = Duration.zero,
    this.onPhaseCue,
    this.replacementVisual,
    this.inCycle = false,
    this.clock,
  });

  final Duration initialElapsed;

  /// When true, finishing the session continues into the face ritual.
  final bool inCycle;
  final MerkabaPhaseCue? onPhaseCue;

  /// When set, it is shown instead of the pre-rendered video. Without it the
  /// screen plays the video, and draws [MerkabaStage]'s painter if the video
  /// cannot be loaded.
  final Widget Function(MerkabaFrame frame)? replacementVisual;

  /// Wall clock used to measure how long the session really took. Tests
  /// replace it.
  final DateTime Function()? clock;

  @override
  ConsumerState<MerkabaMeditationScreen> createState() =>
      _MerkabaMeditationScreenState();
}

class _MerkabaMeditationScreenState
    extends ConsumerState<MerkabaMeditationScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const Duration _controlsHideAfter = Duration(seconds: 3);
  static const Duration _resumeSaveEvery = Duration(seconds: 5);
  static const Duration _videoSyncEvery = Duration(seconds: 1);

  /// A frame gap longer than this is a stall, not time the user sat through.
  static const Duration _maxTickStep = Duration(seconds: 1);

  late final Ticker _ticker;
  late final MerkabaProgressRepository _progress;
  MerkabaVideoPlayback? _video;
  final MerkabaSoundscape _sound = MerkabaSoundscape();

  // The clock and everything derived from it live in notifiers, so only the
  // widgets that show them rebuild. The screen itself rebuilds on finish.
  late final ValueNotifier<Duration> _elapsed;
  late final ValueNotifier<BreathPhase> _phase;
  late final ValueNotifier<int> _cycles;
  late final ValueNotifier<int> _sceneIndex;
  late final ValueNotifier<int> _remainingSeconds;
  final ValueNotifier<bool> _playing = ValueNotifier(false);
  final ValueNotifier<bool> _controlsVisible = ValueNotifier(true);

  Timer? _hideControls;
  Duration _lastTick = Duration.zero;
  Duration _lastResumeSave = Duration.zero;
  Duration _lastVideoSync = Duration.zero;
  bool _started = false;
  bool _recorded = false;
  bool _finished = false;
  bool _scrubbing = false;

  /// Furthest point the member has really reached. The bar can go back to
  /// repeat a part, never past this, so every exercise is done in full.
  Duration _furthest = Duration.zero;
  final ValueNotifier<_Summary> _summary = ValueNotifier(const _Summary());
  DateTime? _sittingStart;
  Duration _sittingOffset = Duration.zero;
  Duration _sittingLength = Duration.zero;

  DateTime _now() => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _progress = ref.read(merkabaProgressRepositoryProvider);
    final initial = widget.initialElapsed >= merkabaDuration
        ? merkabaDuration
        : (widget.initialElapsed.isNegative
              ? Duration.zero
              : widget.initialElapsed);
    final frame = merkabaFrameAt(initial);
    _furthest = initial;
    _elapsed = ValueNotifier(initial);
    _phase = ValueNotifier(frame.phase);
    _cycles = ValueNotifier(frame.completedCycles);
    _sceneIndex = ValueNotifier(merkabaScenes.indexOf(frame.scene));
    _remainingSeconds = ValueNotifier(_secondsLeft(initial));
    _finished = frame.isFinished;
    _sittingLength = merkabaDuration;

    _ticker = createTicker(_handleTick);
    WidgetsBinding.instance.addObserver(this);
    if (widget.replacementVisual == null) {
      final source = ref.read(merkabaVideoSourceProvider);
      _video = ref.read(merkabaVideoPlaybackFactoryProvider)(source)..load();
    }
    unawaited(_holdScreen());
    unawaited(_restoreResume());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.inactive &&
        state != AppLifecycleState.paused) {
      return;
    }
    if (_playing.value) _pause();
  }

  /// Keeps the screen awake and upright for the whole session.
  Future<void> _holdScreen() async {
    try {
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
      ]);
      await WakelockPlus.enable();
    } catch (error, stackTrace) {
      log(
        'Merkaba could not hold the screen',
        name: 'hikaru.merkaba',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _releaseScreen() async {
    try {
      await WakelockPlus.disable();
    } catch (error, stackTrace) {
      log(
        'Merkaba could not release the screen',
        name: 'hikaru.merkaba',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _restoreResume() async {
    if (widget.initialElapsed > Duration.zero) return;
    final elapsed = await _progress.readResume();
    if (!mounted || elapsed == null || _started || _recorded) return;
    if (elapsed <= Duration.zero || elapsed >= merkabaDuration) return;
    // Reopening a half-done session: back to the start is allowed, past
    // where it was left is not.
    if (elapsed > _furthest) _furthest = elapsed;
    _publish(elapsed, cue: false);
  }

  Future<void> _rememberPlace() async {
    final elapsed = _elapsed.value;
    if (!_started || _recorded || _finished) return;
    if (elapsed <= Duration.zero) return;
    _lastResumeSave = elapsed;
    try {
      await _progress.saveResume(elapsed);
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideControls?.cancel();
    unawaited(_saveSession(completed: false));
    _ticker.dispose();
    unawaited(_sound.dispose());
    _video?.dispose();
    unawaited(_releaseScreen());
    _elapsed.dispose();
    _phase.dispose();
    _cycles.dispose();
    _sceneIndex.dispose();
    _remainingSeconds.dispose();
    _playing.dispose();
    _controlsVisible.dispose();
    _summary.dispose();
    super.dispose();
  }

  Future<void> _saveSession({required bool completed}) async {
    if (_recorded) return;
    if (!completed && !_started) return;
    _recorded = true;
    final elapsed = _elapsed.value;
    final frame = merkabaFrameAt(elapsed);
    try {
      if (completed) {
        await _progress.clearResume();
      } else {
        await _progress.saveResume(elapsed);
      }
      await _progress.recordSession(
        MerkabaSessionRecord(
          date: DateTime.now(),
          completedCycles: frame.completedCycles,
          completed: completed,
          elapsed: elapsed,
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

  static int _secondsLeft(Duration elapsed) =>
      ((merkabaDuration - elapsed).inMilliseconds / 1000).ceil().clamp(
        0,
        merkabaDuration.inSeconds,
      );

  /// Moves the session clock to [next] and updates only the values that
  /// changed, so most frames notify nobody but the breath orb.
  void _publish(Duration next, {required bool cue}) {
    final frame = merkabaFrameAt(next);
    _elapsed.value = next;
    if (_phase.value != frame.phase) {
      _phase.value = frame.phase;
      if (cue) _cuePhase(frame.phase);
    }
    _cycles.value = frame.completedCycles;
    _sceneIndex.value = merkabaScenes.indexOf(frame.scene);
    _remainingSeconds.value = _secondsLeft(next);
  }

  void _cuePhase(BreathPhase phase, {Duration into = Duration.zero}) {
    widget.onPhaseCue?.call(phase);
    unawaited(_sound.cue(phase, into: into));
  }

  void _handleTick(Duration sinceStart) {
    if (!_playing.value) return;
    var delta = sinceStart - _lastTick;
    _lastTick = sinceStart;
    // While the bar is being dragged the person leads, not the clock.
    if (_scrubbing) return;
    if (delta.isNegative) delta = Duration.zero;
    if (delta > _maxTickStep) delta = _maxTickStep;
    final next = _elapsed.value + delta;
    if (next >= merkabaDuration) {
      _completeSession();
      return;
    }
    if (next > _furthest) _furthest = next;
    _publish(next, cue: true);
    if (next - _lastVideoSync >= _videoSyncEvery) {
      _lastVideoSync = next;
      unawaited(_video?.sync(next));
    }
    if (next - _lastResumeSave >= _resumeSaveEvery) {
      unawaited(_rememberPlace());
    }
  }

  void _completeSession() {
    if (_finished) return;
    _ticker.stop();
    _publish(merkabaDuration, cue: false);
    _playing.value = false;
    _hideControls?.cancel();
    final start = _sittingStart;
    setState(() {
      _finished = true;
      _sittingLength = start == null
          ? merkabaDuration
          : _sittingOffset + _now().difference(start);
    });
    unawaited(_sound.finish());
    final video = _video;
    if (video != null) {
      unawaited(video.pause());
      unawaited(video.keepForNextTime());
    }
    unawaited(_recordCompletion());
  }

  /// Saves the sitting, marks today's Merkaba in the ritual and tells the
  /// closing screen what was stored.
  Future<void> _recordCompletion() async {
    _summary.value = const _Summary(status: _SaveStatus.saving);
    await _saveSession(completed: true);
    final todayBefore = ref.read(todayRitualProvider);
    var saved = true;
    try {
      await ref.read(ritualCycleControllerProvider.notifier).markMerkaba();
    } catch (error, stackTrace) {
      saved = false;
      log(
        'Merkaba completion was not recorded in the ritual',
        name: 'hikaru.merkaba',
        error: error,
        stackTrace: stackTrace,
      );
    }
    if (!mounted) return;
    // markMerkaba keeps an unsent change on the device instead of throwing,
    // so ask whether the backend actually has today's sitting.
    try {
      if (await ref.read(ritualCycleRepositoryProvider).hasPending()) {
        saved = false;
      }
    } catch (_) {}
    if (!mounted) return;
    var practicedDays = 1;
    try {
      final history = await _progress.history();
      final onDevice = history
          .where((record) => record.completed)
          .map((record) => dateOnly(record.date))
          .toSet()
          .length;
      // The backend counts the days from every phone; the device only knows
      // its own. The larger of the two is the honest number.
      final inBackend = await ref.read(merkabaPracticedDaysReaderProvider)();
      practicedDays = inBackend != null && inBackend > onDevice
          ? inBackend
          : onDevice;
    } catch (error, stackTrace) {
      log(
        'Merkaba history could not be read',
        name: 'hikaru.merkaba',
        error: error,
        stackTrace: stackTrace,
      );
    }
    if (!mounted) return;
    _summary.value = _Summary(
      status: saved ? _SaveStatus.saved : _SaveStatus.onDevice,
      cycleDay: ref.read(journeyProgressProvider).currentDay,
      practicedDays: practicedDays < 1 ? 1 : practicedDays,
    );
    // The closing screen already congratulates the sitting; the dialog only
    // appears when Merkaba was the last step of the day.
    await celebrateStep(
      context,
      ref,
      step: RitualStep.merkaba,
      before: todayBefore,
      onlyWhenDayCompletes: true,
    );
  }

  void _handlePlayPause() {
    if (_finished) return;
    if (_playing.value) {
      _pause();
    } else {
      _play();
    }
  }

  void _play() {
    _started = true;
    final elapsed = _elapsed.value;
    if (_sittingStart == null) {
      _sittingStart = _now();
      _sittingOffset = elapsed;
    }
    final frame = merkabaFrameAt(elapsed);
    _playing.value = true;
    _lastVideoSync = elapsed;
    unawaited(_sound.startAmbient());
    _cuePhase(frame.phase, into: frame.phaseElapsed);
    unawaited(_video?.play(elapsed));
    _lastTick = Duration.zero;
    _ticker.start();
    _scheduleHide();
  }

  void _pause() {
    _playing.value = false;
    _ticker.stop();
    _hideControls?.cancel();
    _controlsVisible.value = true;
    unawaited(_sound.pause());
    unawaited(_video?.pause());
    unawaited(_rememberPlace());
  }

  void _handleRepeat() {
    _recorded = false;
    _lastResumeSave = Duration.zero;
    _sittingStart = null;
    _sittingOffset = Duration.zero;
    unawaited(_progress.clearResume());
    _publish(Duration.zero, cue: false);
    setState(() => _finished = false);
    _play();
  }

  void _handleBack() {
    unawaited(_saveSession(completed: false));
    unawaited(_video?.pause());
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.home);
  }

  void _handleCycleContinue() {
    // Skips the steps already done today.
    context.go(
      nextCycleRoute(context, current: RitualStep.merkaba) ?? AppRoutes.home,
    );
  }

  void _handleSeekStart() {
    _scrubbing = true;
    _hideControls?.cancel();
    _controlsVisible.value = true;
  }

  /// Rewinding is free; moving ahead stops at the furthest point reached.
  Duration _allowedSeek(Duration to) => to > _furthest ? _furthest : to;

  void _handleSeek(Duration to) => _publish(_allowedSeek(to), cue: false);

  void _handleSeekEnd(Duration requested) {
    final to = _allowedSeek(requested);
    _publish(to, cue: false);
    _scrubbing = false;
    _lastVideoSync = to;
    _lastResumeSave = to;
    unawaited(_video?.seek(to));
    if (_playing.value) {
      final frame = merkabaFrameAt(to);
      _cuePhase(frame.phase, into: frame.phaseElapsed);
      _scheduleHide();
    }
  }

  /// A touch during the session pauses it and shows the controls. While
  /// paused, a touch only toggles the controls; PLAY resumes.
  void _handleSurfaceTap() {
    if (_playing.value) {
      _handlePlayPause();
      _controlsVisible.value = true;
      return;
    }
    _controlsVisible.value = !_controlsVisible.value;
  }

  void _scheduleHide() {
    _hideControls?.cancel();
    if (!_playing.value) return;
    if (MediaQuery.maybeAccessibleNavigationOf(context) ?? false) return;
    _hideControls = Timer(_controlsHideAfter, () {
      if (_playing.value) _controlsVisible.value = false;
    });
  }

  Widget _buildStage() {
    final custom = widget.replacementVisual;
    if (custom != null) {
      return ValueListenableBuilder<Duration>(
        valueListenable: _elapsed,
        builder: (context, elapsed, _) {
          final frame = merkabaFrameAt(elapsed);
          return MerkabaStage(frame: frame, replacement: custom(frame));
        },
      );
    }
    final painter = ValueListenableBuilder<Duration>(
      valueListenable: _elapsed,
      builder: (context, elapsed, _) =>
          MerkabaStage(frame: merkabaFrameAt(elapsed)),
    );
    return MerkabaStage(
      frame: merkabaFrameAt(_elapsed.value),
      replacement: MerkabaVideoLayer(playback: _video!, fallback: painter),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final video = _video;

    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _handleSurfaceTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Image(
              image: AssetImage(merkabaStarryNightAsset),
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
            Positioned.fill(
              child: Offstage(offstage: _finished, child: _buildStage()),
            ),
            const MerkabaSanctuaryFrame(),
            Positioned.fill(
              child: Offstage(
                offstage: _finished,
                child: video == null
                    ? MerkabaBreathOrb(
                        elapsed: _elapsed,
                        reduceMotion: reduceMotion,
                      )
                    : ListenableBuilder(
                        listenable: video,
                        builder: (context, _) =>
                            video.status == MerkabaVideoStatus.ready
                            ? MerkabaBreathOrb(
                                elapsed: _elapsed,
                                reduceMotion: reduceMotion,
                              )
                            : const SizedBox.shrink(),
                      ),
              ),
            ),
            SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Offstage(
                    offstage: _finished,
                    child: _Session(
                      sceneIndex: _sceneIndex,
                      phase: _phase,
                      cycles: _cycles,
                      remainingSeconds: _remainingSeconds,
                      playing: _playing,
                      elapsed: _elapsed,
                      controlsVisible: _controlsVisible,
                      reduceMotion: reduceMotion,
                      onPlayPause: _handlePlayPause,
                      onLeave: _handleBack,
                      onSeekStart: _handleSeekStart,
                      onSeek: _handleSeek,
                      onSeekEnd: _handleSeekEnd,
                    ),
                  ),
                  Offstage(
                    offstage: !_finished,
                    child: _Finished(
                      length: _sittingLength,
                      summary: _summary,
                      onBack: _handleBack,
                      onRepeat: _handleRepeat,
                      onContinue: widget.inCycle ? _handleCycleContinue : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mudra on top; breath text, counter, time left and controls below. The
/// middle stays empty for the figure.
class _Session extends StatelessWidget {
  const _Session({
    required this.sceneIndex,
    required this.phase,
    required this.cycles,
    required this.remainingSeconds,
    required this.playing,
    required this.elapsed,
    required this.controlsVisible,
    required this.reduceMotion,
    required this.onPlayPause,
    required this.onLeave,
    required this.onSeekStart,
    required this.onSeek,
    required this.onSeekEnd,
  });

  final ValueListenable<int> sceneIndex;
  final ValueListenable<BreathPhase> phase;
  final ValueListenable<int> cycles;
  final ValueListenable<int> remainingSeconds;
  final ValueListenable<bool> playing;
  final ValueListenable<Duration> elapsed;
  final ValueListenable<bool> controlsVisible;
  final bool reduceMotion;
  final VoidCallback onPlayPause;
  final VoidCallback onLeave;
  final VoidCallback onSeekStart;
  final ValueChanged<Duration> onSeek;
  final ValueChanged<Duration> onSeekEnd;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          children: [
            const SizedBox(height: AppSpacing.s24),
            MerkabaMudraTitle(
              sceneIndex: sceneIndex,
              reduceMotion: reduceMotion,
            ),
            const Spacer(),
            MerkabaControls(
              visible: controlsVisible,
              playing: playing,
              elapsed: elapsed,
              onPlayPause: onPlayPause,
              onSeekStart: onSeekStart,
              onSeek: onSeek,
              onSeekEnd: onSeekEnd,
              reduceMotion: reduceMotion,
            ),
            const SizedBox(height: AppSpacing.s6),
            MerkabaBreathPanel(
              sceneIndex: sceneIndex,
              phase: phase,
              elapsed: elapsed,
              cycles: cycles,
              remainingSeconds: remainingSeconds,
              reduceMotion: reduceMotion,
            ),
            const SizedBox(height: AppSpacing.s12),
          ],
        ),
        // Top left like every other screen. It fades with the other
        // controls so it does not interrupt the meditation.
        Positioned(
          top: AppSpacing.s8,
          left: AppSpacing.s16,
          child: ValueListenableBuilder<bool>(
            valueListenable: controlsVisible,
            builder: (context, shown, child) => IgnorePointer(
              ignoring: !shown,
              child: AnimatedOpacity(
                opacity: shown ? 1 : 0,
                duration: reduceMotion ? Duration.zero : MerkabaControls.fade,
                child: child,
              ),
            ),
            child: HikaruBackButton(onPressed: onLeave),
          ),
        ),
      ],
    );
  }
}

enum _SaveStatus { idle, saving, saved, onDevice }

/// What the closing screen says about the progress of today.
class _Summary {
  const _Summary({
    this.status = _SaveStatus.idle,
    this.cycleDay,
    this.practicedDays = 0,
  });

  final _SaveStatus status;

  /// Day of the 30-day cycle, once the ritual has been marked.
  final int? cycleDay;

  /// Distinct days with a finished Merkaba.
  final int practicedDays;
}

class _Finished extends StatelessWidget {
  const _Finished({
    required this.length,
    required this.summary,
    required this.onBack,
    required this.onRepeat,
    this.onContinue,
  });

  /// How long the sitting really lasted, pauses included.
  final Duration length;
  final ValueListenable<_Summary> summary;
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
          child: HikaruBackButton(onPressed: onBack),
        ),
        const Spacer(),
        Text(
          l10n.merkabaSilence,
          textAlign: TextAlign.center,
          style: AppTypography.title.copyWith(
            color: AppColors.white,
            fontSize: AppFontSizes.s32,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: AppSpacing.s24),
        Text(
          l10n.merkabaSessionLength,
          style: AppTypography.subheadline.copyWith(
            color: AppColors.champagneGold,
            fontSize: AppFontSizes.s10,
            letterSpacing: 2.4,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          formatMerkabaClock(length),
          style: AppTypography.subheadline.copyWith(
            color: AppColors.cymaticTurquoise,
            fontSize: AppFontSizes.s16,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.s24),
        ValueListenableBuilder<_Summary>(
          valueListenable: summary,
          builder: (context, value, _) => _ProgressNote(summary: value),
        ),
        const SizedBox(height: AppSpacing.s24),
        if (onContinue != null) ...[
          MerkabaTextControl(
            label: l10n.commonContinue,
            onPressed: onContinue!,
          ),
          const SizedBox(height: AppSpacing.s12),
        ],
        MerkabaTextControl(label: l10n.merkabaRepeat, onPressed: onRepeat),
        const Spacer(),
      ],
    );
  }
}

/// Tells whether today's sitting and the streak were saved.
class _ProgressNote extends StatelessWidget {
  const _ProgressNote({required this.summary});

  final _Summary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = switch (summary.status) {
      _SaveStatus.idle => null,
      _SaveStatus.saving => l10n.merkabaSaving,
      _SaveStatus.saved => l10n.merkabaSaved,
      _SaveStatus.onDevice => l10n.merkabaSavedOnDevice,
    };
    if (text == null) return const SizedBox(height: AppFontSizes.s11 * 2);
    final cycleDay = summary.cycleDay;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: AppTypography.subheadline.copyWith(
            color: AppColors.cymaticIndigoLight.withValues(alpha: 0.75),
            fontSize: AppFontSizes.s11,
            letterSpacing: 0.8,
          ),
        ),
        if (summary.status != _SaveStatus.saving) ...[
          const SizedBox(height: AppSpacing.s4),
          Text(
            cycleDay == null
                ? l10n.merkabaDaysPracticed(summary.practicedDays)
                : '${l10n.merkabaCycleDay(cycleDay, ritualCycleLength)} · '
                      '${l10n.merkabaDaysPracticed(summary.practicedDays)}',
            style: AppTypography.subheadline.copyWith(
              color: AppColors.champagneGold.withValues(alpha: 0.7),
              fontSize: AppFontSizes.s11,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ],
    );
  }
}
