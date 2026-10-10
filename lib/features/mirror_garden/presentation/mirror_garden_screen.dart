import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/router/app_routes.dart';
import 'photo_mirror.dart';

const List<Shadow> _titleShadow = [
  Shadow(
    color: Color.fromRGBO(2, 3, 10, 0.8),
    offset: Offset(0, 2),
    blurRadius: 8,
  ),
];

const List<Shadow> _bodyGlow = [
  Shadow(color: Color.fromRGBO(255, 250, 242, 0.65), blurRadius: 12),
];

class MirrorGardenScreen extends StatelessWidget {
  const MirrorGardenScreen({super.key});

  static const String _backgroundAsset = 'assets/images/mirror_garden.png';
  static const double _headerTop = 72;
  static const double _bottomGap = 36;
  static const double _minInsetGap = 16;
  static const double _horizontalPadding = 32;
  static const double _hintWidth = 270;

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
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                _horizontalPadding,
                topSpace,
                _horizontalPadding,
                bottomSpace,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: math.max(
                    0.0,
                    constraints.maxHeight - topSpace - bottomSpace,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Opacity(
                          opacity: 0.85,
                          child: Text(
                            'THE MIRROR GARDEN',
                            textAlign: TextAlign.center,
                            style: AppTypography.headline.copyWith(
                              color: AppColors.champagneGold,
                              fontSize: 10,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Add A Photo Of Your Face For Personal Tracking',
                          textAlign: TextAlign.center,
                          style: AppTypography.title.copyWith(
                            color: AppColors.white,
                            fontSize: 30,
                            height: 1.15,
                            shadows: _titleShadow,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const SizedBox(height: 24),
                        PhotoMirror(onPressed: () {}),
                        _TextAction(label: 'UPLOAD A PHOTO', onPressed: () {}),
                        const SizedBox(height: 4),
                        Text(
                          '(Optional)',
                          textAlign: TextAlign.center,
                          style: AppTypography.subheadline.copyWith(
                            color: AppColors.champagneGold,
                            fontSize: 16,
                            height: 1.25,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: _hintWidth,
                          child: Text(
                            'This helps you track your progress and personalize '
                            'your ritual even more.',
                            textAlign: TextAlign.center,
                            style: AppTypography.body.copyWith(
                              color: AppColors.white,
                              fontSize: 11,
                              height: 1.7,
                              letterSpacing: 0.55,
                              shadows: _bodyGlow,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _TextAction(
                          label: 'SKIP FOR NOW',
                          onPressed: () => _openResonanceChamber(context),
                        ),
                        const SizedBox(height: 4),
                        _ContinueButton(
                          onPressed: () => _openResonanceChamber(context),
                        ),
                      ],
                    ),
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
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: AppTypography.subheadline.copyWith(
            color: AppColors.champagneGold,
            fontSize: 11,
            letterSpacing: 1.65,
          ),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.onPressed});

  static const double _height = 56;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_height / 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.champagneGold.withValues(alpha: 0.35),
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
            'CONTINUE',
            style: AppTypography.subheadline.copyWith(
              color: AppColors.darkIndigoBlue,
              fontSize: 11,
              letterSpacing: 1.65,
            ),
          ),
        ),
      ),
    );
  }
}
