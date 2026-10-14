import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../core/router/app_routes.dart';
import 'photo_mirror.dart';

const List<Shadow> _titleShadow = [
  Shadow(color: AppColors.ink80, offset: Offset(0, 2), blurRadius: 8),
];

const List<Shadow> _bodyGlow = [
  Shadow(color: AppColors.ivoryGlow, blurRadius: 12),
];

class MirrorGardenScreen extends StatelessWidget {
  const MirrorGardenScreen({super.key});

  static const String _backgroundAsset = 'assets/images/mirror_garden.png';
  static const double _headerTop = 72;

  /// With the skip action under it, CONTINUE sits as high as the main
  /// button on the Listening Room and Ritual Ready screens.
  static const double _bottomGap = AppSpacing.s30;
  static const double _minInsetGap = AppSpacing.s16;
  static const double _horizontalPadding = AppSpacing.s32;

  void _openResonanceChamber(BuildContext context) =>
      context.push(AppRoutes.resonanceChamber);

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    final topSpace = math.max(_headerTop, insets.top + _minInsetGap);
    final bottomSpace = math.max(_bottomGap, insets.bottom + _minInsetGap);

    return Scaffold(
      backgroundColor: AppColors.indigoBlue,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              AppColors.indigoBlue.withValues(alpha: 0.12),
              BlendMode.color,
            ),
            child: const Image(
              image: AssetImage(_backgroundAsset),
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
          const _Vignettes(),
          Padding(
            padding: EdgeInsets.fromLTRB(
              _horizontalPadding,
              topSpace,
              _horizontalPadding,
              bottomSpace,
            ),
            child: Column(
              children: [
                Opacity(
                  opacity: 0.85,
                  child: Text(
                    'THE MIRROR GARDEN',
                    textAlign: TextAlign.center,
                    style: AppTypography.headline.copyWith(
                      color: AppColors.champagneGold,
                      fontSize: AppFontSizes.s10,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s28),
                Text(
                  'Add A Photo Of Your Face For Personal Tracking',
                  textAlign: TextAlign.center,
                  style: AppTypography.title.copyWith(
                    color: AppColors.white,
                    fontSize: AppFontSizes.s30,
                    height: 1.15,
                    shadows: _titleShadow,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _PhotoChoice(onUpload: () {}),
                    ),
                  ),
                ),
                HikaruPillButton(
                  label: 'CONTINUE',
                  onPressed: () => _openResonanceChamber(context),
                ),
                const SizedBox(height: AppSpacing.s8),
                _TextAction(
                  label: 'SKIP FOR NOW',
                  onPressed: () => _openResonanceChamber(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Vignettes extends StatelessWidget {
  const _Vignettes();

  static const double _topHeight = 220;
  static const double _bottomHeight = 284;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _topHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.indigoBlue.withValues(alpha: 0.6),
                    AppColors.indigoBlue.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: _bottomHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.indigoBlue.withValues(alpha: 0),
                    AppColors.indigoBlue.withValues(alpha: 0.48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The mirror with its upload option and the optional note right under it.
class _PhotoChoice extends StatelessWidget {
  const _PhotoChoice({required this.onUpload});

  static const double _hintWidth = 270;

  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _hintWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhotoMirror(onPressed: () {}),
          const SizedBox(height: AppSpacing.s8),
          _TextAction(label: 'UPLOAD A PHOTO', onPressed: onUpload),
          Text(
            '(Optional)',
            textAlign: TextAlign.center,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.champagneGold,
              fontSize: AppFontSizes.s16,
              height: 1.25,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            'This helps you track your progress and personalize '
            'your ritual even more.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: AppColors.white,
              fontSize: AppFontSizes.s11,
              height: 1.7,
              letterSpacing: 0.55,
              shadows: _bodyGlow,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.champagneGold,
          minimumSize: const Size.fromHeight(AppSpacing.s40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.r8),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.subheadline.copyWith(
            color: AppColors.champagneGold,
            fontSize: AppFontSizes.s11,
            letterSpacing: 1.65,
          ),
        ),
      ),
    );
  }
}
