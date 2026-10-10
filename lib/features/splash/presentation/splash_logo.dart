import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design_system/tokens/app_colors.dart';

/// Length of the one-shot splash mark. The screen waits this long.
const Duration splashLogoDuration = Duration(milliseconds: 7500);

const String splashLogoAsset = 'assets/images/official_logo.png';

/// Official logo: the mark draws on, writhes, then locks to the asset.
class SplashLogo extends StatefulWidget {
  const SplashLogo({super.key});

  @override
  State<SplashLogo> createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo>
    with SingleTickerProviderStateMixin {
  static const double _maxSide = 280;

  late final AnimationController _controller;
  ui.Image? _image;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: splashLogoDuration,
    );
    _loadLogo();
  }

  Future<void> _loadLogo() async {
    final data = await rootBundle.load(splashLogoAsset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    if (!mounted) {
      frame.image.dispose();
      return;
    }
    setState(() => _image = frame.image);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion == _reduceMotion && _controller.isAnimating) return;
    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _controller.value = 1;
      return;
    }
    if (!_controller.isAnimating && _controller.value < 1) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final side = math.min(_maxSide, MediaQuery.sizeOf(context).width - 48);
    final image = _image;

    return Semantics(
      label: 'Hikaru Lift',
      image: true,
      child: SizedBox(
        width: side,
        height: side,
        child: image == null
            ? const SizedBox.expand()
            : AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: SplashLogoPainter(
                    image: image,
                    t: _reduceMotion ? 1 : _controller.value,
                  ),
                  size: Size.square(side),
                ),
              ),
      ),
    );
  }
}

class SplashLogoPainter extends CustomPainter {
  const SplashLogoPainter({required this.image, required this.t});

  final ui.Image image;
  final double t;

  static const double _markFraction = 0.6;
  static const int _strips = 42;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final motion = _SplashMotion(t);
    final markHeight = size.height * _markFraction;
    final markRect = Rect.fromLTWH(0, 0, size.width, markHeight);
    final wordRect = Rect.fromLTWH(
      0,
      markHeight,
      size.width,
      size.height - markHeight,
    );

    _drawAxis(canvas, size, motion);
    if (motion.settled) {
      _drawSlice(canvas, 0, image.height * _markFraction, markRect, 1);
    } else {
      _drawWrithe(canvas, markRect, motion);
    }
    _drawSlice(
      canvas,
      image.height * _markFraction,
      image.height.toDouble(),
      wordRect,
      1,
    );
    _drawGlow(canvas, markRect, motion);
  }

  void _drawWrithe(Canvas canvas, Rect markRect, _SplashMotion motion) {
    final srcHeight = image.height * _markFraction;
    final stripSrc = srcHeight / _strips;
    final stripDst = markRect.height / _strips;
    for (var index = 0; index < _strips; index++) {
      final reveal = (motion.draw * (_strips + 5) - index) / 5;
      if (reveal <= 0) continue;
      final yNorm = index / (_strips - 1);
      final wave = math.sin(yNorm * math.pi * 2.5 + motion.phase * math.pi * 2);
      final shift = wave * motion.writhe * markRect.width * 0.045;
      final dst = Rect.fromLTWH(
        markRect.left + shift,
        markRect.top + index * stripDst,
        markRect.width,
        stripDst + 0.5,
      );
      _drawSlice(
        canvas,
        index * stripSrc,
        stripSrc + 0.5,
        dst,
        reveal.clamp(0, 1) * (0.62 + 0.38 * motion.brighten),
        sourceHeight: true,
      );
    }
  }

  void _drawSlice(
    Canvas canvas,
    double srcTop,
    double srcBottomOrHeight,
    Rect dst,
    double opacity, {
    bool sourceHeight = false,
  }) {
    if (opacity <= 0 || dst.height <= 0) return;
    final srcH = sourceHeight ? srcBottomOrHeight : srcBottomOrHeight - srcTop;
    final src = Rect.fromLTWH(0, srcTop, image.width.toDouble(), srcH);
    canvas.drawImageRect(
      image,
      src,
      dst,
      Paint()..color = Color.fromRGBO(255, 255, 255, opacity.clamp(0, 1)),
    );
  }

  void _drawAxis(Canvas canvas, Size size, _SplashMotion motion) {
    final opacity = (1 - motion.brighten) * 0.28 * motion.draw;
    if (opacity <= 0.01) return;
    final markHeight = size.height * _markFraction;
    canvas.drawLine(
      Offset(size.width / 2, markHeight * 0.06),
      Offset(size.width / 2, markHeight * 0.96),
      Paint()
        ..color = AppColors.champagneGold.withValues(alpha: opacity)
        ..strokeWidth = 1,
    );
  }

  void _drawGlow(Canvas canvas, Rect markRect, _SplashMotion motion) {
    final amount = math.max(motion.bloom, motion.pulse * 0.35);
    if (amount <= 0.01) return;
    canvas.saveLayer(
      markRect.inflate(24),
      Paint()
        ..imageFilter = ui.ImageFilter.blur(
          sigmaX: 10 + 14 * motion.bloom,
          sigmaY: 10 + 14 * motion.bloom,
        ),
    );
    _drawSlice(
      canvas,
      0,
      image.height * _markFraction,
      markRect,
      0.55 * amount,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(SplashLogoPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.image != image;
}

class _SplashMotion {
  const _SplashMotion(this.t);

  final double t;

  double get draw => _unit(0, 0.18);

  double get writhe {
    if (t < 0.18) return draw;
    if (t < 0.46) return 1;
    return 1 - _unit(0.46, 0.74);
  }

  double get phase => t * 1.7;

  double get brighten => _unit(0.46, 0.74);

  bool get settled => t >= 0.74;

  double get bloom {
    if (t < 0.74) return 0;
    if (t < 0.82) return Curves.easeOut.transform(_unit(0.74, 0.82));
    return 1 - Curves.easeOut.transform(_unit(0.82, 0.9));
  }

  double get pulse {
    if (t < 0.88) return 0;
    return 0.5 + 0.5 * math.sin(_unit(0.88, 1) * math.pi * 2);
  }

  double _unit(double start, double end) {
    final value = ((t - start) / (end - start)).clamp(0.0, 1.0);
    return value;
  }
}
