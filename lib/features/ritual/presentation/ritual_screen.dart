import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_dividers.dart';
import '../../../core/design_system/widgets/hikaru_outline_button.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';

const List<Shadow> _textShadow = [
  Shadow(color: AppColors.scrim80, offset: Offset(0, 1), blurRadius: 8),
];

const List<Shadow> _softTextShadow = [
  Shadow(color: AppColors.scrim50, offset: Offset(0, 1), blurRadius: 8),
];

class RitualScreen extends StatelessWidget {
  const RitualScreen({super.key});

  static const String _backgroundAsset = 'assets/images/ritual_background.png';

  static const double _horizontalPadding = AppSpacing.s28;
  static const double _pathsHeight = 130;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final padding = MediaQuery.paddingOf(context);
    final topPadding = padding.top + 24;
    final bottomPadding = padding.bottom + 8;

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
                  AppColors.darkIndigoBlue.withValues(alpha: 0.35),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.5),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.42),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.2),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.05),
                  AppColors.darkIndigoBlue.withValues(alpha: 0),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.1),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.4),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.62),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.75),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.82),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.85),
                ],
                stops: const [
                  0,
                  0.12,
                  0.22,
                  0.32,
                  0.42,
                  0.5,
                  0.58,
                  0.66,
                  0.74,
                  0.82,
                  0.9,
                  1,
                ],
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      _horizontalPadding,
                      topPadding,
                      _horizontalPadding,
                      bottomPadding,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.s26),
                        Text(
                          l10n.ritualHeadline,
                          textAlign: TextAlign.center,
                          style: AppTypography.headline.copyWith(
                            color: AppColors.white,
                            fontSize: AppFontSizes.s25,
                            height: 1.3,
                            letterSpacing: 3.5,
                            shadows: _textShadow,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        Text(
                          l10n.ritualSubtitle,
                          textAlign: TextAlign.center,
                          style: AppTypography.headline.copyWith(
                            color: AppColors.fog,
                            fontSize: AppFontSizes.s12_5,
                            height: 1.45,
                            shadows: _textShadow,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        const HikaruGlyphStarDivider(lineWidth: AppSpacing.s64),
                        const SizedBox(height: AppSpacing.s10),
                        Text(
                          l10n.ritualChoosePath,
                          textAlign: TextAlign.center,
                          style: AppTypography.title.copyWith(
                            color: AppColors.white,
                            fontSize: AppFontSizes.s13,
                            letterSpacing: 3.3,
                            shadows: _softTextShadow,
                          ),
                        ),
                        const Expanded(child: SizedBox(height: AppSpacing.s32)),
                        Column(
                          children: [
                            _FrostedPaths(
                              child: SizedBox(
                                height: _pathsHeight,
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: _RitualPath(
                                        title: l10n.ritualPathNoHikaruTitle,
                                        actionLabel:
                                            l10n.ritualPathNoHikaruAction,
                                        onPressed: () {},
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.s16),
                                    Expanded(
                                      child: _RitualPath(
                                        title: l10n.ritualPathHaveHikaruTitle,
                                        actionLabel:
                                            l10n.ritualPathHaveHikaruAction,
                                        onPressed: () =>
                                            context.push(AppRoutes.login),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s4),
                            const HikaruGlyphStarDivider(
                              lineWidth: AppSpacing.s110,
                            ),
                            const SizedBox(height: AppSpacing.s6),
                            Text(
                              l10n.ritualFooter,
                              textAlign: TextAlign.center,
                              style: AppTypography.headline.copyWith(
                                color: AppColors.white.withValues(alpha: 0.9),
                                fontSize: AppFontSizes.s9,
                                height: 1.7,
                                letterSpacing: 2.2,
                                shadows: _textShadow,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark, blurred veil behind both paths. The mask fades the blur so it
/// dissolves into the photo instead of forming a hard panel.
class _FrostedPaths extends StatelessWidget {
  const _FrostedPaths({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _FadedBlur()),
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.s22,
            bottom: AppSpacing.s8,
          ),
          child: child,
        ),
      ],
    );
  }
}

class _FadedBlur extends StatelessWidget {
  const _FadedBlur();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.transparentWhite,
            AppColors.white,
            AppColors.white,
            AppColors.transparentWhite,
          ],
          stops: [0, 0.08, 0.92, 1],
        ).createShader(bounds);
      },
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.transparentWhite,
              AppColors.white,
              AppColors.white,
              AppColors.transparentWhite,
            ],
            stops: [0, 0.18, 0.82, 1],
          ).createShader(bounds);
        },
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: ColoredBox(
              color: AppColors.darkIndigoBlue.withValues(alpha: 0.55),
            ),
          ),
        ),
      ),
    );
  }
}

class _RitualPath extends StatelessWidget {
  const _RitualPath({
    required this.title,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.headline.copyWith(
            color: AppColors.white,
            fontSize: AppFontSizes.s12_5,
            height: 1.35,
            letterSpacing: 2,
            shadows: _textShadow,
          ),
        ),
        const SizedBox(height: AppSpacing.s28),
        HikaruOutlineButton(label: actionLabel, onPressed: onPressed),
      ],
    );
  }
}
