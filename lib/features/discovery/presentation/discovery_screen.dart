import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_button.dart';
import '../../../core/design_system/widgets/hikaru_dividers.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';

class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({super.key});

  static const String _backgroundAsset = 'assets/images/discovery_room.png';

  /// The eyebrow sits at about a tenth of the screen height in the design, so
  /// it keeps its place on tall and short phones alike.
  static const double _topShare = 0.105;
  static const double _minContentTop = AppSpacing.s16;
  static const double _maxContentTop = 120;
  static const double _horizontalPadding = AppSpacing.s24;
  static const double _eyebrowGap = 11;
  static const double _titleGap = AppSpacing.s20;
  static const double _listGap = 56;
  static const double _buttonBottom = AppSpacing.s28;

  static List<_DiscoveryStepData> _steps(AppLocalizations l10n) => [
    _DiscoveryStepData(
      iconAsset: 'assets/images/discovery_icon_sun.svg',
      title: l10n.discoveryStepKnowYouTitle,
      body: l10n.discoveryStepKnowYouBody,
    ),
    _DiscoveryStepData(
      iconAsset: 'assets/images/discovery_icon_target.svg',
      title: l10n.discoveryStepSkinTitle,
      body: l10n.discoveryStepSkinBody,
    ),
    _DiscoveryStepData(
      iconAsset: 'assets/images/discovery_icon_diamond.svg',
      title: l10n.discoveryStepPrivacyTitle,
      body: l10n.discoveryStepPrivacyBody,
    ),
    _DiscoveryStepData(
      iconAsset: 'assets/images/discovery_icon_heart.svg',
      title: l10n.discoveryStepChoiceTitle,
      body: l10n.discoveryStepChoiceBody,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final contentTop = (size.height * _topShare - padding.top).clamp(
      _minContentTop,
      _maxContentTop,
    );
    final steps = _steps(l10n);

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
                  AppColors.darkIndigoBlue.withValues(alpha: 0.05),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.12),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.24),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.36),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.44),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.52),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.6),
                ],
                stops: const [0, 0.12, 0.3, 0.5, 0.68, 0.85, 1],
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
                          l10n.discoveryRoomEyebrow,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyAccent.copyWith(
                            color: AppColors.champagneGold,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: _eyebrowGap),
                        const HikaruGoldDivider(
                          width: 44,
                          height: AppSpacing.s1,
                        ),
                        const SizedBox(height: _titleGap),
                        Text(
                          l10n.discoveryHeadline,
                          textAlign: TextAlign.center,
                          style: AppTypography.title.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: _listGap),
                        for (final (index, step) in steps.indexed) ...[
                          if (index > 0) const _StepDivider(),
                          _DiscoveryStep(data: step),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    _horizontalPadding,
                    AppSpacing.s0,
                    _horizontalPadding,
                    padding.bottom + _buttonBottom,
                  ),
                  child: HikaruButton(
                    label: l10n.discoveryBegin,
                    onPressed: () => context.push(AppRoutes.ritual),
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

/// Faint rule between two steps.
class _StepDivider extends StatelessWidget {
  const _StepDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: HikaruGoldRule(width: double.infinity, height: 0.5, opacity: 0.25),
    );
  }
}

/// A discovery step: bare gold icon on the left, gold title and a short text
/// on the right.
class _DiscoveryStep extends StatelessWidget {
  const _DiscoveryStep({required this.data});

  static const double _iconSize = 24;
  static const double _iconColumn = 62;
  static const double _leadingInset = 36;
  static const double _trailingInset = 44;

  final _DiscoveryStepData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _leadingInset,
        AppSpacing.s15,
        _trailingInset,
        AppSpacing.s15,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: _iconColumn,
            child: Align(
              alignment: Alignment.centerLeft,
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
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: AppTypography.bodyAccent.copyWith(
                    color: AppColors.champagneGold,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.s6),
                Text(
                  data.body,
                  style: AppTypography.body.copyWith(
                    color: AppColors.fog,
                    fontSize: AppFontSizes.s10_5,
                    height: 1.55,
                    letterSpacing: 0.2,
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
