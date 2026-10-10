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

class _CrystalVista extends ConsumerWidget {
  const _CrystalVista();

  static const String _gardenAsset = 'assets/images/resonance_crystal.png';
  static const double _imageAspectRatio = 768 / 1344;
  static const double _visibleImageFraction = 303 / 845;
  static const Offset _crystalFocus = Offset(0.4667, 0.36);
  static const double _topFeather = 25;
  static const double _bottomFeather = 53;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crystal = ref.watch(selectedCrystalProvider).value;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            if (crystal == null)
              _GardenPortrait(constraints: constraints)
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s40,
                  AppSpacing.s16,
                  AppSpacing.s40,
                  AppSpacing.s28,
                ),
                child: Image(
                  image: AssetImage(crystal.imageAsset),
                  fit: BoxFit.contain,
                  semanticLabel: '${crystal.displayName} crystal',
                ),
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

class _GardenPortrait extends StatelessWidget {
  const _GardenPortrait({required this.constraints});

  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final imageHeight =
        constraints.maxHeight / _CrystalVista._visibleImageFraction;
    final imageWidth = imageHeight * _CrystalVista._imageAspectRatio;

    return Stack(
      children: [
        Positioned(
          left:
              constraints.maxWidth / 2 -
              _CrystalVista._crystalFocus.dx * imageWidth,
          top:
              constraints.maxHeight / 2 -
              _CrystalVista._crystalFocus.dy * imageHeight,
          width: imageWidth,
          height: imageHeight,
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              AppColors.indigoBlue.withValues(alpha: 0.12),
              BlendMode.color,
            ),
            child: const Image(
              image: AssetImage(_CrystalVista._gardenAsset),
              fit: BoxFit.fill,
              semanticLabel: 'Your crystal in the garden',
            ),
          ),
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
