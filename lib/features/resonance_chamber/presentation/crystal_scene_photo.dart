import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../crystals/domain/crystal.dart';
import 'resonance_sections.dart';

class _CrystalScene {
  const _CrystalScene({
    required this.asset,
    required this.aspectRatio,
    required this.visibleHeightFraction,
    required this.crystalFocus,
    this.isTinted = false,
  });

  final String asset;
  final double aspectRatio;

  /// Share of the image height that fills the photo, so every crystal
  /// shows at the same size.
  final double visibleHeightFraction;

  /// Crystal center as a fraction of the image size.
  final Offset crystalFocus;
  final bool isTinted;
}

const _CrystalScene _whiteQuartzScene = _CrystalScene(
  asset: 'assets/images/resonance_crystal.png',
  aspectRatio: 768 / 1344,
  visibleHeightFraction: 303 / 845,
  crystalFocus: Offset(0.4667, 0.36),
  isTinted: true,
);

const Map<Crystal, _CrystalScene> _crystalScenes = {
  Crystal.whiteQuartz: _whiteQuartzScene,
  Crystal.jade: _CrystalScene(
    asset: 'assets/images/jade.png',
    aspectRatio: 1672 / 941,
    visibleHeightFraction: 0.95,
    crystalFocus: Offset(0.5, 0.512),
  ),
  Crystal.redJasper: _CrystalScene(
    asset: 'assets/images/jasper.png',
    aspectRatio: 1671 / 941,
    visibleHeightFraction: 0.95,
    crystalFocus: Offset(0.5, 0.482),
  ),
  Crystal.obsidian: _CrystalScene(
    asset: 'assets/images/obsidian.png',
    aspectRatio: 1672 / 941,
    visibleHeightFraction: 0.95,
    crystalFocus: Offset(0.5, 0.477),
  ),
};

/// Crystal photo centered on the crystal, feathered into the chamber color.
/// Without a crystal it shows white quartz in the garden.
class CrystalScenePhoto extends StatelessWidget {
  const CrystalScenePhoto({super.key, required this.crystal});

  static const double _topFeather = 25;
  static const double _bottomFeather = 53;

  final Crystal? crystal;

  @override
  Widget build(BuildContext context) {
    final selected = crystal;
    final scene = _crystalScenes[selected] ?? _whiteQuartzScene;
    final semanticLabel = selected == null
        ? 'Your crystal in the garden'
        : '${selected.displayName} crystal';

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            _ScenePortrait(
              scene: scene,
              constraints: constraints,
              semanticLabel: semanticLabel,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _topFeather,
              child: _Feather(
                colors: [resonanceChamberColor, _transparentChamber],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: _bottomFeather,
              child: _Feather(
                colors: [_transparentChamber, resonanceChamberColor],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScenePortrait extends StatelessWidget {
  const _ScenePortrait({
    required this.scene,
    required this.constraints,
    required this.semanticLabel,
  });

  final _CrystalScene scene;
  final BoxConstraints constraints;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final imageHeight = constraints.maxHeight / scene.visibleHeightFraction;
    final imageWidth = imageHeight * scene.aspectRatio;
    final image = Image(
      image: AssetImage(scene.asset),
      fit: BoxFit.fill,
      semanticLabel: semanticLabel,
    );

    return Stack(
      children: [
        Positioned(
          left: constraints.maxWidth / 2 - scene.crystalFocus.dx * imageWidth,
          top: constraints.maxHeight / 2 - scene.crystalFocus.dy * imageHeight,
          width: imageWidth,
          height: imageHeight,
          child: scene.isTinted
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    AppColors.indigoBlue.withValues(alpha: 0.12),
                    BlendMode.color,
                  ),
                  child: image,
                )
              : image,
        ),
      ],
    );
  }
}

final Color _transparentChamber = resonanceChamberColor.withValues(alpha: 0);

class _Feather extends StatelessWidget {
  const _Feather({required this.colors});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
        ),
      ),
    );
  }
}
