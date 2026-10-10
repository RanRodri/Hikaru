import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../core/router/app_routes.dart';

const List<Shadow> _titleShadow = [
  Shadow(
    color: Color.fromRGBO(2, 3, 10, 0.8),
    offset: Offset(0, 2),
    blurRadius: 8,
  ),
];

const List<Shadow> _bodyShadow = [
  Shadow(
    color: Color.fromRGBO(0, 0, 0, 0.6),
    offset: Offset(0, 2),
    blurRadius: 12,
  ),
];

const List<Shadow> _footerShadow = [
  Shadow(
    color: Color.fromRGBO(0, 0, 0, 0.7),
    offset: Offset(0, 2),
    blurRadius: 8,
  ),
];

class RitualReadyScreen extends StatelessWidget {
  const RitualReadyScreen({super.key});

  static const String _backgroundAsset = 'assets/images/ritual_ready.png';
  static const double _titleTop = 148;
  static const double _titleTopRatio = 0.17;
  static const double _footerBottom = 50;
  static const double _minInsetGap = 16;
  static const double _messageWidth = 267;

  @override
  Widget build(BuildContext context) {
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
          const Image(
            image: AssetImage(_backgroundAsset),
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
            padding: EdgeInsets.fromLTRB(32, topSpace, 32, bottomSpace),
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
                            'Your\nRitual Is Ready',
                            textAlign: TextAlign.center,
                            style: AppTypography.title.copyWith(
                              color: AppColors.white,
                              fontSize: 38,
                              height: 1.05,
                              shadows: _titleShadow,
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: _messageWidth,
                            child: Text(
                              'Your personalized Hikaru Ritual has been '
                              'thoughtfully prepared, bringing together the '
                              'techniques, crystal, frequencies, and intention '
                              'that best support your skin and your energy today.',
                              textAlign: TextAlign.center,
                              style: AppTypography.headline.copyWith(
                                color: AppColors.white,
                                fontSize: 13,
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
                  label: 'ENTER YOUR RITUAL',
                  onPressed: () => context.push(AppRoutes.mirrorGarden),
                ),
                const SizedBox(height: 14),
                Text(
                  'A  MORE  RADIANT  YOU  AWAITS',
                  textAlign: TextAlign.center,
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.white,
                    letterSpacing: 1.2,
                    shadows: _footerShadow,
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
