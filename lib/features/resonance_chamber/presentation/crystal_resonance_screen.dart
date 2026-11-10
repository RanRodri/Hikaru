import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/widgets/hikaru_back_button.dart';
import '../../../core/audio/audio_report.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_outline_button.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../crystals/domain/crystal.dart';
import '../../crystals/presentation/crystal_texts.dart';
import '../../journey/application/ritual_cycle_controller.dart';
import '../../journey/domain/ritual_cycle.dart' show RitualStep;
import '../../journey/presentation/ritual_celebration_dialog.dart';
import '../../massage/application/massage_video_preheat.dart';
import '../../massage/domain/massage_ritual.dart';
import '../../massage/presentation/massage_screen.dart';
import '../../listening_room/application/journey_recommendation_controller.dart';
import '../application/crystal_track_duration.dart';
import '../data/crystal_audio_store.dart';
import '../data/crystal_tutorial_progress.dart';
import '../data/cymatic_headphones_prompts.dart';
import '../domain/cymatic_audio.dart';
import 'crystal_cymatic_portrait.dart';
import 'cymatic_audio_loader.dart';
import 'cymatic_plate.dart';
import 'cymatic_projection.dart';
import 'resonance_sections.dart';

final TextStyle _bodyStyle = AppTypography.headline.copyWith(
  color: AppColors.white,
  fontSize: AppFontSizes.s12,
  height: 1.6,
  letterSpacing: 0.2,
);

/// Where the crystal screen is in its flow:
/// overview → tutorial → headphones → projecting → completion.
enum _ResonancePhase { overview, tutorial, projecting, completion }

class CrystalResonanceScreen extends ConsumerStatefulWidget {
  const CrystalResonanceScreen({super.key, required this.crystal});

  final Crystal crystal;

  @override
  ConsumerState<CrystalResonanceScreen> createState() =>
      _CrystalResonanceScreenState();
}

