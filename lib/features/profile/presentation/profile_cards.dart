import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../journey/domain/journey_progress.dart';

const Color _ink = AppColors.darkIndigoBlue;
const Color _accent = AppColors.matteChampagne80;

final TextStyle _cardText = AppTypography.headline.copyWith(
  color: _ink,
  height: 1.23,
  letterSpacing: 0,
);

final TextStyle _sectionLabel = _cardText.copyWith(
  fontSize: 9.5,
  letterSpacing: 1.4,
);

final int _sampleCycleDay = sampleJourneyProgress.currentDay;
final int _cycleLength = sampleJourneyProgress.cycleLength;

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.child, this.icon, this.label});

  final String? icon;
  final String? label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cardIcon = icon;
    final cardLabel = label;

    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          decoration: BoxDecoration(
            color: AppColors.fog.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AppColors.white, width: 0.6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (cardIcon != null && cardLabel != null) ...[
                Row(
                  children: [
                    SvgPicture.asset(
                      cardIcon,
                      width: 18,
                      height: 18,
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(cardLabel, style: _sectionLabel)),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/profile_chevron.svg',
      width: 5.74,
      height: 10.5,
      excludeFromSemantics: true,
    );
  }
}

class _GoldRule extends StatelessWidget {
  const _GoldRule.vertical({required double length})
    : width = 0.5,
      height = length;

  const _GoldRule.horizontal() : width = double.infinity, height = 0.4;

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.champagneGold.withValues(alpha: 0.7),
    );
  }
}

class MemberCard extends StatelessWidget {
  const MemberCard({super.key});

  static const double _portraitSize = 77;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      child: Semantics(
        button: true,
        label:
            'María González, sanctuary member, day $_sampleCycleDay of '
            '$_cycleLength',
        excludeSemantics: true,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(9),
          child: Row(
            children: [
              SizedBox.square(
                dimension: _portraitSize,
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: Image(
                        image: AssetImage('assets/images/profile_portrait.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/images/profile_portrait_border.svg',
                      width: _portraitSize,
                      height: _portraitSize,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'María González',
                      style: _cardText.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SANCTUARY MEMBER — DAY $_sampleCycleDay OF $_cycleLength',
                      style: _cardText.copyWith(
                        fontSize: 8.5,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const _Chevron(),
            ],
          ),
        ),
      ),
    );
  }
}

typedef _Reminder = ({String icon, String title, String detail, String time});

class RitualRemindersCard extends StatefulWidget {
  const RitualRemindersCard({super.key});

  @override
  State<RitualRemindersCard> createState() => _RitualRemindersCardState();
}

class _RitualRemindersCardState extends State<RitualRemindersCard> {
  static const List<_Reminder> _reminders = [
    (
      icon: 'assets/images/profile_sunrise.svg',
      title: 'Morning Sacred Ritual',
      detail: 'Meditation & facial massage',
      time: '08:00 AM',
    ),
    (
      icon: 'assets/images/profile_moon.svg',
      title: 'Evening Reflection & Breath',
      detail: 'Conscious breathing before sleep',
      time: '09:30 PM',
    ),
  ];

  final List<bool> _enabled = List.filled(_reminders.length, true);

  void _handleToggle(int index, bool value) {
    setState(() => _enabled[index] = value);
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      icon: 'assets/images/profile_sun.svg',
      label: 'RITUAL ALARMS & REMINDERS',
      child: Column(
        children: [
          for (var index = 0; index < _reminders.length; index++) ...[
            if (index > 0)
              const Padding(
                padding: EdgeInsets.only(left: 40, top: 6, bottom: 6),
                child: _GoldRule.horizontal(),
              ),
            _ReminderRow(
              reminder: _reminders[index],
              enabled: _enabled[index],
              onChanged: (value) => _handleToggle(index, value),
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

  static const double _medallionSize = 28;

  final _Reminder reminder;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox.square(
          dimension: _medallionSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/profile_ritual_medallion.svg',
                width: _medallionSize,
                height: _medallionSize,
                excludeFromSemantics: true,
              ),
              SvgPicture.asset(
                reminder.icon,
                width: 16,
                height: 16,
                excludeFromSemantics: true,
              ),
            ],
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reminder.title, style: _cardText.copyWith(fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                reminder.detail,
                style: _cardText.copyWith(
                  fontSize: 10.5,
                  color: AppColors.darkIndigoBlue80,
                ),
              ),
            ],
          ),
        ),
        Text(reminder.time, style: _cardText.copyWith(fontSize: 9.5)),
        const SizedBox(width: 4),
        Semantics(
          label: '${reminder.title} reminder',
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
                Colors.transparent,
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
    return _ProfileCard(
      icon: 'assets/images/profile_lock.svg',
      label: 'YOUR DATA, TREATED WITH REVERENCE',
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Your facial photos and personal information are encrypted and '
              'protected with the highest standards of security and '
              'confidentiality.',
              style: _cardText.copyWith(fontSize: 10.3),
            ),
          ),
          const SizedBox(width: 10),
          const _GoldRule.vertical(length: 33),
          const SizedBox(width: 10),
          Semantics(
            button: true,
            label: 'Open privacy settings',
            excludeSemantics: true,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Column(
                      children: [
                        SvgPicture.asset(
                          'assets/images/profile_flower.svg',
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Privacy',
                          style: _cardText.copyWith(fontSize: 8.4),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    const _Chevron(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CycleCard extends StatelessWidget {
  const CycleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      icon: 'assets/images/profile_flower.svg',
      label: '30-DAY CYCLE',
      child: Row(
        children: [
          _CycleRing(day: _sampleCycleDay, length: _cycleLength),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your journey is in progress',
                  style: _cardText.copyWith(fontSize: 9.7),
                ),
                const SizedBox(height: 4),
                Text(
                  'Day $_sampleCycleDay of $_cycleLength',
                  style: _cardText.copyWith(fontSize: 10.7),
                ),
              ],
            ),
          ),
          const _GoldRule.vertical(length: 57),
          const SizedBox(width: 12),
          const Expanded(child: _CompleteCycle()),
        ],
      ),
    );
  }
}

class _CompleteCycle extends StatelessWidget {
  const _CompleteCycle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/images/profile_mountain.svg',
              width: 22,
              height: 22,
              excludeFromSemantics: true,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Complete your cycle',
                style: _cardText.copyWith(fontSize: 9.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'At day $_cycleLength, you’ll unlock your new diagnosis and '
          'recalibrate your crystal, frequency and cymatic signature.',
          style: _cardText.copyWith(fontSize: 7.7),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 22,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFFBF7E9),
              foregroundColor: _accent,
              side: const BorderSide(
                color: AppColors.champagneGold,
                width: 0.5,
              ),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'END CYCLE',
              style: AppTypography.footnote.copyWith(
                color: _accent,
                letterSpacing: 0.8,
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
              Text('$day', style: _cardText.copyWith(fontSize: 19, height: 1)),
              Text('/ $length', style: _cardText.copyWith(fontSize: 10)),
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
