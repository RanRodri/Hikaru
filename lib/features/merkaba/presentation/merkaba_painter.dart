import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/merkaba_session.dart';

/// Seated woman on a transparent background, over the starry night.
const String merkabaWomanAsset = 'assets/images/merkaba_woman.png';

/// Width / height of [merkabaWomanAsset].
const double merkabaWomanAspect = 900 / 720;

/// Breath level shown while animations are disabled.
const double merkabaRestingBreath = 0.62;

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
        Image(
          image: const AssetImage(merkabaWomanAsset),
          fit: BoxFit.contain,
          semanticLabel: AppLocalizations.of(context).merkabaWomanSemantics,
          frameBuilder: _fadeInWoman,
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

  static const Duration _womanFade = Duration(milliseconds: 900);

  static Widget _fadeInWoman(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) return child;
    return AnimatedOpacity(
      opacity: frame == null ? 0 : 1,
      duration: _womanFade,
      curve: Curves.easeOut,
      alwaysIncludeSemantics: true,
      child: child,
    );
  }
}

/// Geometry drawn in phases: a triangle forms, dissolves into figure-eight
/// lines that envelop her, the Merkaba builds and turns, and a heart blossoms.
class MerkabaFieldPainter extends CustomPainter {
  const MerkabaFieldPainter({required this.frame, required this.reduceMotion});

  final MerkabaFrame frame;
  final bool reduceMotion;

  /// Indexes into [merkabaScenes].
  static const int _blueprintScene = 0;
  static const int _envelopeScene = 1;
  static const int _buildScene = 2;
  static const int _expansionScene = 3;
  static const int _blossomScene = 4;

  /// Share of the blueprint scene spent on the woman and heart alone
  /// before the triangle starts tracing, and the share spent tracing it.
  static const double _triangleDelay = 0.25;
  static const double _triangleTrace = 0.6;
  static const double _triangleRadius = 0.30;

  /// Share of the envelope scene the triangle takes to split into
  /// figure-eight lines, and how the three lines differ in size.
  static const double _dissolveShare = 0.35;
  static const int _envelopeLines = 3;
  static const int _morphSamples = 120;
  static const double _eightHalfWidth = 0.34;
  static const double _eightHalfHeight = 0.42;

  /// The two tetrahedra close slightly before the rotation scene begins.
  static const double _buildShare = 0.9;

  /// Share of the blossom scene spent tracing the outer heart, and when the
  /// inner heart starts.
  static const double _heartTrace = 0.7;
  static const double _innerHeartDelay = 0.35;

  /// Heart curve units per woman height, and the curve's vertical middle.
  static const double _heartScale = 0.022;
  static const double _heartCurveMiddle = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    final woman = _womanRect(size);
    if (woman.width <= 0 || woman.height <= 0) return;

    // Heart glow sits on the chest. The geometry shares her vertical axis
    // and is centered so each figure frames the whole seated body.
    final heart = Offset(
      woman.left + woman.width * _axisX,
      woman.top + woman.height * _heartY,
    );
    final sceneIndex = merkabaScenes.indexOf(frame.scene);
    final breath = reduceMotion ? merkabaRestingBreath : frame.breathLevel;
    final sceneT = _sceneProgress(frame);

