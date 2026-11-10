import 'dart:ui' show FontFeature;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../application/crystal_track_duration.dart';
import '../../../core/media/starry_night.dart';
import '../../../l10n/app_localizations.dart';
import '../../crystals/domain/crystal.dart';
import '../../crystals/presentation/crystal_texts.dart';
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
    this.furthestPosition,
    this.trackLength,
    this.onSeek,
  });

  /// Soft indigo veil so the plate stays the brightest element.
  static final Color _veil = AppColors.darkIndigoBlue.withValues(alpha: 0.35);

  /// Rewind step of the back button and of a screen reader step.
  static const Duration rewindStep = Duration(seconds: 10);

  final Crystal crystal;
  final bool playing;
  final bool controlsVisible;
  final CymaticEnvelope? envelope;
  final ValueListenable<Duration> playbackPosition;
  final VoidCallback onSurfaceTap;
  final VoidCallback onTogglePlayback;
  final VoidCallback onStop;

  /// Furthest point already played; the bar does not go past it.
  final ValueListenable<Duration>? furthestPosition;

  /// Length of the frequency. Without it (or without [onSeek]) there is no
  /// bar, only Pause and Stop.
  final Duration? trackLength;
  final ValueChanged<Duration>? onSeek;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final insets = mediaQuery.padding;
    final isLandscape = mediaQuery.size.width > mediaQuery.size.height;
    final length = trackLength;
    final seek = onSeek;
    final canSeek = length != null && length > Duration.zero && seek != null;

    final controls = _ProjectionControls(
      playing: playing,
      onTogglePlayback: onTogglePlayback,
      onStop: onStop,
      onRewind: canSeek
          ? () => seek(playbackPosition.value - rewindStep)
          : null,
    );
    final bar = canSeek
        ? CymaticSeekBar(
            position: playbackPosition,
            furthest: furthestPosition ?? playbackPosition,
            length: length,
            onSeek: seek,
          )
        : null;
    final l10n = AppLocalizations.of(context);

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
        Align(
          alignment: Alignment.bottomCenter,
          child: _SlidingPanel(
            visible: controlsVisible,
            child: ConstrainedBox(
              // Landscape: a centered sheet instead of a full-width band.
              constraints: BoxConstraints(
                maxWidth: isLandscape ? 560 : double.infinity,
              ),
              child: _PanelSurface(
                bottomInset: insets.bottom,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isLandscape) ...[
                      Text(
                        l10n.resonanceYourFrequency,
                        textAlign: TextAlign.center,
                        style: AppTypography.subheadline.copyWith(
                          color: AppColors.champagneGold,
                          fontSize: AppFontSizes.s9,
                          letterSpacing: 2.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        crystal.localizedFrequency(l10n),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headline.copyWith(
                          color: AppColors.white,
                          fontSize: AppFontSizes.s15,
                          fontWeight: FontWeight.w300,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                    ],
                    if (bar != null) ...[
                      bar,
                      SizedBox(
                        height: isLandscape ? AppSpacing.s6 : AppSpacing.s12,
                      ),
                    ],
                    controls,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Slides up from the bottom when the surface is tapped or the frequency is
/// paused, and back down on Play, like the panel of the face and body
/// rituals.
class _SlidingPanel extends StatelessWidget {
  const _SlidingPanel({required this.visible, required this.child});

  static const Duration _slide = Duration(milliseconds: 320);

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : _slide;
    return IgnorePointer(
      ignoring: !visible,
      child: ExcludeSemantics(
        excluding: !visible,
        child: AnimatedSlide(
          offset: visible ? Offset.zero : const Offset(0, 1),
          duration: duration,
          curve: visible ? Curves.easeOutCubic : Curves.easeInCubic,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: duration,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Same look as the ritual panel: rounded top, thin gold edge, indigo
/// gradient fading out at the bottom, and the small handle.
class _PanelSurface extends StatelessWidget {
  const _PanelSurface({required this.bottomInset, required this.child});

  static const double _radius = 26;

  final double bottomInset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(_radius),
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.champagneGold.withValues(alpha: 0.35),
            width: 0.5,
          ),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.indigoBlue.withValues(alpha: 0.94),
            AppColors.darkIndigoBlue.withValues(alpha: 0.96),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.champagneGold.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.s24,
          AppSpacing.s10,
          AppSpacing.s24,
          bottomInset + AppSpacing.s16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.champagneGold80.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppSpacing.s14),
            child,
          ],
        ),
      ),
    );
  }
}

/// Thin gold bar with the time played and the length of the frequency.
///
/// Dragging back repeats a part; dragging forward stops at the furthest
/// point already played (shown a little brighter than the rest), so the
/// frequency is never skipped. The audio moves when the finger lifts.
class CymaticSeekBar extends StatefulWidget {
  const CymaticSeekBar({
    super.key,
    required this.position,
    required this.furthest,
    required this.length,
    required this.onSeek,
  });

  final ValueListenable<Duration> position;
  final ValueListenable<Duration> furthest;
  final Duration length;
  final ValueChanged<Duration> onSeek;

  @override
  State<CymaticSeekBar> createState() => _CymaticSeekBarState();
}

class _CymaticSeekBarState extends State<CymaticSeekBar> {
  static const double _height = 36;
  static const double _thumbRadius = 5;

  /// Where the finger is, while dragging.
  Duration? _drag;

  int get _lengthMs => widget.length.inMilliseconds;

  Duration _reachable(Duration target) {
    final furthest = widget.furthest.value;
    final limit = furthest < widget.length ? furthest : widget.length;
    if (target.isNegative) return Duration.zero;
    return target > limit ? limit : target;
  }

  Duration _at(Offset local, double width) {
    final usable = width - 2 * _thumbRadius;
    if (usable <= 0) return Duration.zero;
    final fraction = ((local.dx - _thumbRadius) / usable).clamp(0.0, 1.0);
    return _reachable(Duration(milliseconds: (fraction * _lengthMs).round()));
  }

  void _update(Offset local, double width) =>
      setState(() => _drag = _at(local, width));

  void _end() {
    final target = _drag;
    setState(() => _drag = null);
    if (target != null) widget.onSeek(target);
  }

  double _fraction(Duration value) =>
      _lengthMs == 0 ? 0 : (value.inMilliseconds / _lengthMs).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final timeStyle = AppTypography.subheadline.copyWith(
      color: AppColors.champagneGold,
      fontSize: AppFontSizes.s11,
      letterSpacing: 1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: ListenableBuilder(
        listenable: Listenable.merge([widget.position, widget.furthest]),
        builder: (context, _) {
          final shown = _drag ?? widget.position.value;
          final elapsed = formatTrackDuration(shown);
          final total = formatTrackDuration(widget.length);
          final step = CymaticProjection.rewindStep;
          return Semantics(
            slider: true,
            label: l10n.cymaticProgress,
            value: l10n.cymaticProgressValue(elapsed, total),
            decreasedValue: l10n.cymaticProgressValue(
              formatTrackDuration(_reachable(shown - step)),
              total,
            ),
            increasedValue: l10n.cymaticProgressValue(
              formatTrackDuration(_reachable(shown + step)),
              total,
            ),
            onDecrease: () => widget.onSeek(_reachable(shown - step)),
            onIncrease: () => widget.onSeek(_reachable(shown + step)),
            excludeSemantics: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: (d) =>
                          _update(d.localPosition, width),
                      onHorizontalDragUpdate: (d) =>
                          _update(d.localPosition, width),
                      onHorizontalDragEnd: (_) => _end(),
                      onHorizontalDragCancel: _end,
                      onTapDown: (d) => _update(d.localPosition, width),
                      onTapUp: (_) => _end(),
                      onTapCancel: () {
                        if (_drag != null) _end();
                      },
                      child: SizedBox(
                        width: width,
                        height: _height,
                        child: CustomPaint(
                          painter: _SeekBarPainter(
                            played: _fraction(shown),
                            reachable: _fraction(widget.furthest.value),
                            thumbRadius: _thumbRadius,
                            dragging: _drag != null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _thumbRadius),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(elapsed, style: timeStyle),
                      Text(
                        total,
                        style: timeStyle.copyWith(
                          color: AppColors.champagneGold.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SeekBarPainter extends CustomPainter {
  const _SeekBarPainter({
    required this.played,
    required this.reachable,
    required this.thumbRadius,
    required this.dragging,
  });

  final double played;
  final double reachable;
  final double thumbRadius;
  final bool dragging;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final start = thumbRadius;
    final end = size.width - thumbRadius;
    double x(double fraction) => start + (end - start) * fraction;
    final line = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(start, y),
      Offset(end, y),
      line..color = AppColors.champagneGold.withValues(alpha: 0.18),
    );
    // Already listened to: free to move back into.
    canvas.drawLine(
      Offset(start, y),
      Offset(x(reachable), y),
      line..color = AppColors.champagneGold.withValues(alpha: 0.4),
    );
    canvas.drawLine(
      Offset(start, y),
      Offset(x(played), y),
      line..color = AppColors.champagneGold,
    );
    final thumb = Offset(x(played), y);
    if (dragging) {
      canvas.drawCircle(
        thumb,
        16,
        Paint()..color = AppColors.champagneGold.withValues(alpha: 0.14),
      );
    }
    canvas.drawCircle(
      thumb,
      thumbRadius,
      Paint()..color = AppColors.champagneGold,
    );
  }

  @override
  bool shouldRepaint(_SeekBarPainter oldDelegate) =>
      oldDelegate.played != played ||
      oldDelegate.reachable != reachable ||
      oldDelegate.dragging != dragging;
}

/// Back 10 s, Play/Pause (larger, in the middle) and Stop, like the ritual
/// controls.
class _ProjectionControls extends StatelessWidget {
  const _ProjectionControls({
    required this.playing,
    required this.onTogglePlayback,
    required this.onStop,
    this.onRewind,
  });

  final bool playing;
  final VoidCallback onTogglePlayback;
  final VoidCallback onStop;

  /// Back ten seconds. Hidden without a known track length.
  final VoidCallback? onRewind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rewind = onRewind;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.s26,
      children: [
        if (rewind != null)
          _ProjectionButton(
            label: l10n.cymaticRewind,
            icon: Icons.replay_10_rounded,
            onPressed: rewind,
          ),
        _ProjectionButton(
          label: playing ? l10n.commonPause : l10n.commonPlay,
          icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
          onPressed: onTogglePlayback,
          primary: true,
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
    this.primary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  /// Play/Pause: larger, with the soft gold glow of the ritual controls.
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final diameter = primary ? AppSpacing.s56 : AppSpacing.s44;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onPressed,
        radius: diameter / 2 + AppSpacing.s4,
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: primary
                ? RadialGradient(
                    colors: [
                      AppColors.champagneGold.withValues(alpha: 0.22),
                      AppColors.darkIndigoBlue,
                    ],
                  )
                : null,
            color: primary ? null : AppColors.darkIndigoBlue,
            border: Border.all(
              color: AppColors.champagneGold80.withValues(
                alpha: primary ? 0.9 : 0.5,
              ),
              width: primary ? 0.8 : 0.5,
            ),
            boxShadow: primary
                ? [
                    BoxShadow(
                      color: AppColors.champagneGold.withValues(alpha: 0.35),
                      blurRadius: 14,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: AppColors.champagneGold80,
            size: diameter * 0.5,
          ),
        ),
      ),
    );
  }
}
