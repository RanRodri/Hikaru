import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../data/merkaba_video_source.dart';

/// Video drift from the session clock that triggers a corrective seek.
///
/// Generous on purpose: a far seek has to find a keyframe and, when streamed,
/// buffer. A tight tolerance re-seeks before the previous seek has landed,
/// which restarts the buffering every time and freezes the picture.
const Duration merkabaVideoMaxDrift = Duration(milliseconds: 1500);

/// Time a seek is given to land before drift is measured again.
const Duration merkabaVideoSeekSettle = Duration(seconds: 3);

enum MerkabaVideoStatus { loading, ready, failed }

/// The silent pre-rendered video. The session clock leads: the screen tells
/// the playback where the clock is and the playback follows.
abstract class MerkabaVideoPlayback extends ChangeNotifier {
  MerkabaVideoStatus get status;

  /// Starts loading. Safe to call more than once.
  void load();

  /// Plays from [clock], seeking when the video is not already there.
  Future<void> play(Duration clock);

  Future<void> pause();

  /// Jumps to [clock] right away, playing or not.
  Future<void> seek(Duration clock);

  /// Seeks when the video has drifted more than [merkabaVideoMaxDrift] from
  /// [clock].
  Future<void> sync(Duration clock);

  /// Called once the whole session was played, so the next one can read the
  /// video from the device.
  Future<void> keepForNextTime();

  /// The picture, covering its box.
  Widget buildView();
}

typedef MerkabaVideoPlaybackFactory =
    MerkabaVideoPlayback Function(MerkabaVideoSource source);

/// Plays the video with `video_player`, muted and mixing with other audio so
/// it never takes the audio session away from the ambient sound.
class VideoPlayerMerkabaPlayback extends MerkabaVideoPlayback {
  VideoPlayerMerkabaPlayback(this._source);

  final MerkabaVideoSource _source;

  VideoPlayerController? _controller;
  MerkabaVideoStatus _status = MerkabaVideoStatus.loading;
  bool _loading = false;
  bool _disposed = false;
  bool _wantsPlay = false;
  Duration _clock = Duration.zero;
  bool _positioned = false;

  /// A seek is running. Seeks never overlap: a request that arrives meanwhile
  /// is kept in [_pendingSeek] and only the latest one runs next.
  bool _seeking = false;
  Duration? _pendingSeek;
  DateTime _settledAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  MerkabaVideoStatus get status => _status;

  @override
  void load() {
    if (_loading || _disposed) return;
    _loading = true;
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    VideoPlayerController? controller;
    try {
      final location = await _source.resolve();
      final options = VideoPlayerOptions(mixWithOthers: true);
      controller = switch (location) {
        MerkabaCachedVideo(:final file) => VideoPlayerController.file(
          file,
          videoPlayerOptions: options,
        ),
        MerkabaStreamedVideo(:final url) => VideoPlayerController.networkUrl(
          url,
          videoPlayerOptions: options,
        ),
      };
      await controller.initialize();
      await _activate(controller);
      // Keep a device copy from the first session on, not only after a full
      // sitting: seeking and resuming in a local file is instant, while a
      // stream has to buffer at every jump.
      if (location is MerkabaStreamedVideo) unawaited(_source.cache());
    } catch (error, stackTrace) {
      log(
        'Merkaba video could not be loaded',
        name: 'hikaru.merkaba',
        error: error,
        stackTrace: stackTrace,
      );
      await controller?.dispose();
      _fail();
    }
  }

  Future<void> _activate(VideoPlayerController controller) async {
    if (_disposed) {
      await controller.dispose();
      return;
    }
    await controller.setVolume(0);
    await controller.setLooping(false);
    controller.addListener(_watchForErrors);
    _controller = controller;
    _status = MerkabaVideoStatus.ready;
    notifyListeners();
    if (_wantsPlay) await play(_clock);
  }

  void _watchForErrors() {
    if (_controller?.value.hasError ?? false) _fail();
  }

  void _fail() {
    if (_disposed || _status == MerkabaVideoStatus.failed) return;
    _status = MerkabaVideoStatus.failed;
    notifyListeners();
  }

  @override
  Future<void> play(Duration clock) async {
    _wantsPlay = true;
    _clock = clock;
    final controller = _readyController;
    if (controller == null) return;
    try {
      if (!_positioned || _drift(controller, clock) > merkabaVideoMaxDrift) {
        await _seekTo(controller, clock);
      }
      if (_wantsPlay) await controller.play();
    } catch (error, stackTrace) {
      _report(error, stackTrace);
    }
  }

