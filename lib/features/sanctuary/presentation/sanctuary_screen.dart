import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_button.dart';
import '../../../core/router/app_routes.dart';

class SanctuaryScreen extends StatelessWidget {
  const SanctuaryScreen({super.key});

  static const String _heroAsset = 'assets/images/sanctuary_hero.png';
  static const String _dotAsset = 'assets/images/sanctuary_dot.svg';
  static const String _kanjiAsset = 'assets/images/sanctuary_kanji.svg';

  static const double _kanjiGapBelowStatusBar = 32;
  static const double _contentTopPadding = 16;
  static const double _contentHorizontalPadding = 24;
  static const double _contentBottomPadding = 48;
  static const double _gradientHeight = 440;

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.paddingOf(context).top;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final kanjiTop = safeTop + _kanjiGapBelowStatusBar;
    final bottomPadding = safeBottom > _contentBottomPadding
        ? safeBottom
        : _contentBottomPadding;

    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Image(
            image: AssetImage(_heroAsset),
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _gradientHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.darkIndigoBlue.withValues(alpha: 0),
                    AppColors.darkIndigoBlue.withValues(alpha: 0.75),
                    AppColors.darkIndigoBlue.withValues(alpha: 0.95),
                    AppColors.darkIndigoBlue,
                  ],
                  stops: const [0, 0.35, 0.7, 1],
                ),
              ),
            ),
          ),
          Positioned(
            top: kanjiTop,
            left: 0,
            right: 0,
            child: Center(
              child: SvgPicture.asset(_kanjiAsset, semanticsLabel: 'Hikaru'),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _contentHorizontalPadding,
                _contentTopPadding,
                _contentHorizontalPadding,
                bottomPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(_dotAsset),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to',
                    textAlign: TextAlign.center,
                    style: AppTypography.headline.copyWith(
                      color: AppColors.champagneGold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'HIKARU SANCTUARY',
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      style: AppTypography.title.copyWith(
                        color: AppColors.white,
                        height: 1.1,
                        letterSpacing: 0.64,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Where Beauty Meets Frequency.',
                    textAlign: TextAlign.center,
                    style: AppTypography.headline.copyWith(
                      color: AppColors.champagneGold,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 36),
                  HikaruButton(
                    label: 'ENTER THE SANCTUARY',
                    onPressed: () => context.push(AppRoutes.discovery),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
