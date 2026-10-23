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

/// Full-viewport cymatic for projection, in portrait or landscape.
/// Caption and controls stay hidden until the surface is tapped.
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

  static const BoxDecoration _vignette = BoxDecoration(
    gradient: RadialGradient(
      radius: 1.1,
      colors: [AppColors.indigoBlue, AppColors.darkIndigoBlue],
      stops: [0.4, 1],
    ),
  );

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
    final mediaQuery = MediaQuery.of(context);
    final insets = mediaQuery.padding;
    final isLandscape = mediaQuery.size.width > mediaQuery.size.height;

    final caption = _ProjectionCaption(crystal: crystal);
    final controls = _ProjectionControls(
      direction: isLandscape ? Axis.vertical : Axis.horizontal,
      playing: playing,
      onTogglePlayback: onTogglePlayback,
      onExit: onExit,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSurfaceTap,
          child: DecoratedBox(
            decoration: _vignette,
            child: CymaticSignature(
              crystal: crystal,
              playing: playing,
              style: CymaticStyle.kaleidoscope,
              fillBackground: false,
              envelope: envelope,
              playbackPosition: playbackPosition,
              semanticLabel: AppLocalizations.of(context).cymaticSemantics,
            ),
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
            child: Flex(
              direction: isLandscape ? Axis.horizontal : Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [caption, controls],
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
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: _fadeDuration,
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
}

class _ProjectionCaption extends StatelessWidget {
  const _ProjectionCaption({required this.crystal});

  static const double _maxWidth = 200;

  final Crystal crystal;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            crystal.localizedName(AppLocalizations.of(context)),
            textAlign: TextAlign.center,
            style: AppTypography.headline.copyWith(
              color: AppColors.white,
              fontSize: AppFontSizes.s14,
              height: 1.2,
              letterSpacing: 4.2,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            '${crystal.hertz} Hz',
            textAlign: TextAlign.center,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.champagneGold,
              fontSize: AppFontSizes.s11,
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectionControls extends StatelessWidget {
  const _ProjectionControls({
    required this.direction,
    required this.playing,
    required this.onTogglePlayback,
    required this.onExit,
  });

  final Axis direction;
  final bool playing;
  final VoidCallback onTogglePlayback;
  final VoidCallback onExit;

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
          label: l10n.commonExit,
          icon: Icons.close_rounded,
          onPressed: onExit,
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
