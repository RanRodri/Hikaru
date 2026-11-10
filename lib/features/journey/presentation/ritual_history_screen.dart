import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/hikaru_back_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/ritual_cycle_controller.dart';
import '../domain/ritual_cycle.dart';
import 'ritual_step_texts.dart';

/// Opens the 30-day history above the tabs, like the progress photos.
void openRitualHistory(BuildContext context) {
  Navigator.of(
    context,
    rootNavigator: true,
  ).push(MaterialPageRoute<void>(builder: (_) => const RitualHistoryScreen()));
}

/// The 30 days of the current cycle. Each day shows whether the full ritual,
/// part of it, or nothing was done; tapping it lists the four steps.
class RitualHistoryScreen extends ConsumerStatefulWidget {
  const RitualHistoryScreen({super.key});

  @override
  ConsumerState<RitualHistoryScreen> createState() =>
      _RitualHistoryScreenState();
}

class _RitualHistoryScreenState extends ConsumerState<RitualHistoryScreen> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = ref.watch(ritualClockProvider)();
    final history = ref.watch(cycleHistoryProvider);
    final value = history.value;
    final cycle = value?.cycle;
    final today = cycle?.dayNumber(now);

    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s8,
            AppSpacing.s20,
            AppSpacing.s32,
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: HikaruBackButton(
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              l10n.historyTitle,
              textAlign: TextAlign.center,
              style: AppTypography.subheadline.copyWith(
                color: AppColors.champagneGold,
                fontSize: AppFontSizes.s14,
                letterSpacing: 2.4,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              l10n.historySubtitle,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.fog,
                fontSize: AppFontSizes.s12,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            if (history.isLoading && value == null)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.s32),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.champagneGold,
                    strokeWidth: 2,
                  ),
                ),
              )
            else if (cycle == null || today == null)
              Text(
                l10n.historyNoCycle,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.fog,
                  fontSize: AppFontSizes.s13,
                ),
              )
            else ...[
              Text(
                l10n.historyCompletedDays(
                  value!.completedDays,
                  ritualCycleLength,
                ),
                textAlign: TextAlign.center,
                style: AppTypography.headline.copyWith(
                  color: AppColors.white,
                  fontSize: AppFontSizes.s16,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              _DayGrid(
                cycle: cycle,
                history: value,
                today: today,
                selected: _selected ?? today,
                onSelected: (day) => setState(() => _selected = day),
              ),
              const SizedBox(height: AppSpacing.s12),
              const _Legend(),
              const SizedBox(height: AppSpacing.s20),
              _DayDetail(
                day: _selected ?? today,
                date: cycle.startDate.add(
                  Duration(days: (_selected ?? today) - 1),
                ),
                flags: value.on(_selected ?? today),
                upcoming: (_selected ?? today) > today,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _DayState { complete, partial, none, upcoming }

_DayState _stateOf(DailyRitualFlags flags, {required bool upcoming}) {
  if (upcoming) return _DayState.upcoming;
  if (flags.completed) return _DayState.complete;
  if (!flags.isEmpty) return _DayState.partial;
  return _DayState.none;
}

class _DayGrid extends StatelessWidget {
  const _DayGrid({
    required this.cycle,
    required this.history,
    required this.today,
    required this.selected,
    required this.onSelected,
  });

  static const int _columns = 6;

  final RitualCycle cycle;
  final CycleHistory history;
  final int today;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final format = DateFormat.MMMd(locale);
    final l10n = AppLocalizations.of(context);
    return GridView.count(
      crossAxisCount: _columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.s8,
      crossAxisSpacing: AppSpacing.s8,
      childAspectRatio: 0.8,
      children: [
        for (var day = 1; day <= ritualCycleLength; day++)
          _DayCell(
            day: day,
            date: format.format(cycle.startDate.add(Duration(days: day - 1))),
            state: _stateOf(history.on(day), upcoming: day > today),
            isToday: day == today,
            isSelected: day == selected,
            semanticLabel: l10n.historyDayTitle(day),
            onTap: () => onSelected(day),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.date,
    required this.state,
    required this.isToday,
    required this.isSelected,
    required this.semanticLabel,
    required this.onTap,
  });

  final int day;
  final String date;
  final _DayState state;
  final bool isToday;
  final bool isSelected;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final complete = state == _DayState.complete;
    final fill = switch (state) {
      _DayState.complete => AppColors.champagneGold,
      _DayState.partial => AppColors.champagneGold.withValues(alpha: 0.28),
      _DayState.none => AppColors.white.withValues(alpha: 0.04),
      _DayState.upcoming => AppColors.transparent,
    };
    final foreground = complete ? AppColors.darkIndigoBlue : AppColors.white;
    final faded = state == _DayState.upcoming;

    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.r16),
          side: BorderSide(
            color: isSelected
                ? AppColors.goldGlow
                : AppColors.champagneGold.withValues(alpha: faded ? 0.18 : 0.5),
            width: isSelected || isToday ? 1.6 : 0.6,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Opacity(
            opacity: faded ? 0.45 : 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: AppTypography.headline.copyWith(
                    color: foreground,
                    fontSize: AppFontSizes.s16,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.s2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    date,
                    maxLines: 1,
                    style: AppTypography.body.copyWith(
                      color: foreground.withValues(alpha: 0.8),
                      fontSize: AppFontSizes.s9,
                      letterSpacing: 0,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget item(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(
              color: AppColors.champagneGold.withValues(alpha: 0.5),
              width: 0.6,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s6),
        Text(
          label,
          style: AppTypography.body.copyWith(
            color: AppColors.fog,
            fontSize: AppFontSizes.s11,
            letterSpacing: 0,
          ),
        ),
      ],
    );
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.s16,
      runSpacing: AppSpacing.s8,
      children: [
        item(AppColors.champagneGold, l10n.historyLegendComplete),
        item(
          AppColors.champagneGold.withValues(alpha: 0.28),
          l10n.historyLegendPartial,
        ),
        item(AppColors.transparent, l10n.historyLegendNone),
      ],
    );
  }
}

class _DayDetail extends StatelessWidget {
  const _DayDetail({
    required this.day,
    required this.date,
    required this.flags,
    required this.upcoming,
  });

  final int day;
  final DateTime date;
  final DailyRitualFlags flags;
  final bool upcoming;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppRadii.r16),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.historyDayTitle(day)} · '
            '${DateFormat.yMMMMd(locale).format(date)}',
            style: AppTypography.subheadline.copyWith(
              color: AppColors.champagneGold,
              fontSize: AppFontSizes.s12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          if (upcoming)
            Text(
              l10n.historyUpcoming,
              style: AppTypography.body.copyWith(
                color: AppColors.fog,
                fontSize: AppFontSizes.s13,
              ),
            )
          else
            for (final step in RitualStep.values) ...[
              _StepRow(step: step, done: flags.isDone(step)),
              if (step != RitualStep.values.last)
                const SizedBox(height: AppSpacing.s10),
            ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.done});

  final RitualStep step;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = done ? l10n.historyStepDone : l10n.historyStepPending;
    return Semantics(
      label: '${step.label(l10n)}: $status',
      excludeSemantics: true,
      child: Row(
        children: [
          RitualStepIcon(step: step, size: 20),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text(
              step.label(l10n),
              style: AppTypography.headline.copyWith(
                color: AppColors.white,
                fontSize: AppFontSizes.s14,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: done
                ? AppColors.champagneGold
                : AppColors.fog.withValues(alpha: 0.5),
          ),
          const SizedBox(width: AppSpacing.s6),
          Text(
            status,
            style: AppTypography.body.copyWith(
              color: done ? AppColors.champagneGold : AppColors.fog,
              fontSize: AppFontSizes.s12,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
