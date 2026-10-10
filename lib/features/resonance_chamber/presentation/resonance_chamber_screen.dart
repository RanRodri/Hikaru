import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';
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
              insets.top + 28,
              _horizontalPadding,
              0,
            ),
            child: const _ChamberIntroduction(),
          ),
          SizedBox(height: heroHeight, child: const _CrystalVista()),
          const Expanded(child: _ScrollableDetails()),
          Padding(
            padding: EdgeInsets.fromLTRB(
              32,
              12,
              32,
              math.max(24, insets.bottom + 12),
            ),
            child: _JourneyButton(
              onPressed: () => context.push(AppRoutes.home),
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
        const SizedBox(height: 14),
        Text(
          'Your 30-Day Resonance Journey Has Been Created.',
          textAlign: TextAlign.center,
          style: bodyStyle.copyWith(fontSize: 11, height: 1.35),
        ),
        const SizedBox(height: 3),
        Text(
          'Your crystal, ritual, frequency, and cymatic signature have been '
          'aligned to guide your evolution for the next 30 days.',
          textAlign: TextAlign.center,
          style: bodyStyle.copyWith(fontSize: 10.5, height: 1.5),
        ),
        if (crystal != null) ...[
          const SizedBox(height: 8),
          Text(
            crystal.displayName,
            textAlign: TextAlign.center,
            semanticsLabel: 'Assigned crystal ${crystal.displayName}',
            style: AppTypography.subheadline.copyWith(
              color: AppColors.champagneGold,
              fontSize: 12,
              letterSpacing: 1.4,
            ),
          ),
          Text(
            crystal.temple,
            textAlign: TextAlign.center,
            style: bodyStyle.copyWith(fontSize: 10.5, height: 1.4),
          ),
        ],
      ],
    );
  }
}

class _CrystalVista extends StatelessWidget {
  const _CrystalVista();

  static const String _crystalAsset = 'assets/images/resonance_crystal.png';
  static const double _imageAspectRatio = 768 / 1344;
  static const double _visibleImageFraction = 303 / 845;
  static const Offset _crystalFocus = Offset(0.4667, 0.36);
  static const double _topFeather = 25;
  static const double _bottomFeather = 53;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = constraints.maxHeight / _visibleImageFraction;
        final imageWidth = imageHeight * _imageAspectRatio;

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: constraints.maxWidth / 2 - _crystalFocus.dx * imageWidth,
              top: constraints.maxHeight / 2 - _crystalFocus.dy * imageHeight,
              width: imageWidth,
              height: imageHeight,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  AppColors.indigoBlue.withValues(alpha: 0.12),
                  BlendMode.color,
                ),
                child: const Image(
                  image: AssetImage(_crystalAsset),
                  fit: BoxFit.fill,
                  semanticLabel: 'Your crystal in the garden',
                ),
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
        12,
        ResonanceChamberScreen._horizontalPadding,
        16,
      ),
      children: [
        SectionHeading(label: 'THE ALIGNMENT TRIAD'),
        SizedBox(height: 15),
        AlignmentTriad(),
        SizedBox(height: 24),
        SectionHeading(label: '30 DAYS WITH YOUR CRYSTAL'),
        SizedBox(height: 12),
        CrystalBenefits(),
      ],
    );
  }
}

class _JourneyButton extends StatelessWidget {
  const _JourneyButton({required this.onPressed});

  static const double _height = 56;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_height / 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.champagneGold.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: _height,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.champagneGold,
            foregroundColor: AppColors.darkIndigoBlue,
            shape: StadiumBorder(
              side: BorderSide(
                color: AppColors.champagneGold.withValues(alpha: 0.3),
              ),
            ),
            elevation: 0,
          ),
          child: Text(
            'ENTER MY 30-DAY JOURNEY',
            style: AppTypography.subheadline.copyWith(
              color: AppColors.darkIndigoBlue,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
