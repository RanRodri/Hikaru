import 'dart:async';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The 10 s animation plus the time it takes to decode its first frame.
const Duration splashLogoDuration = Duration(milliseconds: 10400);

const String _symbolAsset = 'assets/images/splash_symbol.webp';
const String _logoAsset = 'assets/images/official_logo.png';
const String _soundAsset = 'audio/splash.m4a';

/// The official logo. Only its symbol moves: the S-wave unravels and
/// settles into the gold figure-8, with the animation's sound.
class SplashLogo extends StatefulWidget {
  const SplashLogo({super.key});

  @override
  State<SplashLogo> createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo> {
  static const double _logoSize = 280;

  final Stopwatch _clock = Stopwatch();
  ui.Codec? _symbolCodec;
  ui.Image? _symbolFrame;
  ui.Image? _wordmark;
  Timer? _frameTimer;
  AudioPlayer? _player;
  Duration _nextFrameAt = Duration.zero;
  int _framesShown = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    _symbolCodec?.dispose();
    _symbolFrame?.dispose();
    _wordmark?.dispose();
    _player?.dispose();
    super.dispose();
  }

  Future<ui.Codec> _codecFor(String asset) async {
    final data = await rootBundle.load(asset);
    return ui.instantiateImageCodec(data.buffer.asUint8List());
  }

  Future<void> _start() async {
    final [symbolCodec, logoCodec] = await Future.wait([
      _codecFor(_symbolAsset),
      _codecFor(_logoAsset),
    ]);
    final firstFrame = await symbolCodec.getNextFrame();
    final wordmark = (await logoCodec.getNextFrame()).image;
    logoCodec.dispose();
    if (!mounted) {
      symbolCodec.dispose();
      firstFrame.image.dispose();
      wordmark.dispose();
      return;
    }

    setState(() {
      _symbolFrame = firstFrame.image;
      _wordmark = wordmark;
    });
    unawaited(_playSound());
    if (MediaQuery.disableAnimationsOf(context)) {
      symbolCodec.dispose();
      return;
    }

    _symbolCodec = symbolCodec;
    _framesShown = 1;
    _nextFrameAt = firstFrame.duration;
    _clock.start();
    _scheduleNextFrame();
  }

  Future<void> _playSound() async {
    try {
      final player = _player = AudioPlayer();
      await player.play(AssetSource(_soundAsset));
    } catch (_) {
      // Widget tests have no audio backend. The splash stays silent.
    }
  }

  void _scheduleNextFrame() {
    final codec = _symbolCodec;
    if (codec == null || _framesShown >= codec.frameCount) return;
    _frameTimer = Timer(_nextFrameAt - _clock.elapsed, _showNextFrame);
  }

  Future<void> _showNextFrame() async {
    final codec = _symbolCodec;
    if (codec == null) return;

    final frame = await codec.getNextFrame();
    if (!mounted) {
      frame.image.dispose();
      return;
    }

    _framesShown++;
    _nextFrameAt += frame.duration;
    setState(() {
      _symbolFrame?.dispose();
      _symbolFrame = frame.image;
    });
    _scheduleNextFrame();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Hikaru Lift',
      image: true,
      child: Center(
        child: SizedBox.square(
          dimension: _logoSize,
          child: CustomPaint(
            painter: _SplashLogoPainter(
              symbol: _symbolFrame,
              wordmark: _wordmark,
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashLogoPainter extends CustomPainter {
  const _SplashLogoPainter({required this.symbol, required this.wordmark});

  /// official_logo.png is 1080 px square. Both rects use its pixels.
  static const double _logoPixels = 1080;

  /// Sized so the animation's S-wave matches the logo's own symbol.
  static const Rect _symbolRect = Rect.fromLTWH(377, 13, 340, 633);

  /// 光, HIKARU LIFT, the divider and the tagline.
  static const Rect _wordmarkRect = Rect.fromLTRB(0, 640, 1080, 1080);

  final ui.Image? symbol;
  final ui.Image? wordmark;

  @override
  void paint(Canvas canvas, Size size) {
    final symbolFrame = symbol;
    final wordmarkImage = wordmark;
    if (symbolFrame == null || wordmarkImage == null) return;

    final symbolSource = Rect.fromLTWH(
      0,
      0,
      symbolFrame.width.toDouble(),
      symbolFrame.height.toDouble(),
    );

    canvas
      ..save()
      ..scale(size.width / _logoPixels)
      ..drawImageRect(
        wordmarkImage,
        _wordmarkRect,
        _wordmarkRect,
        Paint()..filterQuality = FilterQuality.medium,
      )
      // The frames are gold on black. Screen drops the black and lets the
      // glow light up the blue background.
      ..drawImageRect(
        symbolFrame,
        symbolSource,
        _symbolRect,
        Paint()
          ..blendMode = BlendMode.screen
          ..filterQuality = FilterQuality.medium,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_SplashLogoPainter oldDelegate) =>
      oldDelegate.symbol != symbol || oldDelegate.wordmark != wordmark;
}
