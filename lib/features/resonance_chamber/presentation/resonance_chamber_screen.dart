import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../core/router/app_routes.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../listening_room/application/journey_recommendation_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../crystals/presentation/crystal_texts.dart';
import '../../listening_room/domain/journey_recommendation.dart';
import 'crystal_scene_photo.dart';
import 'resonance_sections.dart';

/// Post-quiz revelation: crystal + personalized protocol.
///
/// No frequency audio or cymatics play on this screen.
class ResonanceChamberScreen extends ConsumerWidget {
  const ResonanceChamberScreen({super.key});

  static const double _horizontalPadding = 24;
  static const double _heroScreenRatio = 0.4;
  static const double _minHeroHeight = 250;
  static const double _maxHeroHeight = 380;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final insets = mediaQuery.padding;
    final heroHeight = (mediaQuery.size.height * _heroScreenRatio).clamp(
      _minHeroHeight,
      _maxHeroHeight,
    );
    final recommendation = _resolveRecommendation(ref);

    return Scaffold(
      backgroundColor: resonanceChamberColor,
      body: Column(
        children: [
          SizedBox(height: insets.top + AppSpacing.s16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: _RevealTitle(),
          ),
          const SizedBox(height: AppSpacing.s12),
          SizedBox(
            width: double.infinity,
            height: heroHeight,
            child: CrystalScenePhoto(crystal: recommendation?.crystal),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                _horizontalPadding,
                AppSpacing.s20,
                _horizontalPadding,
                math.max(AppSpacing.s16, insets.bottom + AppSpacing.s8),
              ),
              child: Column(
                children: [
                  if (recommendation != null)
                    _CrystalReveal(recommendation: recommendation)
                  else
                    const _MissingCrystal(),
                  if (recommendation != null) ...[
                    const SizedBox(height: AppSpacing.s24),
                    Text(
                      l10n.resonanceRecommendedProtocol,
                      textAlign: TextAlign.center,
                      style: AppTypography.headline.copyWith(
                        color: AppColors.white,
                        fontSize: AppFontSizes.s10,
                        letterSpacing: 2.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    _ProtocolDetails(recommendation: recommendation),
                  ],
                  const SizedBox(height: AppSpacing.s24),
                  HikaruPillButton(
                    label: l10n.resonanceEnterSanctuary,
                    onPressed: () => context.go(AppRoutes.home),
                    buttonHeight: AppSpacing.s56,
                    blurRadius: 8,
                    shadowAlpha: 0.25,
                    borderAlpha: 0.3,
                    labelStyle: AppTypography.journeyLabel,
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

JourneyRecommendation? _resolveRecommendation(WidgetRef ref) {
  final saved = ref.watch(journeyRecommendationControllerProvider).value;
  if (saved != null) return saved;

  final crystal = ref.watch(selectedCrystalProvider).value;
  if (crystal == null) return null;
  return fallbackRecommendation(crystal);
}

class _RevealTitle extends StatelessWidget {
  const _RevealTitle();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Text(
          l10n.resonanceRevealTitle,
          textAlign: TextAlign.center,
          style: AppTypography.headline.copyWith(
            color: AppColors.white,
            fontSize: AppFontSizes.s22,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(
          l10n.resonanceRevealSubtitle,
          textAlign: TextAlign.center,
          style: AppTypography.headline.copyWith(
            color: AppColors.white,
            fontSize: AppFontSizes.s13,
            height: 1.5,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _MissingCrystal extends StatelessWidget {
  const _MissingCrystal();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context).resonanceMissingCrystal,
      textAlign: TextAlign.center,
      style: AppTypography.headline.copyWith(
        color: AppColors.fog,
        fontSize: AppFontSizes.s12,
        height: 1.5,
        letterSpacing: 0,
      ),
    );
  }
}

class _CrystalReveal extends StatelessWidget {
  const _CrystalReveal({required this.recommendation});

  final JourneyRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final crystal = recommendation.crystal;

    return Column(
      children: [
        Text(
          l10n.resonanceYourCrystal(crystal.localizedName(l10n)),
          textAlign: TextAlign.center,
          style: AppTypography.headline.copyWith(
            color: AppColors.fog,
            fontSize: AppFontSizes.s13,
            height: 1.45,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(
          crystal.localizedName(l10n),
          textAlign: TextAlign.center,
          semanticsLabel: l10n.resonanceAssignedCrystalSemantics(
            crystal.localizedName(l10n),
          ),
          style: AppTypography.title.copyWith(
            color: AppColors.champagneGold,
            fontSize: AppFontSizes.s28,
            letterSpacing: 2.4,
            height: 1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(
          crystal.localizedSymbolicTitle(l10n),
          textAlign: TextAlign.center,
          style: AppTypography.headline.copyWith(
            color: AppColors.white,
            fontSize: AppFontSizes.s14,
            letterSpacing: 0.4,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        Text(
          '"${crystal.localizedRevelation(l10n)}"',
          textAlign: TextAlign.center,
          style: AppTypography.headline.copyWith(
            color: AppColors.white,
            fontSize: AppFontSizes.s12,
            height: 1.55,
            letterSpacing: 0.2,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _ProtocolDetails extends StatelessWidget {
  const _ProtocolDetails({required this.recommendation});

  final JourneyRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = [
      (
        l10n.resonanceProtocolCrystal,
        _titleCase(recommendation.crystal.localizedName(l10n)),
      ),
      (
        l10n.resonanceProtocolIntention,
        l10n.recommendationIntention(recommendation.intention),
      ),
      (
        l10n.resonanceProtocolSkinFocus,
        l10n.recommendationSkinFocus(recommendation.skinFocus),
      ),
      (
        l10n.resonanceProtocolFacialRitual,
        l10n.recommendationFacialRitual(recommendation.facialRitual),
      ),
      (
        l10n.resonanceProtocolDuration,
        l10n.recDuration(recommendation.durationMinutes),
      ),
      (
        l10n.resonanceProtocolTemple,
        recommendation.crystal.localizedTemple(l10n),
      ),
    ];

    const gap = AppSpacing.s16;
    return Column(
      children: [
        for (var index = 0; index < rows.length; index += 2) ...[
          if (index > 0) const SizedBox(height: gap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ProtocolCell(
                  label: rows[index].$1,
                  value: rows[index].$2,
                ),
              ),
              const SizedBox(width: gap),
              Expanded(
                child: _ProtocolCell(
                  label: rows[index + 1].$1,
                  value: rows[index + 1].$2,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ProtocolCell extends StatelessWidget {
  const _ProtocolCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.champagneGold,
              fontSize: AppFontSizes.s9,
              height: 1.3,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTypography.headline.copyWith(
              color: AppColors.white,
              fontSize: AppFontSizes.s13,
              height: 1.35,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

String _titleCase(String value) {
  if (value.isEmpty) return value;
  return value
      .toLowerCase()
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}
