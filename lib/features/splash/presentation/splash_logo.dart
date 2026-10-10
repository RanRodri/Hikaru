import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design_system/tokens/app_colors.dart';

/// Length of the one-shot splash mark. The screen waits this long.
const Duration splashLogoDuration = Duration(milliseconds: 7500);

const String splashLogoAsset = 'assets/images/official_logo.png';

/// Draws the infinity mark, then fades in the official wordmark.
///
/// 0–4 s: thin gold curves draw on and undulate around a faint axis.
/// 4–6 s: they thicken and ease into the figure-8. The axis fades.
/// Then a soft bloom and a slow pulse. The screen keeps the locked mark
/// until [splashLogoDuration] elapses.
class SplashLogo extends StatefulWidget {
  const SplashLogo({super.key});

  @override
  State<SplashLogo> createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo>
    with SingleTickerProviderStateMixin {
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
    if (reduceMotion == _reduceMotion && _controller.isAnimating) {
      return;
    }
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
    return Semantics(
      label: 'Hikaru Lift',
      image: true,
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: SplashLogoPainter(
              wordmark: _image,
              t: _reduceMotion ? 1 : _controller.value,
            ),
          ),
        ),
      ),
    );
  }
}

class SplashLogoPainter extends CustomPainter {
  const SplashLogoPainter({required this.wordmark, required this.t});

  /// Kanji and HIKARU LIFT™ sliced from the official logo. The mark itself
  /// is drawn: the asset's symbol is the S-wave, not this figure-8.
  final ui.Image? wordmark;
  final double t;

  static const int _strands = 10;
  static const int _steps = 220;

