import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../crystals/domain/crystal.dart';
import '../domain/cymatic_audio.dart';

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

double cymaticHertz(Crystal crystal) => crystal.hertz.toDouble();

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
    this.envelope,
    this.playbackPosition,
  });

  final Crystal crystal;
  final bool playing;
  final bool showSeal;
  final bool fillBackground;
  final String? semanticLabel;

  /// Precomputed loudness of the crystal track. Null keeps the simulated pulse.
  final CymaticEnvelope? envelope;

  /// Player position the envelope is sampled against. Ignored without [envelope].
  final ValueListenable<Duration>? playbackPosition;

  @override
  State<CymaticSignature> createState() => CymaticSignatureState();
}

class CymaticSignatureState extends State<CymaticSignature>
    with TickerProviderStateMixin {
  late final AnimationController _phase;
  late final AnimationController _energy;
  late final AnimationController _color;
  final CymaticVisual _visual = CymaticVisual();
  final CymaticFollower _follower = CymaticFollower();
  final Stopwatch _clock = Stopwatch();
  bool _reduceMotion = false;
  bool _synced = false;
  bool _reactive = false;
  Ticker? _ticker;
  Duration? _lastTick;
  Duration _anchor = Duration.zero;
  Duration _anchorClock = Duration.zero;
  int _sparkCursor = 0;
  int _emitSerial = 0;

  double get phase => _phase.value;

  /// 0 at rest, 1 while the rhythm is fully present.
  double get motion => _reduceMotion ? 0 : _energy.value;

  /// 0 is fire. 1 is the indigo the journey ends on.
  double get colorProgress => _color.value;

  bool get isAnimating =>
      _phase.isAnimating ||
      _energy.isAnimating ||
      _color.isAnimating ||
      (_ticker?.isActive ?? false);

  bool get _usesEnvelope =>
      widget.envelope != null && widget.envelope!.frames > 0;

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
    _clock.start();
    _publish();
    for (final controller in [_phase, _energy, _color]) {
      controller.addListener(_publish);
    }
    widget.playbackPosition?.addListener(_onPosition);
    _onPosition();
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
    if (oldWidget.playbackPosition != widget.playbackPosition) {
      oldWidget.playbackPosition?.removeListener(_onPosition);
      widget.playbackPosition?.addListener(_onPosition);
      _onPosition();
    }
    if (oldWidget.playing != widget.playing ||
        oldWidget.crystal != widget.crystal ||
        oldWidget.envelope != widget.envelope) {
      _sync();
    }
  }

  void _onPosition() {
    _anchor = widget.playbackPosition?.value ?? Duration.zero;
    _anchorClock = _clock.elapsed;
  }

  Duration _estimatedPosition() {
    final extra = widget.playing
        ? _clock.elapsed - _anchorClock
        : Duration.zero;
    final position = _anchor + extra;
    if (position.isNegative) return Duration.zero;
    return position;
  }

  void _publish() {
    _visual.phase = _phase.value;
    _visual.motion = motion;
    _visual.colorProgress = _color.value;
    _visual.reactive = _reactive;
    if (_reactive &&
        !widget.playing &&
        !_reduceMotion &&
        _energy.value <= 0.001 &&
        !_energy.isAnimating) {
      _settleEnvelope();
    }
  }

  void _settleEnvelope() {
    _clearSparks();
    _follower.reset();
    _reactive = false;
    _visual.audioScale = null;
    _visual.audioMorph = null;
    _visual.glow = null;
    _visual.reactive = false;
    _stopTicker();
  }

  void _sync() {
    if (_reduceMotion) {
      _stopTicker();
      _follower.reset();
      _clearSparks();
      _reactive = false;
      _visual.audioScale = null;
      _visual.audioMorph = null;
      _visual.glow = null;
      _phase
        ..stop()
        ..value = 0;
      _energy.value = 0;
      _color
        ..stop()
        ..value = 1;
      _publish();
      return;
    }

    if (widget.playing) {
      _energy.animateTo(1, curve: Curves.easeInOut);
      if (_color.value >= 1) {
        _color.forward(from: 0);
      } else if (!_color.isAnimating) {
        _color.forward();
      }
      if (_usesEnvelope) {
        _reactive = true;
        if (_phase.isAnimating) _phase.stop();
        _ensureTicker();
      } else {
        _reactive = false;
        _visual.audioScale = null;
        _visual.audioMorph = null;
        _visual.glow = null;
        _stopTicker();
        if (!_phase.isAnimating) _phase.repeat();
      }
      _publish();
      return;
    }

    _phase.stop();
    _color.stop();
    _energy.animateTo(0, curve: Curves.easeInOut);
    if (!_usesEnvelope) {
      _reactive = false;
      _visual.audioScale = null;
      _visual.audioMorph = null;
      _visual.glow = null;
      _stopTicker();
    } else {
      _ensureTicker();
    }
    _publish();
  }

  void _ensureTicker() {
    _ticker ??= createTicker(_onTick);
    if (!_ticker!.isActive) {
      _lastTick = null;
      _ticker!.start();
    }
  }

  void _stopTicker() {
    _lastTick = null;
    if (_ticker?.isActive ?? false) _ticker!.stop();
  }

  void _onTick(Duration elapsed) {
    final dt = _lastTick == null
        ? 1 / 60
        : (elapsed - _lastTick!).inMicroseconds / 1000000;
    _lastTick = elapsed;
    if (!widget.playing && _energy.value <= 0.001 && !_energy.isAnimating) {
      _settleEnvelope();
      return;
    }

    final envelope = widget.envelope;
    if (envelope == null) {
      _stopTicker();
      return;
    }

    final CymaticDrive drive;
    if (widget.playing) {
      final window = envelope.sampleAt(_estimatedPosition());
      drive = _follower.step(
        rms: window.rms,
        low: window.low,
        mid: window.mid,
        high: window.high,
        dt: dt,
      );
    } else {
      drive = _follower.release(dt);
    }
    _visual.audioScale = drive.scale;
    _visual.audioMorph = drive.morph;
    _visual.glow = drive.glow;
    _advanceSparks(dt.clamp(0.0, 0.05));
    if (drive.spawn && widget.playing) _emitSparks();
    final ripple = dt.clamp(0.0, 0.05) * (0.12 + drive.amplitude);
    _phase.value = (_phase.value + ripple) % 1;
  }

  void _emitSparks() {
    const rays = 8;
    for (var ray = 0; ray < rays; ray++) {
      final spark = _visual.sparks[_sparkCursor];
      _sparkCursor = (_sparkCursor + 1) % _visual.sparks.length;
      final serial = _emitSerial++;
      spark.angle =
          ray / rays * math.pi * 2 -
          math.pi / 2 +
          (serial.isEven ? 0.05 : -0.05);
      spark.travel = 0.02 + (ray % 3) * 0.02;
      spark.life = 1;
      spark.speed = 0.85 + (serial % 4) * 0.12;
    }
    _visual.sparkRevision++;
  }

  void _advanceSparks(double dt) {
    for (final spark in _visual.sparks) {
      if (spark.life <= 0) continue;
      spark.travel += spark.speed * dt * 1.35;
      spark.life -= dt * 1.8;
      if (spark.travel > 1.2 || spark.life <= 0) spark.life = 0;
    }
  }

  void _clearSparks() {
    for (final spark in _visual.sparks) {
      spark.life = 0;
    }
  }

  @override
  void dispose() {
    widget.playbackPosition?.removeListener(_onPosition);
    _ticker?.dispose();
    _phase.dispose();
    _energy.dispose();
    _color.dispose();
    _clock.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final seal = widget.showSeal
        ? AnimatedAlign(
            alignment: widget.playing
                ? const Alignment(0, 0.86)
                : Alignment.center,
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
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
      child: CustomPaint(
        painter: CymaticSignaturePainter(
          repaint: Listenable.merge([_phase, _energy, _color]),
          visual: _visual,
          motif: CymaticMotif.of(widget.crystal),
          fillBackground: widget.fillBackground,
        ),
        child: seal,
      ),
    );
  }
}

