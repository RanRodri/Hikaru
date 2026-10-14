import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/audio/audio_report.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import 'cymatic_signature.dart';

const String _kaleidoscopeShader = 'shaders/cymatic_kaleidoscope.frag';

Future<ui.FragmentProgram?>? _kaleidoscopeProgram;

/// Loads the kaleidoscope shader once. Null when the device cannot compile it,
/// so the cymatic falls back to the vector mandala.
Future<ui.FragmentProgram?> loadCymaticKaleidoscope() {
  return _kaleidoscopeProgram ??= () async {
    try {
      return await ui.FragmentProgram.fromAsset(_kaleidoscopeShader);
    } catch (error, stackTrace) {
      reportAudioFailure('Cymatic kaleidoscope shader', error, stackTrace);
      return null;
    }
  }();
}

/// Paints the GPU kaleidoscope across the whole canvas, driven by [visual].
class CymaticKaleidoscopePainter extends CustomPainter {
  CymaticKaleidoscopePainter({
    required Listenable repaint,
    required ui.FragmentProgram program,
    required this.visual,
    required this.motif,
  }) : _shader = program.fragmentShader(),
       super(repaint: repaint);

  final ui.FragmentShader _shader;
  final CymaticVisual visual;
  final CymaticMotif motif;

  /// Simulated petal morph when no track drives it.
  double get _morph {
    final audioMorph = visual.audioMorph;
    if (audioMorph != null && visual.motion > 0) {
      return audioMorph.clamp(0.0, 1.0);
    }
    final breath = 0.5 - 0.5 * math.cos(visual.phase * math.pi * 2);
    return (0.34 + visual.motion * 0.5 * breath).clamp(0.0, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final values = <double>[
      size.width,
      size.height,
      visual.time,
      visual.motion,
      visual.pulse,
      _morph,
      visual.glowScale,
      visual.attack,
      visual.low,
      visual.mid,
      visual.high,
      ..._rgb(visual.tint),
      ..._rgb(AppColors.splashHighlight),
      ..._rgb(AppColors.indigoBlue),
      ..._rgb(AppColors.darkIndigoBlue),
      motif.folds.toDouble(),
    ];
    for (final (index, value) in values.indexed) {
      _shader.setFloat(index, value);
    }
    canvas.drawRect(Offset.zero & size, Paint()..shader = _shader);
  }

  @override
  bool shouldRepaint(CymaticKaleidoscopePainter oldDelegate) =>
      oldDelegate.visual != visual || oldDelegate.motif != motif;
}

List<double> _rgb(Color color) => [color.r, color.g, color.b];
