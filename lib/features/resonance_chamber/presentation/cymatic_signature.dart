import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../crystals/domain/crystal.dart';

/// Petal and ring counts that keep the four crystals visually distinct.
class CymaticMotif {
  const CymaticMotif({required this.petals, required this.rings});

  final int petals;
  final int rings;

  static CymaticMotif of(Crystal crystal) => switch (crystal) {
    Crystal.whiteQuartz => const CymaticMotif(petals: 8, rings: 5),
    Crystal.jade => const CymaticMotif(petals: 6, rings: 4),
    Crystal.obsidian => const CymaticMotif(petals: 12, rings: 6),
    Crystal.redJasper => const CymaticMotif(petals: 5, rings: 3),
  };

  @override
  bool operator ==(Object other) =>
      other is CymaticMotif && other.petals == petals && other.rings == rings;

  @override
  int get hashCode => Object.hash(petals, rings);
}

/// Hertz named in [Crystal.frequency], or 528 when the copy has no number.
double cymaticHertz(Crystal crystal) {
  final match = RegExp(r'(\d+(?:\.\d+)?)\s*Hz').firstMatch(crystal.frequency);
  return double.tryParse(match?.group(1) ?? '') ?? _referenceHertz;
}

/// One gentle turn of the pattern. Higher frequencies cycle a little faster.
Duration cymaticCycle(Crystal crystal) {
  final seconds =
      (_referenceCycleSeconds * (_referenceHertz / cymaticHertz(crystal)))
          .clamp(_minCycleSeconds, _maxCycleSeconds);
  return Duration(milliseconds: (seconds * 1000).round());
}

const double _referenceHertz = 528;
const double _referenceCycleSeconds = 4.2;
const double _minCycleSeconds = 2.8;
const double _maxCycleSeconds = 6;

const Duration cymaticSettleDuration = Duration(milliseconds: 800);
const double _sealFactor = 0.28;

/// Gold-on-indigo cymatic. Motion follows [playing] and rests when it is false.
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
  bool _reduceMotion = false;
  bool _synced = false;

  double get phase => _phase.value;

  /// 0 at rest, 1 while the rhythm is fully present.
  double get motion => _reduceMotion ? 0 : _energy.value;

  bool get isAnimating => _phase.isAnimating || _energy.isAnimating;

  @override
  void initState() {
    super.initState();
    _phase = AnimationController(
      vsync: this,
      duration: cymaticCycle(widget.crystal),
    );
    _energy = AnimationController(vsync: this, duration: cymaticSettleDuration);
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
    }
    if (oldWidget.playing != widget.playing ||
        oldWidget.crystal != widget.crystal) {
      _sync();
    }
  }

  void _sync() {
    final shouldMove = widget.playing && !_reduceMotion;
    if (shouldMove) {
      if (!_phase.isAnimating) {
        _phase.repeat();
      }
      _energy.animateTo(1, curve: Curves.easeInOut);
      return;
    }
    _phase.stop();
    if (_reduceMotion) {
      _energy.value = 0;
      _phase.value = 0;
      return;
    }
    _energy.animateTo(0, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _phase.dispose();
    _energy.dispose();
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
        animation: Listenable.merge([_phase, _energy]),
        builder: (context, child) => CustomPaint(
          painter: CymaticSignaturePainter(
            motif: CymaticMotif.of(widget.crystal),
            phase: _phase.value,
            motion: motion,
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
    required this.fillBackground,
  });

  final CymaticMotif motif;
  final double phase;
  final double motion;
  final bool fillBackground;

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = size.shortestSide;
    if (shortest <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = shortest / 2;
    final gold = AppColors.champagneGold;

    if (fillBackground) {
      canvas.drawCircle(center, radius, Paint()..color = AppColors.indigoBlue);
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(phase * math.pi * 2);

    final breath = 1 + 0.045 * motion * math.sin(phase * math.pi * 2);
    canvas.scale(breath);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = shortest * 0.004;
    for (var ring = 1; ring <= motif.rings; ring++) {
      final t = ring / motif.rings;
      final pulse = 1 + 0.028 * motion * math.sin(phase * math.pi * 2 + ring);
      ringPaint.color = gold.withValues(alpha: 0.28 + 0.5 * t);
      canvas.drawCircle(
        Offset.zero,
        radius * (0.18 + 0.72 * t) * pulse,
        ringPaint,
      );
    }

    canvas.drawPath(_rose(radius), _stroke(shortest * 0.007, 0.92));

    final spoke = _stroke(shortest * 0.003, 0.45);
    for (var petal = 0; petal < motif.petals; petal++) {
      final theta = petal / motif.petals * math.pi * 2;
      canvas.drawLine(
        Offset.zero,
        Offset(
          math.cos(theta) * radius * 0.84,
          math.sin(theta) * radius * 0.84,
        ),
        spoke,
      );
    }

    final dots = math.max(motif.petals * 3, 12);
    final dotPaint = Paint()..color = gold.withValues(alpha: 0.9);
    for (var dot = 0; dot < dots; dot++) {
      final theta = dot / dots * math.pi * 2;
      canvas.drawCircle(
        Offset(math.cos(theta) * radius * 0.9, math.sin(theta) * radius * 0.9),
        shortest * 0.012,
        dotPaint,
      );
    }

    canvas.drawCircle(Offset.zero, radius * 0.045, Paint()..color = gold);
    canvas.restore();

    if (motion <= 0) return;
    canvas.drawCircle(
      center,
      radius * (0.12 + 0.82 * phase),
      _stroke(shortest * 0.006, (1 - phase) * 0.65 * motion),
    );
  }

  Path _rose(double radius) {
    final path = Path();
    final k = motif.petals / 2;
    const samples = 480;
    for (var sample = 0; sample <= samples; sample++) {
      final theta = sample / samples * math.pi * 2;
      final distance = radius * 0.62 * math.cos(k * theta).abs();
      final point = Offset(
        math.cos(theta) * distance,
        math.sin(theta) * distance,
      );
      if (sample == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  Paint _stroke(double width, double alpha) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..color = AppColors.champagneGold.withValues(alpha: alpha);

  @override
  bool shouldRepaint(CymaticSignaturePainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.motion != motion ||
      oldDelegate.fillBackground != fillBackground ||
      oldDelegate.motif != motif;
}
