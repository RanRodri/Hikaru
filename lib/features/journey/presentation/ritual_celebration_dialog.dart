import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_pill_button.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../library/domain/library_article.dart';
import '../application/ritual_cycle_controller.dart';
import '../domain/ritual_cycle.dart';
import 'ritual_history_screen.dart';
import 'ritual_step_texts.dart';

/// What the member chose besides closing the celebration.
enum _CelebrationAction { history, library }

/// Marks [step] with [mark] and congratulates the member.
///
/// Completing the last step of the day shows the day celebration (day of
/// the cycle and streak). Otherwise, unless [onlyWhenDayCompletes] is set,
/// it congratulates the step and names the next one waiting today.
/// Merkaba and the cymatic have their own closing screens, so they only use
/// the day celebration.
Future<void> markAndCelebrate(
  BuildContext context,
  WidgetRef ref, {
  required RitualStep step,
  required Future<void> Function() mark,
  bool onlyWhenDayCompletes = false,
}) async {
  final before = ref.read(todayRitualProvider);
  try {
    await mark();
  } catch (_) {
    // The step stays on the device for the next sync; no celebration yet.
    return;
  }
  if (!context.mounted) return;
  await celebrateStep(
    context,
    ref,
    step: step,
    before: before,
    onlyWhenDayCompletes: onlyWhenDayCompletes,
  );
}

/// Same celebration as [markAndCelebrate] for a step already marked;
/// [before] is today's ritual as it was before marking.
Future<void> celebrateStep(
  BuildContext context,
  WidgetRef ref, {
  required RitualStep step,
  required DailyRitualFlags before,
  bool onlyWhenDayCompletes = false,
}) async {
  final after = ref.read(todayRitualProvider);
  final dayCompleted = !before.completed && after.completed;
  if (!dayCompleted && onlyWhenDayCompletes) return;
  final progress = ref.read(journeyProgressProvider);
  final action = await showDialog<_CelebrationAction>(
    context: context,
    barrierColor: AppColors.scrim70,
    builder: (context) => _RitualCelebrationDialog(
      step: step,
      dayCompleted: dayCompleted,
      day: progress.currentDay,
      cycleLength: progress.cycleLength,
      streak: progress.streak,
      next: after.pending.isEmpty ? null : after.pending.first,
    ),
  );
  if (!context.mounted) return;
  switch (action) {
    case _CelebrationAction.history:
      openRitualHistory(context);
    case _CelebrationAction.library:
      // `go`, not `push`: the Library lives in its own tab, and this can be
      // called from screens outside the tab shell.
      context.go(
        _libraryRouteFor(step, ref.read(selectedCrystalProvider).value?.name),
      );
    case null:
      break;
  }
}

/// The Library guide that matches [step]; the member's crystal for the
/// crystal step, or the Library itself when no crystal is chosen yet.
String _libraryRouteFor(RitualStep step, String? crystalId) => switch (step) {
  RitualStep.merkaba => AppRoutes.libraryTopicFor(libraryMerkabaId),
  RitualStep.facial ||
  RitualStep.body => AppRoutes.libraryTopicFor(libraryRitualsId),
  RitualStep.crystal =>
    crystalId == null
        ? AppRoutes.library
        : AppRoutes.libraryTopicFor(crystalId),
};

class _RitualCelebrationDialog extends StatelessWidget {
  const _RitualCelebrationDialog({
    required this.step,
    required this.dayCompleted,
    required this.day,
    required this.cycleLength,
    required this.streak,
    required this.next,
  });

  final RitualStep step;
  final bool dayCompleted;
  final int day;
  final int cycleLength;
  final int streak;
  final RitualStep? next;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final upcoming = next;
    final title = dayCompleted
        ? l10n.celebrationDayTitle
        : l10n.celebrationStepTitle;
    final body = dayCompleted
        ? l10n.celebrationDayBody(day, cycleLength)
        : l10n.celebrationStepBody(step.label(l10n));
    final libraryTitle = switch (step) {
      RitualStep.merkaba => l10n.celebrationLibraryMerkaba,
      RitualStep.facial => l10n.celebrationLibraryFacial,
      RitualStep.body => l10n.celebrationLibraryBody,
      RitualStep.crystal => l10n.celebrationLibraryCrystal,
    };

