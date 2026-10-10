import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_button.dart';
import '../../../core/router/app_routes.dart';

class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({super.key});

  static const String _backgroundAsset = 'assets/images/discovery_room.png';

  static const double _contentTop = 48;
  static const double _minContentTop = 16;
  static const double _horizontalPadding = 24;
  static const double _sectionGap = 14;
  static const double _footerGap = 16;
  static const double _footerBottom = 28;
  static const double _footerMinGapAboveSystemBar = 8;
  static const double _buttonHeight = 62;

  static const List<_DiscoveryStepData> _steps = [
    _DiscoveryStepData(
      iconAsset: 'assets/images/discovery_icon_sun.svg',
      title: 'GETTING TO KNOW YOU',
      body: 'A few details to make your Hikaru experience uniquely yours.',
    ),
    _DiscoveryStepData(
      iconAsset: 'assets/images/discovery_icon_target.svg',
      title: 'YOUR SKIN JOURNEY',
      body: 'Optional photos to help you observe your progress over time.',
    ),
    _DiscoveryStepData(
      iconAsset: 'assets/images/discovery_icon_diamond.svg',
      title: 'YOUR PRIVACY',
      body: 'Your information is yours. Your trust is our priority.',
    ),
    _DiscoveryStepData(
      iconAsset: 'assets/images/discovery_icon_heart.svg',
      title: 'ALWAYS YOUR CHOICE',
      body: 'You decide what to share and how to personalize your experience.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final contentTop = (_contentTop - padding.top).clamp(
      _minContentTop,
      _contentTop,
    );
    final footerBottom =
        padding.bottom + _footerMinGapAboveSystemBar > _footerBottom
        ? padding.bottom + _footerMinGapAboveSystemBar
        : _footerBottom;

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
                  AppColors.darkIndigoBlue.withValues(alpha: 0.08),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.18),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.35),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.52),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.6),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.68),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.78),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.88),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.92),
                ],
                stops: const [0, 0.12, 0.28, 0.42, 0.55, 0.68, 0.8, 0.92, 1],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      _horizontalPadding,
                      contentTop,
                      _horizontalPadding,
                      _horizontalPadding,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'THE DISCOVERY ROOM',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyAccent.copyWith(
                            color: AppColors.champagneGold,
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: _sectionGap),
                        const _GoldDivider(),
                        const SizedBox(height: _sectionGap),
                        Text(
                          'Your Journey\nBegins With You',
                          textAlign: TextAlign.center,
                          style: AppTypography.title.copyWith(
                            color: AppColors.white,
                            fontSize: 34,
                            height: 1.15,
                          ),
                        ),
                        for (final step in _steps) ...[
                          const SizedBox(height: _sectionGap),
                          _DiscoveryStep(data: step),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    _horizontalPadding,
                    0,
                    _horizontalPadding,
                    footerBottom,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: _buttonHeight,
                        child: HikaruButton(
                          label: 'BEGIN MY DISCOVERY',
                          onPressed: () => context.push(AppRoutes.ritual),
                        ),
                      ),
                      const SizedBox(height: _footerGap),
                      const _GoldDivider(),
                      const SizedBox(height: _footerGap),
                      Text(
                        'BEAUTY MEETS FREQUENCY',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyAccent.copyWith(
                          color: AppColors.champagneGold,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ],
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

class _GoldDivider extends StatelessWidget {
  const _GoldDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 30, height: 2, color: AppColors.champagneGold);
  }
}

class _DiscoveryStepData {
  const _DiscoveryStepData({
    required this.iconAsset,
    required this.title,
    required this.body,
  });

  final String iconAsset;
  final String title;
  final String body;
}

class _DiscoveryStep extends StatelessWidget {
  const _DiscoveryStep({required this.data});

  static const double _iconCircleSize = 52;
  static const double _iconSize = 28;

  final _DiscoveryStepData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: _iconCircleSize,
            height: _iconCircleSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.champagneGold.withValues(alpha: 0.1),
            ),
            child: SvgPicture.asset(
              data.iconAsset,
              width: _iconSize,
              height: _iconSize,
              excludeFromSemantics: true,
              colorFilter: const ColorFilter.mode(
                AppColors.champagneGold,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: AppTypography.bodyAccent.copyWith(
                    color: AppColors.champagneGold,
                    fontSize: 12,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.body,
                  style: AppTypography.body.copyWith(
                    color: AppColors.fog,
                    fontSize: 14,
                    height: 1.5,
                    letterSpacing: 0.28,
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
