import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../crystals/domain/crystal.dart';
import '../domain/cymatic_audio.dart';
import 'cymatic_signature.dart';

/// Full-viewport cymatic for projection. No crystal, no chrome until tapped.
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
    required this.onExit,
  });

  final Crystal crystal;
  final bool playing;
  final bool controlsVisible;
  final CymaticEnvelope? envelope;
  final ValueListenable<Duration> playbackPosition;
  final VoidCallback onSurfaceTap;
  final VoidCallback onTogglePlayback;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);

    return ColoredBox(
      color: AppColors.indigoBlue,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onSurfaceTap,
            child: CymaticSignature(
              crystal: crystal,
              playing: playing,
              envelope: envelope,
              playbackPosition: playbackPosition,
              semanticLabel: 'Cymatic',
            ),
          ),
          if (controlsVisible)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: insets.bottom + AppSpacing.s24,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ProjectionButton(
                      label: playing ? 'Pause' : 'Play',
                      icon: playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      onPressed: onTogglePlayback,
                    ),
                    const SizedBox(width: AppSpacing.s24),
                    _ProjectionButton(
                      label: 'Exit',
                      icon: Icons.close_rounded,
                      onPressed: onExit,
                    ),
                  ],
                ),
              ),
            ),
        ],
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
