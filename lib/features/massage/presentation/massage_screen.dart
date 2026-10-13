import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_header.dart';
import '../../../core/router/app_routes.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../crystals/domain/crystal.dart';
import '../domain/massage_ritual.dart';
import 'ritual_video_slot.dart';

const double _designWidth = 390;
const double _panelOverlap = 26;
const Duration _inhale = Duration(seconds: 4);
const Duration _breathCycle = Duration(seconds: 10);
const double _sheetOpen = 0.62;
const double _sheetShown = 0.4;

/// Top padding, handle, and the gap under it. Collapsed, this is all that shows.
const double _handleBarHeight = 28;

const List<Shadow> _textShadow = [
  Shadow(color: AppColors.scrim80, offset: Offset(0, 1), blurRadius: 6),
];

class MassageScreen extends ConsumerStatefulWidget {
  const MassageScreen({super.key, required this.surface});

  final MassageSurface surface;

  @override
  ConsumerState<MassageScreen> createState() => _MassageScreenState();
}

class _MassageScreenState extends ConsumerState<MassageScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _zoneElapsed = Duration.zero;
  Duration _lastTick = Duration.zero;
  bool _playing = false;
  int _zoneIndex = 0;
  final DraggableScrollableController _sheet = DraggableScrollableController();
  double _sheetExtent = _sheetOpen;

  MassageRitual get _ritual => ritualFor(widget.surface);

  bool get _isLastZone => _zoneIndex >= _ritual.zones.length - 1;

  Duration get _sessionElapsed =>
      _ritual.zoneLength * _zoneIndex + _zoneElapsed;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_handleTick);
    _sheet.addListener(_handleSheet);
  }

  @override
  void dispose() {
    _sheet.removeListener(_handleSheet);
    _sheet.dispose();
    _ticker.dispose();
    super.dispose();
  }

  void _handleSheet() {
    if (!_sheet.isAttached) return;
    final next = _sheet.size;
    if ((next - _sheetExtent).abs() < 0.008) return;
    setState(() => _sheetExtent = next);
  }

  double _crystalOpacity(double collapsed) {
    final span = _sheetShown - collapsed;
    if (span <= 0) return _sheetExtent >= _sheetShown ? 1 : 0;
    return ((_sheetExtent - collapsed) / span).clamp(0.0, 1.0);
  }

  void _handleTick(Duration sinceStart) {
    if (!_playing) return;
    final delta = sinceStart - _lastTick;
    _lastTick = sinceStart;
    final zoneLength = _ritual.zoneLength;
    final elapsed = _zoneElapsed + delta;

    if (elapsed < zoneLength) {
      setState(() => _zoneElapsed = elapsed);
      return;
    }
    if (_isLastZone) {
      _stop();
      setState(() => _zoneElapsed = zoneLength);
      return;
    }
    setState(() {
      _zoneIndex += 1;
      _zoneElapsed = Duration.zero;
    });
  }

  void _stop() {
    _ticker.stop();
    _playing = false;
  }

  void _handleBackPressed() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.home);
  }

  void _handlePlayPause() {
    if (_playing) {
      setState(_stop);
      return;
    }
    final finished = _isLastZone && _zoneElapsed >= _ritual.zoneLength;
    setState(() {
      if (finished) {
        _zoneIndex = 0;
        _zoneElapsed = Duration.zero;
      }
      _playing = true;
    });
    _lastTick = Duration.zero;
    _ticker.start();
  }

  void _handleRestart() {
    setState(() {
      _stop();
      _zoneIndex = 0;
      _zoneElapsed = Duration.zero;
    });
  }

  void _handleZoneSelected(int index) {
    if (index < 0 || index >= _ritual.zones.length) return;
    setState(() {
      _zoneIndex = index;
      _zoneElapsed = Duration.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final crystal = ref.watch(selectedCrystalProvider).value;
    final insets = MediaQuery.paddingOf(context);
    final ritual = _ritual;

    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / _designWidth;
          final collapsed = (_handleBarHeight * scale / constraints.maxHeight)
              .clamp(0.02, 0.12);
          final crystalOpacity = _crystalOpacity(collapsed);

          return Stack(
            children: [
              Positioned.fill(
                child: RitualVideoSlot(videoUrl: ritual.videoUrl),
              ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(top: insets.top),
                  child: _RitualHero(
                    scale: scale,
                    ritual: ritual,
                    onBackPressed: _handleBackPressed,
                  ),
                ),
              ),
              DraggableScrollableSheet(
                controller: _sheet,
                initialChildSize: _sheetOpen,
                minChildSize: collapsed,
                maxChildSize: 0.86,
                snap: true,
                snapSizes: [collapsed, _sheetOpen],
                builder: (context, scrollController) {
                  return DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.darkIndigoBlue,
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: _ControlPanel(
                        scale: scale,
                        bottomInset: insets.bottom,
                        ritual: ritual,
                        crystal: crystal,
                        crystalOpacity: crystalOpacity,
                        zoneIndex: _zoneIndex,
                        zoneElapsed: _zoneElapsed,
                        sessionElapsed: _sessionElapsed,
                        playing: _playing,
                        onZoneSelected: _handleZoneSelected,
                        onPrevious: () => _handleZoneSelected(_zoneIndex - 1),
                        onPlayPause: _handlePlayPause,
                        onNext: () => _handleZoneSelected(_zoneIndex + 1),
                        onRestart: _handleRestart,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

TextStyle _spaced(double size, {Color color = AppColors.silver}) {
  return AppTypography.footnote.copyWith(
    color: color,
    fontSize: size,
    height: 1.25,
    letterSpacing: size * 0.3,
  );
}

class _RitualHero extends StatelessWidget {
  const _RitualHero({
    required this.scale,
    required this.ritual,
    required this.onBackPressed,
  });

  final double scale;
  final MassageRitual ritual;
  final VoidCallback onBackPressed;

  Widget _place({
    double? left,
    double? right,
    required double top,
    double? width,
    required Widget child,
  }) {
    return Positioned(
      left: left == null ? null : left * scale,
      right: right == null ? null : right * scale,
      top: top * scale,
      width: width == null ? null : width * scale,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned(top: 0, left: 0, right: 0, child: HikaruHeader()),
        _place(
          left: 6,
          top: 18,
          child: _TextControl(
            label: 'BACK',
            semanticsLabel: 'Back',
            scale: scale,
            onPressed: onBackPressed,
          ),
        ),
        _place(right: 16, top: 22, child: _HeaderActions(scale: scale)),
        _place(
          left: 0,
          right: 0,
          top: 69,
          child: Column(
            children: [
              Text(
                ritual.temple,
                textAlign: TextAlign.center,
                style: AppTypography.headline.copyWith(
                  color: AppColors.silver,
                  fontSize: AppFontSizes.s18 * scale,
                  letterSpacing: 4.5 * scale,
                  shadows: _textShadow,
                ),
              ),
              SizedBox(height: AppSpacing.s4 * scale),
              Text(
                ritual.subtitle,
                textAlign: TextAlign.center,
                style: _spaced(
                  AppFontSizes.s8 * scale,
                ).copyWith(shadows: _textShadow),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TextControl extends StatelessWidget {
  const _TextControl({
    required this.label,
    required this.semanticsLabel,
    required this.scale,
    required this.onPressed,
  });

  final String label;
  final String semanticsLabel;
  final double scale;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: Size(AppSpacing.s40 * scale, AppSpacing.s36 * scale),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s10 * scale),
        ),
        child: Text(
          label,
          style: _spaced(
            AppFontSizes.s10 * scale,
            color: AppColors.champagneGold80,
          ).copyWith(shadows: _textShadow),
        ),
      ),
    );
  }
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: 'Sound',
          excludeSemantics: true,
          child: GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.s6 * scale),
              child: SvgPicture.asset(
                'assets/images/ritual_sound.svg',
                width: 21 * scale,
                height: 15 * scale,
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.s6 * scale),
        Semantics(
          button: true,
          label: 'More options',
          excludeSemantics: true,
          child: GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.s6 * scale),
              child: Row(
                children: [
                  for (var dot = 0; dot < 3; dot++)
                    Container(
                      width: 2.4 * scale,
                      height: 2.4 * scale,
                      margin: EdgeInsets.symmetric(horizontal: 2.4 * scale),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.champagneGold80,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({
    required this.scale,
    required this.bottomInset,
    required this.ritual,
    required this.crystal,
    required this.crystalOpacity,
    required this.zoneIndex,
    required this.zoneElapsed,
    required this.sessionElapsed,
    required this.playing,
    required this.onZoneSelected,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
    required this.onRestart,
  });

  final double scale;
  final double bottomInset;
  final MassageRitual ritual;
  final Crystal? crystal;
  final double crystalOpacity;
  final int zoneIndex;
  final Duration zoneElapsed;
  final Duration sessionElapsed;
  final bool playing;
  final ValueChanged<int> onZoneSelected;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final zone = ritual.zones[zoneIndex];
    final zoneLength = ritual.zoneLength;
    final zoneProgress = zoneElapsed.inMilliseconds / zoneLength.inMilliseconds;
    final breathPosition =
        sessionElapsed.inMilliseconds % _breathCycle.inMilliseconds;
    final isInhaling = breathPosition < _inhale.inMilliseconds;
    final cardGap = AppSpacing.s6 * scale;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s20 * scale,
        0,
        AppSpacing.s20 * scale,
        bottomInset + AppSpacing.s24 * scale,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_panelOverlap * scale),
        ),
        border: const Border(
          top: BorderSide(color: AppColors.champagneGold, width: 0.5),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.indigoBlue,
            AppColors.darkIndigoBlue,
            AppColors.darkClear,
          ],
          stops: [0, 0.8, 1],
        ),
      ),
      child: Column(
        children: [
          Semantics(
            label: 'Ritual sheet',
            child: SizedBox(
              height: _handleBarHeight * scale,
              child: Center(
                child: Container(
                  width: 36 * scale,
                  height: 4 * scale,
                  decoration: BoxDecoration(
                    color: AppColors.champagneGold80,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          _StepSummary(
            scale: scale,
            zone: zone,
            crystal: crystal,
            crystalOpacity: crystalOpacity,
            number: zoneIndex + 1,
            total: ritual.zones.length,
          ),
          SizedBox(height: AppSpacing.s10 * scale),
          SizedBox(
            height: 95 * scale,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 117,
                  child: _ControlCard(
                    scale: scale,
                    label: 'BREATHE',
                    icon: const _FlowEmblem(),
                    child: _BreathingGauge(
                      scale: scale,
                      isInhaling: isInhaling,
                      progress: isInhaling
                          ? breathPosition / _inhale.inMilliseconds
                          : 1 -
                                (breathPosition - _inhale.inMilliseconds) /
                                    (_breathCycle - _inhale).inMilliseconds,
                    ),
                  ),
                ),
                SizedBox(width: cardGap),
                Expanded(
                  flex: 101,
                  child: _ControlCard(
                    scale: scale,
                    label: 'DURATION',
                    icon: Icon(
                      Icons.hourglass_bottom_outlined,
                      color: AppColors.champagneGold80,
                      size: 18 * scale,
                    ),
                    child: _DurationGauge(
                      scale: scale,
                      elapsed: zoneElapsed,
                      total: zoneLength,
                      progress: zoneProgress,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.s14 * scale),
          _ZoneTimeline(
            scale: scale,
            zones: ritual.zones,
            activeIndex: zoneIndex,
            onSelected: onZoneSelected,
          ),
          SizedBox(height: AppSpacing.s10 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoundControl(
                scale: scale,
                size: 28,
                icon: Icons.skip_previous_rounded,
                semanticsLabel: 'Previous zone',
                onPressed: zoneIndex == 0 ? null : onPrevious,
              ),
              SizedBox(width: AppSpacing.s26 * scale),
              _RoundControl(
                scale: scale,
                size: 43,
                icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                semanticsLabel: playing ? 'Pause' : 'Play',
                isPrimary: true,
                onPressed: onPlayPause,
              ),
              SizedBox(width: AppSpacing.s26 * scale),
              _RoundControl(
                scale: scale,
                size: 28,
                icon: Icons.skip_next_rounded,
                semanticsLabel: 'Next zone',
                onPressed: zoneIndex >= ritual.zones.length - 1 ? null : onNext,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s10 * scale),
          _TextControl(
            label: 'RESTART',
            semanticsLabel: 'Restart ritual',
            scale: scale,
            onPressed: onRestart,
          ),
        ],
      ),
    );
  }
}

class _StepSummary extends StatelessWidget {
  const _StepSummary({
    required this.scale,
    required this.zone,
    required this.crystal,
    required this.crystalOpacity,
    required this.number,
    required this.total,
  });

  final double scale;
  final MassageZone zone;
  final Crystal? crystal;
  final double crystalOpacity;
  final int number;
  final int total;

  String _pad(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final frameSize = 71 * scale;
    final assigned = crystal;

    return Row(
      children: [
        Opacity(
          opacity: crystalOpacity,
          child: ExcludeSemantics(
            excluding: assigned == null || crystalOpacity <= 0.05,
            child: Semantics(
              label: assigned == null
                  ? null
                  : 'Assigned crystal ${assigned.displayName}',
              excludeSemantics: true,
              child: Container(
                width: frameSize,
                height: frameSize,
                padding: EdgeInsets.all(3 * scale),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.champagneGold80,
                    width: 0.8,
                  ),
                ),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.darkIndigoBlue,
                  ),
                  child: assigned == null
                      ? const SizedBox.expand()
                      : ClipOval(
                          child: Image.asset(
                            assigned.imageAsset,
                            fit: BoxFit.cover,
                            excludeFromSemantics: true,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.s11 * scale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_pad(number)} / ${_pad(total)}',
                style: AppTypography.footnote.copyWith(
                  color: AppColors.champagneGold80,
                  fontSize: AppFontSizes.s9 * scale,
                ),
              ),
              SizedBox(height: AppSpacing.s4 * scale),
              Text(
                zone.name.toUpperCase(),
                style: AppTypography.headline.copyWith(
                  color: AppColors.silver,
                  fontSize: AppFontSizes.s15 * scale,
                  letterSpacing: 4 * scale,
                ),
              ),
              SizedBox(height: AppSpacing.s4 * scale),
              Text(
                zone.instruction,
                style: AppTypography.body.copyWith(
                  color: AppColors.silver,
                  fontSize: AppFontSizes.s10_5 * scale,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlCard extends StatelessWidget {
  const _ControlCard({
    required this.scale,
    required this.label,
    required this.icon,
    required this.child,
  });

  final double scale;
  final String label;
  final Widget icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.darkIndigoBlue.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(11 * scale),
        border: Border.all(color: AppColors.champagneGold, width: 0.45),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.s8 * scale),
        child: Column(
          children: [
            SizedBox(
              width: 20 * scale,
              height: 19 * scale,
              child: FittedBox(child: icon),
            ),
            SizedBox(height: AppSpacing.s5 * scale),
            Text(
              label,
              style: _spaced(
                AppFontSizes.s6_6 * scale,
                color: AppColors.champagneGold80,
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _FlowEmblem extends StatelessWidget {
  const _FlowEmblem();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 19,
      height: 19,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.champagneGold80, width: 0.65),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'assets/images/ritual_flow_waves.svg',
        width: 11,
        height: 8,
        excludeFromSemantics: true,
      ),
    );
  }
}

class _BreathingGauge extends StatelessWidget {
  const _BreathingGauge({
    required this.scale,
    required this.isInhaling,
    required this.progress,
  });

  final double scale;
  final bool isInhaling;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: AppSpacing.s2 * scale),
        Text(
          isInhaling ? 'INHALE' : 'EXHALE',
          style: AppTypography.footnote.copyWith(
            color: AppColors.silver,
            fontSize: AppFontSizes.s6_6 * scale,
            letterSpacing: 0.6 * scale,
          ),
        ),
        const Spacer(),
        SizedBox.square(
          dimension: 30 * scale,
          child: CustomPaint(
            painter: _RingPainter(progress: progress, glow: true),
          ),
        ),
      ],
    );
  }
}

class _DurationGauge extends StatelessWidget {
  const _DurationGauge({
    required this.scale,
    required this.elapsed,
    required this.total,
    required this.progress,
  });

  final double scale;
  final Duration elapsed;
  final Duration total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final size = 46 * scale;

    return Center(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(progress: progress, track: true),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formatMassageClock(elapsed),
                style: AppTypography.headline.copyWith(
                  color: AppColors.silver,
                  fontSize: AppFontSizes.s12 * scale,
                  height: 1.1,
                ),
              ),
              Text(
                '/ ${formatMassageClock(total)}',
                style: AppTypography.footnote.copyWith(
                  color: AppColors.silver,
                  fontSize: AppFontSizes.s6_6 * scale,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    this.glow = false,
    this.track = false,
  });

  final double progress;
  final bool glow;
  final bool track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final ring = rect.deflate(2);
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);

    if (track) {
      canvas.drawOval(
        ring,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6
          ..color = AppColors.champagneGold80.withValues(alpha: 0.35),
      );
    }
    if (glow) {
      canvas.drawCircle(
        rect.center,
        size.width / 2,
        Paint()
          ..color = AppColors.champagneGold.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
    canvas.drawArc(
      ring,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = glow ? 1.6 : 1
        ..color = AppColors.champagneGold80,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _ZoneTimeline extends StatelessWidget {
  const _ZoneTimeline({
    required this.scale,
    required this.zones,
    required this.activeIndex,
    required this.onSelected,
  });

  final double scale;
  final List<MassageZone> zones;
  final int activeIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final markerTop = 7 * scale;

    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: markerTop + 4.75 * scale,
          child: Container(
            height: AppSpacing.s0_5,
            color: AppColors.champagneGold80.withValues(alpha: 0.7),
          ),
        ),
        Row(
          children: [
            for (final (index, zone) in zones.indexed)
              Expanded(
                child: _ZoneStage(
                  scale: scale,
                  name: zone.name,
                  isActive: index == activeIndex,
                  isDone: index < activeIndex,
                  markerTop: markerTop,
                  onPressed: () => onSelected(index),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ZoneStage extends StatelessWidget {
  const _ZoneStage({
    required this.scale,
    required this.name,
    required this.isActive,
    required this.isDone,
    required this.markerTop,
    required this.onPressed,
  });

  final double scale;
  final String name;
  final bool isActive;
  final bool isDone;
  final double markerTop;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final marker = 9.5 * scale;
    final filled = isActive || isDone;

    return Semantics(
      button: true,
      selected: isActive,
      label: name,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            SizedBox(height: markerTop),
            Container(
              width: marker,
              height: marker,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? AppColors.champagneGold80 : AppColors.black,
                border: Border.all(
                  color: AppColors.champagneGold80,
                  width: 0.6,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.champagneGold,
                          blurRadius: 5 * scale,
                          spreadRadius: 2 * scale,
                        ),
                      ]
                    : null,
              ),
            ),
            SizedBox(height: AppSpacing.s9 * scale),
            Text(
              name.toUpperCase(),
              style: AppTypography.footnote.copyWith(
                color: isActive ? AppColors.champagneGold80 : AppColors.silver,
                fontSize: AppFontSizes.s7_5 * scale,
                letterSpacing: 0.4 * scale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.scale,
    required this.size,
    required this.icon,
    required this.semanticsLabel,
    required this.onPressed,
    this.isPrimary = false,
  });

  final double scale;
  final double size;
  final IconData icon;
  final String semanticsLabel;
  final VoidCallback? onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final diameter = size * scale;
    final enabled = onPressed != null;
    final color = enabled
        ? AppColors.champagneGold80
        : AppColors.champagneGold80.withValues(alpha: 0.35);

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticsLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.black,
            border: Border.all(color: color, width: isPrimary ? 0.7 : 0.3),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.champagneGold,
                      blurRadius: 2.7 * scale,
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, color: color, size: diameter * 0.5),
        ),
      ),
    );
  }
}