    _paintHeartGlow(canvas, heart, woman.height, breath, sceneIndex, sceneT);
    _paintTriangle(canvas, heart, woman, sceneIndex, sceneT, breath);
    _paintEnvelope(canvas, heart, woman, sceneIndex, sceneT, breath);
    _paintMerkaba(canvas, heart, woman, sceneIndex, sceneT, breath);
    _paintHeartFigure(canvas, heart, woman, sceneIndex, sceneT);
  }

  void _paintHeartGlow(
    Canvas canvas,
    Offset heart,
    double height,
    double breath,
    int sceneIndex,
    double sceneT,
  ) {
    final calm = sceneIndex == _blossomScene ? sceneT : 0.0;
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
    if (sceneIndex == _expansionScene) {
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

  void _paintTriangle(
    Canvas canvas,
    Offset center,
    Rect woman,
    int sceneIndex,
    double sceneT,
    double breath,
  ) {
    if (sceneIndex != _blueprintScene) return;
    final draw = reduceMotion
        ? 1.0
        : ((sceneT - _triangleDelay) / _triangleTrace).clamp(0.0, 1.0);
    if (draw <= 0) return;
    final radius = _triangleRadiusFor(woman, draw >= 1 ? breath : 0);
    final path = _closedPath(_trianglePoints(center, radius, _morphSamples));
    _stroke(canvas, path, 0.82, draw);
  }

  /// The closed triangle splits into three figure-eight lines that wrap her
  /// head and lap, crossing at the heart. They breathe and drift gently.
  void _paintEnvelope(
    Canvas canvas,
    Offset center,
    Rect woman,
    int sceneIndex,
    double sceneT,
    double breath,
  ) {
    final double dissolve;
    final double opacity;
    if (sceneIndex == _envelopeScene) {
      dissolve = reduceMotion
          ? 1.0
          : Curves.easeInOut.transform(
              (sceneT / _dissolveShare).clamp(0.0, 1.0),
            );
      opacity = 1;
    } else if (sceneIndex == _buildScene) {
      dissolve = 1;
      opacity = (1 - sceneT / 0.08).clamp(0.0, 1.0);
    } else {
      return;
    }
    if (opacity <= 0) return;

    final triangle = _trianglePoints(
      center,
      _triangleRadiusFor(woman, breath),
      _morphSamples,
    );
    final reach = 0.86 + breath * 0.14;
    final seconds = reduceMotion ? 0.0 : frame.elapsed.inMilliseconds / 1000;
    for (var line = 0; line < _envelopeLines; line++) {
      final tilt = math.sin(seconds * 0.25 + line * 2.1) * 0.07 * dissolve;
      final eight = _eightPoints(
        center: center,
        halfWidth: woman.height * _eightHalfWidth * reach * (1 - line * 0.12),
        halfHeight: woman.height * _eightHalfHeight * reach * (1 - line * 0.05),
        tilt: tilt,
        samples: _morphSamples,
      );
      final points = [
        for (var index = 0; index < _morphSamples; index++)
          Offset.lerp(triangle[index], eight[index], dissolve)!,
      ];
      final alpha = line == 0 ? 0.82 - 0.22 * dissolve : 0.42 * dissolve;
      _stroke(canvas, _closedPath(points), alpha * opacity, 1);
    }
  }

  void _paintMerkaba(
    Canvas canvas,
    Offset center,
    Rect woman,
    int sceneIndex,
    double sceneT,
    double breath,
  ) {
    if (sceneIndex < _buildScene) return;
    final built = sceneIndex == _buildScene && !reduceMotion
        ? (sceneT / _buildShare).clamp(0.0, 1.0) * 6
        : 6.0;
    if (built <= 0) return;
    final fade = sceneIndex == _blossomScene
        ? (1 - sceneT / _heartTrace).clamp(0.0, 1.0)
        : 1.0;
    if (fade <= 0) return;
    final scale = sceneIndex == _expansionScene
        ? 1 + breath * 0.08
        : 1 + breath * 0.02;
    final radius = woman.height * 0.42 * scale;
    final spin = _spin(frame);
    _drawTetra(
      canvas: canvas,
      center: center,
      radius: radius,
      rotation: spin,
      pointUp: false,
      edges: _edges(built, 0),
      alpha: 0.9 * fade,
    );
    _drawTetra(
      canvas: canvas,
      center: center,
      radius: radius,
      rotation: -spin,
      pointUp: true,
      edges: _edges(built, 3),
      alpha: 0.9 * fade,
    );
  }

  /// Both halves of the heart trace from the top dip down to its point,
  /// cradling her, then a smaller heart blooms inside.
  void _paintHeartFigure(
    Canvas canvas,
    Offset heart,
    Rect woman,
    int sceneIndex,
    double sceneT,
  ) {
    if (sceneIndex != _blossomScene) return;
    final outer = reduceMotion ? 1.0 : (sceneT / _heartTrace).clamp(0.0, 1.0);
    if (outer <= 0) return;
    final scale = woman.height * _heartScale;
    for (final side in const [1.0, -1.0]) {
      _stroke(canvas, _heartHalf(heart, scale, side), 0.85, outer);
    }
    final inner = reduceMotion
        ? 1.0
        : ((sceneT - _innerHeartDelay) / (1 - _innerHeartDelay)).clamp(
            0.0,
            1.0,
          );
    if (inner <= 0) return;
    for (final side in const [1.0, -1.0]) {
      _stroke(canvas, _heartHalf(heart, scale * 0.6, side), 0.5, inner);
    }
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
    final path = Path();
    var drawing = false;
    for (var edge = 0; edge < 3; edge++) {
      final progress = edges[edge].clamp(0.0, 1.0);
      if (progress <= 0) break;
      final start = points[edge];
      final end = points[(edge + 1) % 3];
      final tip = Offset.lerp(start, end, progress)!;
      if (!drawing) {
        path.moveTo(start.dx, start.dy);
        drawing = true;
      }
      path.lineTo(tip.dx, tip.dy);
      if (progress < 1) break;
    }
    if (drawing) _stroke(canvas, path, alpha, 1);
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

  double _triangleRadiusFor(Rect woman, double breath) {
    final pulse = reduceMotion ? 1.0 : 1 + breath * 0.035;
    return woman.height * _triangleRadius * pulse;
  }

  /// Evenly spaced points around an upward triangle, clockwise from the top.
  List<Offset> _trianglePoints(Offset center, double radius, int samples) {
    final corners = [
      for (var corner = 0; corner < 3; corner++)
        center +
            Offset(
                  math.cos(-math.pi / 2 + corner * 2 * math.pi / 3),
                  math.sin(-math.pi / 2 + corner * 2 * math.pi / 3),
                ) *
                radius,
    ];
    return [
      for (var index = 0; index < samples; index++)
        _alongTriangle(corners, index * 3 / samples),
    ];
  }

  Offset _alongTriangle(List<Offset> corners, double position) {
    final side = position.floor();
    return Offset.lerp(
      corners[side % 3],
      corners[(side + 1) % 3],
      position - side,
    )!;
  }

  /// Vertical figure eight starting at the top, so its lower-right and
  /// lower-left lobes line up with the triangle's lower corners.
  List<Offset> _eightPoints({
    required Offset center,
    required double halfWidth,
    required double halfHeight,
    required double tilt,
    required int samples,
  }) {
    final cosTilt = math.cos(tilt);
    final sinTilt = math.sin(tilt);
    final points = <Offset>[];
    for (var index = 0; index < samples; index++) {
      final t = math.pi / 2 + index * 2 * math.pi / samples;
      final x = halfWidth * math.sin(2 * t);
      final y = -halfHeight * math.sin(t);
      points.add(
        center + Offset(x * cosTilt - y * sinTilt, x * sinTilt + y * cosTilt),
      );
    }
    return points;
  }

  /// One half of the classic heart curve, from the top dip to the point.
  /// [side] is 1 for her left (screen right) and -1 for the other half.
  Path _heartHalf(Offset center, double scale, double side) {
    final path = Path();
    const steps = 64;
    for (var step = 0; step <= steps; step++) {
      final t = side * math.pi * step / steps;
      final sine = math.sin(t);
      final x = 16 * sine * sine * sine;
      final y =
          13 * math.cos(t) -
          5 * math.cos(2 * t) -
          2 * math.cos(3 * t) -
          math.cos(4 * t);
      final point =
          center + Offset(x * scale, -(y + _heartCurveMiddle) * scale);
      if (step == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path;
  }

  Path _closedPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  /// Lower tetrahedron, then the upper one, one edge at a time.
  /// They stay on her vertical axis until both triangles are closed,
  /// then turn gently in opposite directions.
  double _spin(MerkabaFrame frame) {
    if (reduceMotion) return 0;
    final start = merkabaScenes[_expansionScene].start;
    if (frame.elapsed <= start) return 0;
    const rate = 0.012;
    final blossom = merkabaScenes[_blossomScene];
    if (frame.elapsed <= blossom.start) {
      return (frame.elapsed - start).inMilliseconds / 1000 * rate;
    }
    final settled = (blossom.start - start).inMilliseconds / 1000 * rate;
    final sceneLength = (blossom.end - blossom.start).inMilliseconds / 1000;
    final into = (frame.elapsed - blossom.start).inMilliseconds / 1000;
    final t = into.clamp(0.0, sceneLength);
    return settled + rate * t * (1 - t / (2 * sceneLength));
  }

  /// Vertical centerline through the heart in the portrait.
  static const double _axisX = 0.50;

  /// Glowing heart in the portrait, also the center of her seated figure.
  static const double _heartY = 0.478;

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
