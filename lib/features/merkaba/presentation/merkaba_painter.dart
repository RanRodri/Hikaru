import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../domain/merkaba_session.dart';

/// Painted Merkaba field. A pre-rendered video can replace this widget later
/// by passing [MerkabaStage.replacement].
class MerkabaStage extends StatelessWidget {
  const MerkabaStage({super.key, required this.frame, this.replacement});

  final MerkabaFrame frame;
  final Widget? replacement;

  @override
  Widget build(BuildContext context) {
    final video = replacement;
    if (video != null) return video;
    return CustomPaint(
      painter: MerkabaFieldPainter(frame: frame),
      child: const SizedBox.expand(),
    );
  }
}

class MerkabaFieldPainter extends CustomPainter {
  const MerkabaFieldPainter({required this.frame});

  final MerkabaFrame frame;

  static const List<Offset> _seeds = [
    Offset(0.12, 0.18),
    Offset(0.22, 0.72),
    Offset(0.31, 0.28),
    Offset(0.38, 0.84),
    Offset(0.46, 0.16),
    Offset(0.52, 0.62),
    Offset(0.58, 0.34),
    Offset(0.66, 0.78),
    Offset(0.74, 0.22),
    Offset(0.82, 0.58),
    Offset(0.18, 0.46),
    Offset(0.88, 0.4),
    Offset(0.08, 0.62),
    Offset(0.42, 0.48),
    Offset(0.62, 0.12),
    Offset(0.28, 0.9),
    Offset(0.7, 0.9),
    Offset(0.9, 0.18),
    Offset(0.5, 0.5),
    Offset(0.36, 0.38),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final breath = _breathScale(frame);
    final sceneIndex = merkabaScenes.indexOf(frame.scene);
    final fade = _sceneFade(frame);

    _paintGlow(canvas, center, size, breath, sceneIndex);
    _paintParticles(canvas, size, center, breath, sceneIndex);
    _paintGeometry(canvas, center, size.shortestSide, sceneIndex, breath, fade);
  }

  void _paintGlow(
    Canvas canvas,
    Offset center,
    Size size,
    double breath,
    int sceneIndex,
  ) {
    final radius = size.shortestSide * (0.18 + breath * 0.08);
    final emerald = sceneIndex == 5;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          (emerald ? const Color(0xFF7DCEA0) : AppColors.fog).withValues(
            alpha: 0.55,
          ),
          AppColors.champagneGold.withValues(alpha: 0.18),
          AppColors.indigoBlue.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  void _paintParticles(
    Canvas canvas,
    Size size,
    Offset center,
    double breath,
    int sceneIndex,
  ) {
    final paint = Paint()..color = AppColors.champagneGold;
    for (var index = 0; index < _seeds.length; index++) {
      final seed = _seeds[index];
      final base = Offset(seed.dx * size.width, seed.dy * size.height);
      final toward = center - base;
      final gather = sceneIndex == 2 ? -0.08 : 0.12;
      final point = base + toward * gather * breath;
      paint.color = AppColors.champagneGold.withValues(
        alpha: 0.35 + (index % 5) * 0.08,
      );
      canvas.drawCircle(point, 1.2 + (index % 3) * 0.6, paint);
    }
  }

  void _paintGeometry(
    Canvas canvas,
    Offset center,
    double side,
    int sceneIndex,
    double breath,
    double fade,
  ) {
    if (sceneIndex == 0 || fade == 0) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.champagneGold.withValues(alpha: 0.85 * fade);

    final radius = side * (0.28 + breath * 0.04);
    switch (sceneIndex) {
      case 1:
        _drawStar(canvas, center, radius, paint);
      case 2:
        _drawSpiral(canvas, center, radius, paint);
      case 3:
      case 4:
        paint.color = AppColors.champagneGold.withValues(
          alpha: (sceneIndex == 4 ? 0.45 : 0.85) * fade,
        );
        _drawMerkaba(
          canvas,
          center,
          radius * (sceneIndex == 4 ? 1.15 : 1),
          paint,
        );
      case 5:
        _drawFlower(canvas, center, radius, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var point = 0; point < 5; point++) {
      final angle = -math.pi / 2 + point * 4 * math.pi / 5;
      final offset = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (point == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSpiral(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const turns = 18;
    for (var step = 0; step <= turns; step++) {
      final t = step / turns;
      final angle = t * math.pi * 3;
      final distance = radius * (0.2 + t * 0.8);
      final offset =
          center + Offset(math.cos(angle), math.sin(angle)) * distance;
      if (step == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawMerkaba(Canvas canvas, Offset center, double radius, Paint paint) {
    canvas.drawPath(_triangle(center, radius, 0), paint);
    canvas.drawPath(_triangle(center, radius, math.pi), paint);
  }

  Path _triangle(Offset center, double radius, double rotation) {
    final path = Path();
    for (var point = 0; point < 3; point++) {
      final angle = rotation - math.pi / 2 + point * 2 * math.pi / 3;
      final offset = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (point == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    path.close();
    return path;
  }

  void _drawFlower(Canvas canvas, Offset center, double radius, Paint paint) {
    for (var petal = 0; petal < 8; petal++) {
      final angle = petal * math.pi / 4;
      final petalCenter =
          center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.45;
      canvas.drawCircle(petalCenter, radius * 0.28, paint);
    }
    canvas.drawCircle(
      center,
      radius * 0.12,
      Paint()..color = const Color(0xFF7DCEA0).withValues(alpha: 0.9),
    );
  }

  double _breathScale(MerkabaFrame frame) {
    final progress = frame.phaseProgress;
    return switch (frame.phase) {
      BreathPhase.inhale => progress,
      BreathPhase.hold => 1,
      BreathPhase.exhale => 1 - progress,
    };
  }

  double _sceneFade(MerkabaFrame frame) {
    final into = frame.elapsed - frame.scene.start;
    return (into.inMilliseconds / 2000).clamp(0.0, 1.0);
  }

  @override
  bool shouldRepaint(covariant MerkabaFieldPainter oldDelegate) =>
      oldDelegate.frame.elapsed != frame.elapsed ||
      oldDelegate.frame.scene != frame.scene ||
      oldDelegate.frame.phase != frame.phase;
}
