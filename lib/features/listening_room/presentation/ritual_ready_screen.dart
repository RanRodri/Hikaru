import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../core/media/remote_image.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';

const List<Shadow> _titleShadow = [
  Shadow(color: AppColors.ink80, offset: Offset(0, 2), blurRadius: 8),
];

const List<Shadow> _bodyShadow = [
  Shadow(color: AppColors.scrim60, offset: Offset(0, 2), blurRadius: 12),
];

class RitualReadyScreen extends StatelessWidget {
  const RitualReadyScreen({super.key});

  static const String _backgroundAsset = RemoteImages.ritualReady;
  static const double _titleTop = 148;
  static const double _titleTopRatio = 0.17;
  static const double _footerBottom = 50;
  static const double _minInsetGap = AppSpacing.s16;
  static const double _messageWidth = 267;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final insets = MediaQuery.paddingOf(context);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final topSpace = math.max(
      math.min(_titleTop, screenHeight * _titleTopRatio),
      insets.top + _minInsetGap,
    );
    final bottomSpace = math.max(_footerBottom, insets.bottom + _minInsetGap);

    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const RemoteImage(
            fileName: _backgroundAsset,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.black.withValues(alpha: 0),
                  AppColors.black.withValues(alpha: 0.4),
                  AppColors.black.withValues(alpha: 0.6),
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s32,
              topSpace,
              AppSpacing.s32,
              bottomSpace,
            ),
            child: Column(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.ritualReadyTitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.title.copyWith(
                              color: AppColors.white,
                              fontSize: AppFontSizes.s38,
                              height: 1.05,
                              shadows: _titleShadow,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s18),
                          SizedBox(
                            width: _messageWidth,
                            child: Text(
                              l10n.ritualReadyBody,
                              textAlign: TextAlign.center,
                              style: AppTypography.headline.copyWith(
                                color: AppColors.white,
                                fontSize: AppFontSizes.s13,
                                height: 1.6,
                                letterSpacing: 0.65,
                                shadows: _bodyShadow,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                HikaruPillButton(
                  label: l10n.ritualReadyEnter,
                  onPressed: () => context.push(AppRoutes.mirrorGarden),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
