import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/audio/audio_report.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../crystals/domain/crystal.dart';
import '../domain/cymatic_audio.dart' show cymaticModeCount;
import '../domain/cymatic_plate_profiles.g.dart';
import 'cymatic_palette.dart';

const String _plateShaderAsset = 'shaders/cymatic_plate.frag';

Future<ui.FragmentProgram?>? _plateProgram;
final Map<String, Future<ui.Image?>> _lutImages = {};

final class CymaticPlateResources {
  const CymaticPlateResources({required this.program, required this.lut});

  final ui.FragmentProgram program;
  final ui.Image lut;
}

Future<CymaticPlateResources?> loadCymaticPlate(Crystal crystal) async {
  final profile = crystal.cymaticPlateProfile;
  final results = await Future.wait<Object?>([
    _loadPlateProgram(),
    _loadLut(profile.lutAsset),
  ]);
  final program = results[0] as ui.FragmentProgram?;
  final lut = results[1] as ui.Image?;
  if (program == null || lut == null) return null;
  return CymaticPlateResources(program: program, lut: lut);
}

Future<ui.FragmentProgram?> _loadPlateProgram() {
  return _plateProgram ??= () async {
    try {
      return await ui.FragmentProgram.fromAsset(_plateShaderAsset);
    } catch (error, stackTrace) {
      reportAudioFailure('Cymatic plate shader', error, stackTrace);
      return null;
    }
  }();
}

Future<ui.Image?> _loadLut(String asset) {
  return _lutImages.putIfAbsent(asset, () async {
    try {
      final data = await rootBundle.load(asset);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final completer = Completer<ui.Image>();
      ui.decodeImageFromList(bytes, completer.complete);
      final image = await completer.future;
      if (image.width != 512 || image.height != 12) {
        image.dispose();
        throw StateError(
          '$asset is ${image.width}x${image.height}; expected 512x12',
        );
      }
      return image;
    } catch (error, stackTrace) {
      reportAudioFailure('Cymatic plate LUT $asset', error, stackTrace);
      return null;
    }
  });
}

/// Mutable frame data read directly by the painter. Updating it never rebuilds
/// the projection; AnimationControllers and the audio ticker request repaints.
final class CymaticPlateVisual {
  double level = 0;
  final List<double> amplitudes = List.filled(cymaticModeCount, 1);
  double normInv = 1;

  /// Slow radial phase for the two fractal-inspired detail scales. It never
  /// rotates the plate or breaks its exact symmetry.
  double detailPhase = 0;

  double motion = 0;
  double colorProgress = 0;
}

final class CymaticPlatePainter extends CustomPainter {
  CymaticPlatePainter({
    required Listenable repaint,
    required ui.FragmentProgram program,
    required ui.Image lut,
    required this.visual,
    required this.profile,
    required this.palette,
    this.reducedResolution = false,
    this.rasterScale = 1,
  }) : _shader = program.fragmentShader(),
       _lut = lut,
       super(repaint: repaint);

  final ui.FragmentShader _shader;
  final ui.Image _lut;
  final CymaticPlateVisual visual;
  final CymaticPlateProfile profile;

  /// The crystal's colors.
  final CymaticPalette palette;

  /// Whether to render through a half-resolution offscreen target.
  final bool reducedResolution;

  /// Physical-pixel scale used by the reduced-resolution target.
  final double rasterScale;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    if (!reducedResolution) {
      _paintPlate(canvas, size);
      return;
    }