class CymaticVisual {
  double phase = 0;
  double motion = 0;
  double colorProgress = 1;
  double? audioScale;
  double? audioMorph;
  double? glow;
  bool reactive = false;
  int sparkRevision = 0;
  final List<CymaticSpark> sparks = List<CymaticSpark>.generate(
    48,
    (_) => CymaticSpark(),
  );
}

class CymaticSpark {
  double angle = 0;
  double travel = 0;
  double life = 0;
  double speed = 1;
}

class CymaticSignaturePainter extends CustomPainter {
  CymaticSignaturePainter({
    required Listenable repaint,
    required this.visual,
    required this.motif,
    required this.fillBackground,
  }) : super(repaint: repaint);

  final CymaticVisual visual;
  final CymaticMotif motif;
  final bool fillBackground;

  double get phase => visual.phase;

  double get motion => visual.motion;

  double get colorProgress => visual.colorProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = size.shortestSide;
    if (shortest <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = shortest / 2;
    final tint = _cymaticTint(colorProgress);
    final pulse = visual.audioScale == null
        ? _pulseScale(phase, motion)
        : 1 + (visual.audioScale! - 1) * motion;

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
    final glow = _glowScale;
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(
          colors: [
            tint.withValues(alpha: 0),
            tint.withValues(alpha: 0.08 * glow),
            tint.withValues(alpha: 0.20 * glow),
            tint.withValues(alpha: 0),
          ],
          stops: const [0, 0.62, 0.86, 1],
        ).createShader(rect),
    );
    canvas.drawCircle(
      Offset.zero,
      radius * 0.97,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.045
        ..blendMode = BlendMode.screen
        ..color = tint.withValues(alpha: 0.18 * glow),
    );
  }

  double get _glowScale {
    final glow = visual.glow;
    if (glow == null || motion <= 0) return 1;
    return 1 + ((0.55 + 0.9 * glow.clamp(0.0, 1.0)) - 1) * motion;
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
      _BloomRing(0.10, 0.34, 0.16, 1, 0),
      _BloomRing(0.26, 0.54, 0.13, 0.75, 0.5),
      _BloomRing(0.46, 0.76, 0.12, 1, 0),
      _BloomRing(0.64, 0.96, 0.10, 0.32, 0),
    ];

    final glow = _glowScale;
    for (var index = 0; index < rings.length; index++) {
      final ring = rings[index];
      final morph = _ringMorph(index, ring);
      final path = _bloom(
        inner: radius * ring.inner,
        outer: radius * ring.outer,
        spread: ring.spread,
        morph: morph,
      );
      final fill = Paint()
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.screen
        ..color = tint.withValues(alpha: 0.10 + 0.025 * index);
      final lift = Paint()
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.plus
        ..color = tint.withValues(alpha: 0.045);
      final bloom = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.032
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.screen
        ..color = tint.withValues(alpha: 0.16 * glow);
      final edge = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.007
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.plus
        ..color = Color.lerp(
          tint,
          AppColors.splashHighlight,
          0.55,
        )!.withValues(alpha: 0.55);

      for (var fold = 0; fold < motif.folds; fold++) {
        canvas.save();
        canvas.rotate((fold + ring.turn) * math.pi * 2 / motif.folds);
        canvas.drawPath(path, bloom);
        canvas.drawPath(path, fill);
        canvas.drawPath(path, lift);
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
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.028
        ..strokeJoin = StrokeJoin.round
        ..blendMode = BlendMode.screen
        ..color = tint.withValues(alpha: 0.14),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.006
        ..strokeJoin = StrokeJoin.round
        ..blendMode = BlendMode.plus
        ..color = tint.withValues(alpha: 0.62),
    );
  }

  void _drawSpokes(Canvas canvas, double radius, Color tint) {
    final paint = Paint()
      ..strokeWidth = radius * 0.004
      ..blendMode = BlendMode.screen
      ..color = tint.withValues(alpha: 0.28);
    for (var fold = 0; fold < motif.folds; fold++) {
      final theta = fold / motif.folds * math.pi * 2 - math.pi / 2;
      canvas.drawLine(
        Offset.zero,
        Offset(math.cos(theta) * radius * 0.9, math.sin(theta) * radius * 0.9),
        paint,
      );
    }
  }

  double _ringMorph(int index, _BloomRing ring) {
    if (motion <= 0 || visual.audioMorph == null) {
      return (0.34 +
              motion *
                  ring.morphScale *
                  (0.5 - 0.5 * math.cos((phase + index * 0.17) * math.pi * 2)))
          .clamp(0.0, 1.0);
    }
    return (0.18 + 0.78 * visual.audioMorph!.clamp(0.0, 1.0) * ring.morphScale)
        .clamp(0.0, 1.0);
  }

  void _drawParticles(Canvas canvas, double radius, Color tint) {
    const count = 24;
    final still = motion <= 0 || visual.reactive;
    final presence = still ? 0.7 : motion;
    for (var index = 0; index < count; index++) {
      final axis = index % motif.folds;
      final lane = index ~/ motif.folds;
      final seed = (index * 0.173) % 1;
      final travel = still
          ? (0.22 + seed * 0.7)
          : (seed + phase * (0.7 + lane * 0.18)) % 1;
      final theta =
          axis / motif.folds * math.pi * 2 - math.pi / 2 + lane * 0.08;
      final fade = still ? 0.9 : math.sin(travel * math.pi);
      final trails = still ? 1 : 3;
      for (var trail = 0; trail < trails; trail++) {
        final along = (travel - trail * 0.045).clamp(0.0, 1.0);
        final distance = radius * (0.12 + 0.82 * along);
        canvas.drawCircle(
          Offset(math.cos(theta) * distance, math.sin(theta) * distance),
          radius * (0.018 - trail * 0.004),
          Paint()
            ..blendMode = BlendMode.plus
            ..color = Color.lerp(
              tint,
              AppColors.splashHighlight,
              0.65,
            )!.withValues(alpha: presence * fade * (0.85 - trail * 0.2)),
        );
      }
    }
    if (visual.reactive && motion > 0) _drawSparks(canvas, radius, tint);
  }

  void _drawSparks(Canvas canvas, double radius, Color tint) {
    for (final spark in visual.sparks) {
      if (spark.life <= 0) continue;
      final fade = spark.life.clamp(0.0, 1.0) * motion;
      if (fade <= 0) continue;
      for (var trail = 0; trail < 3; trail++) {
        final along = (spark.travel - trail * 0.04).clamp(0.0, 1.0);
        final distance = radius * (0.04 + 0.92 * along);
        canvas.drawCircle(
          Offset(
            math.cos(spark.angle) * distance,
            math.sin(spark.angle) * distance,
          ),
          radius * (0.022 - trail * 0.005),
          Paint()
            ..blendMode = BlendMode.plus
            ..color = Color.lerp(
              tint,
              AppColors.splashHighlight,
              0.7,
            )!.withValues(alpha: fade * (0.95 - trail * 0.28)),
        );
      }
    }
  }

  void _drawCore(Canvas canvas, double radius, Color tint) {
    final coreRadius = radius * 0.09;
    final rect = Rect.fromCircle(center: Offset.zero, radius: coreRadius);
    canvas.drawCircle(
      Offset.zero,
      coreRadius,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(
          colors: [
            AppColors.splashHighlight,
            tint.withValues(alpha: 0.9),
            tint.withValues(alpha: 0),
          ],
          stops: const [0, 0.28, 1],
        ).createShader(rect),
    );
    canvas.drawCircle(
      Offset.zero,
      radius * 0.022,
      Paint()
        ..blendMode = BlendMode.plus
        ..color = AppColors.splashHighlight.withValues(alpha: 0.95),
    );
  }

  @override
  bool shouldRepaint(CymaticSignaturePainter oldDelegate) =>
      oldDelegate.visual != visual ||
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
