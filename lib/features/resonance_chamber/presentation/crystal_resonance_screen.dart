import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../core/router/app_routes.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../crystals/domain/crystal.dart';
import 'resonance_sections.dart';

final TextStyle _bodyStyle = AppTypography.headline.copyWith(
  color: AppColors.white,
  fontSize: 12,
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
  static const double _horizontalPadding = 24;
  static const double _heroScreenRatio = 0.3;
  static const double _minHeroHeight = 180;
  static const double _maxHeroHeight = 300;

  final AudioPlayer _player = AudioPlayer();
  late final StreamSubscription<PlayerState> _playerStateSubscription;
  bool _isPlaying = false;
  bool _isAudioUnavailable = false;

  Crystal get _crystal => widget.crystal;

  @override
  void initState() {
    super.initState();
    _playerStateSubscription = _player.onPlayerStateChanged.listen(
      _handlePlayerStateChanged,
    );
    _startFrequency();
    WidgetsBinding.instance.addPostFrameCallback((_) => _offerSelection());
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    _player.dispose();
    super.dispose();
  }

  void _handlePlayerStateChanged(PlayerState playerState) {
    if (!mounted) return;
    setState(() => _isPlaying = playerState == PlayerState.playing);
  }

  Future<void> _startFrequency() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(_crystal.audioAsset));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isAudioUnavailable = true);
    }
  }

  Future<void> _handleTogglePlayback() async {
    if (_isPlaying) {
      await _player.pause();
      return;
    }
    await _player.resume();
  }

  Future<void> _offerSelection() async {
    final currentCrystal = await ref.read(selectedCrystalProvider.future);
    if (!mounted || currentCrystal == _crystal) return;

    final shouldChoose = await showDialog<bool>(
      context: context,
      builder: (context) => _ChooseCrystalDialog(
        crystal: _crystal,
        currentCrystal: currentCrystal,
      ),
    );
    if (shouldChoose != true) return;
    await _handleChooseCrystal();
  }

  Future<void> _handleChooseCrystal() async {
    await ref.read(selectedCrystalProvider.notifier).select(_crystal);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_crystal.displayName} is now your crystal.')),
    );
  }

  void _handleEnterJourney() => context.go(AppRoutes.home);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final insets = mediaQuery.padding;
    final heroHeight = (mediaQuery.size.height * _heroScreenRatio).clamp(
      _minHeroHeight,
      _maxHeroHeight,
    );
    final isSelected = ref.watch(selectedCrystalProvider).value == _crystal;

    return Scaffold(
      backgroundColor: resonanceChamberColor,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              _horizontalPadding,
              insets.top + 28,
              _horizontalPadding,
              0,
            ),
            child: _CrystalIntroduction(crystal: _crystal),
          ),
          SizedBox(
            height: heroHeight,
            child: _CrystalHero(crystal: _crystal),
          ),
          Expanded(
            child: ChamberScrollView(
              padding: const EdgeInsets.fromLTRB(
                _horizontalPadding,
                12,
                _horizontalPadding,
                16,
              ),
              children: [
                _FrequencyPlayer(
                  crystal: _crystal,
                  isPlaying: _isPlaying,
                  isUnavailable: _isAudioUnavailable,
                  onToggle: _handleTogglePlayback,
                ),
                const SizedBox(height: 24),
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
          Padding(
            padding: EdgeInsets.fromLTRB(
              32,
              12,
              32,
              math.max(24, insets.bottom + 12),
            ),
            child: isSelected
                ? HikaruPillButton(
                    label: 'ENTER MY 30-DAY JOURNEY',
                    onPressed: _handleEnterJourney,
                  )
                : HikaruPillButton(
                    label: 'CHOOSE THIS CRYSTAL',
                    onPressed: _handleChooseCrystal,
                  ),
          ),
        ],
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
        const SizedBox(height: 14),
        Text(
          crystal.displayName,
          textAlign: TextAlign.center,
          style: AppTypography.headline.copyWith(
            color: AppColors.white,
            fontSize: 22,
            height: 1.2,
            letterSpacing: 4.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          crystal.temple,
          textAlign: TextAlign.center,
          style: AppTypography.footnote.copyWith(
            color: AppColors.fog,
            fontSize: 12,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

class _CrystalHero extends StatelessWidget {
  const _CrystalHero({required this.crystal});

  final Crystal crystal;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.champagneGold.withValues(alpha: 0.22),
                blurRadius: 48,
                spreadRadius: -12,
              ),
            ],
          ),
          child: Image.asset(
            crystal.imageAsset,
            fit: BoxFit.contain,
            semanticLabel: '${crystal.displayName} crystal',
          ),
        ),
      ),
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

  static const double _buttonSize = 52;

  final Crystal crystal;
  final bool isPlaying;
  final bool isUnavailable;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final goldLabel = AppTypography.subheadline.copyWith(
      color: AppColors.champagneGold,
      fontSize: 9,
      letterSpacing: 1.2,
    );

    return Column(
      children: [
        const SectionHeading(label: 'YOUR FREQUENCY'),
        const SizedBox(height: 14),
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crystal.frequency,
                    style: AppTypography.headline.copyWith(
                      color: AppColors.white,
                      fontSize: 22,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    crystal.frequencyDetail,
                    style: _bodyStyle.copyWith(
                      color: AppColors.fog,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${crystal.protocol.toUpperCase()} · '
                    '${Crystal.sessionLength.toUpperCase()}',
                    style: goldLabel,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUnavailable
                        ? 'Frequency unavailable right now'
                        : 'Composed by ${Crystal.composer}',
                    style: _bodyStyle.copyWith(fontSize: 10, height: 1.4),
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
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        children: [
          SectionHeading(label: label),
          const SizedBox(height: 10),
          Text(text, textAlign: TextAlign.center, style: _bodyStyle),
        ],
      ),
    );
  }
}

class _ChooseCrystalDialog extends StatelessWidget {
  const _ChooseCrystalDialog({required this.crystal, this.currentCrystal});

  final Crystal crystal;
  final Crystal? currentCrystal;

  void _handleAnswer(BuildContext context, bool shouldChoose) {
    Navigator.of(context).pop(shouldChoose);
  }

  @override
  Widget build(BuildContext context) {
    final previousCrystal = currentCrystal;
    final message = previousCrystal == null
        ? 'It will guide your ritual and appear in your Harmony Garden.'
        : 'It will replace ${previousCrystal.displayName} in your Harmony '
              'Garden.';

    return AlertDialog(
      backgroundColor: resonanceChamberColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.champagneGold.withValues(alpha: 0.6),
          width: 0.75,
        ),
      ),
      title: Text(
        'Choose ${crystal.displayName} as your crystal?',
        textAlign: TextAlign.center,
        style: AppTypography.headline.copyWith(
          color: AppColors.white,
          fontSize: 16,
          height: 1.4,
          letterSpacing: 0.8,
        ),
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: _bodyStyle.copyWith(color: AppColors.fog),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => _handleAnswer(context, false),
          style: TextButton.styleFrom(foregroundColor: AppColors.fog),
          child: Text(
            'NOT NOW',
            style: AppTypography.subheadline.copyWith(letterSpacing: 1.2),
          ),
        ),
        FilledButton(
          onPressed: () => _handleAnswer(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.champagneGold,
            foregroundColor: AppColors.darkIndigoBlue,
            shape: const StadiumBorder(),
          ),
          child: Text(
            'CHOOSE',
            style: AppTypography.subheadline.copyWith(
              color: AppColors.darkIndigoBlue,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
