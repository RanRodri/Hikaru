import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../domain/merkaba_session.dart';

/// The seated woman, with the studio gray removed, on the indigo field.
const String merkabaWomanAsset = 'assets/images/merkaba_woman.png';

/// Width / height of [merkabaWomanAsset].
const double merkabaWomanAspect = 1186 / 1280;

/// Painted Merkaba field over the seated woman. A pre-rendered video can
/// replace this widget later by passing [MerkabaStage.replacement].
class MerkabaStage extends StatelessWidget {
  const MerkabaStage({super.key, required this.frame, this.replacement});

  final MerkabaFrame frame;
  final Widget? replacement;

  @override
  Widget build(BuildContext context) {
    final video = replacement;
    if (video != null) return video;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        const Image(
          image: AssetImage(merkabaWomanAsset),
          fit: BoxFit.contain,
          semanticLabel: 'Seated woman in meditation',
        ),
        CustomPaint(
          painter: MerkabaFieldPainter(
            frame: frame,
            reduceMotion: reduceMotion,
          ),
          child: const SizedBox.expand(),
        ),
      ],
    );
  }
}

class MerkabaFieldPainter extends CustomPainter {
  const MerkabaFieldPainter({required this.frame, required this.reduceMotion});

  final MerkabaFrame frame;
  final bool reduceMotion;

  @override
  void paint(Canvas canvas, Size size) {
    final woman = _womanRect(size);
    if (woman.width <= 0 || woman.height <= 0) return;

    final heart = Offset(
      woman.left + woman.width * 0.5,
      woman.top + woman.height * 0.4,
    );
    final body = Offset(
      woman.left + woman.width * 0.5,
      woman.top + woman.height * 0.5,
    );
    final sceneIndex = merkabaScenes.indexOf(frame.scene);
    final breath = reduceMotion ? 0.62 : _breath(frame);
    final sceneT = _sceneProgress(frame);

    _paintHeart(canvas, heart, woman.height, breath, sceneIndex, sceneT);
    _paintStar(canvas, body, woman, sceneIndex, sceneT, breath);
    _paintRibbons(canvas, body, woman, sceneIndex, sceneT, breath);
    _paintMerkaba(canvas, heart, woman, sceneIndex, sceneT, breath);
    _paintMandala(canvas, heart, woman, sceneIndex, sceneT);
  }

