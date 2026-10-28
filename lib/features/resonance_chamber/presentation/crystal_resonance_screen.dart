import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/audio_report.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../crystals/domain/crystal.dart';
import '../../journey/application/ritual_cycle_controller.dart';
import '../data/crystal_audio_store.dart';
import '../data/cymatic_headphones_prompts.dart';
import '../domain/cymatic_audio.dart';
import 'crystal_scene_photo.dart';
import 'crystal_temple_pages.dart';
import 'cymatic_audio_loader.dart';
import 'cymatic_kaleidoscope.dart';
import 'cymatic_projection.dart';
import 'resonance_sections.dart';

final TextStyle _bodyStyle = AppTypography.headline.copyWith(
  color: AppColors.white,
  fontSize: AppFontSizes.s12,
  height: 1.6,
  letterSpacing: 0.2,
);

enum _CrystalStage { temple, tutorial, resonance, closing }

class CrystalResonanceScreen extends ConsumerStatefulWidget {
  const CrystalResonanceScreen({super.key, required this.crystal});

  final Crystal crystal;

  @override
  ConsumerState<CrystalResonanceScreen> createState() =>
      _CrystalResonanceScreenState();
}

class _CrystalResonanceScreenState
    extends ConsumerState<CrystalResonanceScreen> {
  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<Duration> _position = ValueNotifier(Duration.zero);
  final CymaticHeadphonesPrompts _prompts = CymaticHeadphonesPrompts(
    SharedPreferencesAsync(),
  );
  late final StreamSubscription<PlayerState> _playerStateSubscription;
  late final StreamSubscription<Duration> _positionSubscription;
  bool _isPlaying = false;
  bool _isAudioUnavailable = false;
  bool _followPlayerPause = false;
  bool _cymaticVisible = false;
  bool _showCrystal = true;
  bool _resumeAfterTutorial = false;
  bool _closing = false;
  double _volume = 1;
  int _playbackToken = 0;
  _CrystalStage _stage = _CrystalStage.temple;
  Duration _audioDuration = Duration.zero;
  CymaticEnvelope? _envelope;
  late final StreamSubscription<Duration> _durationSubscription;
  late final StreamSubscription<void> _completeSubscription;

  Crystal get _crystal => widget.crystal;

  @override
  void initState() {
    super.initState();
    _playerStateSubscription = _player.onPlayerStateChanged.listen(
      _handlePlayerStateChanged,
    );
    _positionSubscription = _player.onPositionChanged.listen((position) {
      _position.value = position;
    });
    _durationSubscription = _player.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _audioDuration = duration);
    });
    _completeSubscription = _player.onPlayerComplete.listen((_) {
      if (!mounted || _stage != _CrystalStage.resonance) return;
      unawaited(_openClosing());
    });
    _loadEnvelope();
    unawaited(loadCymaticKaleidoscope());
  }

  @override
  void dispose() {
    unawaited(_restorePortraitChrome());
    _playerStateSubscription.cancel();
    _positionSubscription.cancel();
    _durationSubscription.cancel();
    _completeSubscription.cancel();
    _position.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _promptHeadphonesThenPlay() async {
    if (!mounted) return;
    final proceed = await _HeadphonesDialog.show(context);
    if (!mounted || proceed != true) return;
    await _prompts.recordShown();
    await _enterResonance();
  }

  Future<void> _enterResonance() async {
    final token = ++_playbackToken;
    _followPlayerPause = false;
    _closing = false;
    setState(() {
      _stage = _CrystalStage.resonance;
      _cymaticVisible = false;
      _showCrystal = true;
      _isPlaying = true;
    });
    unawaited(ref.read(ritualCycleControllerProvider.notifier).markFrequency());
    await _allowRotationImmersive();
    if (!mounted || token != _playbackToken) return;
    setState(() => _cymaticVisible = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted || token != _playbackToken) return;
    setState(() => _showCrystal = false);
    await _startFrequency(token);
  }

  Future<void> _openClosing() async {
    if (_closing || _stage == _CrystalStage.closing) return;
    _closing = true;
    _playbackToken++;
    if (mounted) {
      setState(() {
        _cymaticVisible = false;
        _showCrystal = true;
      });
    }
    await Future<void>.delayed(const Duration(milliseconds: 700));
    unawaited(_stopPlayback());
    await _restorePortraitChrome();
    if (!mounted) return;
    setState(() {
      _stage = _CrystalStage.closing;
      _isPlaying = false;
      _isAudioUnavailable = false;
      _cymaticVisible = false;
      _closing = false;
    });
  }

  Future<void> _stopPlayback() async {
    try {
      await _player.stop();
    } catch (error, stackTrace) {
      reportAudioFailure('Cymatic stop', error, stackTrace);
    }
  }

  Future<void> _setVolume(double value) async {
    setState(() => _volume = value);
    try {
      await _player.setVolume(value);
    } catch (error, stackTrace) {
      reportAudioFailure('Cymatic volume', error, stackTrace);
    }
  }

  Future<void> _replayTutorial() async {
    _followPlayerPause = true;
    final shouldPause = _isPlaying && !_isAudioUnavailable;
    if (!mounted) return;
    setState(() {
      _isPlaying = false;
      _resumeAfterTutorial = true;
      _stage = _CrystalStage.tutorial;
      _cymaticVisible = false;
    });
    if (shouldPause) {
      try {
        await _player.pause();
      } catch (error, stackTrace) {
        reportAudioFailure('Cymatic pause', error, stackTrace);
      }
    }
    await _restorePortraitChrome();
  }

  Future<void> _leaveTutorial() async {
    if (_resumeAfterTutorial) {
      _resumeAfterTutorial = false;
      setState(() {
        _stage = _CrystalStage.resonance;
        _cymaticVisible = true;
        _isPlaying = true;
      });
      await _allowRotationImmersive();
      if (_isAudioUnavailable) return;
      try {
        await _player.resume();
      } catch (error, stackTrace) {
        reportAudioFailure('Cymatic resume', error, stackTrace);
      }
      return;
    }
    await _promptHeadphonesThenPlay();
  }

  void _openLibrary() {
    context.push(AppRoutes.libraryTopicFor(_crystal.name));
  }

  void _completeRitual() => context.go(AppRoutes.home);

  void _exploreTemples() => context.go(AppRoutes.fourTemples);

  void _handleBackPressed() {
    if (_stage == _CrystalStage.tutorial) {
      if (_resumeAfterTutorial) {
        unawaited(_leaveTutorial());
      } else {
        setState(() => _stage = _CrystalStage.temple);
      }
      return;
    }
    if (_stage == _CrystalStage.closing) {
      setState(() => _stage = _CrystalStage.temple);
      return;
    }
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    final inResonance = _stage == _CrystalStage.resonance;

    return PopScope(
      canPop: !inResonance,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || !inResonance) return;
        unawaited(_openClosing());
      },
      child: Scaffold(
        backgroundColor: inResonance
            ? AppColors.indigoBlue
            : resonanceChamberColor,
        body: switch (_stage) {
          _CrystalStage.temple => CrystalTempleEntry(
            crystal: _crystal,
            insets: insets,
            onBack: _handleBackPressed,
            onLibrary: _openLibrary,
            onLearn: () => setState(() => _stage = _CrystalStage.tutorial),
            onEnterFrequency: () => unawaited(_promptHeadphonesThenPlay()),
          ),
          _CrystalStage.tutorial => CrystalTutorialPage(
            crystal: _crystal,
            insets: insets,
            onBack: _handleBackPressed,
            onFinished: () => unawaited(_leaveTutorial()),
          ),
          _CrystalStage.resonance => Stack(
            fit: StackFit.expand,
            children: [
              if (_showCrystal) CrystalScenePhoto(crystal: _crystal),
              AnimatedOpacity(
                opacity: _cymaticVisible ? 1 : 0,
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOut,
                child: CymaticProjection(
                  crystal: _crystal,
                  playing: _isPlaying,
                  envelope: _isAudioUnavailable ? null : _envelope,
                  playbackPosition: _position,
                  duration: _audioDuration,
                  volume: _volume,
                  onTogglePlayback: () => unawaited(_handleTogglePlayback()),
                  onStop: () => unawaited(_openClosing()),
                  onVolumeChanged: (value) => unawaited(_setVolume(value)),
                  onReplayTutorial: () => unawaited(_replayTutorial()),
                ),
              ),
            ],
          ),
          _CrystalStage.closing => CrystalCoherenceClose(
            crystal: _crystal,
            insets: insets,
            onComplete: _completeRitual,
            onExplore: _exploreTemples,
          ),
        },
      ),
    );
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
    if (!mounted || _isAudioUnavailable || _stage != _CrystalStage.resonance) {
      return;
    }
    final playing = playerState == PlayerState.playing;
    if (!playing && !_followPlayerPause) return;
    setState(() => _isPlaying = playing);
  }

  Future<void> _startFrequency(int token) async {
    try {
      await _player.setReleaseMode(ReleaseMode.release);
      await _player.setVolume(_volume);
      if (!mounted || token != _playbackToken) return;
      final path = await ref
          .read(crystalAudioCacheProvider)
          .resolve(_crystal.audioAsset);
      if (!mounted || token != _playbackToken) return;
      if (path == null) {
        setState(() {
          _isAudioUnavailable = true;
          _isPlaying = true;
        });
        return;
      }
      await _player.play(DeviceFileSource(path));
    } catch (error, stackTrace) {
      reportAudioFailure('Cymatic play', error, stackTrace);
      if (!mounted || token != _playbackToken) return;
      // No player here: the projection keeps the simulated rhythm.
      setState(() {
        _isAudioUnavailable = true;
        _isPlaying = true;
      });
    }
  }

  Future<void> _handleTogglePlayback() async {
    if (_isAudioUnavailable) {
      setState(() => _isPlaying = !_isPlaying);
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
    setState(() => _isPlaying = true);
    try {
      await _player.resume();
    } catch (error, stackTrace) {
      reportAudioFailure('Cymatic resume', error, stackTrace);
      if (!mounted) return;
      setState(() {
        _isAudioUnavailable = true;
        _isPlaying = true;
      });
    }
  }
}

