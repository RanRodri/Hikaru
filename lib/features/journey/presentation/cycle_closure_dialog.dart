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
import '../../listening_room/data/quiz_answers_repository.dart';
import '../../listening_room/domain/quiz_answers.dart';
import '../application/ritual_cycle_controller.dart';
import '../domain/ritual_cycle.dart';

enum _ClosureChoice { repeatTest, chooseCrystal }

/// After the 30 days: thanks the member, shows how many days were complete,
/// and lets them repeat the test or pick a new crystal for the next cycle.
/// "Decide later" leaves the cycle as it is, so the offer comes back.
Future<void> showCycleClosureDialog(BuildContext context, WidgetRef ref) async {
  final history = await ref.read(cycleHistoryProvider.future);
  if (!context.mounted) return;
  final completedDays = history.completedDays;
  final choice = await showDialog<_ClosureChoice>(
    context: context,
    barrierColor: AppColors.scrim70,
    builder: (context) => _CycleClosureDialog(completedDays: completedDays),
  );
  if (choice == null || !context.mounted) return;

  await ref
      .read(ritualCycleControllerProvider.notifier)
      .closeCycle(completedDays: completedDays);
  if (!context.mounted) return;

  switch (choice) {
    case _ClosureChoice.repeatTest:
      // Start the questions over instead of resuming the old answers.
      final quiz = ref.read(quizAnswersRepositoryProvider);
      await quiz.save(const QuizAnswers());
      await quiz.clearStep();
      if (!context.mounted) return;
      context.push(AppRoutes.listeningRoomQuiz);
    case _ClosureChoice.chooseCrystal:
      context.push(AppRoutes.fourTemples);
  }
}

class _CycleClosureDialog extends StatelessWidget {
  const _CycleClosureDialog({required this.completedDays});

  final int completedDays;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.champagneGold.withValues(alpha: 0.12),
                border: Border.all(color: AppColors.champagneGold),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldGlow.withValues(alpha: 0.35),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 32,
                color: AppColors.champagneGold,
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            Text(
              l10n.cycleEndTitle,
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
              l10n.cycleEndSummary(completedDays, ritualCycleLength),
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.fog,
                fontSize: AppFontSizes.s14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            HikaruPillButton(
              label: l10n.cycleEndRepeatTest,
              onPressed: () =>
                  Navigator.of(context).pop(_ClosureChoice.repeatTest),
            ),
            const SizedBox(height: AppSpacing.s12),
            SizedBox(
              width: double.infinity,
              height: HikaruPillButton.height,
              child: OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).pop(_ClosureChoice.chooseCrystal),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.champagneGold),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  l10n.cycleEndChooseCrystal,
                  style: AppTypography.pillLabel.copyWith(
                    color: AppColors.champagneGold,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.champagneGold,
                minimumSize: const Size(44, 44),
              ),
              child: Text(
                l10n.cycleEndLater,
                style: AppTypography.body.copyWith(
                  color: AppColors.fog,
                  fontSize: AppFontSizes.s13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