    return Dialog(
      backgroundColor: AppColors.darkIndigoBlue,
      surfaceTintColor: AppColors.darkIndigoBlue,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.r28),
        side: BorderSide(
          color: AppColors.champagneGold.withValues(alpha: 0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s24,
          AppSpacing.s32,
          AppSpacing.s24,
          AppSpacing.s12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.champagneGold.withValues(alpha: 0.12),
                border: Border.all(color: AppColors.champagneGold),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldGlow.withValues(alpha: 0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: dayCompleted
                  ? const Icon(
                      Icons.auto_awesome,
                      size: 34,
                      color: AppColors.champagneGold,
                    )
                  : RitualStepIcon(step: step, size: 36),
            ),
            const SizedBox(height: AppSpacing.s20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.subtitle.copyWith(
                color: AppColors.white,
                fontSize: AppFontSizes.s22,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.s10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.fog,
                fontSize: AppFontSizes.s14,
                height: 1.45,
              ),
            ),
            if (dayCompleted && streak > 0) ...[
              const SizedBox(height: AppSpacing.s12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_fire_department_outlined,
                    size: 18,
                    color: AppColors.champagneGold,
                  ),
                  const SizedBox(width: AppSpacing.s6),
                  Text(
                    l10n.homeProgressStreak(streak),
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.champagneGold,
                      fontSize: AppFontSizes.s13,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ],
            if (!dayCompleted && upcoming != null) ...[
              const SizedBox(height: AppSpacing.s12),
              Text(
                l10n.celebrationNextStep(upcoming.label(l10n)),
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.champagneGold,
                  fontSize: AppFontSizes.s13,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.s20),
            _LibraryPromo(
              eyebrow: l10n.celebrationLibraryEyebrow,
              title: libraryTitle,
              onPressed: () =>
                  Navigator.of(context).pop(_CelebrationAction.library),
            ),
            const SizedBox(height: AppSpacing.s20),
            HikaruPillButton(
              label: l10n.celebrationContinue,
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (dayCompleted)
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(_CelebrationAction.history),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.champagneGold,
                  minimumSize: const Size(44, 44),
                ),
                child: Text(
                  l10n.homeProgressSeeHistory,
                  style: AppTypography.body.copyWith(
                    color: AppColors.fog,
                    fontSize: AppFontSizes.s13,
                  ),
                ),
              )
            else
              const SizedBox(height: AppSpacing.s12),
          ],
        ),
      ),
    );
  }
}

/// Suggestion card that points to the Library guide for the step just done.
class _LibraryPromo extends StatelessWidget {
  const _LibraryPromo({
    required this.eyebrow,
    required this.title,
    required this.onPressed,
  });

  final String eyebrow;
  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$eyebrow. $title',
      excludeSemantics: true,
      child: Material(
        color: AppColors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.r16),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.champagneGold.withValues(alpha: 0.16),
                AppColors.indigoBlue.withValues(alpha: 0.7),
              ],
            ),
            border: Border.all(
              color: AppColors.champagneGold.withValues(alpha: 0.45),
              width: 0.9,
            ),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadii.r16),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s14,
                vertical: AppSpacing.s12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.champagneGold.withValues(alpha: 0.12),
                      border: Border.all(
                        color: AppColors.champagneGold.withValues(alpha: 0.7),
                        width: 0.9,
                      ),
                    ),
                    child: const Icon(
                      Icons.menu_book_outlined,
                      size: 20,
                      color: AppColors.champagneGold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eyebrow,
                          style: AppTypography.subheadline.copyWith(
                            color: AppColors.champagneGold,
                            fontSize: AppFontSizes.s9,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          title,
                          style: AppTypography.headline.copyWith(
                            color: AppColors.white,
                            fontSize: AppFontSizes.s13,
                            height: 1.3,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.champagneGold,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
