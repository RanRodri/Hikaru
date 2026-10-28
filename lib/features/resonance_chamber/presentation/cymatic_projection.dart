import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../crystals/domain/crystal.dart';
import '../../crystals/presentation/crystal_texts.dart';
import '../domain/cymatic_audio.dart';
import 'cymatic_signature.dart';

/// Full-viewport cymatic. The composition plays without a tap.
/// Only the crystal name sits above the pattern.
class CymaticProjection extends StatelessWidget {
  const CymaticProjection({
    super.key,
    required this.crystal,
    required this.playing,
    required this.envelope,
    required this.playbackPosition,
    required this.duration,
    required this.volume,
    required this.onTogglePlayback,
    required this.onStop,
    required this.onVolumeChanged,
    required this.onReplayTutorial,
  });

  static const BoxDecoration _vignette = BoxDecoration(
    gradient: RadialGradient(
      radius: 1.1,
      colors: [AppColors.indigoBlue, AppColors.darkIndigoBlue],
      stops: [0.4, 1],
    ),
  );

  final Crystal crystal;
  final bool playing;
  final CymaticEnvelope? envelope;
  final ValueListenable<Duration> playbackPosition;
  final Duration duration;
  final double volume;
  final VoidCallback onTogglePlayback;
  final VoidCallback onStop;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onReplayTutorial;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final insets = mediaQuery.padding;
    final l10n = AppLocalizations.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: _vignette,
          child: CymaticSignature(
            crystal: crystal,
            playing: playing,
            style: CymaticStyle.kaleidoscope,
            fillBackground: false,
            envelope: envelope,
            playbackPosition: playbackPosition,
            semanticLabel: l10n.cymaticSemantics,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            insets.left + AppSpacing.s20,
            insets.top + AppSpacing.s12,
            insets.right + AppSpacing.s20,
            insets.bottom + AppSpacing.s16,
          ),
          child: Column(
            children: [
              Text(
                crystal.localizedName(l10n),
                textAlign: TextAlign.center,
                style: AppTypography.headline.copyWith(
                  color: AppColors.white,
                  fontSize: AppFontSizes.s14,
                  height: 1.2,
                  letterSpacing: 4.2,
                ),
              ),
              const Spacer(),
              _ProjectionControls(
                playing: playing,
                position: playbackPosition,
                duration: duration,
                volume: volume,
                onTogglePlayback: onTogglePlayback,
                onStop: onStop,
                onVolumeChanged: onVolumeChanged,
                onReplayTutorial: onReplayTutorial,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProjectionControls extends StatelessWidget {
  const _ProjectionControls({
    required this.playing,
    required this.position,
    required this.duration,
    required this.volume,
    required this.onTogglePlayback,
    required this.onStop,
    required this.onVolumeChanged,
    required this.onReplayTutorial,
  });

  final bool playing;
  final ValueListenable<Duration> position;
  final Duration duration;
  final double volume;
  final VoidCallback onTogglePlayback;
  final VoidCallback onStop;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onReplayTutorial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<Duration>(
          valueListenable: position,
          builder: (context, current, _) {
            final total = duration.inMilliseconds;
            final value = total <= 0
                ? 0.0
                : (current.inMilliseconds / total).clamp(0.0, 1.0);
            return Semantics(
              label: l10n.crystalProgress,
              value: value.toStringAsFixed(2),
              child: LinearProgressIndicator(
                value: total <= 0 ? null : value,
                minHeight: 3,
                backgroundColor: AppColors.white.withValues(alpha: 0.2),
                color: AppColors.champagneGold,
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.s12),
        Row(
          children: [
            _ProjectionButton(
              label: playing ? l10n.commonPause : l10n.commonPlay,
              icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              onPressed: onTogglePlayback,
            ),
            const SizedBox(width: AppSpacing.s12),
            _ProjectionButton(
              label: l10n.crystalStop,
              icon: Icons.stop_rounded,
              onPressed: onStop,
            ),
            const SizedBox(width: AppSpacing.s8),
            Expanded(
              child: Semantics(
                label: l10n.crystalVolume,
                child: Slider(
                  value: volume.clamp(0, 1),
                  onChanged: onVolumeChanged,
                  activeColor: AppColors.champagneGold,
                  inactiveColor: AppColors.white.withValues(alpha: 0.25),
                ),
              ),
            ),
            _ReplayTutorialButton(
              label: l10n.crystalReplayTutorial,
              onPressed: onReplayTutorial,
            ),
          ],
        ),
      ],
    );
  }
}

class _ReplayTutorialButton extends StatelessWidget {
  const _ReplayTutorialButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: IconButton(
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
        icon: const Icon(
          Icons.replay_rounded,
          color: AppColors.champagneGold,
          size: 18,
        ),
      ),
    );
  }
}

class _ProjectionButton extends StatelessWidget {
  const _ProjectionButton({
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
      child: InkResponse(
        onTap: onPressed,
        radius: AppSpacing.s28,
        child: Container(
          width: AppSpacing.s44,
          height: AppSpacing.s44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.darkIndigoBlue.withValues(alpha: 0.45),
            border: Border.all(
              color: AppColors.champagneGold.withValues(alpha: 0.8),
            ),
          ),
          child: Icon(icon, color: AppColors.champagneGold, size: 22),
        ),
      ),
    );
  }
}
