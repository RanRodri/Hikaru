import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../core/design_system/widgets/hikaru_back_button.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_header.dart';
import '../../../core/router/app_routes.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../crystals/domain/crystal.dart';
import '../../journey/application/ritual_cycle_controller.dart';
import '../../journey/domain/ritual_cycle.dart';
import '../../journey/presentation/ritual_celebration_dialog.dart';
import '../../journey/presentation/ritual_cycle_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../crystals/presentation/crystal_texts.dart';
import '../data/massage_video_source.dart';
import '../domain/massage_ritual.dart';
import 'massage_texts.dart';
import 'ritual_video_slot.dart';

const double _designWidth = 390;
const double _panelOverlap = 26;
const Duration _inhale = Duration(seconds: 4);
const Duration _breathCycle = Duration(seconds: 10);

/// Open extent until the panel has been measured, and the tallest it may get.
const double _sheetOpen = 0.62;
const double _sheetMax = 0.86;

/// Share of the slide from collapsed to open over which the crystal fades in.
const double _crystalFadeShare = 0.6;
const Duration _sheetSlide = Duration(milliseconds: 420);

/// Fade of the title and back button when the video starts or stops.
const Duration _heroFade = Duration(milliseconds: 300);

/// Top padding, handle, and the gap under it. Collapsed, this is all that shows.
const double _handleBarHeight = 28;

const List<Shadow> _textShadow = [
  Shadow(color: AppColors.scrim80, offset: Offset(0, 1), blurRadius: 6),
];

class MassageScreen extends ConsumerStatefulWidget {
  const MassageScreen({
    super.key,
    required this.surface,
    this.inCycle = false,
    this.onBack,
    this.onCompleted,
    this.onContinue,
  });

  final MassageSurface surface;

  /// Replaces the default back navigation, for screens that host this one.
  final VoidCallback? onBack;

  /// Runs once when the video ends. Replaces marking a cycle step.
  final Future<void> Function()? onCompleted;

  /// Shows CONTINUE when the video ends and runs this on press.

  /// When true, finishing this ritual continues to the next cycle step.
  final bool inCycle;
  final VoidCallback? onContinue;

  @override
  ConsumerState<MassageScreen> createState() => _MassageScreenState();
}