class _CrystalResonanceScreenState
    extends ConsumerState<CrystalResonanceScreen> {
  static const Duration _phaseDuration = Duration(milliseconds: 500);

  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<Duration> _position = ValueNotifier(Duration.zero);

  /// Furthest point really played. The bar rewinds freely but never jumps
  /// past this, so the frequency is listened to in full.
  final ValueNotifier<Duration> _furthest = ValueNotifier(Duration.zero);
  final CymaticHeadphonesPrompts _prompts = CymaticHeadphonesPrompts(
    SharedPreferencesAsync(),
  );
  final CrystalTutorialProgress _progress = CrystalTutorialProgress(
    SharedPreferencesAsync(),
  );
  late final StreamSubscription<PlayerState> _playerStateSubscription;
  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<void> _playerCompleteSubscription;

  /// Stand-in for the player when there is no audio: the plate keeps its
  /// simulated pulse and the ritual still ends after the real track length.
  final Stopwatch _simulatedClock = Stopwatch();
  Timer? _simulatedEnd;

  _ResonancePhase _phase = _ResonancePhase.overview;
  bool _isPlaying = false;
  bool _isAudioUnavailable = false;
  bool _controlsVisible = false;
  bool _followPlayerPause = false;
  bool _choosing = false;
  bool _reminding = false;
  bool _starting = false;
  int _playbackToken = 0;
  CymaticEnvelope? _envelope;

  Crystal get _crystal => widget.crystal;

  bool get _projecting => _phase == _ResonancePhase.projecting;

  @override
  void initState() {
    super.initState();
    ref.read(massageVideoPreheatProvider).warm(massageVideoWarmOrder);
    _playerStateSubscription = _player.onPlayerStateChanged.listen(
      _handlePlayerStateChanged,
    );
    _positionSubscription = _player.onPositionChanged.listen((position) {
      _position.value = position;
      if (_isPlaying && position > _furthest.value) {
        _furthest.value = position;
      }
    });
    _playerCompleteSubscription = _player.onPlayerComplete.listen((_) {
      if (_projecting) unawaited(_finishResonance(trackEnded: true));
    });
    _loadEnvelope();
    unawaited(loadCymaticPlate(_crystal));
  }

  @override
  void dispose() {
    _simulatedEnd?.cancel();
    unawaited(_restorePortraitChrome());
    _playerStateSubscription.cancel();
    _positionSubscription.cancel();
    _playerCompleteSubscription.cancel();
    _position.dispose();
    _furthest.dispose();
    _player.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- flow ---

  void _openTutorial() {
    if (!mounted) return;
    setState(() => _phase = _ResonancePhase.tutorial);
  }

  void _showOverview() {
    if (!mounted) return;
    setState(() => _phase = _ResonancePhase.overview);
  }

  /// START YOUR FREQUENCY: asks about the tutorial first, unless it was
  /// already watched.
  Future<void> _handleStartFrequencyPressed() async {
    if (_reminding) return;
    _reminding = true;
    try {
      final watched = await _progress.hasWatched(_crystal);
      if (!mounted) return;
      if (watched) {
        await _beginResonance();
        return;
      }
      final choice = await _TutorialReminderDialog.show(context);
      if (!mounted) return;
      switch (choice) {
        case _TutorialReminderChoice.watch:
          _openTutorial();
        case _TutorialReminderChoice.continueAnyway:
          await _beginResonance();
        case null:
          break;
      }
    } finally {
      _reminding = false;
    }
  }

  /// Headphones note, then the cymatic. Also the entry from the tutorial.
  Future<void> _beginResonance() async {
    if (!mounted || _starting || _projecting) return;
    _starting = true;
    try {
      final proceed = await _HeadphonesDialog.show(context);
      if (!mounted || proceed != true) return;
      await _prompts.recordShown();
      if (!mounted) return;
      await _enterProjection();
    } finally {
      _starting = false;
    }
  }

  Future<void> _enterProjection() async {
    final token = ++_playbackToken;
    _followPlayerPause = false;
    _stopSimulatedClock(reset: true);
    _position.value = Duration.zero;
    _furthest.value = Duration.zero;
    setState(() {
      _phase = _ResonancePhase.projecting;
      _controlsVisible = false;
      _isPlaying = true;
      _isAudioUnavailable = false;
    });
    await _allowRotationImmersive();
    if (!mounted || token != _playbackToken) return;
    await _startFrequency(token);
  }

  /// Back from the projection: leaves without the closing screen.
  Future<void> _exitProjection() async {
    _playbackToken++;
    _followPlayerPause = false;
    _stopSimulatedClock(reset: true);
    if (mounted) {
      setState(() {
        _phase = _ResonancePhase.overview;
        _controlsVisible = false;
        _isPlaying = false;
        _isAudioUnavailable = false;
      });
    }
    await _restorePortraitChrome();
    await _stopPlayer('Cymatic stop');
  }

  /// Share of the track that counts the crystal step as done when Stop is
  /// pressed before the end.
  static const double _frequencyDoneShare = 0.8;

  /// Whether enough of the frequency played for today's crystal step. Read
  /// before the clocks are reset.
  bool _frequencyListenedEnough({required bool trackEnded}) {
    if (trackEnded) return true;
    final total = _envelope?.duration;
    // Unknown length: Stop is the only way out, so it counts.
    if (total == null || total == Duration.zero) return true;
    // The furthest point counts: rewinding to repeat a part does not undo
    // what was already listened to.
    final played = _isAudioUnavailable
        ? _simulatedClock.elapsed
        : (_position.value > _furthest.value
              ? _position.value
              : _furthest.value);
    return played.inMilliseconds >= total.inMilliseconds * _frequencyDoneShare;
  }

  /// The track ended, or Stop was pressed: on to the closing screen.
  Future<void> _finishResonance({bool trackEnded = false}) async {
    if (!_projecting) return;
    final listened = _frequencyListenedEnough(trackEnded: trackEnded);
    final todayBefore = ref.read(todayRitualProvider);
    final marking = listened
        ? ref.read(ritualCycleControllerProvider.notifier).markFrequency()
        : null;
    _playbackToken++;
    _followPlayerPause = false;
    _stopSimulatedClock(reset: true);
    if (mounted) {
      setState(() {
        _phase = _ResonancePhase.completion;
        _controlsVisible = false;
        _isPlaying = false;
        _isAudioUnavailable = false;
      });
    }
    await _restorePortraitChrome();
    await _stopPlayer('Cymatic finish');
    if (marking == null) return;
    try {
      await marking;
    } catch (_) {
      // Kept on the device for the next sync; nothing to celebrate yet.
      return;
    }
    if (!mounted) return;
    // The closing screen already thanks the member; the dialog only appears
    // when the crystal was the last step of the day.
    await celebrateStep(
      context,
      ref,
      step: RitualStep.crystal,
      before: todayBefore,
      onlyWhenDayCompletes: true,
    );
  }

  Future<void> _stopPlayer(String action) async {
    try {
      await _player.stop();
    } catch (error, stackTrace) {
      reportAudioFailure(action, error, stackTrace);
    }
  }

  /// A touch on the playing cymatic pauses it and shows the controls. While
  /// paused, a touch only toggles the controls; PLAY resumes.
  void _handleSurfaceTap() {
    if (_isPlaying) {
      setState(() => _controlsVisible = true);
      unawaited(_handleTogglePlayback());
      return;
    }
    setState(() => _controlsVisible = !_controlsVisible);
  }

  Future<void> _allowRotationImmersive() async {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _restorePortraitChrome() async {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> _loadEnvelope() async {
    final envelope = await loadCymaticEnvelope(_crystal.audioAsset);
    if (!mounted) return;
    setState(() => _envelope = envelope);
  }

  void _handlePlayerStateChanged(PlayerState playerState) {
    if (!mounted || _isAudioUnavailable || !_projecting) return;
    final playing = playerState == PlayerState.playing;
    if (!playing && !_followPlayerPause) return;
    setState(() => _isPlaying = playing);
  }

  // --------------------------------------------------------------- audio ---

  Future<void> _startFrequency(int token) async {
    try {
      // One pass: the ritual ends when the track does.
      await _player.setReleaseMode(ReleaseMode.release);
      if (!mounted || token != _playbackToken) return;
      final path = await ref
          .read(crystalAudioCacheProvider)
          .resolve(_crystal.audioAsset);
      if (!mounted || token != _playbackToken) return;
      if (path == null) {
        _useSimulatedPlayback(token);
        return;
      }
      await _player.play(DeviceFileSource(path));
    } catch (error, stackTrace) {
      reportAudioFailure('Cymatic play', error, stackTrace);
      if (!mounted || token != _playbackToken) return;
      // No player here: the projection keeps the simulated rhythm.
      _useSimulatedPlayback(token);
    }
  }

  void _useSimulatedPlayback(int token) {
    setState(() {
      _isAudioUnavailable = true;
      _isPlaying = true;
    });
    _simulatedClock
      ..reset()
      ..start();
    _scheduleSimulatedEnd(token);
  }

  /// Closes the ritual after the real track length when there is no audio.
  /// Without an envelope the length is unknown and Stop is the way out.
  void _scheduleSimulatedEnd(int token) {
    _simulatedEnd?.cancel();
    final total = _envelope?.duration;
    if (total == null || total == Duration.zero) return;
    final remaining = total - _simulatedClock.elapsed;
    _simulatedEnd = Timer(remaining.isNegative ? Duration.zero : remaining, () {
      if (!mounted || token != _playbackToken) return;
      unawaited(_finishResonance(trackEnded: true));
    });
  }

  void _stopSimulatedClock({bool reset = false}) {
    _simulatedEnd?.cancel();
    _simulatedEnd = null;
    _simulatedClock.stop();
    if (reset) _simulatedClock.reset();
  }

  Future<void> _handleTogglePlayback() async {
    if (_isAudioUnavailable) {
      final resuming = !_isPlaying;
      setState(() {
        _isPlaying = resuming;
        // Play hides the panel, like the rituals; pause keeps it up.
        if (resuming) _controlsVisible = false;
      });
      if (resuming) {
        _simulatedClock.start();
        _scheduleSimulatedEnd(_playbackToken);
      } else {
        _stopSimulatedClock();
      }
      return;
    }
    if (_isPlaying) {
      _followPlayerPause = true;
      setState(() => _isPlaying = false);
      try {
        await _player.pause();
      } catch (error, stackTrace) {
        reportAudioFailure('Cymatic pause', error, stackTrace);
        if (!mounted) return;
        setState(() => _isAudioUnavailable = true);
      }
      return;
    }
    _followPlayerPause = false;
    setState(() {
      _isPlaying = true;
      // Play hides the panel, like the rituals; pause keeps it up.
      _controlsVisible = false;
    });
    try {
      await _player.resume();
    } catch (error, stackTrace) {
      reportAudioFailure('Cymatic resume', error, stackTrace);
      if (!mounted) return;
      _useSimulatedPlayback(_playbackToken);
    }
  }

  /// Moves the frequency to [target]. Back is free; forward stops at the
  /// furthest point already played, and never at the very end, so the
  /// ritual still finishes by listening.
  Future<void> _seekTo(Duration target) async {
    if (_isAudioUnavailable) return;
    final total = _envelope?.duration;
    var bounded = target.isNegative ? Duration.zero : target;
    if (bounded > _furthest.value) bounded = _furthest.value;
    if (total != null) {
      final lastSecond = total - const Duration(seconds: 1);
      if (bounded > lastSecond) bounded = lastSecond;
    }
    _position.value = bounded;
    try {
      await _player.seek(bounded);
    } catch (error, stackTrace) {
      reportAudioFailure('Cymatic seek', error, stackTrace);
    }
  }

  // ------------------------------------------------------------- actions ---

  /// Updates the active crystal for Home / sound. Does not rewrite the
  /// Listening Garden skin-care protocol stored in journey recommendation.
  Future<void> _handleChooseCrystal() async {
    if (_choosing) return;
    setState(() => _choosing = true);
    try {
      await ref.read(selectedCrystalProvider.notifier).select(_crystal);
      // The 30-day cycle in progress continues with the new crystal.
      await ref
          .read(ritualCycleControllerProvider.notifier)
          .changeCrystal(_crystal);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.crystalChosenSnackbar(_crystal.localizedName(l10n)),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _choosing = false);
    }
  }

  void _handleBackPressed() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.home);
  }

  /// Pushes the crystal's own Library route (a child of this screen's route),
  /// so Back returns here. Pushing the Library tab's route from this
  /// top-level route would reserve that branch's Navigator key a second time
  /// and crash with `!keyReservation.contains(key)`.
  void _openLibrary() {
    context.push(AppRoutes.crystalLibraryFor(_crystal.name));
  }

  void _handlePopBlocked() {
    switch (_phase) {
      case _ResonancePhase.projecting:
        unawaited(_exitProjection());
      case _ResonancePhase.tutorial:
      case _ResonancePhase.completion:
        _showOverview();
      case _ResonancePhase.overview:
        break;
    }
  }

  // --------------------------------------------------------------- build ---

  Widget _buildPhase(bool isSelected) {
    return switch (_phase) {
      _ResonancePhase.overview => _CrystalOverview(
        crystal: _crystal,
        isSelected: isSelected,
        choosing: _choosing,
        onBack: _handleBackPressed,
        onTutorial: _openTutorial,
        onStart: () => unawaited(_handleStartFrequencyPressed()),
        onLibrary: _openLibrary,
        onChoose: () => unawaited(_handleChooseCrystal()),
      ),
      _ResonancePhase.tutorial => MassageScreen(
        surface: MassageSurface.tutorial,
        onBack: _showOverview,
        onCompleted: () => _progress.markWatched(_crystal),
        onContinue: () => unawaited(_beginResonance()),
      ),
      _ResonancePhase.projecting => _ProjectionStage(
        crystal: _crystal,
        playing: _isPlaying,
        controlsVisible: _controlsVisible,
        envelope: _isAudioUnavailable ? null : _envelope,
        playbackPosition: _position,
        furthestPosition: _furthest,
        // Without real audio there is nothing to move through.
        trackLength: _isAudioUnavailable ? null : _envelope?.duration,
        onSeek: (target) => unawaited(_seekTo(target)),
        onSurfaceTap: _handleSurfaceTap,
        onTogglePlayback: _handleTogglePlayback,
        onStop: () => unawaited(_finishResonance()),
      ),
      _ResonancePhase.completion => _ResonanceCompletion(
        crystal: _crystal,
        onComplete: () => context.go(AppRoutes.home),
        onExplore: () => context.go(AppRoutes.fourTemples),
        onWhy: _openLibrary,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = ref.watch(selectedCrystalProvider).value == _crystal;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return PopScope(
      canPop: _phase == _ResonancePhase.overview,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handlePopBlocked();
      },
      child: Scaffold(
        backgroundColor: _projecting
            ? AppColors.indigoBlue
            : resonanceChamberColor,
        body: AnimatedSwitcher(
          duration: reduceMotion ? Duration.zero : _phaseDuration,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeIn,
          layoutBuilder: (current, previous) =>
              Stack(fit: StackFit.expand, children: [...previous, ?current]),
          child: KeyedSubtree(
            key: ValueKey(_phase),
            child: _buildPhase(isSelected),
          ),
        ),
      ),
    );
  }
}

/// Crystal photo that softly gives way to the cymatic.
class _ProjectionStage extends StatelessWidget {
  const _ProjectionStage({
    required this.crystal,
    required this.playing,
    required this.controlsVisible,
    required this.envelope,
    required this.playbackPosition,
    required this.furthestPosition,
    required this.trackLength,
    required this.onSeek,
    required this.onSurfaceTap,
    required this.onTogglePlayback,
    required this.onStop,
  });

  static const Duration _crossfade = Duration(milliseconds: 1000);

  final Crystal crystal;
  final bool playing;
  final bool controlsVisible;
  final CymaticEnvelope? envelope;
  final ValueNotifier<Duration> playbackPosition;
  final ValueListenable<Duration> furthestPosition;
  final Duration? trackLength;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onSurfaceTap;
  final VoidCallback onTogglePlayback;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        CymaticProjection(
          crystal: crystal,
          playing: playing,
          controlsVisible: controlsVisible,
          envelope: envelope,
          playbackPosition: playbackPosition,
          furthestPosition: furthestPosition,
          trackLength: trackLength,
          onSeek: onSeek,
          onSurfaceTap: onSurfaceTap,
          onTogglePlayback: onTogglePlayback,
          onStop: onStop,
        ),
        if (!reduceMotion)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: _crossfade,
            curve: Curves.easeInOut,
            builder: (context, t, _) {
              if (t >= 1) return const SizedBox.shrink();
              return IgnorePointer(
                child: Opacity(
                  opacity: 1 - t,
                  child: Transform.scale(
                    scale: 1 + 0.08 * t,
                    child: ColoredBox(
                      color: resonanceChamberColor,
                      child: CrystalCymaticPortrait(crystal: crystal),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Lets a column fill the viewport, or scroll when it needs more room.
class _FillOrScroll extends StatelessWidget {
  const _FillOrScroll({required this.minHeight, required this.child});

  final double minHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: SizedBox(
          height: math.max(constraints.maxHeight, minHeight),
          child: child,
        ),
      ),
    );
  }
}

/// Room the fixed parts of a screen need at the current text scale, so the
/// photo is what gives way first.
double _fixedContentHeight(BuildContext context, double base) {
  final scale = MediaQuery.textScalerOf(context).scale(10) / 10;
  return base + 140 * (scale - 1);
}

class _CrystalOverview extends ConsumerWidget {
  const _CrystalOverview({
    required this.crystal,
    required this.isSelected,
    required this.choosing,
    required this.onBack,
    required this.onTutorial,
    required this.onStart,
    required this.onLibrary,
    required this.onChoose,
  });

  static const double _minPhotoHeight = 140;

  final Crystal crystal;
  final bool isSelected;
  final bool choosing;
  final VoidCallback onBack;
  final VoidCallback onTutorial;
  final VoidCallback onStart;
  final VoidCallback onLibrary;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final insets = MediaQuery.paddingOf(context);
    final duration = ref.watch(crystalTrackDurationProvider(crystal)).value;

    return _FillOrScroll(
      minHeight:
          _fixedContentHeight(context, 440) + _minPhotoHeight + insets.vertical,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s24,
              insets.top + AppSpacing.s4,
              AppSpacing.s24,
              AppSpacing.s4,
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: HikaruBackButton(onPressed: onBack),
                ),
                _CrystalIntroduction(crystal: crystal, isSelected: isSelected),
              ],
            ),
          ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: CrystalCymaticPortrait(crystal: crystal),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s32,
              AppSpacing.s4,
              AppSpacing.s32,
              AppSpacing.s20,
            ),
            child: _FrequencyInfo(crystal: crystal, duration: duration),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s40),
            child: Column(
              children: [
                _GhostPillButton(
                  label: l10n.crystalTutorialButton,
                  icon: Icons.play_circle_outline_rounded,
                  onPressed: onTutorial,
                ),
                const SizedBox(height: AppSpacing.s12),
                HikaruPillButton(
                  label: l10n.crystalStartFrequencyButton,
                  onPressed: onStart,
                  buttonHeight: _actionHeight,
                  blurRadius: 14,
                  shadowAlpha: 0.22,
                  labelStyle: _actionLabel,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _QuietLink(
                    label: l10n.crystalYourCrystalLibraryButton,
                    icon: Icons.auto_stories_outlined,
                    onPressed: onLibrary,
                  ),
                ),
                if (!isSelected) ...[
                  const SizedBox(width: AppSpacing.s10),
                  Expanded(
                    child: _QuietLink(
                      label: l10n.crystalChoose,
                      icon: Icons.favorite_border_rounded,
                      onPressed: choosing ? null : onChoose,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: math.max(AppSpacing.s8, insets.bottom)),
        ],
      ),
    );
  }
}

