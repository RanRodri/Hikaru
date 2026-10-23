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

const List<Shadow> _bodyGlow = [
  Shadow(color: Color.fromRGBO(255, 250, 242, 0.65), blurRadius: 12),
];

class ListeningRoomScreen extends StatelessWidget {
  const ListeningRoomScreen({super.key});

  static const String _backgroundAsset = 'assets/images/listening_room.png';
  static const double _titleTop = 170;
  static const double _footerBottom = 50;
  static const double _minInsetGap = AppSpacing.s16;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final insets = MediaQuery.paddingOf(context);
    final topSpace = math.max(_titleTop, insets.top + _minInsetGap);
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
          ColoredBox(color: AppColors.darkIndigoBlue.withValues(alpha: 0.45)),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.darkIndigoBlue.withValues(alpha: 0),
                  AppColors.darkIndigoBlue.withValues(alpha: 0),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.078),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.2),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.302),
                ],
                stops: const [0, 0.6, 0.8, 0.92, 1],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s40,
              topSpace,
              AppSpacing.s40,
              bottomSpace,
            ),
            child: Column(
              children: [
                Text(
                  l10n.listeningRoomTitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.title.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: AppFontSizes.s38,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  l10n.listeningRoomTagline,
                  textAlign: TextAlign.center,
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                Container(width: 50, height: 1, color: AppColors.champagneGold),
                const SizedBox(height: AppSpacing.s24),
                Text(
                  l10n.listeningRoomDescription,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: AppFontSizes.s11,
                    height: 1.7,
                    letterSpacing: 0.55,
                    shadows: _bodyGlow,
                  ),
                ),
                const Spacer(),
                HikaruPillButton(
                  label: l10n.listeningRoomBegin,
                  onPressed: () => context.push(AppRoutes.listeningRoomQuiz),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
