import 'dart:async';
import 'dart:math' as math;
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
import '../../crystals/application/selected_crystal_controller.dart';
import '../../crystals/domain/crystal.dart';
import '../data/cymatic_headphones_prompts.dart';
import '../domain/cymatic_audio.dart';
import 'crystal_scene_photo.dart';
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

class CrystalResonanceScreen extends ConsumerStatefulWidget {
  const CrystalResonanceScreen({super.key, required this.crystal});

  final Crystal crystal;

  @override
  ConsumerState<CrystalResonanceScreen> createState() =>
      _CrystalResonanceScreenState();
}

class _CrystalResonanceScreenState
    extends ConsumerState<CrystalResonanceScreen> {
  static const EdgeInsets _sidePadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.s24,
  );
  static const double _heroScreenRatio = 0.36;
  static const double _minHeroHeight = 220;
  static const double _maxHeroHeight = 360;

  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<Duration> _position = ValueNotifier(Duration.zero);
  final CymaticHeadphonesPrompts _prompts = CymaticHeadphonesPrompts(
    SharedPreferencesAsync(),
  );
  late final StreamSubscription<PlayerState> _playerStateSubscription;
  late final StreamSubscription<Duration> _positionSubscription;
  bool _isPlaying = false;
  bool _isAudioUnavailable = false;
  bool _projecting = false;
  bool _controlsVisible = false;
  bool _followPlayerPause = false;
  int _playbackToken = 0;
  CymaticEnvelope? _envelope;

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
    _loadEnvelope();
    unawaited(loadCymaticKaleidoscope());
  }

  @override
  void dispose() {
    unawaited(_restorePortraitChrome());
    _playerStateSubscription.cancel();
    _positionSubscription.cancel();
    _position.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _handlePlayProjection() async {
    if (await _prompts.shouldShow()) {
      if (!mounted) return;
      await _HeadphonesDialog.show(context);
      if (!mounted) return;
      await _prompts.recordShown();
    }
    if (!mounted) return;
    await _enterProjection();
  }

  Future<void> _enterProjection() async {
    final token = ++_playbackToken;
    _followPlayerPause = false;
    setState(() {
      _projecting = true;
      _controlsVisible = false;
      _isPlaying = true;
    });
    await _allowRotationImmersive();
    if (!mounted || token != _playbackToken) return;
    await _startFrequency(token);
  }

  Future<void> _exitProjection() async {
    _playbackToken++;
    _followPlayerPause = false;
    if (mounted) {
      setState(() {
        _projecting = false;
        _controlsVisible = false;
        _isPlaying = false;
        _isAudioUnavailable = false;
      });
    }
    await _restorePortraitChrome();
    try {
      await _player.stop();
    } catch (error, stackTrace) {
      reportAudioFailure('Cymatic stop', error, stackTrace);
    }
  }

  void _handleSurfaceTap() {
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

  Future<void> _startFrequency(int token) async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      if (!mounted || token != _playbackToken) return;
      await _player.play(AssetSource(_crystal.audioAsset));
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

  Future<void> _handleChooseCrystal() async {
    await ref.read(selectedCrystalProvider.notifier).select(_crystal);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_crystal.displayName} is now your crystal.')),
    );
  }

  void _handleBackPressed() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final insets = mediaQuery.padding;
    final heroHeight = (mediaQuery.size.height * _heroScreenRatio).clamp(
      _minHeroHeight,
      _maxHeroHeight,
    );
    final isSelected = ref.watch(selectedCrystalProvider).value == _crystal;

    return PopScope(
      canPop: !_projecting,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || !_projecting) return;
        unawaited(_exitProjection());
      },
      child: Scaffold(
        backgroundColor: _projecting
            ? AppColors.indigoBlue
            : resonanceChamberColor,
        body: _projecting
            ? CymaticProjection(
                crystal: _crystal,
                playing: _isPlaying,
                controlsVisible: _controlsVisible,
                envelope: _isAudioUnavailable ? null : _envelope,
                playbackPosition: _position,
                onSurfaceTap: _handleSurfaceTap,
                onTogglePlayback: _handleTogglePlayback,
                onExit: () => unawaited(_exitProjection()),
              )
            : Column(
                children: [
                  Expanded(
                    child: ChamberScrollView(
                      padding: EdgeInsets.only(
                        top: insets.top + AppSpacing.s8,
                        bottom: AppSpacing.s16,
                      ),
                      children: [
                        Padding(
                          padding: _sidePadding,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: _BackButton(
                                  onPressed: _handleBackPressed,
                                ),
                              ),
                              _CrystalIntroduction(crystal: _crystal),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: heroHeight,
                          width: double.infinity,
                          child: CrystalScenePhoto(crystal: _crystal),
                        ),
                        Padding(
                          padding: _sidePadding,
                          child: Column(
                            children: [
                              _FrequencyPlayer(
                                crystal: _crystal,
                                isPlaying: false,
                                isUnavailable: false,
                                onToggle: () =>
                                    unawaited(_handlePlayProjection()),
                              ),
                              const SizedBox(height: AppSpacing.s24),
                              _CrystalDetail(
                                label: 'THERAPEUTIC PURPOSE',
                                text: _crystal.purpose,
                              ),
                              _CrystalDetail(
                                label: 'SKIN BENEFIT',
                                text: _crystal.skinBenefit,
                              ),
                              _CrystalDetail(
                                label: 'ILLUMINATED MERIDIANS',
                                text: _crystal.meridians,
                              ),
                              _CrystalDetail(
                                label: 'VISUAL ENVIRONMENT',
                                text: _crystal.environment,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.s32,
                      AppSpacing.s12,
                      AppSpacing.s32,
                      math.max(AppSpacing.s24, insets.bottom + AppSpacing.s12),
                    ),
                    child: isSelected
                        ? _YourCrystalBadge(crystal: _crystal)
                        : HikaruPillButton(
                            label: 'CHOOSE THIS CRYSTAL',
                            onPressed: _handleChooseCrystal,
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      excludeSemantics: true,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.champagneGold,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
        ),
        child: Text(
          'BACK',
          style: AppTypography.subheadline.copyWith(
            color: AppColors.champagneGold,
            fontSize: AppFontSizes.s11,
            letterSpacing: 1.8,
          ),
        ),
      ),
    );
  }
}

class _YourCrystalBadge extends StatelessWidget {
  const _YourCrystalBadge({required this.crystal});

  final Crystal crystal;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${crystal.displayName} is your crystal',
      excludeSemantics: true,
      child: Center(
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: AppColors.champagneGold.withValues(alpha: 0.08),
            shape: StadiumBorder(
              side: BorderSide(
                color: AppColors.champagneGold.withValues(alpha: 0.7),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s24,
              vertical: AppSpacing.s12,
            ),
            child: Text(
              'YOUR CRYSTAL',
              style: AppTypography.subheadline.copyWith(
                color: AppColors.champagneGold,
                fontSize: AppFontSizes.s12,
                letterSpacing: 2.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CrystalIntroduction extends StatelessWidget {
  const _CrystalIntroduction({required this.crystal});

  final Crystal crystal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ChamberTitle(),
        const SizedBox(height: AppSpacing.s14),
        Text(
          crystal.displayName,
          textAlign: TextAlign.center,
          style: AppTypography.headline.copyWith(
            color: AppColors.white,
            fontSize: AppFontSizes.s22,
            height: 1.2,
            letterSpacing: 4.4,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          crystal.temple,
          textAlign: TextAlign.center,
          style: AppTypography.footnote.copyWith(
            color: AppColors.fog,
            fontSize: AppFontSizes.s12,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

class _FrequencyPlayer extends StatelessWidget {
  const _FrequencyPlayer({
    required this.crystal,
    required this.isPlaying,
    required this.isUnavailable,
    required this.onToggle,
  });

  static const double _buttonSize = AppSpacing.s52;

  final Crystal crystal;
  final bool isPlaying;
  final bool isUnavailable;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final goldLabel = AppTypography.subheadline.copyWith(
      color: AppColors.champagneGold,
      fontSize: AppFontSizes.s9,
      letterSpacing: 1.2,
    );

    return Column(
      children: [
        const SectionHeading(label: 'YOUR FREQUENCY'),
        const SizedBox(height: AppSpacing.s14),
        Row(
          children: [
            Semantics(
              button: true,
              label: isPlaying ? 'Pause frequency' : 'Play frequency',
              excludeSemantics: true,
              child: InkResponse(
                onTap: isUnavailable ? null : onToggle,
                radius: _buttonSize / 2,
                child: Container(
                  width: _buttonSize,
                  height: _buttonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.darkIndigoBlue.withValues(alpha: 0.4),
                    border: Border.all(color: AppColors.champagneGold),
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: AppColors.champagneGold,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crystal.frequency,
                    style: AppTypography.headline.copyWith(
                      color: AppColors.white,
                      fontSize: AppFontSizes.s22,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    crystal.frequencyDetail,
                    style: _bodyStyle.copyWith(
                      color: AppColors.fog,
                      fontSize: AppFontSizes.s11,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  Text(
                    '${crystal.protocol.toUpperCase()} · '
                    '${Crystal.sessionLength.toUpperCase()}',
                    style: goldLabel,
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    isUnavailable
                        ? 'Frequency unavailable right now'
                        : Crystal.compositionCredit,
                    style: _bodyStyle.copyWith(
                      fontSize: AppFontSizes.s10,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CrystalDetail extends StatelessWidget {
  const _CrystalDetail({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s22),
      child: Column(
        children: [
          SectionHeading(label: label),
          const SizedBox(height: AppSpacing.s10),
          Text(text, textAlign: TextAlign.center, style: _bodyStyle),
        ],
      ),
    );
  }
}

/// Gentle note before the cymatic plays: the frequency is meant to be heard
/// in stereo. The chamber blurs softly behind it.
class _HeadphonesDialog extends StatelessWidget {
  const _HeadphonesDialog();

  static const Duration _transition = Duration(milliseconds: 280);
  static const double _maxWidth = 300;
  static const double _iconRing = AppSpacing.s52;
  static const double _backdropBlur = 6;

  static Future<void> show(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return showGeneralDialog<void>(
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

  void _handleContinue(BuildContext context) => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Semantics(
            scopesRoute: true,
            namesRoute: true,
            explicitChildNodes: true,
            label: 'Headphones recommended',
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
                        width: _iconRing,
                        height: _iconRing,
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
                        'FOR THE FULL EXPERIENCE',
                        textAlign: TextAlign.center,
                        style: AppTypography.subheadline.copyWith(
                          color: AppColors.champagneGold,
                          fontSize: AppFontSizes.s10,
                          letterSpacing: 2.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text(
                        'This experience will be better with headphones',
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
                        'Stereo sound lets the frequency surround you.',
                        textAlign: TextAlign.center,
                        style: _bodyStyle.copyWith(
                          color: AppColors.fog,
                          fontSize: AppFontSizes.s11,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s28),
                      HikaruPillButton(
                        label: 'CONTINUE',
                        onPressed: () => _handleContinue(context),
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
