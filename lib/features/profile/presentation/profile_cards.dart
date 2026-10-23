import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_journal.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../journey/application/ritual_cycle_controller.dart';
import '../application/member_profile_controller.dart';
import '../application/ritual_reminders_controller.dart';
import '../data/member_profile_repository.dart';

const Color _ink = AppColors.white;
const Color _accent = AppColors.champagneGold;

final TextStyle _cardText = AppTypography.headline.copyWith(
  color: _ink,
  height: 1.35,
  letterSpacing: 0,
);

final TextStyle _sectionLabel = _cardText.copyWith(
  color: _accent,
  fontSize: AppFontSizes.s9,
  fontWeight: FontWeight.w500,
  letterSpacing: 1.8,
);

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.child, this.label});

  final String? label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cardLabel = label;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppJournal.radius),
        boxShadow: const [
          BoxShadow(
            color: AppJournal.shadow,
            blurRadius: AppJournal.shadowBlur,
            spreadRadius: AppJournal.elevation / 4,
            offset: Offset(0, AppJournal.shadowOffset),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppJournal.radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppJournal.blur,
            sigmaY: AppJournal.blur,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              AppSpacing.s14,
              AppSpacing.s16,
              AppSpacing.s16,
            ),
            decoration: BoxDecoration(
              color: AppJournal.surface,
              borderRadius: BorderRadius.circular(AppJournal.radius),
              border: Border.all(color: AppJournal.border, width: 0.9),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (cardLabel != null) ...[
                  Text(cardLabel, style: _sectionLabel),
                  const SizedBox(height: AppSpacing.s14),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MemberCard extends ConsumerWidget {
  const MemberCard({super.key});

  static const double _portraitSize = 64;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile =
        ref.watch(memberProfileControllerProvider).value ??
        const MemberProfile(name: MemberProfile.defaultName);
    final photo = profile.photo;
    final progress = ref.watch(journeyProgressProvider);

    return _ProfileCard(
      child: Semantics(
        button: true,
        label: l10n.profileMemberSemantics(
          profile.name,
          progress.currentDay,
          progress.cycleLength,
        ),
        child: InkWell(
          onTap: () => context.push(AppRoutes.profileAccount),
          child: Row(
            children: [
              Container(
                width: _portraitSize,
                height: _portraitSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.champagneGold.withValues(alpha: 0.7),
                    width: 0.8,
                  ),
                ),
                child: ClipOval(
                  child: photo == null
                      ? Image.asset(
                          'assets/images/profile_portrait.png',
                          fit: BoxFit.cover,
                        )
                      : Image.memory(
                          photo,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: _cardText.copyWith(
                        fontSize: AppFontSizes.s18,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    Text(
                      l10n.profileMemberLabel(
                        progress.currentDay,
                        progress.cycleLength,
                      ),
                      style: _cardText.copyWith(
                        color: AppColors.fog,
                        fontSize: AppFontSizes.s9,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    Text(
                      l10n.profileAccountEdit,
                      style: _cardText.copyWith(
                        color: _accent,
                        fontSize: AppFontSizes.s9,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef _Reminder = ({String icon, String title, String detail, String time});

class RitualRemindersCard extends ConsumerWidget {
  const RitualRemindersCard({super.key});

  /// Times are sample values until reminders are configurable.
  static List<_Reminder> _reminders(AppLocalizations l10n) => [
    (
      icon: 'assets/images/profile_sunrise.svg',
      title: l10n.profileReminderMorningTitle,
      detail: l10n.profileReminderMorningDetail,
      time: '08:00 AM',
    ),
    (
      icon: 'assets/images/profile_moon.svg',
      title: l10n.profileReminderEveningTitle,
      detail: l10n.profileReminderEveningDetail,
      time: '09:30 PM',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reminders = _reminders(l10n);
    final enabled =
        ref.watch(ritualRemindersControllerProvider).value ??
        RitualReminders.defaults;
    final controller = ref.read(ritualRemindersControllerProvider.notifier);
    final states = [enabled.morning, enabled.evening];
    final toggles = [controller.setMorning, controller.setEvening];

    return _ProfileCard(
      label: l10n.profileRemindersTitle,
      child: Column(
        children: [
          for (var index = 0; index < reminders.length; index++) ...[
            if (index > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                child: Container(
                  height: 0.4,
                  color: AppColors.champagneGold.withValues(alpha: 0.22),
                ),
              ),
            _ReminderRow(
              reminder: reminders[index],
              enabled: states[index],
              onChanged: toggles[index],
            ),
          ],
        ],
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.reminder,
    required this.enabled,
    required this.onChanged,
  });

  final _Reminder reminder;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          reminder.icon,
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(_accent, BlendMode.srcIn),
          excludeFromSemantics: true,
        ),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reminder.title,
                style: _cardText.copyWith(fontSize: AppFontSizes.s12),
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(
                reminder.detail,
                style: _cardText.copyWith(
                  fontSize: AppFontSizes.s10_5,
                  color: AppColors.fog,
                ),
              ),
            ],
          ),
        ),
        Text(
          reminder.time,
          style: _cardText.copyWith(fontSize: AppFontSizes.s9_5),
        ),
        const SizedBox(width: AppSpacing.s4),
        Semantics(
          label: AppLocalizations.of(
            context,
          ).profileReminderSemantics(reminder.title),
          child: Transform.scale(
            scale: 0.7,
            child: Switch(
              value: enabled,
              onChanged: onChanged,
              activeThumbColor: AppColors.white,
              activeTrackColor: _accent,
              inactiveThumbColor: AppColors.white,
              inactiveTrackColor: AppColors.darkIndigoBlue20,
              trackOutlineColor: const WidgetStatePropertyAll(
                AppColors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DataPrivacyCard extends StatelessWidget {
  const DataPrivacyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _ProfileCard(
      label: l10n.profilePrivacyTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profilePrivacyBody,
            style: _cardText.copyWith(
              color: AppColors.fog,
              fontSize: AppFontSizes.s12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Semantics(
            button: true,
            label: l10n.profilePrivacyOpenSemantics,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: _accent,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.profilePrivacy,
                style: _cardText.copyWith(
                  color: _accent,
                  fontSize: AppFontSizes.s11,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CycleCard extends ConsumerWidget {
  const CycleCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final progress = ref.watch(journeyProgressProvider);
    return _ProfileCard(
      label: l10n.profileCycleTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _CycleRing(
                day: progress.currentDay,
                length: progress.cycleLength,
              ),
              const SizedBox(width: AppSpacing.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profileCycleInProgress,
                      style: _cardText.copyWith(fontSize: AppFontSizes.s13),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      l10n.commonDayOfTotal(
                        progress.currentDay,
                        progress.cycleLength,
                      ),
                      style: _cardText.copyWith(
                        color: _accent,
                        fontSize: AppFontSizes.s12,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s14),
          _CompleteCycle(cycleLength: progress.cycleLength),
        ],
      ),
    );
  }
}

class _CompleteCycle extends ConsumerWidget {
  const _CompleteCycle({required this.cycleLength});

  final int cycleLength;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profileCycleComplete,
          style: _cardText.copyWith(fontSize: AppFontSizes.s12),
        ),
        const SizedBox(height: AppSpacing.s6),
        Text(
          l10n.profileCycleUnlock(cycleLength),
          style: _cardText.copyWith(
            color: AppColors.fog,
            fontSize: AppFontSizes.s11,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () =>
                ref.read(ritualCycleControllerProvider.notifier).endCycle(),
            style: TextButton.styleFrom(
              foregroundColor: _accent,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.profileCycleEnd,
              style: _cardText.copyWith(
                color: _accent,
                fontSize: AppFontSizes.s11,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CycleRing extends StatelessWidget {
  const _CycleRing({required this.day, required this.length});

  static const double _size = 61;

  final int day;
  final int length;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _size,
      child: CustomPaint(
        painter: _CycleRingPainter(progress: day / length),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$day',
                style: _cardText.copyWith(
                  fontSize: AppFontSizes.s19,
                  height: 1,
                ),
              ),
              Text(
                '/ $length',
                style: _cardText.copyWith(fontSize: AppFontSizes.s10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CycleRingPainter extends CustomPainter {
  const _CycleRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1.5);
    final track = Paint()
      ..color = AppColors.champagneGold.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final arc = Paint()
      ..color = AppColors.champagneGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    canvas.drawOval(rect, track);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(covariant _CycleRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Lets the user switch the app language at runtime. The choice is persisted
/// and the whole app rebuilds in the selected locale.
class LanguageCard extends ConsumerWidget {
  const LanguageCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = Localizations.localeOf(context).languageCode;

    return _ProfileCard(
      label: l10n.profileLanguageCardTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.profileLanguageCardSubtitle,
            style: _cardText.copyWith(fontSize: AppFontSizes.s9_7),
          ),
          const SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              Expanded(
                child: _LanguageOption(
                  label: l10n.languageEnglish,
                  selected: current == 'en',
                  onTap: () => ref
                      .read(localeControllerProvider.notifier)
                      .setLocale(const Locale('en')),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: _LanguageOption(
                  label: l10n.languageSpanish,
                  selected: current == 'es',
                  onTap: () => ref
                      .read(localeControllerProvider.notifier)
                      .setLocale(const Locale('es')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected
            ? AppColors.champagneGold.withValues(alpha: 0.14)
            : AppColors.transparent,
        shape: StadiumBorder(
          side: BorderSide(
            color: AppColors.champagneGold.withValues(
              alpha: selected ? 0.8 : 0.3,
            ),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: AppSpacing.s36,
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                style: _cardText.copyWith(
                  fontSize: AppFontSizes.s9_7,
                  color: selected ? AppColors.champagneGold : _ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
