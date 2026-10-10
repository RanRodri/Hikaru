import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../crystals/domain/crystal.dart';

/// Eight-fold cymatic shared by every crystal.
class CymaticMotif {
  const CymaticMotif({required this.folds, required this.rings});

  final int folds;
  final int rings;

  static const shared = CymaticMotif(folds: 8, rings: 4);

  static CymaticMotif of(Crystal crystal) => shared;

  @override
  bool operator ==(Object other) =>
      other is CymaticMotif && other.folds == folds && other.rings == rings;

  @override
  int get hashCode => Object.hash(folds, rings);
}

/// Hertz named in [Crystal.frequency], or 528 when the copy has no number.
double cymaticHertz(Crystal crystal) {
  final match = RegExp(r'(\d+(?:\.\d+)?)\s*Hz').firstMatch(crystal.frequency);
  return double.tryParse(match?.group(1) ?? '') ?? _referenceHertz;
}

/// One pulse of the pattern. Higher frequencies cycle a little faster.
Duration cymaticCycle(Crystal crystal) {
  final seconds =
      (_referenceCycleSeconds * (_referenceHertz / cymaticHertz(crystal)))
          .clamp(_minCycleSeconds, _maxCycleSeconds);
  return Duration(milliseconds: (seconds * 1000).round());
}

/// Fire, gold, turquoise, emerald, then indigo. The same journey for every crystal.
Duration cymaticColorJourney(Crystal crystal) {
  final seconds =
      (_colorJourneySeconds * (_referenceHertz / cymaticHertz(crystal))).clamp(
        _minColorJourneySeconds,
        _maxColorJourneySeconds,
      );
  return Duration(milliseconds: (seconds * 1000).round());
}

const double _referenceHertz = 528;
const double _referenceCycleSeconds = 4.2;
const double _minCycleSeconds = 2.8;
const double _maxCycleSeconds = 6;
const double _colorJourneySeconds = 28;
const double _minColorJourneySeconds = 18;
const double _maxColorJourneySeconds = 36;

const Duration cymaticSettleDuration = Duration(milliseconds: 800);
const double _sealFactor = 0.28;

const List<Color> _cymaticStops = [
  AppColors.cymaticFire,
  AppColors.champagneGold,
  AppColors.cymaticTurquoise,
  AppColors.emerald,
  AppColors.cymaticIndigoLight,
];

/// Eight-fold cymatic. Motion follows [playing] and rests when it is false.
class CymaticSignature extends StatefulWidget {
  const CymaticSignature({
    super.key,
    required this.crystal,
    required this.playing,
    this.showSeal = false,
    this.fillBackground = true,
    this.semanticLabel,
  });

  final Crystal crystal;
  final bool playing;
  final bool showSeal;
  final bool fillBackground;
  final String? semanticLabel;

  @override
  State<CymaticSignature> createState() => CymaticSignatureState();
}

class CymaticSignatureState extends State<CymaticSignature>
    with TickerProviderStateMixin {
  late final AnimationController _phase;
  late final AnimationController _energy;
  late final AnimationController _color;
  bool _reduceMotion = false;
  bool _synced = false;

  double get phase => _phase.value;

  /// 0 at rest, 1 while the rhythm is fully present.
  double get motion => _reduceMotion ? 0 : _energy.value;

  /// 0 is fire. 1 is the indigo the journey ends on.
  double get colorProgress => _color.value;

  bool get isAnimating =>
      _phase.isAnimating || _energy.isAnimating || _color.isAnimating;

  @override
  void initState() {
    super.initState();
    _phase = AnimationController(
      vsync: this,
      duration: cymaticCycle(widget.crystal),
    );
    _energy = AnimationController(vsync: this, duration: cymaticSettleDuration);
    _color = AnimationController(
      vsync: this,
      duration: cymaticColorJourney(widget.crystal),
      value: 1,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final changed = reduceMotion != _reduceMotion;
    _reduceMotion = reduceMotion;
    if (!_synced || changed) {
      _synced = true;
      _sync();
    }
  }

  @override
  void didUpdateWidget(CymaticSignature oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.crystal != widget.crystal) {
      _phase.duration = cymaticCycle(widget.crystal);
      _color.duration = cymaticColorJourney(widget.crystal);
    }
    if (oldWidget.playing != widget.playing ||
        oldWidget.crystal != widget.crystal) {
      _sync();
    }
  }

  void _sync() {
    if (_reduceMotion) {
      _phase
        ..stop()
        ..value = 0;
      _energy.value = 0;
      _color
        ..stop()
        ..value = 1;
      return;
    }

    final shouldMove = widget.playing;
    if (shouldMove) {
      if (!_phase.isAnimating) _phase.repeat();
      _energy.animateTo(1, curve: Curves.easeInOut);
      if (_color.value >= 1) {
        _color.forward(from: 0);
      } else if (!_color.isAnimating) {
        _color.forward();
      }
      return;
    }

    _phase.stop();
    _color.stop();
    _energy.animateTo(0, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _phase.dispose();
    _energy.dispose();
    _color.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seal = widget.showSeal
        ? Center(
            child: FractionallySizedBox(
              widthFactor: _sealFactor,
              heightFactor: _sealFactor,
              child: Image.asset(
                widget.crystal.imageAsset,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
          )
        : const SizedBox.expand();

    return Semantics(
      label: widget.semanticLabel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_phase, _energy, _color]),
        builder: (context, child) => CustomPaint(
          painter: CymaticSignaturePainter(
            motif: CymaticMotif.of(widget.crystal),
            phase: _phase.value,
            motion: motion,
            colorProgress: _color.value,
            fillBackground: widget.fillBackground,
          ),
          child: child,
        ),
        child: seal,
      ),
    );
  }
}