  /// Official logo pixels for 光 and HIKARU LIFT™, without the tagline.
  static const Rect _wordSrc = Rect.fromLTWH(190, 640, 700, 290);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final motion = _SplashMotion(t);
    final layout = _SplashLayout.of(size);
    _drawAxis(canvas, layout, motion);
    _drawDots(canvas, layout, motion);
    if (motion.glow > 0.01) {
      _drawBloom(canvas, layout, motion);
    }
    _drawStrands(canvas, layout, motion, glow: false);
    _drawWordmark(canvas, layout, motion);
  }

  void _drawAxis(Canvas canvas, _SplashLayout layout, _SplashMotion motion) {
    final opacity = (1 - motion.morph) * motion.draw * 0.34;
    if (opacity <= 0.01) return;
    canvas.drawLine(
      Offset(layout.center.dx, layout.top - layout.halfHeight * 0.04),
      Offset(layout.center.dx, layout.bottomDot),
      Paint()
        ..color = AppColors.champagneGold.withValues(alpha: opacity)
        ..strokeWidth = 1,
    );
  }

  void _drawDots(Canvas canvas, _SplashLayout layout, _SplashMotion motion) {
    final opacity = motion.draw.clamp(0.0, 1.0);
    if (opacity <= 0.01) return;
    final paint = Paint()
      ..color = AppColors.champagneGold.withValues(alpha: 0.9 * opacity);
    final radius = math.max(2.2, layout.halfWidth * 0.018);
    for (final dot in layout.dots) {
      canvas.drawCircle(dot, radius, paint);
    }
  }

  void _drawBloom(Canvas canvas, _SplashLayout layout, _SplashMotion motion) {
    final bounds = layout.markBounds.inflate(36);
    canvas.saveLayer(
      bounds,
      Paint()
        ..imageFilter = ui.ImageFilter.blur(
          sigmaX: 10 + 8 * motion.bloom,
          sigmaY: 10 + 8 * motion.bloom,
        ),
    );
    _drawStrands(canvas, layout, motion, glow: true);
    canvas.restore();
  }

  void _drawStrands(
    Canvas canvas,
    _SplashLayout layout,
    _SplashMotion motion, {
    required bool glow,
  }) {
    final reveal = motion.reveal;
    if (reveal <= 0.001) return;

    // First half sits under the return stroke, so the waist reads as a weave.
    _strokeRange(canvas, layout, motion, 0, math.min(reveal, 0.5), glow);
    if (reveal > 0.5) {
      _strokeRange(canvas, layout, motion, 0.5, reveal, glow);
    }
  }

  void _strokeRange(
    Canvas canvas,
    _SplashLayout layout,
    _SplashMotion motion,
    double from,
    double to,
    bool glow,
  ) {
    for (var strand = 0; strand < _strands; strand++) {
      final path = _strandPath(layout, motion, strand, from, to);
      final place = (strand / (_strands - 1)) * 2 - 1;
      final edge = place.abs();
      final gold = Color.lerp(
        AppColors.champagneGold,
        AppColors.splashHighlight,
        glow ? 0.35 : 0.15 + edge * 0.75,
      )!;
      final alpha = glow
          ? 0.34 * motion.glow
          : (0.55 + 0.45 * motion.brighten) * (0.78 + 0.22 * edge);
      final width = glow
          ? layout.strandWidth * 3.2
          : layout.strandWidth * (0.85 + 0.9 * motion.brighten);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = gold.withValues(alpha: alpha.clamp(0.0, 1.0)),
      );
    }
  }

  Path _strandPath(
    _SplashLayout layout,
    _SplashMotion motion,
    int strand,
    double from,
    double to,
  ) {
    final path = Path();
    final place = (strand / (_strands - 1)) * 2 - 1;
    final start = (from * _steps).round();
    final end = (to * _steps).round();
    for (var step = start; step <= end; step++) {
      final u = step / _steps;
      final point = _point(layout, motion, place, u);
      if (step == start) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path;
  }

  Offset _point(
    _SplashLayout layout,
    _SplashMotion motion,
    double place,
    double u,
  ) {
    final theta = u * math.pi * 2 + motion.phase;
    final local = _figure(theta, motion.morph);
    final ahead = _figure(theta + 0.02, motion.morph);
    final dx = ahead.dx - local.dx;
    final dy = ahead.dy - local.dy;
    final len = math.max(0.0001, math.sqrt(dx * dx + dy * dy));
    final nx = -dy / len;
    final ny = dx / len;
    final ribbon = ui.lerpDouble(
      layout.halfWidth * 0.05,
      layout.halfWidth * 0.2,
      motion.morph,
    )!;
    final shift = place * ribbon;
    return Offset(
      layout.center.dx +
          local.dx * layout.halfWidth +
          nx * shift * motion.morph,
      layout.center.dy -
          local.dy * layout.halfHeight +
          ny * shift * motion.morph * 0.72 +
          place * (1 - motion.morph) * layout.halfWidth * 0.055,
    );
  }

  /// Unit figure-8. Y is +1 at the top. X widens as [morph] closes the loops.
  Offset _figure(double theta, double morph) {
    final sine = math.sin(theta);
    final cosine = math.cos(theta);
    final denom = 1 + sine * sine;
    final eightX = (sine * cosine) / denom * 2.35;
    final waveX = math.sin(theta) * 0.42;
    return Offset(ui.lerpDouble(waveX, eightX, morph)!, cosine / denom);
  }

  void _drawWordmark(
    Canvas canvas,
    _SplashLayout layout,
    _SplashMotion motion,
  ) {
    final image = wordmark;
    if (image == null || motion.text <= 0.01) return;
    final width = math.min(layout.size.width * 0.78, 380.0);
    final height = width * _wordSrc.height / _wordSrc.width;
    final rect = Rect.fromCenter(
      center: Offset(layout.center.dx, layout.wordCenterY),
      width: width,
      height: height,
    );
    canvas.drawImageRect(
      image,
      _wordSrc,
      rect,
      Paint()..color = Color.fromRGBO(255, 255, 255, motion.text),
    );
  }

  @override
  bool shouldRepaint(SplashLogoPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.wordmark != wordmark;
}

class _SplashLayout {
  const _SplashLayout({
    required this.size,
    required this.center,
    required this.halfWidth,
    required this.halfHeight,
    required this.strandWidth,
    required this.dots,
    required this.bottomDot,
    required this.wordCenterY,
    required this.markBounds,
  });

  final Size size;
  final Offset center;
  final double halfWidth;
  final double halfHeight;
  final double strandWidth;
  final List<Offset> dots;
  final double bottomDot;
  final double wordCenterY;
  final Rect markBounds;

  double get top => center.dy - halfHeight;

  factory _SplashLayout.of(Size size) {
    final halfHeight = size.height * 0.235;
    final halfWidth = math.min(size.width * 0.42, halfHeight * 0.92);
    final center = Offset(size.width / 2, size.height * 0.30);
    final topHole = center.dy - halfHeight * 0.52;
    final bottomHole = center.dy + halfHeight * 0.52;
    final gap = halfHeight * 0.16;
    final below = center.dy + halfHeight + halfHeight * 0.16;
    final dots = <Offset>[
      Offset(center.dx, topHole - gap),
      Offset(center.dx, topHole),
      Offset(center.dx, topHole + gap),
      Offset(center.dx, bottomHole - gap * 0.65),
      Offset(center.dx, bottomHole + gap * 0.65),
      Offset(center.dx, below),
    ];
    final wordCenterY = below + size.height * 0.11;
    return _SplashLayout(
      size: size,
      center: center,
      halfWidth: halfWidth,
      halfHeight: halfHeight,
      strandWidth: math.max(1.5, halfWidth * 0.018),
      dots: dots,
      bottomDot: below,
      wordCenterY: wordCenterY,
      markBounds: Rect.fromCenter(
        center: center,
        width: halfWidth * 2.4,
        height: halfHeight * 2.5,
      ),
    );
  }
}

class _SplashMotion {
  const _SplashMotion(this.t);

  final double t;

  double get seconds => t * splashLogoDuration.inMilliseconds / 1000;

  /// The open curves are on early, then keep undulating until the morph.
  double get draw => Curves.easeOut.transform((seconds / 1.7).clamp(0.0, 1.0));

  /// 4–6 s. The loops close first; the thickness eases in behind them.
  double get morph =>
      Curves.easeOutCubic.transform(((seconds - 4) / 2).clamp(0.0, 1.0));

  double get reveal => morph <= 0 ? draw * 0.5 : 0.5 + morph * 0.5;

  double get phase => math.sin(seconds * 1.7) * 0.38 * (1 - morph);

  double get brighten => ((seconds - 4) / 2).clamp(0.0, 1.0);

  double get bloom {
    if (seconds < 6) return 0;
    if (seconds < 6.45) {
      return Curves.easeOut.transform(((seconds - 6) / 0.45).clamp(0.0, 1.0));
    }
    if (seconds < 6.9) {
      return 1 -
          Curves.easeIn.transform(((seconds - 6.45) / 0.45).clamp(0.0, 1.0));
    }
    return 0;
  }

  /// Soft pulse after the bloom settles, until the splash hands off.
  double get pulse {
    if (seconds < 6.7) return 0;
    return 0.5 + 0.5 * math.sin((seconds - 6.7) * math.pi * 0.85);
  }

  double get glow {
    if (seconds < 6) return 0;
    return math.max(bloom, 0.22 + 0.18 * pulse);
  }

  double get text =>
      Curves.easeOut.transform(((seconds - 0.25) / 2.4).clamp(0.0, 1.0));
}
