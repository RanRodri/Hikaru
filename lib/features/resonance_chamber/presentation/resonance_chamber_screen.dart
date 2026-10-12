import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../core/router/app_routes.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../crystals/domain/crystal.dart';
import 'resonance_sections.dart';

class ResonanceChamberScreen extends StatelessWidget {
  const ResonanceChamberScreen({super.key});

  static const double _horizontalPadding = 21;
  static const double _heroScreenRatio = 0.42;
  static const double _minHeroHeight = 260;
  static const double _maxHeroHeight = 420;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final insets = mediaQuery.padding;
    final heroHeight = (mediaQuery.size.height * _heroScreenRatio).clamp(
      _minHeroHeight,
      _maxHeroHeight,
    );

    return Scaffold(
      backgroundColor: resonanceChamberColor,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              _horizontalPadding,
              insets.top + AppSpacing.s28,
              _horizontalPadding,
              AppSpacing.s0,
            ),
            child: const _ChamberIntroduction(),
          ),
          SizedBox(height: heroHeight, child: const _CrystalVista()),
          const Expanded(child: _ScrollableDetails()),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s32,
              AppSpacing.s12,
              AppSpacing.s32,
              math.max(AppSpacing.s24, insets.bottom + AppSpacing.s12),
            ),
            child: HikaruPillButton(
              label: 'ENTER MY 30-DAY JOURNEY',
              onPressed: () => context.go(AppRoutes.home),
              buttonHeight: AppSpacing.s56,
              blurRadius: 8,
              shadowAlpha: 0.25,
              borderAlpha: 0.3,
              labelStyle: AppTypography.journeyLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChamberIntroduction extends ConsumerWidget {
  const _ChamberIntroduction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crystal = ref.watch(selectedCrystalProvider).value;
    final bodyStyle = AppTypography.headline.copyWith(
      color: AppColors.white,
      letterSpacing: 0,
    );

    return Column(
      children: [
        const ChamberTitle(),
        const SizedBox(height: AppSpacing.s14),
        Text(
          'Your 30-Day Resonance Journey Has Been Created.',
          textAlign: TextAlign.center,
          style: bodyStyle.copyWith(fontSize: AppFontSizes.s11, height: 1.35),
        ),
        const SizedBox(height: AppSpacing.s3),
        Text(
          'Your crystal, ritual, frequency, and cymatic signature have been '
          'aligned to guide your evolution for the next 30 days.',
          textAlign: TextAlign.center,
          style: bodyStyle.copyWith(fontSize: AppFontSizes.s10_5, height: 1.5),
        ),
        if (crystal != null) ...[
          const SizedBox(height: AppSpacing.s8),
          Text(
            crystal.displayName,
            textAlign: TextAlign.center,
            semanticsLabel: 'Assigned crystal ${crystal.displayName}',
            style: AppTypography.subheadline.copyWith(
              color: AppColors.champagneGold,
              fontSize: AppFontSizes.s12,
              letterSpacing: 1.4,
            ),
          ),
          Text(
            crystal.temple,
            textAlign: TextAlign.center,
            style: bodyStyle.copyWith(
              fontSize: AppFontSizes.s10_5,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

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

  /// Share of the image height that fills the vista, so every crystal
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

class _CrystalVista extends ConsumerWidget {
  const _CrystalVista();

  static const double _topFeather = 25;
  static const double _bottomFeather = 53;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crystal = ref.watch(selectedCrystalProvider).value;
    final scene = _crystalScenes[crystal] ?? _whiteQuartzScene;
    final semanticLabel = crystal == null
        ? 'Your crystal in the garden'
        : '${crystal.displayName} crystal';

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

class _ScrollableDetails extends StatelessWidget {
  const _ScrollableDetails();

  @override
  Widget build(BuildContext context) {
    return const ChamberScrollView(
      padding: EdgeInsets.fromLTRB(
        ResonanceChamberScreen._horizontalPadding,
        AppSpacing.s12,
        ResonanceChamberScreen._horizontalPadding,
        AppSpacing.s16,
      ),
      children: [
        SectionHeading(label: 'THE ALIGNMENT TRIAD'),
        SizedBox(height: AppSpacing.s15),
        AlignmentTriad(),
        SizedBox(height: AppSpacing.s24),
        SectionHeading(label: '30 DAYS WITH YOUR CRYSTAL'),
        SizedBox(height: AppSpacing.s12),
        CrystalBenefits(),
      ],
    );
  }
}