/// Slimmer than the default pill, so the two actions feel lighter.
const double _actionHeight = AppSpacing.s44 + AppSpacing.s4;

final TextStyle _actionLabel = AppTypography.pillLabel.copyWith(
  fontSize: AppFontSizes.s11,
  letterSpacing: 2.2,
);

/// "YOUR FREQUENCY · 5:20", the frequency name and what it supports.
class _FrequencyInfo extends StatelessWidget {
  const _FrequencyInfo({required this.crystal, required this.duration});

  final Crystal crystal;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final length = duration == null ? null : formatTrackDuration(duration!);
    final eyebrow = length == null
        ? l10n.resonanceYourFrequency
        : '${l10n.resonanceYourFrequency}  ·  $length';

    return Column(
      children: [
        Semantics(
          label: length == null
              ? l10n.resonanceYourFrequency
              : '${l10n.resonanceYourFrequency}. '
                    '${l10n.crystalTrackDurationSemantics(length)}',
          excludeSemantics: true,
          child: Text(
            eyebrow,
            textAlign: TextAlign.center,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.champagneGold,
              fontSize: AppFontSizes.s9,
              letterSpacing: 2.2,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s6),
        Text(
          crystal.localizedFrequency(l10n),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.headline.copyWith(
            color: AppColors.white,
            fontSize: AppFontSizes.s16,
            fontWeight: FontWeight.w300,
            height: 1.3,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          crystal.localizedFrequencyDetail(l10n),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _bodyStyle.copyWith(
            color: AppColors.fog.withValues(alpha: 0.8),
            fontSize: AppFontSizes.s11,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Same size as the gold pill, but light: a thin gold outline over a faint
/// indigo glass, for the action that comes before the frequency.
class _GhostPillButton extends StatelessWidget {
  const _GhostPillButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: AppColors.indigoBlue.withValues(alpha: 0.35),
        shape: StadiumBorder(
          side: BorderSide(
            color: AppColors.champagneGold.withValues(alpha: 0.75),
            width: 0.8,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: _actionHeight,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: AppColors.champagneGold, size: 18),
                    const SizedBox(width: AppSpacing.s8),
                    Text(
                      label,
                      maxLines: 1,
                      style: _actionLabel.copyWith(
                        color: AppColors.champagneGold,
                      ),
                    ),
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

/// Small gold link with an icon, readable but quieter than the buttons.
class _QuietLink extends StatelessWidget {
  const _QuietLink({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: AppColors.champagneGold.withValues(alpha: 0.06),
        shape: StadiumBorder(
          side: BorderSide(
            color: AppColors.champagneGold.withValues(alpha: 0.55),
            width: 0.8,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: AppSpacing.s44,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: AppColors.champagneGold, size: 18),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        label,
                        maxLines: 1,
                        style: AppTypography.subheadline.copyWith(
                          color: AppColors.champagneGold,
                          fontSize: AppFontSizes.s11,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small gold tag beside the temple when this is the user's crystal.
class _YourCrystalChip extends StatelessWidget {
  const _YourCrystalChip({required this.crystal});

  final Crystal crystal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.crystalIsYoursSemantics(crystal.localizedName(l10n)),
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: AppColors.champagneGold.withValues(alpha: 0.08),
          shape: StadiumBorder(
            side: BorderSide(
              color: AppColors.champagneGold.withValues(alpha: 0.7),
              width: 0.8,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s10,
            vertical: AppSpacing.s3,
          ),
          child: Text(
            l10n.crystalIsYours,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.champagneGold,
              fontSize: AppFontSizes.s9,
              letterSpacing: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}

class _CrystalIntroduction extends StatelessWidget {
  const _CrystalIntroduction({required this.crystal, required this.isSelected});

  final Crystal crystal;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            crystal.localizedName(l10n),
            maxLines: 1,
            textAlign: TextAlign.center,
            style: AppTypography.headline.copyWith(
              color: AppColors.white,
              fontSize: AppFontSizes.s22,
              height: 1.2,
              letterSpacing: 4.4,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s4,
          children: [
            Text(
              crystal.localizedTemple(l10n),
              textAlign: TextAlign.center,
              style: AppTypography.footnote.copyWith(
                color: AppColors.fog,
                fontSize: AppFontSizes.s12,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.6,
              ),
            ),
            if (isSelected) _YourCrystalChip(crystal: crystal),
          ],
        ),
      ],
    );
  }
}

/// Closing screen once the track ends or Stop is pressed.
class _ResonanceCompletion extends ConsumerWidget {
  const _ResonanceCompletion({
    required this.crystal,
    required this.onComplete,
    required this.onExplore,
    required this.onWhy,
  });

  static const double _minPhotoHeight = 140;

  final Crystal crystal;
  final VoidCallback onComplete;
  final VoidCallback onExplore;
  final VoidCallback onWhy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final insets = MediaQuery.paddingOf(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final isRecommended =
        ref.watch(journeyRecommendationControllerProvider).value?.crystal ==
        crystal;
    final whyLabel = isRecommended
        ? l10n.libraryCrystalHeadingWhyRecommended
        : l10n.resonanceDiscoverInLibraryLink;

    return _FillOrScroll(
      minHeight:
          _fixedContentHeight(context, 380) + _minPhotoHeight + insets.vertical,
      child: Column(
        children: [
          SizedBox(height: insets.top + AppSpacing.s16),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, opacity, child) =>
                  Opacity(opacity: opacity, child: child),
              child: SizedBox(
                width: double.infinity,
                child: CrystalCymaticPortrait(crystal: crystal),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s32,
              AppSpacing.s12,
              AppSpacing.s32,
              AppSpacing.s20,
            ),
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.resonanceReturnTitle,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: AppTypography.headline.copyWith(
                      color: AppColors.white,
                      fontSize: AppFontSizes.s16,
                      letterSpacing: 3.2,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  l10n.resonanceReturnSubtitle,
                  textAlign: TextAlign.center,
                  style: _bodyStyle.copyWith(
                    color: AppColors.champagneGold,
                    height: 1.4,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s32),
            child: Column(
              children: [
                HikaruPillButton(
                  label: l10n.resonanceCompleteRitual,
                  onPressed: onComplete,
                  buttonHeight: AppSpacing.s56,
                ),
                const SizedBox(height: AppSpacing.s12),
                HikaruOutlineButton(
                  label: l10n.resonanceExploreAnotherTemple,
                  onPressed: onExplore,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s24,
              vertical: AppSpacing.s8,
            ),
            child: _LibraryInvitation(
              title: l10n.resonanceExploreMeaning,
              detail: whyLabel,
              onPressed: onWhy,
            ),
          ),
          SizedBox(height: math.max(AppSpacing.s8, insets.bottom)),
        ],
      ),
    );
  }
}

/// The suggestion that closes the ritual: a gold-edged card that opens the
/// crystal's topic in the Library.
class _LibraryInvitation extends StatelessWidget {
  const _LibraryInvitation({
    required this.title,
    required this.detail,
    required this.onPressed,
  });

  final String title;
  final String detail;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $detail',
      excludeSemantics: true,
      child: Material(
        color: AppColors.champagneGold.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.r16),
          side: BorderSide(
            color: AppColors.champagneGold.withValues(alpha: 0.55),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s12,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_stories_outlined,
                  size: 22,
                  color: AppColors.champagneGold,
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.headline.copyWith(
                          color: AppColors.white,
                          fontSize: AppFontSizes.s14,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        detail,
                        style: AppTypography.body.copyWith(
                          color: AppColors.champagneGold,
                          fontSize: AppFontSizes.s11,
                          letterSpacing: 0.4,
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
}

// ------------------------------------------------------------- dialogs ---

const Duration _dialogTransition = Duration(milliseconds: 280);
const double _dialogBackdropBlur = 6;

/// Blurred, fading dialog shared by the headphones note and the tutorial
/// reminder. Honors reduce motion.
Future<T?> _showResonanceDialog<T>(BuildContext context, Widget dialog) {
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.darkIndigoBlue.withValues(alpha: 0.55),
    transitionDuration: reduceMotion ? Duration.zero : _dialogTransition,
    pageBuilder: (context, animation, secondaryAnimation) => dialog,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final eased = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: _dialogBackdropBlur * animation.value,
          sigmaY: _dialogBackdropBlur * animation.value,
        ),
        child: FadeTransition(
          opacity: eased,
          child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(eased),
            child: child,
          ),
        ),
      );
    },
  );
}

/// Smaller pill label so the dialog buttons hold their text at large scales.
final TextStyle _dialogPillLabel = AppTypography.pillLabel.copyWith(
  fontSize: AppFontSizes.s10,
  letterSpacing: 1.2,
);

/// Card shared by the dialogs of this screen.
class _ResonanceDialogCard extends StatelessWidget {
  const _ResonanceDialogCard({
    required this.semanticsLabel,
    required this.children,
  });

  static const double _maxWidth = 328;

  final String semanticsLabel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Semantics(
            scopesRoute: true,
            namesRoute: true,
            explicitChildNodes: true,
            label: semanticsLabel,
            child: Material(
              type: MaterialType.transparency,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.r28),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.indigoBlue.withValues(alpha: 0.96),
                      resonanceChamberColor.withValues(alpha: 0.98),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.champagneGold.withValues(alpha: 0.45),
                    width: 0.6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.champagneGold.withValues(alpha: 0.12),
                      blurRadius: 32,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s20,
                    AppSpacing.s32,
                    AppSpacing.s20,
                    AppSpacing.s24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _TutorialReminderChoice { watch, continueAnyway }

/// Shown when the frequency is started before the tutorial was watched.
class _TutorialReminderDialog extends StatelessWidget {
  const _TutorialReminderDialog();

  static Future<_TutorialReminderChoice?> show(BuildContext context) =>
      _showResonanceDialog<_TutorialReminderChoice>(
        context,
        const _TutorialReminderDialog(),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _ResonanceDialogCard(
      semanticsLabel: l10n.crystalTutorialButton,
      children: [
        Text(
          l10n.crystalTutorialReminderBody,
          textAlign: TextAlign.center,
          style: _bodyStyle.copyWith(
            color: AppColors.white,
            fontSize: AppFontSizes.s13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.s24),
        HikaruPillButton(
          label: l10n.crystalWatchTutorial,
          onPressed: () =>
              Navigator.of(context).pop(_TutorialReminderChoice.watch),
          buttonHeight: AppSpacing.s52,
          blurRadius: 12,
          shadowAlpha: 0.25,
          labelStyle: _dialogPillLabel,
        ),
        const SizedBox(height: AppSpacing.s12),
        HikaruOutlineButton(
          label: l10n.crystalContinueToResonance,
          onPressed: () =>
              Navigator.of(context).pop(_TutorialReminderChoice.continueAnyway),
        ),
      ],
    );
  }
}

/// Gentle note before the cymatic plays: the Hikaru frequency is meant to be
/// heard in stereo. Headphones are recommended but never required — the user
/// can continue without them. The chamber blurs softly behind it.
///
/// Returns `true` once the user chooses to continue (with or without
/// headphones), or `null` if the dialog is dismissed without a choice.
class _HeadphonesDialog extends StatefulWidget {
  const _HeadphonesDialog();

  static const double _iconRing = 72;

  /// A soft chime played when the note appears. Optional: if the asset is
  /// missing playback fails silently and the dialog still shows.
  static const String _chimeAsset = 'audio/notification.m4a';

  static Future<bool?> show(BuildContext context) =>
      _showResonanceDialog<bool>(context, const _HeadphonesDialog());

  @override
  State<_HeadphonesDialog> createState() => _HeadphonesDialogState();
}

class _HeadphonesDialogState extends State<_HeadphonesDialog> {
  final AudioPlayer _chime = AudioPlayer();

  @override
  void initState() {
    super.initState();
    unawaited(_playChime());
  }

  @override
  void dispose() {
    unawaited(_chime.dispose());
    super.dispose();
  }

  Future<void> _playChime() async {
    try {
      await _chime.setReleaseMode(ReleaseMode.release);
      await _chime.play(
        AssetSource(_HeadphonesDialog._chimeAsset),
        volume: 0.4,
      );
    } catch (error, stackTrace) {
      // Optional cue: a missing asset must never block the note.
      reportAudioFailure('Headphones chime', error, stackTrace);
    }
  }

  void _handleContinue() => Navigator.of(context).pop(true);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _ResonanceDialogCard(
      semanticsLabel: l10n.headphonesDialogSemanticsLabel,
      children: [
        Container(
          width: _HeadphonesDialog._iconRing,
          height: _HeadphonesDialog._iconRing,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.champagneGold.withValues(alpha: 0.08),
            border: Border.all(
              color: AppColors.champagneGold.withValues(alpha: 0.6),
              width: 0.75,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.champagneGold.withValues(alpha: 0.28),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.headphones_outlined,
            color: AppColors.champagneGold,
            size: AppSpacing.s32,
          ),
        ),
        const SizedBox(height: AppSpacing.s24),
        Text(
          l10n.headphonesDialogEyebrow,
          textAlign: TextAlign.center,
          style: AppTypography.subheadline.copyWith(
            color: AppColors.champagneGold,
            fontSize: AppFontSizes.s11,
            letterSpacing: 2.4,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Text(
          l10n.headphonesDialogBody,
          textAlign: TextAlign.center,
          style: _bodyStyle.copyWith(
            color: AppColors.white,
            fontSize: AppFontSizes.s14,
            fontWeight: FontWeight.w300,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.s28),
        HikaruPillButton(
          label: l10n.headphonesDialogReady,
          onPressed: _handleContinue,
          buttonHeight: AppSpacing.s52,
          blurRadius: 12,
          shadowAlpha: 0.25,
          labelStyle: _dialogPillLabel,
        ),
        const SizedBox(height: AppSpacing.s12),
        HikaruOutlineButton(
          label: l10n.headphonesDialogContinueWithout,
          onPressed: _handleContinue,
        ),
      ],
    );
  }
}
