import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../crystals/domain/crystal.dart';
import 'crystal_scene_photo.dart';
import 'cymatic_signature.dart';

/// One image: the crystal's photo with its own cymatic plate glowing behind
/// it like an aura.
///
/// The plate is the same [CymaticSignature] used in the projection. Only how
/// it is composited changes: its dark disc is turned transparent, so just the
/// lines of light remain, and the center is masked so the crystal stays in
/// front. It breathes gently, and stays still with reduce motion.
class CrystalCymaticPortrait extends StatelessWidget {
  const CrystalCymaticPortrait({super.key, required this.crystal});

  final Crystal crystal;

  /// Plate diameter as a share of the photo's shortest side.
  static const double _plateShare = 0.98;

  /// Strength of the aura over the photo.
  static const double _auraAlpha = 0.85;

  /// Keeps the bright lines and drops the plate's dark, translucent disc:
  /// alpha follows brightness (colors in 0–255, unpremultiplied).
  static const ColorFilter _lightOnly = ColorFilter.matrix([
    1.1, 0, 0, 0, 0, //
    0, 1.1, 0, 0, 0, //
    0, 0, 1.1, 0, 0, //
    0.96, 1.89, 0.35, 0, -40,
  ]);

  /// Transparent over the crystal, full on the rings, soft at the rim.
  static final Gradient _aura = RadialGradient(
    radius: 0.5,
    colors: [
      AppColors.white.withValues(alpha: 0),
      AppColors.white.withValues(alpha: 0),
      AppColors.white.withValues(alpha: _auraAlpha),
      AppColors.white.withValues(alpha: _auraAlpha),
      AppColors.white.withValues(alpha: 0),
    ],
    stops: const [0, 0.44, 0.62, 0.88, 1],
  );

  @override
  Widget build(BuildContext context) {
    final animate = !MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, box) {
        final side = math.min(box.maxWidth, box.maxHeight) * _plateShare;
        return Stack(
          fit: StackFit.expand,
          children: [
            CrystalScenePhoto(crystal: crystal),
            IgnorePointer(
              child: ExcludeSemantics(
                child: Center(
                  child: SizedBox.square(
                    dimension: side,
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: _aura.createShader,
                      child: ColorFiltered(
                        colorFilter: _lightOnly,
                        child: RepaintBoundary(
                          child: CymaticSignature(
                            crystal: crystal,
                            playing: animate,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
