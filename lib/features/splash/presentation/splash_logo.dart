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

  /// Official logo pixels for 光 and HIKARU LIFT™, without the tagline.
  static const Rect _wordSrc = Rect.fromLTWH(190, 640, 700, 290);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final motion = _SplashMotion(t);
    final layout = _SplashLayout.of(size);
    final frame = _SplashFrame.of(layout, motion);
    if (motion.glow > 0.01) {
      _drawStrands(canvas, layout, motion, frame, glow: true);
    }
    _drawStrands(canvas, layout, motion, frame, glow: false);
    _drawAxis(canvas, layout, motion);
    _drawDots(canvas, layout, motion);
    _drawWordmark(canvas, layout, motion);
  }

  void _drawAxis(Canvas canvas, _SplashLayout layout, _SplashMotion motion) {
    final opacity = (1 - motion.morph) * motion.draw * 0.34;
    if (opacity <= 0.01) return;
    canvas.drawLine(
      Offset(layout.center.dx, layout.top - layout.ribbon * 0.15),
      Offset(layout.center.dx, layout.bottomDot),
      Paint()
        ..color = AppColors.accentGold.withValues(alpha: opacity)
        ..strokeWidth = 1,
    );
  }

  void _drawDots(Canvas canvas, _SplashLayout layout, _SplashMotion motion) {
    final opacity = motion.draw.clamp(0.0, 1.0);
    if (opacity <= 0.01) return;
    final paint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.95 * opacity);
    for (final dot in layout.dots) {
      canvas.drawCircle(dot, layout.dotRadius, paint);
    }
  }

  void _drawStrands(
    Canvas canvas,
    _SplashLayout layout,
    _SplashMotion motion,
    _SplashFrame frame, {
    required bool glow,
  }) {
    if (motion.reveal <= 0.001 || frame.points.isEmpty) return;

    for (var strand = 0; strand < _strands; strand++) {
      final paint = _strandPaint(layout, motion, strand, glow);
      final under = strand.isEven ? 2 : 1;
      // Ovals, then the diagonal that passes under at the crossing.
      _strokeBand(canvas, layout, motion, frame, strand, 0, paint);
      _strokeBand(canvas, layout, motion, frame, strand, under, paint);
      if (!glow) {
        final core = _corePaint(motion, strand);
        _strokeBand(canvas, layout, motion, frame, strand, 0, core);
        _strokeBand(canvas, layout, motion, frame, strand, under, core);
      }
    }
    for (var strand = 0; strand < _strands; strand++) {
      final over = strand.isEven ? 1 : 2;
      _strokeBand(
        canvas,
        layout,
        motion,
        frame,
        strand,
        over,
        _strandPaint(layout, motion, strand, glow),
      );
      if (!glow) {
        _strokeBand(
          canvas,
          layout,
          motion,
          frame,
          strand,
          over,
          _corePaint(motion, strand),
        );
      }
    }
  }

  Paint _strandPaint(
    _SplashLayout layout,
    _SplashMotion motion,
    int strand,
    bool glow,
  ) {
    final place = _place(strand);
    final edge = place.abs();
    final gold = _gold(edge);
    final alpha = glow
        ? 0.30 * motion.glow
        : (0.55 + 0.45 * motion.brighten) * (0.86 + 0.14 * (1 - edge));
    final width = glow
        ? layout.strandWidth * 1.8
        : layout.strandWidth * (0.62 + 0.38 * motion.brighten);
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = glow
          ? ui.MaskFilter.blur(ui.BlurStyle.normal, 1.15 + 2.4 * motion.bloom)
          : null
      ..color = gold.withValues(alpha: alpha.clamp(0.0, 1.0));
  }

  /// Thin warmer core so the filament reads as metal, not a flat cream stroke.
  Paint _corePaint(_SplashMotion motion, int strand) {
    final edge = _place(strand).abs();
    final bright = Color.lerp(AppColors.accentGold, AppColors.goldGlow, 0.22)!;
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round
      ..color = bright.withValues(
        alpha: (0.22 + 0.35 * motion.brighten) * (1 - edge * 0.35),
      );
  }

  /// Deeper amber on the outer filaments, brighter gold toward the middle.
  Color _gold(double edge) {
    final deep = Color.lerp(
      AppColors.matteChampagne,
      AppColors.accentGold,
      0.62,
    )!;
    final bright = Color.lerp(AppColors.accentGold, AppColors.goldGlow, 0.12)!;
    final lit = (1 - edge).clamp(0.0, 1.0);
    return Color.lerp(deep, bright, 0.25 + 0.75 * lit)!;
  }

  double _place(int strand) => (strand / (_strands - 1)) * 2 - 1;

  void _strokeBand(
    Canvas canvas,
    _SplashLayout layout,
    _SplashMotion motion,
    _SplashFrame frame,
    int strand,
    int band,
    Paint paint,
  ) {
    final place = _place(strand);
    final spread = layout.ribbon * (0.30 + 0.70 * motion.morph);
    final path = Path();
    var drawing = false;
    for (final sample in frame.points) {
      final visible = sample.u <= motion.reveal + 0.0001 && sample.band == band;
      if (!visible) {
        drawing = false;
        continue;
      }
      final point = sample.point + sample.normal * place * spread;
      if (!drawing) {
        path.moveTo(point.dx, point.dy);
        drawing = true;
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawWordmark(
    Canvas canvas,
    _SplashLayout layout,
    _SplashMotion motion,
  ) {
    final image = wordmark;
    if (image == null || motion.text <= 0.01) return;
    final width = math.min(layout.size.width * 0.58, layout.outerWidth * 1.2);
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

class _Anchor {
  const _Anchor(this.point, this.u, this.band);

  final Offset point;
  final double u;

  /// 0 oval, 1 one diagonal of the crossing, 2 the other diagonal.
  final int band;
}

class _Sample {
  const _Sample(this.point, this.normal, this.u, this.band);

  final Offset point;
  final Offset normal;
  final double u;
  final int band;
}

class _SplashFrame {
  const _SplashFrame(this.points);

  final List<_Sample> points;

  factory _SplashFrame.of(_SplashLayout layout, _SplashMotion motion) {
    final anchors = _ovalEight(layout);
    if (anchors.length < 4) return const _SplashFrame([]);

    final morphed = <Offset>[];
    for (final anchor in anchors) {
      final wave = _wave(layout, motion, anchor.u);
      morphed.add(Offset.lerp(wave, anchor.point, motion.morph)!);
    }
    final count = morphed.length;
    final samples = <_Sample>[];
    for (var i = 0; i < count; i++) {
      final prev = morphed[(i - 1 + count) % count];
      final next = morphed[(i + 1) % count];
      final delta = next - prev;
      final len = math.max(0.001, delta.distance);
      final normal = Offset(-delta.dy / len, delta.dx / len);
      samples.add(_Sample(morphed[i], normal, anchors[i].u, anchors[i].band));
    }
    final first = samples.first;
    samples.add(_Sample(first.point, first.normal, 1, first.band));
    return _SplashFrame(samples);
  }
}

Offset _wave(_SplashLayout layout, _SplashMotion motion, double u) {
  final theta = u * math.pi * 2 + motion.phase;
  return Offset(
    layout.center.dx + math.sin(theta) * layout.halfWidth * 0.36,
    layout.center.dy - math.cos(theta) * layout.halfHeight,
  );
}

/// Two stacked ellipses with the inner corners replaced by crossing cubics.
///
/// The left and right of each loop are the ellipse itself, so the caps stay
/// round. Offsets are taken from this screen-space curve, which keeps the
/// strands parallel.
List<_Anchor> _ovalEight(_SplashLayout layout) {
  final rx = layout.halfWidth;
  final ry = layout.halfHeight * 0.5;
  final cx = layout.center.dx;
  final cyTop = layout.center.dy - ry;
  final cyBot = layout.center.dy + ry;
  const alpha = 36 * math.pi / 180;
  final phiR = math.pi / 2 - alpha;
  final phiL = math.pi / 2 + alpha;
  final phiLEnd = phiL - math.pi * 2;
  final phiBr = -math.pi / 2 + alpha;
  final phiBl = -math.pi / 2 - alpha;
  final phiBlEnd = phiBl + math.pi * 2;

  Offset at(double cye, double phi) {
    return Offset(cx + rx * math.cos(phi), cye + ry * math.sin(phi));
  }

  Offset tangent(double phi) {
    return Offset(-rx * math.sin(phi), ry * math.cos(phi));
  }

  Offset reversed(Offset value) => Offset(-value.dx, -value.dy);

  final top = _arc(at, cyTop, phiR, phiLEnd, 96);
  final bottom = _arc(at, cyBot, phiBr, phiBlEnd, 96);
  final down = _cubic(
    at(cyTop, phiL),
    reversed(tangent(phiL)),
    at(cyBot, phiBr),
    tangent(phiBr),
    48,
    0.46,
  );
  final up = _cubic(
    at(cyBot, phiBl),
    tangent(phiBl),
    at(cyTop, phiR),
    reversed(tangent(phiR)),
    48,
    0.46,
  );

  final raw = <_Anchor>[
    ..._tagged(top, 0, skipLast: true),
    ..._tagged(down, 1, skipLast: true),
    ..._tagged(bottom, 0, skipLast: true),
    ..._tagged(up, 2, skipLast: true),
  ];
  if (raw.isEmpty) return raw;

  var topIndex = 0;
  for (var i = 1; i < raw.length; i++) {
    if (raw[i].point.dy < raw[topIndex].point.dy) topIndex = i;
  }
  final ordered = <_Anchor>[
    ...raw.sublist(topIndex),
    ...raw.sublist(0, topIndex),
  ];

  final lengths = <double>[0];
  var total = 0.0;
  for (var i = 1; i < ordered.length; i++) {
    total += (ordered[i].point - ordered[i - 1].point).distance;
    lengths.add(total);
  }
  total += (ordered.first.point - ordered.last.point).distance;
  if (total <= 0) return const [];

  return [
    for (var i = 0; i < ordered.length; i++)
      _Anchor(ordered[i].point, lengths[i] / total, ordered[i].band),
  ];
}

List<_Anchor> _tagged(List<Offset> points, int band, {required bool skipLast}) {
  final end = skipLast ? points.length - 1 : points.length;
  return [for (var i = 0; i < end; i++) _Anchor(points[i], 0, band)];
}

List<Offset> _arc(
  Offset Function(double cye, double phi) at,
  double cye,
  double a0,
  double a1,
  int steps,
) {
  return [for (var i = 0; i <= steps; i++) at(cye, a0 + (a1 - a0) * i / steps)];
}

List<Offset> _cubic(
  Offset p0,
  Offset d0,
  Offset p1,
  Offset d1,
  int steps,
  double scale,
) {
  Offset unit(Offset value) {
    final len = math.max(0.001, value.distance);
    return Offset(value.dx / len, value.dy / len);
  }

  final dist = (p1 - p0).distance;
  final handle = dist * scale;
  final c0 = p0 + unit(d0) * handle;
  final c1 = p1 - unit(d1) * handle;
  return [for (var i = 0; i <= steps; i++) _bezier(p0, c0, c1, p1, i / steps)];
}

Offset _bezier(Offset p0, Offset c0, Offset c1, Offset p1, double t) {
  final u = 1 - t;
  return p0 * (u * u * u) +
      c0 * (3 * u * u * t) +
      c1 * (3 * u * t * t) +
      p1 * (t * t * t);
}

class _SplashLayout {
  const _SplashLayout({
    required this.size,
    required this.center,
    required this.halfWidth,
    required this.halfHeight,
    required this.ribbon,
    required this.outerWidth,
    required this.strandWidth,
    required this.dotRadius,
    required this.dots,
    required this.bottomDot,
    required this.wordCenterY,
  });

  final Size size;
  final Offset center;
  final double halfWidth;
  final double halfHeight;
  final double ribbon;
  final double outerWidth;
  final double strandWidth;
  final double dotRadius;
  final List<Offset> dots;
  final double bottomDot;
  final double wordCenterY;

  double get top => center.dy - halfHeight;

  factory _SplashLayout.of(Size size) {
    final outerWidth = size.width * 0.46;
    final outerHeight = size.height * 0.56;
    final ribbon = (outerWidth * 0.08).clamp(13.0, 17.0);
    final halfWidth = outerWidth / 2 - ribbon;
    final halfHeight = outerHeight / 2 - ribbon;
    final center = Offset(size.width / 2, size.height * 0.345);
    final ry = halfHeight * 0.5;
    final topHole = center.dy - ry;
    final bottomHole = center.dy + ry;
    final spread = ry * 0.30;
    final below = center.dy + halfHeight + ribbon + ry * 0.16;
    final dots = <Offset>[
      Offset(center.dx, topHole - spread),
      Offset(center.dx, topHole),
      Offset(center.dx, topHole + spread),
      Offset(center.dx, bottomHole - spread * 0.62),
      Offset(center.dx, bottomHole + spread * 0.62),
      Offset(center.dx, below),
    ];
    return _SplashLayout(
      size: size,
      center: center,
      halfWidth: halfWidth,
      halfHeight: halfHeight,
      ribbon: ribbon,
      outerWidth: outerWidth,
      strandWidth: 1.55,
      dotRadius: 2.35,
      dots: dots,
      bottomDot: below,
      wordCenterY: below + size.height * 0.072,
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