class CymaticSignaturePainter extends CustomPainter {
  const CymaticSignaturePainter({
    required this.motif,
    required this.phase,
    required this.motion,
    required this.colorProgress,
    required this.fillBackground,
  });

  final CymaticMotif motif;
  final double phase;
  final double motion;
  final double colorProgress;
  final bool fillBackground;

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = size.shortestSide;
    if (shortest <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = shortest / 2;
    final tint = _cymaticTint(colorProgress);
    final pulse = _pulseScale(phase, motion);

    if (fillBackground) {
      canvas.drawCircle(center, radius, Paint()..color = AppColors.indigoBlue);
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(pulse);
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: radius)),
    );

    final layer = Rect.fromCircle(center: Offset.zero, radius: radius);
    canvas.saveLayer(layer, Paint());
    _drawHalo(canvas, radius, tint);
    _drawRipples(canvas, radius, tint);
    _drawBlooms(canvas, radius, tint);
    _drawStar(canvas, radius, tint);
    _drawSpokes(canvas, radius, tint);
    _drawParticles(canvas, radius, tint);
    _drawCore(canvas, radius, tint);
    canvas.restore();
    canvas.restore();
  }

  void _drawHalo(Canvas canvas, double radius, Color tint) {
    final rect = Rect.fromCircle(center: Offset.zero, radius: radius);
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(
          colors: [
            tint.withValues(alpha: 0.55),
            tint.withValues(alpha: 0.18),
            tint.withValues(alpha: 0),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(rect),
    );
  }

  void _drawRipples(Canvas canvas, double radius, Color tint) {
    if (motion <= 0) return;
    for (var ripple = 0; ripple < 3; ripple++) {
      final travel = (phase + ripple / 3) % 1;
      canvas.drawCircle(
        Offset.zero,
        radius * (0.1 + 0.86 * travel),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.008
          ..blendMode = BlendMode.screen
          ..color = tint.withValues(
            alpha: motion * 0.16 * math.sin(travel * math.pi),
          ),
      );
    }
  }

  void _drawBlooms(Canvas canvas, double radius, Color tint) {
    const rings = [
      _BloomRing(0.06, 0.30, 0.40, 1, 0),
      _BloomRing(0.24, 0.52, 0.33, 0.75, 0.5),
      _BloomRing(0.44, 0.76, 0.38, 1, 0),
      _BloomRing(0.66, 0.98, 0.20, 0.32, 0),
    ];

    for (var index = 0; index < rings.length; index++) {
      final ring = rings[index];
      final morph =
          (0.34 +
                  motion *
                      ring.morphScale *
                      (0.5 -
                          0.5 * math.cos((phase + index * 0.17) * math.pi * 2)))
              .clamp(0.0, 1.0);
      final path = _bloom(
        inner: radius * ring.inner,
        outer: radius * ring.outer,
        spread: ring.spread,
        morph: morph,
      );
      final alpha = 0.62 + 0.06 * index;
      final fill = Paint()
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.screen
        ..color = tint.withValues(alpha: alpha);
      final edge = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.016
        ..strokeJoin = StrokeJoin.round
        ..blendMode = BlendMode.screen
        ..color = Color.lerp(
          tint,
          AppColors.splashHighlight,
          0.35,
        )!.withValues(alpha: 0.82);

      for (var fold = 0; fold < motif.folds; fold++) {
        canvas.save();
        canvas.rotate((fold + ring.turn) * math.pi * 2 / motif.folds);
        canvas.drawPath(path, fill);
        canvas.drawPath(path, edge);
        canvas.restore();
      }
    }
  }

  void _drawStar(Canvas canvas, double radius, Color tint) {
    final path = Path();
    const points = 8;
    for (var point = 0; point < points * 2; point++) {
      final theta = point / (points * 2) * math.pi * 2 - math.pi / 2;
      final distance = radius * (point.isEven ? 0.98 : 0.74);
      final offset = Offset(
        math.cos(theta) * distance,
        math.sin(theta) * distance,
      );
      if (point == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.screen
        ..color = tint.withValues(alpha: 0.22),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.012
        ..strokeJoin = StrokeJoin.round
        ..blendMode = BlendMode.screen
        ..color = tint.withValues(alpha: 0.7),
    );
  }

  void _drawSpokes(Canvas canvas, double radius, Color tint) {
    final paint = Paint()
      ..strokeWidth = radius * 0.008
      ..blendMode = BlendMode.screen
      ..color = tint.withValues(alpha: 0.4);
    for (var fold = 0; fold < motif.folds; fold++) {
      final theta = fold / motif.folds * math.pi * 2 - math.pi / 2;
      canvas.drawLine(
        Offset.zero,
        Offset(math.cos(theta) * radius * 0.9, math.sin(theta) * radius * 0.9),
        paint,
      );
    }
  }

  void _drawParticles(Canvas canvas, double radius, Color tint) {
    if (motion <= 0) return;
    const count = 24;
    for (var index = 0; index < count; index++) {
      final axis = index % motif.folds;
      final lane = index ~/ motif.folds;
      final seed = (index * 0.173) % 1;
      final travel = (seed + phase * (0.7 + lane * 0.18)) % 1;
      final theta = axis / motif.folds * math.pi * 2 - math.pi / 2;
      final fade = math.sin(travel * math.pi);
      for (var trail = 0; trail < 3; trail++) {
        final along = (travel - trail * 0.045).clamp(0.0, 1.0);
        final distance = radius * (0.08 + 0.88 * along);
        canvas.drawCircle(
          Offset(math.cos(theta) * distance, math.sin(theta) * distance),
          radius * (0.028 - trail * 0.007),
          Paint()
            ..blendMode = BlendMode.screen
            ..color = Color.lerp(
              tint,
              AppColors.splashHighlight,
              0.65,
            )!.withValues(alpha: motion * fade * (0.9 - trail * 0.22)),
        );
      }
    }
  }

  void _drawCore(Canvas canvas, double radius, Color tint) {
    final coreRadius = radius * 0.28;
    final rect = Rect.fromCircle(center: Offset.zero, radius: coreRadius);
    canvas.drawCircle(
      Offset.zero,
      coreRadius,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(
          colors: [
            AppColors.splashHighlight,
            tint.withValues(alpha: 0.95),
            tint.withValues(alpha: 0),
          ],
          stops: const [0, 0.28, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(CymaticSignaturePainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.motion != motion ||
      oldDelegate.colorProgress != colorProgress ||
      oldDelegate.fillBackground != fillBackground ||
      oldDelegate.motif != motif;
}

class _BloomRing {
  const _BloomRing(
    this.inner,
    this.outer,
    this.spread,
    this.morphScale,
    this.turn,
  );

  final double inner;
  final double outer;
  final double spread;
  final double morphScale;
  final double turn;
}

Path _bloom({
  required double inner,
  required double outer,
  required double spread,
  required double morph,
}) {
  const axis = -math.pi / 2;
  final waist = (inner + outer) / 2;
  final start = _polar(inner, axis);
  final tip = _polar(outer, axis);
  final left = _polar(waist, axis - spread);
  final right = _polar(waist, axis + spread);

  final path = Path()..moveTo(start.dx, start.dy);
  _curve(path, start, left, _polar(waist * 1.18, axis - spread * 1.2), morph);
  _curve(path, left, tip, _polar(outer * 0.94, axis - spread * 0.65), morph);
  _curve(path, tip, right, _polar(outer * 0.94, axis + spread * 0.65), morph);
  _curve(path, right, start, _polar(waist * 1.18, axis + spread * 1.2), morph);
  path.close();
  return path;
}

void _curve(Path path, Offset from, Offset to, Offset outward, double morph) {
  final straight = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
  final control = Offset(
    straight.dx + (outward.dx - straight.dx) * morph,
    straight.dy + (outward.dy - straight.dy) * morph,
  );
  path.quadraticBezierTo(control.dx, control.dy, to.dx, to.dy);
}

Offset _polar(double radius, double angle) =>
    Offset(math.cos(angle) * radius, math.sin(angle) * radius);

Color _cymaticTint(double progress) {
  final t = progress.clamp(0.0, 1.0);
  final scaled = t * (_cymaticStops.length - 1);
  final index = scaled.floor().clamp(0, _cymaticStops.length - 2);
  final local = scaled - index;
  return Color.lerp(_cymaticStops[index], _cymaticStops[index + 1], local) ??
      _cymaticStops[index];
}

/// Rises from 1 to 1.15, then springs back to 1.
double _pulseScale(double phase, double motion) {
  if (motion <= 0) return 1;
  const rise = 0.34;
  if (phase < rise) {
    final t = Curves.easeOut.transform(phase / rise);
    return 1 + 0.15 * motion * t;
  }
  final t = ((phase - rise) / (1 - rise)).clamp(0.0, 1.0);
  final decay = math.exp(-5.5 * t);
  final wobble = math.sin(t * math.pi * 2.5) * math.exp(-3.2 * t);
  return 1 + 0.15 * motion * (decay + 0.22 * wobble);
}