  /// Runs one seek at a time and remembers when it landed.
  Future<void> _seekTo(VideoPlayerController controller, Duration clock) async {
    if (_seeking) {
      _pendingSeek = clock;
      return;
    }
    _seeking = true;
    try {
      var target = clock;
      while (true) {
        await controller.seekTo(_clamped(controller, target));
        _positioned = true;
        final next = _pendingSeek;
        _pendingSeek = null;
        if (next == null || _disposed) break;
        target = next;
      }
    } finally {
      _seeking = false;
      _settledAt = DateTime.now();
    }
  }

  /// True while the last seek may still be decoding or buffering, so its
  /// position is not yet a fair measure of drift.
  bool _settling(VideoPlayerController controller) =>
      _seeking ||
      controller.value.isBuffering ||
      DateTime.now().difference(_settledAt) < merkabaVideoSeekSettle;

  @override
  Future<void> pause() async {
    _wantsPlay = false;
    final controller = _readyController;
    if (controller == null) return;
    try {
      await controller.pause();
    } catch (error, stackTrace) {
      _report(error, stackTrace);
    }
  }

  @override
  Future<void> seek(Duration clock) async {
    _clock = clock;
    final controller = _readyController;
    if (controller == null) return;
    try {
      await _seekTo(controller, clock);
      if (_wantsPlay && !controller.value.isPlaying) await controller.play();
    } catch (error, stackTrace) {
      _report(error, stackTrace);
    }
  }

  @override
  Future<void> sync(Duration clock) async {
    _clock = clock;
    final controller = _readyController;
    if (controller == null || !_wantsPlay) return;
    try {
      // Let a recent seek land before judging drift; re-seeking now would
      // restart the buffering and the picture would never move again.
      if (_settling(controller)) {
        if (!_seeking && !controller.value.isPlaying) await controller.play();
        return;
      }
      if (_drift(controller, clock) > merkabaVideoMaxDrift) {
        await _seekTo(controller, clock);
      }
      if (!controller.value.isPlaying && !controller.value.isBuffering) {
        await controller.play();
      }
    } catch (error, stackTrace) {
      _report(error, stackTrace);
    }
  }

  @override
  Future<void> keepForNextTime() async {
    final controller = _controller;
    if (controller == null) return;
    // Only a video read from the network needs saving.
    if (controller.dataSourceType != DataSourceType.network) return;
    await _source.cache();
  }

  @override
  Widget buildView() {
    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();
    final size = controller.value.size;
    if (size.isEmpty) return const SizedBox.shrink();
    // The picture always spans the full width of the screen, so nothing at
    // the sides is cropped. On taller phones the video sits in the middle and
    // its top and bottom edges melt into the starry night behind it.
    return Center(
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x00FFFFFF),
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
            Color(0x00FFFFFF),
          ],
          stops: [0, 0.07, 0.93, 1],
        ).createShader(bounds),
        child: AspectRatio(
          aspectRatio: size.width / size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }

  VideoPlayerController? get _readyController =>
      _status == MerkabaVideoStatus.ready && !_disposed ? _controller : null;

  Duration _drift(VideoPlayerController controller, Duration clock) =>
      (controller.value.position - _clamped(controller, clock)).abs();

  Duration _clamped(VideoPlayerController controller, Duration clock) {
    final length = controller.value.duration;
    if (length == Duration.zero || clock <= length) return clock;
    return length;
  }

  void _report(Object error, StackTrace stackTrace) {
    log(
      'Merkaba video command failed',
      name: 'hikaru.merkaba',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      controller.removeListener(_watchForErrors);
      unawaited(controller.dispose());
    }
    super.dispose();
  }
}

final merkabaVideoPlaybackFactoryProvider =
    Provider<MerkabaVideoPlaybackFactory>(
      (ref) =>
          (source) => VideoPlayerMerkabaPlayback(source),
    );

/// Full-bleed video over the starry night. While it loads the night shows
/// through with a faint gold indicator; if it fails, [fallback] is drawn.
class MerkabaVideoLayer extends StatelessWidget {
  const MerkabaVideoLayer({
    super.key,
    required this.playback,
    required this.fallback,
  });

  static const Duration fade = Duration(milliseconds: 900);

  final MerkabaVideoPlayback playback;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: playback,
      builder: (context, _) => switch (playback.status) {
        MerkabaVideoStatus.failed => fallback,
        MerkabaVideoStatus.loading => const _VideoLoading(),
        MerkabaVideoStatus.ready => TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : fade,
          curve: Curves.easeOut,
          builder: (context, opacity, child) =>
              Opacity(opacity: opacity, child: child),
          child: RepaintBoundary(child: playback.buildView()),
        ),
      },
    );
  }
}

class _VideoLoading extends StatelessWidget {
  const _VideoLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: AppLocalizations.of(context).merkabaPreparing,
        child: SizedBox.square(
          dimension: 22,
          child: CircularProgressIndicator(
            strokeWidth: 1,
            color: AppColors.champagneGold.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