  void _paintHeart(
    Canvas canvas,
    Offset heart,
    double height,
    double breath,
    int sceneIndex,
    double sceneT,
  ) {
    final calm = sceneIndex == 5 ? sceneT : 0.0;
    final pulse = breath + (0.55 - breath) * calm;
    final radius = height * (0.07 + 0.035 * pulse);
    final rect = Rect.fromCircle(center: heart, radius: radius);
    final alpha = 0.28 + 0.42 * pulse;
    canvas.drawCircle(
      heart,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.splashHighlight.withValues(alpha: alpha),
            AppColors.champagneGold.withValues(alpha: alpha * 0.45),
            AppColors.champagneGold.withValues(alpha: 0),
          ],
          stops: const [0, 0.42, 1],
        ).createShader(rect),
    );
    if (sceneIndex == 4) {
      final field = height * (0.34 + 0.06 * pulse);
      final fieldRect = Rect.fromCircle(center: heart, radius: field);
      canvas.drawCircle(
        heart,
        field,
        Paint()
          ..shader = RadialGradient(
            colors: [
              AppColors.champagneGold.withValues(alpha: 0.05 + 0.1 * pulse),
              AppColors.champagneGold.withValues(alpha: 0),
            ],
          ).createShader(fieldRect),
      );
    }
  }

  void _paintStar(
    Canvas canvas,
    Offset body,
    Rect woman,
    int sceneIndex,
    double sceneT,
    double breath,
  ) {
    final draw = sceneIndex == 1
        ? (reduceMotion ? 1.0 : (sceneT / 0.72).clamp(0.0, 1.0))
        : (sceneIndex == 2 ? 1.0 : 0.0);
    if (draw <= 0) return;
    final fade = sceneIndex == 2 ? (1 - sceneT / 0.28).clamp(0.0, 1.0) : 1.0;
    if (fade <= 0) return;
    final pulse = draw >= 1 && !reduceMotion ? 1 + breath * 0.035 : 1.0;
    final radius = woman.height * 0.4 * pulse;
    final path = _starPath(body, radius);
    _stroke(canvas, path, 0.82 * fade, draw);
  }

  void _paintRibbons(
    Canvas canvas,
    Offset body,
    Rect woman,
    int sceneIndex,
    double sceneT,
    double breath,
  ) {
    var opacity = 0.0;
    if (sceneIndex == 2) {
      final enter = (sceneT / 0.18).clamp(0.0, 1.0);
      final leave = sceneT < 0.82 ? 1.0 : (1 - (sceneT - 0.82) / 0.18);
      opacity = enter * leave.clamp(0.0, 1.0);
    } else if (sceneIndex == 3) {
      opacity = (1 - sceneT / 0.16).clamp(0.0, 1.0);
    }
    if (opacity <= 0) return;
    final turn = reduceMotion
        ? 0.0
        : frame.elapsed.inMilliseconds / 1000 * 0.22;
    final reach = 0.78 + breath * 0.22;
    for (var ribbon = 0; ribbon < 3; ribbon++) {
      final path = _ribbon(
        body,
        woman.width * 0.34 * reach,
        woman.height * (0.22 + ribbon * 0.04) * reach,
        turn + ribbon * 2.05,
      );
      _stroke(canvas, path, 0.42 * opacity, 1);
    }
  }

  void _paintMerkaba(
    Canvas canvas,
    Offset heart,
    Rect woman,
    int sceneIndex,
    double sceneT,
    double breath,
  ) {
    if (sceneIndex < 3) return;
    final built = sceneIndex == 3 ? (reduceMotion ? 6.0 : sceneT * 6) : 6.0;
    if (built <= 0) return;
    final fade = sceneIndex == 5 ? (1 - sceneT).clamp(0.0, 1.0) : 1.0;
    if (fade <= 0) return;
    final scale = sceneIndex == 4 ? 1 + breath * 0.12 : 1 + breath * 0.025;
    final radius = woman.shortestSide * 0.46 * scale;
    final spin = _spin(frame);
    _drawTetra(
      canvas: canvas,
      center: heart,
      radius: radius,
      rotation: spin,
      pointUp: false,
      edges: _edges(built, 0),
      alpha: 0.9 * fade,
    );
    _drawTetra(
      canvas: canvas,
      center: heart,
      radius: radius,
      rotation: -spin,
      pointUp: true,
      edges: _edges(built, 3),
      alpha: 0.9 * fade,
    );
  }

  void _paintMandala(
    Canvas canvas,
    Offset heart,
    Rect woman,
    int sceneIndex,
    double sceneT,
  ) {
    if (sceneIndex != 5) return;
    final appear = reduceMotion ? 1.0 : sceneT.clamp(0.0, 1.0);
    if (appear <= 0) return;
    final radius = woman.height * 0.16 * (0.65 + 0.35 * appear);
    final paint = _line(0.7 * appear);
    for (var petal = 0; petal < 8; petal++) {
      final angle = petal * math.pi / 4 - math.pi / 2;
      final center =
          heart +
          Offset(math.cos(angle), math.sin(angle)) * radius * 0.62 * appear;
      canvas.drawCircle(center, radius * 0.38, paint);
    }
    canvas.drawCircle(
      heart,
      radius * 0.16,
      Paint()..color = AppColors.emerald.withValues(alpha: 0.85 * appear),
    );
  }

  void _drawTetra({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double rotation,
    required bool pointUp,
    required List<double> edges,
    required double alpha,
  }) {
    final base = pointUp ? -math.pi / 2 : math.pi / 2;
    final points = [
      for (var point = 0; point < 3; point++)
        center +
            Offset(
                  math.cos(base + rotation + point * 2 * math.pi / 3),
                  math.sin(base + rotation + point * 2 * math.pi / 3),
                ) *
                radius,
    ];
    for (var edge = 0; edge < 3; edge++) {
      final progress = edges[edge];
      if (progress <= 0) continue;
      final path = Path()
        ..moveTo(points[edge].dx, points[edge].dy)
        ..lineTo(points[(edge + 1) % 3].dx, points[(edge + 1) % 3].dy);
      _stroke(canvas, path, alpha, progress);
    }
  }

  List<double> _edges(double built, int first) {
    return [
      for (var index = 0; index < 3; index++)
        (built - (first + index)).clamp(0.0, 1.0),
    ];
  }

  void _stroke(Canvas canvas, Path path, double alpha, double progress) {
    final t = progress.clamp(0.0, 1.0);
    if (t <= 0 || alpha <= 0) return;
    final halo = _line(alpha * 0.35, width: 6);
    final core = _line(alpha, width: 2);
    if (t >= 1) {
      canvas.drawPath(path, halo);
      canvas.drawPath(path, core);
      return;
    }
    for (final metric in path.computeMetrics()) {
      final partial = metric.extractPath(0, metric.length * t);
      canvas.drawPath(partial, halo);
      canvas.drawPath(partial, core);
    }
  }

  Paint _line(double alpha, {double width = 2}) {
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.champagneGold.withValues(
        alpha: alpha.clamp(0.0, 1.0),
      );
  }

  Path _starPath(Offset center, double radius) {
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
    return path;
  }

  Path _ribbon(Offset center, double radiusX, double radiusY, double turn) {
    final path = Path();
    const steps = 42;
    for (var step = 0; step <= steps; step++) {
      final t = step / steps;
      final angle = turn + t * math.pi * 2.15;
      final grow = 0.42 + t * 0.58;
      final point = Offset(
        center.dx + math.cos(angle) * radiusX * grow,
        center.dy + math.sin(angle) * radiusY * grow,
      );
      if (step == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path;
  }

  /// Lower tetrahedron, then the upper one, one edge at a time.
  /// After both have started, they turn gently in opposite directions.
  double _spin(MerkabaFrame frame) {
    if (reduceMotion) return 0;
    final scene4 = merkabaScenes[3];
    // The upper tetrahedron begins halfway through scene 4.
    final start =
        scene4.start +
        Duration(milliseconds: (scene4.end - scene4.start).inMilliseconds ~/ 2);
    if (frame.elapsed <= start) return 0;
    const rate = 0.028;
    final scene6 = merkabaScenes[5].start;
    if (frame.elapsed <= scene6) {
      return (frame.elapsed - start).inMilliseconds / 1000 * rate;
    }
    final settled = (scene6 - start).inMilliseconds / 1000 * rate;
    final sceneLength = (merkabaScenes[5].end - scene6).inMilliseconds / 1000;
    final into = (frame.elapsed - scene6).inMilliseconds / 1000;
    final t = into.clamp(0.0, sceneLength);
    return settled + rate * t * (1 - t / (2 * sceneLength));
  }

  Rect _womanRect(Size size) {
    final boxAspect = size.width / size.height;
    if (boxAspect > merkabaWomanAspect) {
      final height = size.height;
      final width = height * merkabaWomanAspect;
      return Rect.fromLTWH((size.width - width) / 2, 0, width, height);
    }
    final width = size.width;
    final height = width / merkabaWomanAspect;
    return Rect.fromLTWH(0, (size.height - height) / 2, width, height);
  }

  double _breath(MerkabaFrame frame) {
    final progress = frame.phaseProgress;
    return switch (frame.phase) {
      BreathPhase.inhale => progress,
      BreathPhase.hold => 1,
      BreathPhase.exhale => 1 - progress,
    };
  }

  double _sceneProgress(MerkabaFrame frame) {
    final span = frame.scene.end - frame.scene.start;
    final into = frame.elapsed - frame.scene.start;
    final total = span.inMilliseconds;
    if (total <= 0) return 1;
    return (into.inMilliseconds / total).clamp(0.0, 1.0);
  }

  @override
  bool shouldRepaint(covariant MerkabaFieldPainter oldDelegate) =>
      oldDelegate.frame.elapsed != frame.elapsed ||
      oldDelegate.frame.scene != frame.scene ||
      oldDelegate.frame.phase != frame.phase ||
      oldDelegate.reduceMotion != reduceMotion;
}
