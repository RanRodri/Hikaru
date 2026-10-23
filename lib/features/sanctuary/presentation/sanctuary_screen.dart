import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_button.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';

class SanctuaryScreen extends StatelessWidget {
  const SanctuaryScreen({super.key});

  static const String _heroAsset = 'assets/images/sanctuary_hero.png';
  static const String _dotAsset = 'assets/images/sanctuary_dot.svg';
  static const String _kanjiAsset = 'assets/images/sanctuary_kanji.svg';

  static const double _kanjiGapBelowStatusBar = AppSpacing.s32;
  static const double _contentTopPadding = AppSpacing.s16;
  static const double _contentHorizontalPadding = AppSpacing.s24;
  static const double _contentBottomPadding = 48;
  static const double _gradientHeight = 440;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                  const SizedBox(height: AppSpacing.s20),
                  Text(
                    l10n.sanctuaryWelcome,
                    textAlign: TextAlign.center,
                    style: AppTypography.headline.copyWith(
                      color: AppColors.champagneGold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l10n.sanctuaryTitle,
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
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    l10n.sanctuaryTagline,
                    textAlign: TextAlign.center,
                    style: AppTypography.headline.copyWith(
                      color: AppColors.champagneGold,
                      fontSize: AppFontSizes.s16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s36),
                  HikaruButton(
                    label: l10n.sanctuaryEnter,
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
