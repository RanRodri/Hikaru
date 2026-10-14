import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../core/router/app_routes.dart';

const List<Shadow> _titleShadow = [
  Shadow(color: AppColors.scrim80, offset: Offset(0, 1), blurRadius: 8),
];

const List<Shadow> _bodyShadow = [
  Shadow(color: AppColors.scrim50, offset: Offset(0, 2), blurRadius: 10),
];

class ListeningRoomScreen extends StatelessWidget {
  const ListeningRoomScreen({super.key});

  static const String _backgroundAsset = 'assets/images/listening_room.png';
  static const String _glowAsset = 'assets/images/listening_room_glow.svg';
  static const double _titleTop = AppSpacing.s110;
  static const double _footerBottom = 50;
  static const double _minInsetGap = AppSpacing.s16;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    final topSpace = math.max(_titleTop, insets.top + _minInsetGap);
    final bottomSpace = math.max(_footerBottom, insets.bottom + _minInsetGap);

    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Image(
            image: AssetImage(_backgroundAsset),
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(child: SvgPicture.asset(_glowAsset)),
            ),
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
                  'The\nListening Room',
                  textAlign: TextAlign.center,
                  style: AppTypography.title.copyWith(
                    color: AppColors.white,
                    fontSize: AppFontSizes.s38,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  'A  SPACE  TO  BE  HEARD',
                  textAlign: TextAlign.center,
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Container(width: 50, height: 1, color: AppColors.champagneGold),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  "Share what's on your mind\n"
                  'so we can guide you with a\n'
                  'personalized ritual for your skin,\n'
                  'your body, and your energy.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.white,
                    fontSize: AppFontSizes.s13,
                    fontWeight: FontWeight.w500,
                    height: 1.7,
                    letterSpacing: 0.65,
                    shadows: _bodyShadow,
                  ),
                ),
                const Spacer(),
                HikaruPillButton(
                  label: 'BEGIN',
                  onPressed: () => context.push(AppRoutes.listeningRoomQuiz),
                ),
                const SizedBox(height: AppSpacing.s20),
                Text(
                  'LISTEN   ·   ALIGN   ·   RECEIVE',
                  textAlign: TextAlign.center,
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.white,
                    fontSize: AppFontSizes.s9,
                    letterSpacing: 1.8,
                    shadows: _titleShadow,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