class _MassageScreenState extends ConsumerState<MassageScreen>
    with SingleTickerProviderStateMixin {
  /// The player reports its position about twice a second. Between reports
  /// the clock is estimated, but never by more than this.
  static const Duration _maxExtrapolation = Duration(milliseconds: 600);

  /// Distance from the end at which the video counts as finished.
  static const Duration _endTolerance = Duration(milliseconds: 300);

  late final Ticker _ticker;
  late final MassageVideoSource _videos;
  VideoPlayerController? _video;
  bool _videoFailed = false;
  bool _wantsPlay = false;
  bool _playing = false;
  bool _completionReported = false;
  Duration _reported = Duration.zero;
  final Stopwatch _sinceReport = Stopwatch();
  Duration _position = Duration.zero;

  /// Furthest point really played. Going back to repeat a zone is free;
  /// jumping past this is not, so every exercise is done in full.
  Duration _furthest = Duration.zero;
  final DraggableScrollableController _sheet = DraggableScrollableController();
  double _sheetExtent = _sheetOpen;
  double _panelHeight = 0;
  List<double>? _snapSizes;
  int _videoTaps = 0;

  /// The ritual measured against the real length of the video once loaded.
  MassageRitual get _ritual {
    final base = ritualFor(widget.surface);
    final video = _video;
    if (video == null || !video.value.isInitialized) return base;
    final length = video.value.duration;
    return length > Duration.zero ? base.withVideoDuration(length) : base;
  }

  int get _zoneIndex => _ritual.zoneIndexAt(_position);

  Duration get _zoneElapsed {
    final ritual = _ritual;
    final index = ritual.zoneIndexAt(_position);
    final elapsed = _position - ritual.zoneStart(index);
    final length = ritual.zoneLength(index);
    if (elapsed.isNegative) return Duration.zero;
    return elapsed > length ? length : elapsed;
  }

  bool get _ritualFinished {
    final video = _video;
    if (video == null || !video.value.isInitialized) return false;
    return _position >= video.value.duration - _endTolerance;
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_handleTick);
    _sheet.addListener(_handleSheet);
    _videos = ref.read(massageVideoSourceProvider);
    unawaited(_loadVideo());
  }

  Future<void> _loadVideo() async {
    final path = ritualFor(widget.surface).videoStoragePath;
    final location = await _videos.resolve(path);
    if (!mounted) return;
    final controller = switch (location) {
      MassageCachedVideo(:final file) => VideoPlayerController.file(
        file,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      ),
      MassageStreamedVideo(:final url) => VideoPlayerController.networkUrl(
        url,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      ),
    };
    try {
      await controller.initialize();
    } catch (_) {
      await controller.dispose();
      if (mounted) setState(() => _videoFailed = true);
      return;
    }
    if (!mounted) {
      await controller.dispose();
      return;
    }
    await controller.setLooping(false);
    controller.addListener(_handleVideo);
    setState(() => _video = controller);
    if (_wantsPlay) await controller.play();
  }

  /// Follows the player: position, play state and the end of the video.
  void _handleVideo() {
    final video = _video;
    if (video == null || !mounted) return;
    final value = video.value;
    if (value.hasError) {
      setState(() => _videoFailed = true);
      return;
    }
    if (value.position != _reported) {
      _reported = value.position;
      _sinceReport
        ..reset()
        ..start();
    }
    final playing = value.isPlaying;
    if (playing && !_ticker.isActive) _ticker.start();
    if (!playing && _ticker.isActive) _ticker.stop();
    final wasPlaying = _playing;
    setState(() {
      _playing = playing;
      _position = _estimate(value);
      if (playing && _position > _furthest) _furthest = _position;
    });
    if (wasPlaying && !playing && !_ritualFinished) _revealPanel();
    if (_ritualFinished) _handleCompleted();
  }

  Duration _estimate(VideoPlayerValue value) {
    if (!value.isPlaying || value.isBuffering) return value.position;
    final ahead = _sinceReport.elapsed > _maxExtrapolation
        ? _maxExtrapolation
        : _sinceReport.elapsed;
    final estimate = value.position + ahead;
    return estimate > value.duration ? value.duration : estimate;
  }

  void _handleCompleted() {
    _ticker.stop();
    final video = _video;
    if (video != null && video.value.isPlaying) unawaited(video.pause());
    if (_completionReported) return;
    _completionReported = true;
    setState(() => _playing = false);
    _revealPanel();
    final onCompleted = widget.onCompleted;
    if (onCompleted != null) {
      unawaited(onCompleted());
      return;
    }
    final cycle = ref.read(ritualCycleControllerProvider.notifier);
    switch (widget.surface) {
      case MassageSurface.face:
        unawaited(
          markAndCelebrate(
            context,
            ref,
            step: RitualStep.facial,
            mark: cycle.markFacial,
          ),
        );
      case MassageSurface.body:
        unawaited(
          markAndCelebrate(
            context,
            ref,
            step: RitualStep.body,
            mark: cycle.markBody,
          ),
        );
      case MassageSurface.tutorial:
        // Watching the tutorial is not a step of the daily ritual.
        break;
    }
  }

  /// Face and body must be followed in full: rewinding is free, skipping
  /// ahead is not. The tutorial is reference material, so it seeks freely.
  bool get _locksForward => widget.surface != MassageSurface.tutorial;

  /// Last zone the member may jump to.
  int get _reachedZone {
    final ritual = _ritual;
    if (!_locksForward) return ritual.zones.length - 1;
    return ritual.zoneIndexAt(_furthest);
  }

  @override
  void dispose() {
    _videos.releasePlayback(ritualFor(widget.surface).videoStoragePath);
    _sheet.removeListener(_handleSheet);
    _sheet.dispose();
    _ticker.dispose();
    _video
      ?..removeListener(_handleVideo)
      ..dispose();
    super.dispose();
  }

  void _handleSheet() {
    if (!_sheet.isAttached) return;
    final next = _sheet.size;
    if ((next - _sheetExtent).abs() < 0.008) return;
    final building =
        SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks;
    if (building) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleSheet();
      });
      return;
    }
    setState(() => _sheetExtent = next);
  }

  /// Sheet extent that leaves only the handle bar above the bottom edge.
  double _collapsedExtent(Size size) {
    final scale = size.width / _designWidth;
    return (_handleBarHeight * scale / size.height).clamp(0.02, 0.12);
  }

  /// Sheet extent that fits the whole panel, so no empty space shows below it.
  double _openExtent(Size size) {
    final collapsed = _collapsedExtent(size);
    if (_panelHeight <= 0 || size.height <= 0) return _sheetOpen;
    return (_panelHeight / size.height).clamp(collapsed + 0.1, _sheetMax);
  }

  /// Same list instance while the sizes hold. A new list makes the sheet
  /// snap again, which would fight the user's drag.
  List<double> _snapSizesFor(double collapsed, double open) {
    final current = _snapSizes;
    if (current != null && current[0] == collapsed && current[1] == open) {
      return current;
    }
    return _snapSizes = [collapsed, open];
  }

  void _handlePanelHeight(double height) {
    if (!mounted || (height - _panelHeight).abs() < 1) return;
    final size = MediaQuery.sizeOf(context);
    final wasOpen =
        _sheet.isAttached && (_sheet.size - _openExtent(size)).abs() < 0.01;
    setState(() => _panelHeight = height);
    if (!wasOpen) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_sheet.isAttached) return;
      _sheet.jumpTo(_openExtent(MediaQuery.sizeOf(context)));
    });
  }

  void _slideSheetTo(double extent) {
    if (!_sheet.isAttached) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _sheet.jumpTo(extent);
      return;
    }
    _sheet.animateTo(extent, duration: _sheetSlide, curve: Curves.easeOutCubic);
  }

  void _revealVideo() =>
      _slideSheetTo(_collapsedExtent(MediaQuery.sizeOf(context)));

  void _revealPanel() => _slideSheetTo(_openExtent(MediaQuery.sizeOf(context)));

  double _crystalOpacity(double collapsed, double open) {
    final span = (open - collapsed) * _crystalFadeShare;
    if (span <= 0) return _sheetExtent >= open ? 1 : 0;
    return ((_sheetExtent - collapsed) / span).clamp(0.0, 1.0);
  }

  void _handleTick(Duration _) {
    final video = _video;
    if (video == null || !video.value.isPlaying) return;
    setState(() {
      _position = _estimate(video.value);
      if (_position > _furthest) _furthest = _position;
    });
  }

  void _handleBackPressed() {
    final onBack = widget.onBack;
    if (onBack != null) {
      onBack();
      return;
    }
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.home);
  }

  void _handleCycleContinue() {
    final onContinue = widget.onContinue;
    if (onContinue != null) {
      onContinue();
      return;
    }
    // Next step still waiting today; the ones already done are skipped.
    final current = widget.surface == MassageSurface.face
        ? RitualStep.facial
        : RitualStep.body;
    context.go(nextCycleRoute(context, current: current) ?? AppRoutes.home);
  }

  Future<void> _handlePlayPause() async {
    if (_playing || _wantsPlay && _video == null) {
      _wantsPlay = false;
      await _handlePause();
      return;
    }
    _wantsPlay = true;
    final video = _video;
    if (video == null) return;
    if (_ritualFinished) await _seek(Duration.zero);
    _completionReported = false;
    _revealVideo();
    await video.play();
  }

  Future<void> _handlePause() async {
    final video = _video;
    if (video == null || !video.value.isPlaying) return;
    await video.pause();
  }

  void _handleVideoTap() {
    setState(() => _videoTaps += 1);
    unawaited(_handlePlayPause());
  }

  /// Moves the video and the clock together so the panel never lags behind.
  Future<void> _seek(Duration target) async {
    final video = _video;
    if (video == null) return;
    final length = video.value.duration;
    // Never ahead of what was really played (except in the tutorial).
    final reachable = _locksForward && target > _furthest ? _furthest : target;
    final bounded = reachable > length ? length : reachable;
    _reported = bounded;
    _sinceReport
      ..reset()
      ..start();
    setState(() => _position = bounded);
    await video.seekTo(bounded);
  }

  Future<void> _handleRestart() async {
    _wantsPlay = false;
    _completionReported = false;
    await _handlePause();
    await _seek(Duration.zero);
  }

  void _handleZoneSelected(int index) {
    final ritual = _ritual;
    if (index < 0 || index >= ritual.zones.length) return;
    // A zone not reached yet stays locked: rewinding only.
    if (index > _reachedZone) return;
    _completionReported = false;
    unawaited(_seek(ritual.zoneStart(index)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final crystal = ref.watch(selectedCrystalProvider).value;
    final insets = MediaQuery.paddingOf(context);
    final ritual = _ritual;

    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / _designWidth;
          final collapsed = _collapsedExtent(constraints.biggest);
          final open = _openExtent(constraints.biggest);
          final crystalOpacity = _crystalOpacity(collapsed, open);

          return Stack(
            children: [
              Positioned.fill(
                child: Semantics(
                  button: true,
                  label: _playing
                      ? l10n.massageVideoPauseSemantics
                      : l10n.massageVideoPlaySemantics,
                  child: GestureDetector(
                    onTap: _handleVideoTap,
                    behavior: HitTestBehavior.opaque,
                    child: RitualVideoSlot(
                      controller: _video,
                      failed: _videoFailed,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: _PlaybackPulse(
                      key: ValueKey(_videoTaps),
                      visible: _videoTaps > 0,
                      playing: _playing,
                      scale: scale,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: _playing,
                  child: ExcludeSemantics(
                    excluding: _playing,
                    child: AnimatedOpacity(
                      opacity: _playing ? 0 : 1,
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : _heroFade,
                      curve: Curves.easeOut,
                      child: Padding(
                        padding: EdgeInsets.only(top: insets.top),
                        child: _RitualHero(
                          scale: scale,
                          ritual: ritual,
                          onBackPressed: _handleBackPressed,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              DraggableScrollableSheet(
                controller: _sheet,
                initialChildSize: open,
                minChildSize: collapsed,
                maxChildSize: _sheetMax,
                snap: true,
                snapSizes: _snapSizesFor(collapsed, open),
                builder: (context, scrollController) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.darkIndigoBlue,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(_panelOverlap * scale),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.champagneGold.withValues(
                            alpha: 0.08,
                          ),
                          blurRadius: 24 * scale,
                          offset: Offset(0, -4 * scale),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const ClampingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      child: _MeasuredHeight(
                        onHeight: _handlePanelHeight,
                        child: _ControlPanel(
                          scale: scale,
                          bottomInset: insets.bottom,
                          ritual: ritual,
                          crystal: crystal,
                          crystalOpacity: crystalOpacity,
                          zoneIndex: _zoneIndex,
                          reachedIndex: _reachedZone,
                          zoneElapsed: _zoneElapsed,
                          sessionElapsed: _position,
                          playing: _playing,
                          onZoneSelected: _handleZoneSelected,
                          seekable: !_locksForward,
                          onSeek: (target) => unawaited(_seek(target)),
                          onPrevious: () => _handleZoneSelected(_zoneIndex - 1),
                          onPlayPause: () => unawaited(_handlePlayPause()),
                          onNext: () => _handleZoneSelected(_zoneIndex + 1),
                          onRestart: () => unawaited(_handleRestart()),
                          onCycleContinue:
                              (widget.inCycle || widget.onContinue != null) &&
                                  _ritualFinished
                              ? _handleCycleContinue
                              : null,
                        ),
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

/// Brief play or pause glyph that blooms and fades over the video on each tap.
class _PlaybackPulse extends StatelessWidget {
  const _PlaybackPulse({
    super.key,
    required this.visible,
    required this.playing,
    required this.scale,
  });

  static const Duration _duration = Duration(milliseconds: 750);

  final bool visible;
  final bool playing;
  final double scale;

  @override
  Widget build(BuildContext context) {
    if (!visible || MediaQuery.disableAnimationsOf(context)) {
      return const SizedBox.shrink();
    }
    final diameter = 64 * scale;

    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: _duration,
        curve: Curves.easeOutCubic,
        builder: (context, progress, child) {
          return Opacity(
            opacity: (1 - progress) * 0.9,
            child: Transform.scale(scale: 0.85 + 0.3 * progress, child: child),
          );
        },
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.darkIndigoBlue.withValues(alpha: 0.45),
            border: Border.all(
              color: AppColors.champagneGold80.withValues(alpha: 0.6),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.champagneGold.withValues(alpha: 0.25),
                blurRadius: 18 * scale,
              ),
            ],
          ),
          child: Icon(
            playing ? Icons.play_arrow_rounded : Icons.pause_rounded,
            color: AppColors.champagneGold80,
            size: diameter * 0.45,
          ),
        ),
      ),
    );
  }
}

/// Reports its child's laid-out height after each frame where it changes.
class _MeasuredHeight extends SingleChildRenderObjectWidget {
  const _MeasuredHeight({required this.onHeight, required super.child});

  final ValueChanged<double> onHeight;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasuredHeight(onHeight);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMeasuredHeight renderObject,
  ) {
    renderObject.onHeight = onHeight;
  }
}

class _RenderMeasuredHeight extends RenderProxyBox {
  _RenderMeasuredHeight(this.onHeight);

  ValueChanged<double> onHeight;
  double? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final height = size.height;
    if (height == _reported) return;
    _reported = height;
    WidgetsBinding.instance.addPostFrameCallback((_) => onHeight(height));
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
    final l10n = AppLocalizations.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned(top: 0, left: 0, right: 0, child: HikaruHeader()),
        _place(
          left: 6,
          top: 18,
          child: HikaruBackButton(onPressed: onBackPressed),
        ),
        _place(right: 16, top: 22, child: _HeaderActions(scale: scale)),
        _place(
          left: 0,
          right: 0,
          top: 69,
          child: Column(
            children: [
              Text(
                l10n.massageTemple(ritual),
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
                l10n.massageSubtitle(ritual),
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
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: l10n.massageSound,
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
          label: l10n.massageMoreOptions,
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
    required this.reachedIndex,
    required this.zoneElapsed,
    required this.sessionElapsed,
    required this.playing,
    required this.onZoneSelected,
    required this.seekable,
    required this.onSeek,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
    required this.onRestart,
    this.onCycleContinue,
  });

  final double scale;
  final double bottomInset;
  final MassageRitual ritual;
  final Crystal? crystal;
  final double crystalOpacity;
  final int zoneIndex;

  /// Zones after this one were not played yet and stay locked.
  final int reachedIndex;
  final Duration zoneElapsed;
  final Duration sessionElapsed;
  final bool playing;
  final ValueChanged<int> onZoneSelected;

  /// Reference videos (the tutorial) get a draggable bar instead of the
  /// zone markers, since they have a single zone and no order to follow.
  final bool seekable;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onRestart;
  final VoidCallback? onCycleContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final zone = ritual.zones[zoneIndex];
    final zoneLength = ritual.zoneLength(zoneIndex);
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
        border: Border(
          top: BorderSide(
            color: AppColors.champagneGold.withValues(alpha: 0.35),
            width: 0.5,
          ),
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
            label: l10n.massageRitualSheet,
            child: SizedBox(
              height: _handleBarHeight * scale,
              child: Center(
                child: Container(
                  width: 32 * scale,
                  height: 3 * scale,
                  decoration: BoxDecoration(
                    color: AppColors.champagneGold80.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadii.r4),
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
                    label: l10n.massageBreathe,
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
                    label: l10n.massageDuration,
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
          if (seekable)
            _SeekBar(
              scale: scale,
              position: sessionElapsed,
              total: ritual.videoDuration,
              onSeek: onSeek,
            )
          else
            _ZoneTimeline(
              scale: scale,
              zones: ritual.zones,
              activeIndex: zoneIndex,
              reachedIndex: reachedIndex,
              onSelected: onZoneSelected,
            ),
          SizedBox(height: AppSpacing.s10 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoundControl(
                scale: scale,
                size: 32,
                icon: Icons.skip_previous_rounded,
                semanticsLabel: l10n.massagePreviousZone,
                onPressed: zoneIndex == 0 ? null : onPrevious,
              ),
              SizedBox(width: AppSpacing.s26 * scale),
              _RoundControl(
                scale: scale,
                size: 48,
                icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                semanticsLabel: playing ? l10n.commonPause : l10n.commonPlay,
                isPrimary: true,
                onPressed: onPlayPause,
              ),
              SizedBox(width: AppSpacing.s26 * scale),
              _RoundControl(
                scale: scale,
                size: 32,
                icon: Icons.skip_next_rounded,
                semanticsLabel: l10n.massageNextZone,
                onPressed:
                    zoneIndex >= ritual.zones.length - 1 ||
                        zoneIndex + 1 > reachedIndex
                    ? null
                    : onNext,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s10 * scale),
          if (onCycleContinue != null) ...[
            _TextControl(
              label: l10n.commonContinue,
              semanticsLabel: l10n.commonContinue,
              scale: scale,
              onPressed: onCycleContinue!,
            ),
            SizedBox(height: AppSpacing.s8 * scale),
          ],
          _TextControl(
            label: l10n.massageRestart,
            semanticsLabel: l10n.massageRestartSemantics,
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
    final l10n = AppLocalizations.of(context);
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
                  : l10n.resonanceAssignedCrystalSemantics(
                      assigned.localizedName(l10n),
                    ),
              excludeSemantics: true,
              child: Container(
                width: frameSize,
                height: frameSize,
                padding: EdgeInsets.all(AppSpacing.s3 * scale),
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
                l10n.massageZoneName(zone).toUpperCase(),
                style: AppTypography.headline.copyWith(
                  color: AppColors.silver,
                  fontSize: AppFontSizes.s15 * scale,
                  letterSpacing: 4 * scale,
                ),
              ),
              SizedBox(height: AppSpacing.s4 * scale),
              Text(
                l10n.massageZoneInstruction(zone),
                style: AppTypography.body.copyWith(
                  color: AppColors.silver.withValues(alpha: 0.78),
                  fontSize: AppFontSizes.s10_5 * scale,
                  fontWeight: FontWeight.w300,
                  height: 1.4,
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
        color: AppColors.indigoBlue80.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.r16 * scale),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.28),
          width: 0.6,
        ),
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
          isInhaling
              ? AppLocalizations.of(context).massageInhale
              : AppLocalizations.of(context).massageExhale,
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

/// Draggable progress bar for the tutorial. While dragging it shows the
/// chosen time; the video only moves when the finger is lifted.
class _SeekBar extends StatefulWidget {
  const _SeekBar({
    required this.scale,
    required this.position,
    required this.total,
    required this.onSeek,
  });

  final double scale;
  final Duration position;
  final Duration total;
  final ValueChanged<Duration> onSeek;

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  double? _drag;

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final total = widget.total.inMilliseconds.toDouble();
    final max = total <= 0 ? 1.0 : total;
    final live = widget.position.inMilliseconds.toDouble().clamp(0.0, max);
    final value = _drag ?? live;
    final labelStyle = AppTypography.footnote.copyWith(
      color: AppColors.silver.withValues(alpha: 0.75),
      fontSize: AppFontSizes.s9 * scale,
      letterSpacing: 0.6 * scale,
    );

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2.5 * scale,
            activeTrackColor: AppColors.champagneGold80,
            inactiveTrackColor: AppColors.champagneGold80.withValues(
              alpha: 0.3,
            ),
            thumbColor: AppColors.champagneGold,
            overlayColor: AppColors.champagneGold.withValues(alpha: 0.18),
            trackShape: const RoundedRectSliderTrackShape(),
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 6.5 * scale,
              elevation: 0,
              pressedElevation: 0,
            ),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 16 * scale),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: max,
            onChangeStart: (v) => setState(() => _drag = v),
            onChanged: (v) => setState(() => _drag = v),
            onChangeEnd: (v) {
              setState(() => _drag = null);
              widget.onSeek(Duration(milliseconds: v.round()));
            },
            semanticFormatterCallback: (v) =>
                formatMassageClock(Duration(milliseconds: v.round())),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.s8 * scale),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatMassageClock(Duration(milliseconds: value.round())),
                style: labelStyle,
              ),
              Text(formatMassageClock(widget.total), style: labelStyle),
            ],
          ),
        ),
      ],
    );
  }
}

class _ZoneTimeline extends StatelessWidget {
  const _ZoneTimeline({
    required this.scale,
    required this.zones,
    required this.activeIndex,
    required this.reachedIndex,
    required this.onSelected,
  });

  final double scale;
  final List<MassageZone> zones;
  final int activeIndex;
  final int reachedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final markerTop = 7 * scale;

    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: markerTop + 4.75 * scale,
          child: Container(
            height: AppSpacing.s0_5,
            color: AppColors.champagneGold80.withValues(alpha: 0.3),
          ),
        ),
        Row(
          children: [
            for (final (index, zone) in zones.indexed)
              Expanded(
                child: _ZoneStage(
                  scale: scale,
                  name: l10n.massageZoneName(zone),
                  isActive: index == activeIndex,
                  isDone: index < activeIndex,
                  isLocked: index > reachedIndex,
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
    required this.isLocked,
    required this.markerTop,
    required this.onPressed,
  });

  final double scale;
  final String name;
  final bool isActive;
  final bool isDone;

  /// Not played yet: dimmed and not tappable, so the ritual is not skipped.
  final bool isLocked;
  final double markerTop;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final marker = 9.5 * scale;
    final filled = isActive || isDone;

    return Semantics(
      button: true,
      enabled: !isLocked,
      selected: isActive,
      label: name,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: isLocked ? null : onPressed,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: isLocked ? 0.45 : 1,
          child: Column(
            children: [
              SizedBox(height: markerTop),
              Container(
                width: marker,
                height: marker,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled
                      ? AppColors.champagneGold80
                      : AppColors.darkIndigoBlue,
                  border: Border.all(
                    color: AppColors.champagneGold80.withValues(
                      alpha: filled ? 1 : 0.55,
                    ),
                    width: 0.6,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.champagneGold.withValues(
                              alpha: 0.55,
                            ),
                            blurRadius: 8 * scale,
                            spreadRadius: 1 * scale,
                          ),
                        ]
                      : null,
                ),
              ),
              SizedBox(height: AppSpacing.s9 * scale),
              Text(
                name.toUpperCase(),
                style: AppTypography.footnote.copyWith(
                  color: isActive
                      ? AppColors.champagneGold80
                      : AppColors.silver.withValues(alpha: 0.6),
                  fontSize: AppFontSizes.s7_5 * scale,
                  letterSpacing: 0.4 * scale,
                ),
              ),
            ],
          ),
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
            gradient: isPrimary
                ? RadialGradient(
                    colors: [
                      AppColors.champagneGold.withValues(alpha: 0.22),
                      AppColors.darkIndigoBlue,
                    ],
                  )
                : null,
            color: isPrimary ? null : AppColors.darkIndigoBlue,
            border: Border.all(
              color: color.withValues(alpha: color.a * (isPrimary ? 0.9 : 0.5)),
              width: isPrimary ? 0.8 : 0.5,
            ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.champagneGold.withValues(alpha: 0.35),
                      blurRadius: 14 * scale,
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
