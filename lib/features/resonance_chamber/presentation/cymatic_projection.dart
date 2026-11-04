import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/media/starry_night.dart';
import '../../../l10n/app_localizations.dart';
import '../../crystals/domain/crystal.dart';
import '../domain/cymatic_audio.dart';
import 'cymatic_signature.dart';

/// Full-viewport cymatic over the starry night, in portrait or landscape.
///
/// Nothing is written over the plate. Pause and Stop appear only while the
/// surface is tapped.
class CymaticProjection extends StatelessWidget {
  const CymaticProjection({
    super.key,
    required this.crystal,
    required this.playing,
    required this.controlsVisible,
    required this.envelope,
    required this.playbackPosition,
    required this.onSurfaceTap,
    required this.onTogglePlayback,
    required this.onStop,
  });

  /// Soft indigo veil so the plate stays the brightest element.
  static final Color _veil = AppColors.darkIndigoBlue.withValues(alpha: 0.35);

  final Crystal crystal;
  final bool playing;
  final bool controlsVisible;
  final CymaticEnvelope? envelope;
  final ValueListenable<Duration> playbackPosition;
  final VoidCallback onSurfaceTap;
  final VoidCallback onTogglePlayback;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final insets = mediaQuery.padding;
    final isLandscape = mediaQuery.size.width > mediaQuery.size.height;

    final controls = _ProjectionControls(
      direction: isLandscape ? Axis.vertical : Axis.horizontal,
      playing: playing,
      onTogglePlayback: onTogglePlayback,
      onStop: onStop,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        const Image(
          image: AssetImage(merkabaStarryNightAsset),
          fit: BoxFit.cover,
          excludeFromSemantics: true,
        ),
        ColoredBox(color: _veil),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSurfaceTap,
          child: CymaticSignature(
            crystal: crystal,
            playing: playing,
            envelope: envelope,
            playbackPosition: playbackPosition,
            semanticLabel: AppLocalizations.of(context).cymaticSemantics,
          ),
        ),
        _FadingChrome(
          visible: controlsVisible,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              insets.left + AppSpacing.s32,
              insets.top + AppSpacing.s32,
              insets.right + AppSpacing.s32,
              insets.bottom + AppSpacing.s32,
            ),
            child: Align(
              alignment: isLandscape
                  ? Alignment.centerRight
                  : Alignment.bottomCenter,
              child: controls,
            ),
          ),
        ),
      ],
    );
  }
}

class _FadingChrome extends StatelessWidget {
  const _FadingChrome({required this.visible, required this.child});

  static const Duration _fadeDuration = Duration(milliseconds: 280);

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: reduceMotion ? Duration.zero : _fadeDuration,
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
}

class _ProjectionControls extends StatelessWidget {
  const _ProjectionControls({
    required this.direction,
    required this.playing,
    required this.onTogglePlayback,
    required this.onStop,
  });

  final Axis direction;
  final bool playing;
  final VoidCallback onTogglePlayback;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Flex(
      direction: direction,
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.s24,
      children: [
        _ProjectionButton(
          label: playing ? l10n.commonPause : l10n.commonPlay,
          icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
          onPressed: onTogglePlayback,
        ),
        _ProjectionButton(
          label: l10n.cymaticStop,
          icon: Icons.stop_rounded,
          onPressed: onStop,
        ),
      ],
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
          width: AppSpacing.s52,
          height: AppSpacing.s52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.darkIndigoBlue.withValues(alpha: 0.4),
            border: Border.all(color: AppColors.champagneGold),
          ),
          child: Icon(icon, color: AppColors.champagneGold, size: 28),
        ),
      ),
    );
  }
}
