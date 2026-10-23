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
import '../../../core/design_system/widgets/hikaru_outline_button.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../crystals/domain/crystal.dart';
import '../../crystals/presentation/crystal_texts.dart';
import '../../journey/application/ritual_cycle_controller.dart';
import '../data/crystal_audio_store.dart';
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
  static const double _heroScreenRatio = 0.3;
  static const double _minHeroHeight = 188;
  static const double _maxHeroHeight = 280;

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
    if (!mounted) return;
    final proceed = await _HeadphonesDialog.show(context);
    if (!mounted || proceed != true) return;
    await _prompts.recordShown();
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
    unawaited(ref.read(ritualCycleControllerProvider.notifier).markFrequency());
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

  /// Updates the active crystal for Home / sound. Does not rewrite the
  /// Listening Garden skin-care protocol stored in journey recommendation.
  Future<void> _handleChooseCrystal() async {
    await ref.read(selectedCrystalProvider.notifier).select(_crystal);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.crystalChosenSnackbar(_crystal.localizedName(l10n))),
      ),
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
    final l10n = AppLocalizations.of(context);
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.s24,
                      insets.top + AppSpacing.s4,
                      AppSpacing.s24,
                      AppSpacing.s8,
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _BackButton(onPressed: _handleBackPressed),
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
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s24,
                        AppSpacing.s8,
                        AppSpacing.s24,
                        AppSpacing.s20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FrequencyPlayer(
                            crystal: _crystal,
                            onToggle: () => unawaited(_handlePlayProjection()),
                          ),
                          const SizedBox(height: AppSpacing.s20),
                          const _QuietRule(),
                          const SizedBox(height: AppSpacing.s18),
                          _DetailGrid(
                            facts: [
                              _Fact(
                                l10n.crystalDetailSymbolicMeaning,
                                _crystal.localizedSymbolicTitle(l10n),
                              ),
                              _Fact(
                                l10n.crystalDetailAssociatedIntention,
                                _crystal.localizedDefaultIntention(l10n),
                              ),
                              _Fact(
                                l10n.crystalDetailTherapeuticPurpose,
                                _crystal.localizedPurpose(l10n),
                              ),
                              _Fact(
                                l10n.crystalDetailSkinBenefit,
                                _crystal.localizedSkinBenefit(l10n),
                              ),
                              _Fact(
                                l10n.crystalDetailMeridians,
                                _crystal.localizedMeridians(l10n),
                              ),
                              _Fact(
                                l10n.crystalDetailEnvironment,
                                _crystal.localizedEnvironment(l10n),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                            label: l10n.crystalChoose,
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
    final label = AppLocalizations.of(context).commonBack;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.champagneGold,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
        ),
        child: Text(
          label,
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
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.crystalIsYoursSemantics(crystal.localizedName(l10n)),
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
              l10n.crystalIsYours,
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
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        const ChamberTitle(),
        const SizedBox(height: AppSpacing.s8),
        Text(
          crystal.localizedName(l10n),
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
          crystal.localizedTemple(l10n),
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

class _Fact {
  const _Fact(this.label, this.text);

  final String label;
  final String text;
}

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({required this.facts});

  final List<_Fact> facts;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var index = 0; index < facts.length; index += 2) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: AppSpacing.s18));
      final right = index + 1 < facts.length ? facts[index + 1] : null;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _FactCell(fact: facts[index])),
            const SizedBox(width: AppSpacing.s20),
            Expanded(
              child: right == null
                  ? const SizedBox.shrink()
                  : _FactCell(fact: right),
            ),
          ],
        ),
      );
    }
    return Column(children: rows);
  }
}

class _FactCell extends StatelessWidget {
  const _FactCell({required this.fact});

  final _Fact fact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fact.label, style: _detailLabelStyle),
        const SizedBox(height: AppSpacing.s4),
        Text(fact.text, style: _bodyStyle.copyWith(fontSize: AppFontSizes.s12)),
      ],
    );
  }
}

class _FrequencyPlayer extends StatelessWidget {
  const _FrequencyPlayer({required this.crystal, required this.onToggle});

  static const double _buttonSize = AppSpacing.s44;

  final Crystal crystal;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.resonanceYourFrequency, style: _detailLabelStyle),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    crystal.localizedFrequency(l10n),
                    style: AppTypography.headline.copyWith(
                      color: AppColors.white,
                      fontSize: AppFontSizes.s22,
                      height: 1.2,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Semantics(
              button: true,
              label: l10n.crystalFrequencyPlay,
              excludeSemantics: true,
              child: InkResponse(
                onTap: onToggle,
                radius: _buttonSize / 2,
                child: Container(
                  width: _buttonSize,
                  height: _buttonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.champagneGold.withValues(alpha: 0.08),
                    border: Border.all(
                      color: AppColors.champagneGold.withValues(alpha: 0.85),
                      width: 0.8,
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.champagneGold,
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(
          crystal.localizedFrequencyDetail(l10n),
          style: _bodyStyle.copyWith(
            color: AppColors.fog,
            fontSize: AppFontSizes.s12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Text(
          crystal.localizedProtocol(l10n),
          style: _bodyStyle.copyWith(fontSize: AppFontSizes.s12, height: 1.4),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(Crystal.sessionLength, style: _detailLabelStyle),
        const SizedBox(height: AppSpacing.s8),
        Text(
          l10n.crystalCompositionCredit,
          style: _bodyStyle.copyWith(
            color: AppColors.fog,
            fontSize: AppFontSizes.s11,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

final TextStyle _detailLabelStyle = AppTypography.subheadline.copyWith(
  color: AppColors.champagneGold,
  fontSize: AppFontSizes.s9,
  height: 1.3,
  letterSpacing: 1.35,
);

class _QuietRule extends StatelessWidget {
  const _QuietRule();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: AppSpacing.s28,
        height: AppSpacing.s0_6,
        color: AppColors.champagneGold.withValues(alpha: 0.7),
      ),
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
                      const SizedBox(height: AppSpacing.s12),
                      HikaruOutlineButton(
                        label: l10n.headphonesDialogContinueWithout,
                        onPressed: _handleContinue,
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
