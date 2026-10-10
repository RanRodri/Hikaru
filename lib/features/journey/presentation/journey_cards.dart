import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/router/app_routes.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../crystals/domain/crystal.dart';
import '../domain/journey_progress.dart';

const JourneyProgress _progress = sampleJourneyProgress;

final TextStyle _cardText = AppTypography.headline.copyWith(
  color: AppColors.white,
  height: 1.3,
  letterSpacing: 0,
);

final TextStyle _sectionLabel = _cardText.copyWith(
  fontSize: 10,
  letterSpacing: 1.4,
);

final TextStyle _mutedText = _cardText.copyWith(
  color: AppColors.champagneGold40,
  fontSize: 10,
);

void _openCrystal(BuildContext context, Crystal? crystal) {
  if (crystal == null) {
    context.push(AppRoutes.fourTemples);
    return;
  }
  context.push(AppRoutes.crystalResonanceFor(crystal.name));
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(15, 12, 15, 14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.darkIndigoBlue.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.champagneGold.withValues(alpha: 0.45),
              width: 0.9,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _CardHeading extends StatelessWidget {
  const _CardHeading({required this.icon, required this.label, this.trailing});

  final String icon;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final headingTrailing = trailing;

    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 16,
          height: 16,
          excludeFromSemantics: true,
        ),
        const SizedBox(width: 9),
        Expanded(child: Text(label, style: _sectionLabel)),
        if (headingTrailing != null)
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: headingTrailing,
            ),
          ),
      ],
    );
  }
}

class ActiveCrystalCard extends ConsumerWidget {
  const ActiveCrystalCard({super.key});

  static const double _imageWidth = 122;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crystal = ref.watch(selectedCrystalProvider).value;

    return Semantics(
      button: true,
      label: crystal == null
          ? 'Choose your crystal'
          : 'Your active crystal, ${crystal.displayName}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => _openCrystal(context, crystal),
        child: _JourneyCard(
          padding: EdgeInsets.zero,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: _imageWidth,
                  child: crystal == null
                      ? const _EmptyCrystal()
                      : Image.asset(crystal.imageAsset, fit: BoxFit.cover),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                    child: crystal == null
                        ? const _ChooseCrystalPrompt()
                        : _CrystalSummary(crystal: crystal),
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

class _EmptyCrystal extends StatelessWidget {
  const _EmptyCrystal();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        'assets/images/journey_frequency_control.svg',
        width: 56,
        height: 56,
        excludeFromSemantics: true,
      ),
    );
  }
}

class _ChooseCrystalPrompt extends StatelessWidget {
  const _ChooseCrystalPrompt();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('YOUR ACTIVE CRYSTAL', style: _mutedText.copyWith(fontSize: 9)),
        const SizedBox(height: 6),
        Text('Choose your temple', style: _cardText.copyWith(fontSize: 18)),
        const SizedBox(height: 6),
        Text(
          'Select a crystal to begin your 30-day resonance.',
          style: _cardText.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}

class _CrystalSummary extends StatelessWidget {
  const _CrystalSummary({required this.crystal});

  final Crystal crystal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('YOUR ACTIVE CRYSTAL', style: _mutedText.copyWith(fontSize: 9)),
        const SizedBox(height: 4),
        Text(
          crystal.displayName,
          style: _cardText.copyWith(fontSize: 22, letterSpacing: 1.6),
        ),
        Text(
          crystal.temple.toUpperCase(),
          style: _mutedText.copyWith(fontSize: 9, letterSpacing: 0.9),
        ),
        const SizedBox(height: 4),
        Text(crystal.frequency, style: _cardText.copyWith(fontSize: 13)),
        const SizedBox(height: 6),
        Container(width: 42, height: 0.5, color: AppColors.champagneGold),
        const SizedBox(height: 6),
        Text(crystal.purpose, style: _cardText.copyWith(fontSize: 11)),
      ],
    );
  }
}

class DailyStreakCard extends StatelessWidget {
  const DailyStreakCard({super.key});

  static const int _daysPerRow = 15;
  static const double _dayGap = 4;

