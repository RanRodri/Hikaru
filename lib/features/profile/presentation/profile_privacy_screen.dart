import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_journal.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_back_button.dart';
import '../../../core/media/remote_image.dart';
import '../../../l10n/app_localizations.dart';

/// Read-only summary of what Hikaru keeps. Editing the photo and name lives
/// in the account screen, so nothing is repeated here.
class ProfilePrivacyScreen extends StatelessWidget {
  const ProfilePrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final insets = MediaQuery.paddingOf(context);
    final items = [
      (
        Icons.face_retouching_natural,
        l10n.privacyPhotoTitle,
        l10n.privacyPhotoBody,
      ),
      (
        Icons.person_outline,
        l10n.privacyProfileTitle,
        l10n.privacyProfileBody,
      ),
      (
        Icons.auto_awesome,
        l10n.privacyJourneyTitle,
        l10n.privacyJourneyBody,
      ),
      (
        Icons.notifications_none,
        l10n.privacyRemindersTitle,
        l10n.privacyRemindersBody,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const RemoteImage(
            fileName: RemoteImages.sunsetGarden,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.darkIndigoBlue.withValues(alpha: 0.25),
                  AppColors.darkIndigoBlue.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s24,
                AppSpacing.s8,
                AppSpacing.s24,
                insets.bottom + AppSpacing.s24,
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: HikaruBackButton(onPressed: () => context.pop()),
                ),
                const SizedBox(height: AppSpacing.s24),
                Text(
                  l10n.privacyScreenTitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.headline.copyWith(
                    color: AppColors.white,
                    fontSize: AppFontSizes.s16,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  l10n.privacyScreenSubtitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.fog,
                    fontSize: AppFontSizes.s12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.s28),
                for (final (index, item) in items.indexed) ...[
                  if (index > 0) const SizedBox(height: AppSpacing.s12),
                  _PrivacyItem(icon: item.$1, title: item.$2, body: item.$3),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyItem extends StatelessWidget {
  const _PrivacyItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title. $body',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppJournal.surface,
          borderRadius: BorderRadius.circular(AppJournal.radius),
          border: Border.all(color: AppJournal.border, width: 0.9),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: AppColors.champagneGold),
            const SizedBox(width: AppSpacing.s14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.headline.copyWith(
                      color: AppColors.white,
                      fontSize: AppFontSizes.s14,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    body,
                    style: AppTypography.body.copyWith(
                      color: AppColors.fog,
                      fontSize: AppFontSizes.s12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