    final target = Size(
      math.max(1, (size.width * rasterScale).round()).toDouble(),
      math.max(1, (size.height * rasterScale).round()).toDouble(),
    );
    final recorder = ui.PictureRecorder();
    _paintPlate(Canvas(recorder), target);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(
      target.width.toInt(),
      target.height.toInt(),
    );
    picture.dispose();
    canvas.drawImageRect(
      image,
      Offset.zero & target,
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.medium,
    );
    image.dispose();
  }

  void _paintPlate(Canvas canvas, Size size) {
    final values = <double>[
      size.width,
      size.height,
      visual.level.clamp(0.0, 1.0),
      visual.detailPhase % 1,
      ...visual.amplitudes.map((value) => value.clamp(0.0, 1.0)),
      profile.symmetry.toDouble(),
      ...profile.modes.map((value) => value.toDouble()),
      ...profile.weights,
      visual.normInv,
      ..._rgb(AppColors.darkIndigoBlue),
      ..._cycledRgb(palette.primary, visual.colorProgress, 0),
      ..._cycledRgb(palette.secondary, visual.colorProgress, 1 / 3),
      ..._cycledRgb(palette.tertiary, visual.colorProgress, 2 / 3),
    ];
    assert(values.length == 54);
    for (final (index, value) in values.indexed) {
      _shader.setFloat(index, value);
    }
    _shader.setImageSampler(0, _lut);
    canvas.drawRect(Offset.zero & size, Paint()..shader = _shader);
  }

  @override
  bool shouldRepaint(CymaticPlatePainter oldDelegate) =>
      oldDelegate.visual != visual ||
      oldDelegate.profile != profile ||
      oldDelegate.palette != palette ||
      oldDelegate.reducedResolution != reducedResolution ||
      oldDelegate.rasterScale != rasterScale ||
      oldDelegate._lut != _lut;
}

/// A non-petal fallback shown while the runtime shader or LUT is unavailable.
/// It keeps the crystal's radial mode count and exact outer symmetry, but only
/// the GPU path evaluates the twelve Bessel layers.
final class CymaticPlateFallbackPainter extends CustomPainter {
  CymaticPlateFallbackPainter({
    required Listenable repaint,
    required this.visual,
    required this.profile,
    required this.palette,
  }) : super(repaint: repaint);

  final CymaticPlateVisual visual;
  final CymaticPlateProfile profile;
  final CymaticPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.47;
    // Translucent disc only: the starry night stays visible around it.
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = AppColors.darkIndigoBlue.withValues(alpha: 0.55),
    );

    final glow = 0.45 + 0.55 * visual.level;
    final rings = 4 + profile.modes.where((mode) => mode == 0).length;
    for (var index = 1; index <= rings; index++) {
      final ringRadius = radius * index / (rings + 1);
      final phaseColor = index.isEven ? palette.secondary : palette.tertiary;
      canvas.drawCircle(
        center,
        ringRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1 + 1.4 * glow
          ..color = phaseColor.withValues(alpha: 0.25 + 0.2 * glow),
      );
      canvas.drawCircle(
        center,
        ringRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7
          ..color = palette.primary.withValues(alpha: 0.8),
      );
    }

    // Angular structure starts away from the center so the core remains rings.
    final arcRect = Rect.fromCircle(center: center, radius: radius * 0.78);
    final sweep = math.pi * 0.55 / profile.symmetry;
    for (var fold = 0; fold < profile.symmetry; fold++) {
      final angle = fold * math.pi * 2 / profile.symmetry - sweep / 2;
      canvas.drawArc(
        arcRect,
        angle,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = palette.primary.withValues(alpha: 0.62),
      );
    }
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = AppColors.champagneGold,
    );
  }

  @override
  bool shouldRepaint(CymaticPlateFallbackPainter oldDelegate) =>
      oldDelegate.visual != visual ||
      oldDelegate.profile != profile ||
      oldDelegate.palette != palette;
}

List<double> _rgb(Color color) => [color.r, color.g, color.b];

List<double> _cycledRgb(Color color, double progress, double offset) {
  final wave = 0.5 + 0.5 * math.sin((progress + offset) * math.pi * 2);
  final intensity = 0.76 + 0.24 * wave;
  return [
    (color.r * intensity).clamp(0.0, 1.0),
    (color.g * intensity).clamp(0.0, 1.0),
    (color.b * intensity).clamp(0.0, 1.0),
  ];
}
