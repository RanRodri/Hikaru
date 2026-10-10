import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/router/app_routes.dart';

const List<Shadow> _titleShadow = [
  Shadow(
    color: Color.fromRGBO(0, 0, 0, 0.8),
    offset: Offset(0, 1),
    blurRadius: 8,
  ),
];

const List<Shadow> _bodyShadow = [
  Shadow(
    color: Color.fromRGBO(0, 0, 0, 0.5),
    offset: Offset(0, 2),
    blurRadius: 10,
  ),
];

class ListeningRoomScreen extends StatelessWidget {
  const ListeningRoomScreen({super.key});

  static const String _backgroundAsset = 'assets/images/listening_room.png';
  static const String _glowAsset = 'assets/images/listening_room_glow.svg';
  static const double _titleTop = 110;
  static const double _footerBottom = 50;
  static const double _minInsetGap = 16;

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
            padding: EdgeInsets.fromLTRB(40, topSpace, 40, bottomSpace),
            child: Column(
              children: [
                Text(
                  'The\nListening Room',
                  textAlign: TextAlign.center,
                  style: AppTypography.title.copyWith(
                    color: AppColors.white,
                    fontSize: 38,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A  SPACE  TO  BE  HEARD',
                  textAlign: TextAlign.center,
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(width: 50, height: 1, color: AppColors.champagneGold),
                const SizedBox(height: 12),
                Text(
                  "Share what's on your mind\n"
                  'so we can guide you with a\n'
                  'personalized ritual for your skin,\n'
                  'your body, and your energy.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.7,
                    letterSpacing: 0.65,
                    shadows: _bodyShadow,
                  ),
                ),
                const Spacer(),
                _BeginButton(
                  onPressed: () => context.push(AppRoutes.listeningRoomQuiz),
                ),
                const SizedBox(height: 20),
                Text(
                  'LISTEN   ·   ALIGN   ·   RECEIVE',
                  textAlign: TextAlign.center,
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.white,
                    fontSize: 9,
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

class _BeginButton extends StatelessWidget {
  const _BeginButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.champagneGold.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.champagneGold,
            foregroundColor: AppColors.darkIndigoBlue,
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          child: Text(
            'BEGIN',
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