  @override
  Widget build(BuildContext context) {
    return _JourneyCard(
      child: Column(
        children: [
          _CardHeading(
            icon: 'assets/images/journey_sun.svg',
            label: 'DAILY STREAK',
            trailing: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/journey_flame.svg',
                  width: 16,
                  height: 16,
                  excludeFromSemantics: true,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_progress.currentDay} / ${_progress.cycleLength}',
                  style: _cardText.copyWith(fontSize: 18, height: 1),
                ),
                const SizedBox(width: 8),
                Text('Days in a row', style: _mutedText),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 0.4,
            color: AppColors.champagneGold60.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final daySize =
                  (constraints.maxWidth - _dayGap * (_daysPerRow - 1)) /
                  _daysPerRow;

              return Semantics(
                label:
                    'Day ${_progress.currentDay} of ${_progress.cycleLength}',
                excludeSemantics: true,
                child: Wrap(
                  spacing: _dayGap,
                  runSpacing: 8,
                  children: [
                    for (var day = 1; day <= _progress.cycleLength; day++)
                      _DayDot(day: day, size: daySize),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.day, required this.size});

  final int day;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isCompleted = day < _progress.currentDay;
    final isToday = day == _progress.currentDay;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? AppColors.champagneGold : null,
        border: Border.all(
          color: isToday
              ? AppColors.champagneGold40
              : AppColors.champagneGold60,
          width: isToday ? 1 : 0.4,
        ),
        boxShadow: isToday
            ? const [BoxShadow(color: Color(0xFFFFE7A4), blurRadius: 4)]
            : null,
      ),
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Text(
            '$day',
            style: _cardText.copyWith(
              fontSize: 10,
              height: 1,
              color: isCompleted ? AppColors.darkIndigoBlue : AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressPhotosCard extends StatelessWidget {
  const ProgressPhotosCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _JourneyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading(
            icon: 'assets/images/journey_image.svg',
            label: 'PROGRESS PHOTOS',
            trailing: Semantics(
              button: true,
              label: 'View all progress photos',
              excludeSemantics: true,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Text(
                    'View all',
                    style: _cardText.copyWith(
                      fontSize: 10.5,
                      color: AppColors.champagneGold60,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'See your evolution over time',
            style: _cardText.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: _ProgressPortrait(
                  asset: 'assets/images/journey_before.png',
                  day: 'DAY 1',
                  label: 'Before',
                ),
              ),
              Container(
                width: 24,
                height: 0.6,
                color: AppColors.champagneGold80,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProgressPortrait(
                  asset: 'assets/images/journey_current.png',
                  day: 'DAY ${_progress.currentDay}',
                  label: 'Current',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressPortrait extends StatelessWidget {
  const _ProgressPortrait({
    required this.asset,
    required this.day,
    required this.label,
  });

  static const double _size = 62;

  final String asset;
  final String day;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.champagneGold80, width: 0.8),
          ),
          child: ClipOval(
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              semanticLabel: '$label photo, $day',
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(day, style: _mutedText.copyWith(fontSize: 9)),
              Text(label, style: _cardText.copyWith(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class JourneyContinuesCard extends ConsumerWidget {
  const JourneyContinuesCard({super.key});

  static const double _controlSize = 38;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crystal = ref.watch(selectedCrystalProvider).value;
    final title = crystal == null
        ? 'Choose your crystal'
        : '${crystal.displayName} · ${crystal.frequency}';

    return Semantics(
      button: true,
      label: 'Your journey continues, $title',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => _openCrystal(context, crystal),
        child: _JourneyCard(
          child: Column(
            children: [
              const _CardHeading(
                icon: 'assets/images/journey_lock.svg',
                label: 'YOUR JOURNEY CONTINUES',
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox.square(
                    dimension: _controlSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/journey_frequency_control.svg',
                          width: _controlSize,
                          height: _controlSize,
                        ),
                        SvgPicture.asset(
                          'assets/images/journey_audio_lines.svg',
                          width: 20,
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: _cardText.copyWith(fontSize: 12.5)),
                        const SizedBox(height: 2),
                        Text(
                          'Frequency · Cymatic Signature · Daily Ritual',
                          style: _mutedText.copyWith(fontSize: 9.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