class _HeadphonesDialog extends StatefulWidget {
  const _HeadphonesDialog();

  static const Duration _transition = Duration(milliseconds: 280);
  static const double _maxWidth = 300;
  static const double _iconRing = AppSpacing.s52;
  static const double _backdropBlur = 6;

  /// A soft chime played when the note appears. Optional: if the asset is
  /// missing playback fails silently and the dialog still shows.
  static const String _chimeAsset = 'audio/notification.m4a';

  static Future<bool?> show(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.darkIndigoBlue.withValues(alpha: 0.55),
      transitionDuration: reduceMotion ? Duration.zero : _transition,
      pageBuilder: (context, animation, secondaryAnimation) =>
          const _HeadphonesDialog(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final eased = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _backdropBlur * animation.value,
            sigmaY: _backdropBlur * animation.value,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: _HeadphonesDialog._maxWidth,
          ),
          child: Semantics(
            scopesRoute: true,
            namesRoute: true,
            explicitChildNodes: true,
            label: l10n.headphonesDialogSemanticsLabel,
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s28,
                    AppSpacing.s32,
                    AppSpacing.s28,
                    AppSpacing.s28,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: _HeadphonesDialog._iconRing,
                        height: _HeadphonesDialog._iconRing,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.champagneGold.withValues(
                            alpha: 0.08,
                          ),
                          border: Border.all(
                            color: AppColors.champagneGold.withValues(
                              alpha: 0.6,
                            ),
                            width: 0.75,
                          ),
                        ),
                        child: const Icon(
                          Icons.headphones_outlined,
                          color: AppColors.champagneGold,
                          size: AppSpacing.s24,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s20),
                      Text(
                        l10n.headphonesDialogEyebrow,
                        textAlign: TextAlign.center,
                        style: AppTypography.subheadline.copyWith(
                          color: AppColors.champagneGold,
                          fontSize: AppFontSizes.s10,
                          letterSpacing: 2.4,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text(
                        l10n.headphonesDialogTitle,
                        textAlign: TextAlign.center,
                        style: AppTypography.headline.copyWith(
                          color: AppColors.white,
                          fontSize: AppFontSizes.s18,
                          fontWeight: FontWeight.w300,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      Text(
                        l10n.headphonesDialogBody,
                        textAlign: TextAlign.center,
                        style: _bodyStyle.copyWith(
                          color: AppColors.fog,
                          fontSize: AppFontSizes.s11,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s28),
                      HikaruPillButton(
                        label: l10n.headphonesDialogReady,
                        onPressed: _handleContinue,
                        buttonHeight: AppSpacing.s44,
                        blurRadius: 12,
                        shadowAlpha: 0.25,
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
