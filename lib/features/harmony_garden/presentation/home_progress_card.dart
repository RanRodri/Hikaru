import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../journey/application/ritual_cycle_controller.dart';
import '../../journey/domain/ritual_cycle.dart';
import '../../journey/presentation/ritual_history_screen.dart';
import '../../journey/presentation/ritual_step_texts.dart';

/// A compact glass dashboard above the navigation bar. It keeps all four
/// daily steps in one stable row, animates progress changes once, and only
/// reports yesterday as missed when a complete backend snapshot is known.
class HomeProgressCard extends ConsumerWidget {
  const HomeProgressCard({
    super.key,
    required this.scale,
    this.compact = false,
  });

  final double scale;
  final bool compact;

  void _openStep(BuildContext context, WidgetRef ref, RitualStep step) {
    switch (step) {
      case RitualStep.merkaba:
        context.push(AppRoutes.merkaba);
      case RitualStep.facial:
        context.push(AppRoutes.ritualFace);
      case RitualStep.body:
        context.push(AppRoutes.ritualBody);
      case RitualStep.crystal:
        final crystal = ref.read(selectedCrystalProvider).value;
        context.push(
          crystal == null
              ? AppRoutes.fourTemples
              : AppRoutes.crystalResonanceFor(crystal.name),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final progress = ref.watch(journeyProgressProvider);
    final today = ref.watch(todayRitualProvider);
    final history = ref.watch(cycleHistoryProvider).value;
    final day = progress.currentDay;
    final completedCount = RitualStep.values.where(today.isDone).length;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final stateKey = ValueKey('$day-${_mask(today)}');
    final dayCompleted = today.completed;

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.r20 * scale),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.indigoBlue.withValues(alpha: 0.88),
                AppColors.darkIndigoBlue.withValues(alpha: 0.74),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadii.r20 * scale),
            border: Border.all(
              color: AppColors.champagneGold.withValues(
                alpha: dayCompleted ? 0.9 : 0.52,
              ),
              width: dayCompleted ? 1 : 0.8,
            ),
            boxShadow: [
              const BoxShadow(
                color: AppColors.navShadow,
                blurRadius: 18,
                offset: Offset(0, 7),
              ),
              if (dayCompleted)
                BoxShadow(
                  color: AppColors.goldGlow.withValues(alpha: 0.28),
                  blurRadius: 16,
                ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s12 * scale,
              (compact ? AppSpacing.s8 : AppSpacing.s10) * scale,
              AppSpacing.s12 * scale,
              AppSpacing.s8 * scale,
            ),
            child: AnimatedSwitcher(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Column(
                key: stateKey,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ProgressHeader(
                    scale: scale,
                    day: day,
                    total: progress.cycleLength,
                    completed: completedCount,
                  ),
                  SizedBox(height: AppSpacing.s6 * scale),
                  if (dayCompleted)
                    _DayCompleteMessage(
                      scale: scale,
                      day: day,
                      total: progress.cycleLength,
                    )
                  else
                    Row(
                      children: [
                        for (final step in RitualStep.values)
                          Expanded(
                            child: _StepStatus(
                              step: step,
                              done: today.isDone(step),
                              scale: scale,
                              onPressed: today.isDone(step)
                                  ? null
                                  : () => _openStep(context, ref, step),
                            ),
                          ),
                      ],
                    ),
                  SizedBox(height: AppSpacing.s4 * scale),
                  _ProgressFooter(
                    scale: scale,
                    day: day,
                    streak: progress.streak,
                    // With today complete, today's streak matters more than
                    // yesterday's summary.
                    history: dayCompleted ? null : history,
                    onHistory: () => openRitualHistory(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (!dayCompleted) return card;
    // A single golden sweep the moment the day is complete.
    return Stack(
      children: [
        card,
        Positioned.fill(
          child: _CompletionSheen(
            key: ValueKey('sheen-$day'),
            radius: AppRadii.r20 * scale,
          ),
        ),
      ],
    );
  }

  static int _mask(DailyRitualFlags flags) {
    var mask = 0;
    for (final step in RitualStep.values) {
      if (flags.isDone(step)) mask |= 1 << step.index;
    }
    return mask;
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.scale,
    required this.day,
    required this.total,
    required this.completed,
  });

  final double scale;
  final int day;
  final int total;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Text(
          l10n.homeProgressDay(day, total).toUpperCase(),
          style: AppTypography.headline.copyWith(
            color: AppColors.white,
            fontSize: AppFontSizes.s12 * scale,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8 * scale,
          ),
        ),
        const Spacer(),
        Text(
          l10n.homeProgressTodayCount(completed),
          style: AppTypography.subheadline.copyWith(
            color: completed == RitualStep.values.length
                ? AppColors.champagneGold
                : AppColors.fog,
            fontSize: AppFontSizes.s10 * scale,
            letterSpacing: 0.8 * scale,
          ),
        ),
      ],
    );
  }
}

class _StepStatus extends StatelessWidget {
  const _StepStatus({
    required this.step,
    required this.done,
    required this.scale,
    required this.onPressed,
  });

