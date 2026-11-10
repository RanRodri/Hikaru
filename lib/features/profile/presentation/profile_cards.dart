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
import '../../auth/application/sign_out.dart';
import '../../journey/application/ritual_cycle_controller.dart';
import '../application/member_profile_controller.dart';
import '../application/ritual_reminders_controller.dart';
import '../data/member_profile_repository.dart';
import 'default_avatar.dart';

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
                      ? const DefaultAvatar()
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

typedef _Reminder = ({
  String icon,
  String title,
  String detail,
  TimeOfDay time,
  ValueChanged<TimeOfDay> onTimeChanged,
});

class RitualRemindersCard extends ConsumerWidget {
  const RitualRemindersCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final enabled =
        ref.watch(ritualRemindersControllerProvider).value ??
        RitualReminders.defaults;
    final controller = ref.read(ritualRemindersControllerProvider.notifier);
    final List<_Reminder> reminders = [
      (
        icon: 'assets/images/profile_sunrise.svg',
        title: l10n.profileReminderMorningTitle,
        detail: l10n.profileReminderMorningDetail,
        time: enabled.morningTime,
        onTimeChanged: controller.setMorningTime,
      ),
      (
        icon: 'assets/images/profile_moon.svg',
        title: l10n.profileReminderEveningTitle,
        detail: l10n.profileReminderEveningDetail,
        time: enabled.eveningTime,
        onTimeChanged: controller.setEveningTime,
      ),
    ];
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
        _ReminderTime(
          title: reminder.title,
          time: reminder.time,
          onChanged: reminder.onTimeChanged,
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

/// The reminder time as a gold pill. Tapping it opens the time picker.
class _ReminderTime extends StatelessWidget {
  const _ReminderTime({
    required this.title,
    required this.time,
    required this.onChanged,
  });

  final String title;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: time,
      helpText: title.toUpperCase(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.champagneGold,
            onPrimary: AppColors.darkIndigoBlue,
            surface: AppColors.darkIndigoBlue,
            onSurface: AppColors.white,
            secondary: AppColors.champagneGold,
            onSecondary: AppColors.darkIndigoBlue,
            tertiary: AppColors.champagneGold,
            onTertiary: AppColors.darkIndigoBlue,
          ),
          timePickerTheme: TimePickerThemeData(
            dayPeriodColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.champagneGold
                  : AppColors.transparent,
            ),
            dayPeriodTextColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.darkIndigoBlue
                  : AppColors.white,
            ),
            dayPeriodBorderSide: BorderSide(
              color: AppColors.champagneGold.withValues(alpha: 0.6),
            ),
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked != null && picked != time) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final label = MaterialLocalizations.of(context).formatTimeOfDay(time);
    return Semantics(
      button: true,
      label: AppLocalizations.of(
        context,
      ).profileReminderTimeSemantics(title, label),
      excludeSemantics: true,
      child: Material(
        color: AppColors.transparent,
        shape: StadiumBorder(
          side: BorderSide(color: _accent.withValues(alpha: 0.6), width: 0.8),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _pick(context),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s10,
                vertical: AppSpacing.s6,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: _cardText.copyWith(fontSize: AppFontSizes.s11),
                  ),
                  const SizedBox(width: AppSpacing.s4),
                  const Icon(Icons.schedule, size: 13, color: _accent),
                ],
              ),
            ),
          ),
        ),
      ),
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
              onPressed: () => context.push(AppRoutes.profilePrivacy),
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

class _CompleteCycle extends ConsumerStatefulWidget {
  const _CompleteCycle({required this.cycleLength});

  final int cycleLength;

  @override
  ConsumerState<_CompleteCycle> createState() => _CompleteCycleState();
}

class _CompleteCycleState extends ConsumerState<_CompleteCycle> {
  var _ending = false;

  Future<void> _handleEndCycle() async {
    if (_ending) return;
    setState(() => _ending = true);
    try {
      await ref.read(ritualCycleControllerProvider.notifier).endCycle();
    } finally {
      if (mounted) setState(() => _ending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          l10n.profileCycleUnlock(widget.cycleLength),
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
            onPressed: _ending ? null : _handleEndCycle,
            style: TextButton.styleFrom(
              foregroundColor: _accent,
              disabledForegroundColor: _accent,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: _ending
                ? Semantics(
                    label: l10n.profileCycleEnd,
                    child: const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _accent,
                      ),
                    ),
                  )
                : Text(
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

/// Quiet sign-out at the end of Settings, behind a confirmation.
class SignOutButton extends ConsumerStatefulWidget {
  const SignOutButton({super.key});

  @override
  ConsumerState<SignOutButton> createState() => _SignOutButtonState();
}

class _SignOutButtonState extends ConsumerState<SignOutButton> {
  var _busy = false;

  Future<void> _handlePressed() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.scrim60,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkIndigoBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppJournal.radius),
          side: BorderSide(color: AppJournal.border, width: 0.9),
        ),
        title: Text(
          l10n.profileSignOutTitle,
          style: _cardText.copyWith(fontSize: AppFontSizes.s16),
        ),
        content: Text(
          l10n.profileSignOutBody,
          style: _cardText.copyWith(
            color: AppColors.fog,
            fontSize: AppFontSizes.s12,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.profileSignOutCancel,
              style: _sectionLabel.copyWith(
                color: AppColors.fog,
                fontSize: AppFontSizes.s11,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.profileSignOutConfirm,
              style: _sectionLabel.copyWith(fontSize: AppFontSizes.s11),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await signOutMember(ref);
      if (!mounted) return;
      context.go(AppRoutes.login);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text(l10n.profileSignOutError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Same dark glass as the cards above, so it reads over any part of the
    // garden photo, including the bright rocks at the bottom.
    return Semantics(
      button: true,
      label: l10n.profileSignOut,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppJournal.radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppJournal.blur,
            sigmaY: AppJournal.blur,
          ),
          child: TextButton.icon(
            onPressed: _busy ? null : _handlePressed,
            style: TextButton.styleFrom(
              foregroundColor: _accent,
              disabledForegroundColor: _accent,
              backgroundColor: AppColors.darkIndigoBlue.withValues(alpha: 0.82),
              minimumSize: const Size.fromHeight(52),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppJournal.radius),
                side: const BorderSide(color: _accent, width: 0.9),
              ),
            ),
            icon: _busy
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _accent,
                    ),
                  )
                : const Icon(Icons.logout, size: 16),
            label: Text(
              l10n.profileSignOut,
              style: _sectionLabel.copyWith(
                fontSize: AppFontSizes.s12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