  final RitualStep step;
  final bool done;
  final double scale;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (step) {
      RitualStep.merkaba => l10n.homeProgressShortMerkaba,
      RitualStep.facial => l10n.homeProgressShortFace,
      RitualStep.body => l10n.homeProgressShortBody,
      RitualStep.crystal => l10n.homeProgressShortCrystal,
    };
    return Semantics(
      button: !done,
      enabled: !done,
      label: done
          ? l10n.homeProgressCompletedStepSemantics(step.label(l10n))
          : l10n.homeProgressPendingStepSemantics(step.label(l10n)),
      excludeSemantics: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.s2 * scale),
        child: Material(
          color: done
              ? AppColors.champagneGold.withValues(alpha: 0.18)
              : AppColors.indigoBlue.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(AppRadii.r12 * scale),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 260),
              height: 48 * scale,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s3 * scale),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.r12 * scale),
                border: Border.all(
                  color: AppColors.champagneGold.withValues(
                    alpha: done ? 0.78 : 0.3,
                  ),
                  width: done ? 0.9 : 0.6,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: done
                        ? Icon(
                            Icons.check_rounded,
                            key: const ValueKey('done'),
                            size: 16 * scale,
                            color: AppColors.champagneGold,
                          )
                        : RitualStepIcon(
                            key: const ValueKey('pending'),
                            step: step,
                            size: 15 * scale,
                            color: AppColors.champagneGold80,
                          ),
                  ),
                  SizedBox(height: AppSpacing.s2 * scale),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: AppTypography.body.copyWith(
                        color: done ? AppColors.champagneGold : AppColors.white,
                        fontSize: AppFontSizes.s9 * scale,
                        letterSpacing: 0.1,
                      ),
                    ),
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

class _ProgressFooter extends StatelessWidget {
  const _ProgressFooter({
    required this.scale,
    required this.day,
    required this.streak,
    required this.history,
    required this.onHistory,
  });

  final double scale;
  final int day;
  final int streak;
  final CycleHistory? history;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final yesterday = _yesterdayText(l10n);
    return Row(
      children: [
        Icon(
          yesterday == null
              ? Icons.local_fire_department_outlined
              : Icons.history_rounded,
          size: 14 * scale,
          color: AppColors.champagneGold,
        ),
        SizedBox(width: AppSpacing.s4 * scale),
        Expanded(
          child: Text(
            yesterday ?? l10n.homeProgressStreak(streak),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body.copyWith(
              color: AppColors.fog,
              fontSize: AppFontSizes.s9 * scale,
              letterSpacing: 0.1,
            ),
          ),
        ),
        Semantics(
          button: true,
          label: l10n.homeProgressSeeHistory,
          excludeSemantics: true,
          child: InkWell(
            onTap: onHistory,
            borderRadius: BorderRadius.circular(AppRadii.r12),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s6 * scale,
                vertical: AppSpacing.s4 * scale,
              ),
              child: Text(
                l10n.homeProgressSeeHistory,
                style: AppTypography.subheadline.copyWith(
                  color: AppColors.champagneGold,
                  fontSize: AppFontSizes.s9 * scale,
                  letterSpacing: 0.7 * scale,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String? _yesterdayText(AppLocalizations l10n) {
    final snapshot = history;
    if (day <= 1 || snapshot == null || !snapshot.isAuthoritative) return null;
    final yesterday = snapshot.on(day - 1);
    if (yesterday.completed) return l10n.homeProgressYesterdayComplete;
    final missing = yesterday.pending
        .map(
          (step) => switch (step) {
            RitualStep.merkaba => l10n.homeProgressShortMerkaba,
            RitualStep.facial => l10n.homeProgressShortFace,
            RitualStep.body => l10n.homeProgressShortBody,
            RitualStep.crystal => l10n.homeProgressShortCrystal,
          },
        )
        .join(' · ');
    return l10n.homeProgressYesterdayMissing(missing);
  }
}

/// Shown in place of the four steps once today's ritual is complete:
/// congratulations for the day reached and a thank-you that changes each
/// day, with special words on the weekly milestones and the last day.
class _DayCompleteMessage extends StatelessWidget {
  const _DayCompleteMessage({
    required this.scale,
    required this.day,
    required this.total,
  });

  final double scale;
  final int day;
  final int total;

  String _thanks(AppLocalizations l10n) {
    if (day >= total) return l10n.homeThanksCycleComplete;
    switch (day) {
      case 7:
        return l10n.homeThanksWeekOne;
      case 14:
        return l10n.homeThanksWeekTwo;
      case 21:
        return l10n.homeThanksWeekThree;
    }
    final messages = [
      l10n.homeThanks1,
      l10n.homeThanks2,
      l10n.homeThanks3,
      l10n.homeThanks4,
      l10n.homeThanks5,
    ];
    return messages[(day - 1) % messages.length];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = l10n.homeProgressCongrats(day);
    final thanks = _thanks(l10n);

    return Semantics(
      label: '$title $thanks',
      excludeSemantics: true,
      child: SizedBox(
        height: 48 * scale,
        child: Row(
          children: [
            Container(
              width: 36 * scale,
              height: 36 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.champagneGold.withValues(alpha: 0.16),
                border: Border.all(color: AppColors.champagneGold, width: 0.8),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 18 * scale,
                color: AppColors.champagneGold,
              ),
            ),
            SizedBox(width: AppSpacing.s10 * scale),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headline.copyWith(
                      color: AppColors.champagneGold,
                      fontSize: AppFontSizes.s13 * scale,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s2 * scale),
                  Text(
                    thanks,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(
                      color: AppColors.fog,
                      fontSize: AppFontSizes.s10 * scale,
                      height: 1.3,
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

/// One soft golden light passing over the card, then gone. Skipped with
/// reduce motion.
class _CompletionSheen extends StatefulWidget {
  const _CompletionSheen({super.key, required this.radius});

  final double radius;

  @override
  State<_CompletionSheen> createState() => _CompletionSheenState();
}

class _CompletionSheenState extends State<_CompletionSheen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = Curves.easeInOut.transform(_controller.value);
            if (t >= 1) return const SizedBox.shrink();
            return Align(
              alignment: Alignment(-1.6 + 3.2 * t, 0),
              child: FractionallySizedBox(
                widthFactor: 0.35,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.champagneGold.withValues(alpha: 0),
                        AppColors.champagneGold.withValues(alpha: 0.22),
                        AppColors.champagneGold.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
