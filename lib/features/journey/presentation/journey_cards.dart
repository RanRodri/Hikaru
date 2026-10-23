import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_journal.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/router/app_routes.dart';
import '../../crystals/application/selected_crystal_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../crystals/domain/crystal.dart';
import '../../crystals/presentation/crystal_texts.dart';
import '../../mirror_garden/presentation/face_camera_screen.dart';
import '../application/reflection_photo_controller.dart';
import '../application/ritual_cycle_controller.dart';
import '../domain/reflection_photo.dart';
import 'progress_photos_screen.dart';

final TextStyle _cardText = AppTypography.headline.copyWith(
  color: AppColors.white,
  height: 1.3,
  letterSpacing: 0,
);

final TextStyle _sectionLabel = _cardText.copyWith(
  fontSize: AppFontSizes.s10,
  letterSpacing: 1.4,
);

final TextStyle _mutedText = _cardText.copyWith(
  color: AppColors.champagneGold40,
  fontSize: AppFontSizes.s10,
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
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.s15,
      AppSpacing.s12,
      AppSpacing.s15,
      AppSpacing.s14,
    ),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppJournal.radius),
        boxShadow: [
          BoxShadow(
            color: AppJournal.shadow,
            blurRadius: AppJournal.shadowBlur,
            spreadRadius: AppJournal.elevation / 4,
            offset: const Offset(0, AppJournal.shadowOffset),
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
            padding: padding,
            decoration: BoxDecoration(
              color: AppJournal.surface,
              borderRadius: BorderRadius.circular(AppJournal.radius),
              border: Border.all(color: AppJournal.border, width: 0.9),
            ),
            child: child,
          ),
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
        const SizedBox(width: AppSpacing.s9),
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
    final l10n = AppLocalizations.of(context);

    return Semantics(
      button: true,
      label: crystal == null
          ? l10n.journeyChooseCrystal
          : l10n.journeyActiveCrystalSemantics(crystal.localizedName(l10n)),
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
                      : _CrystalMedallion(asset: crystal.imageAsset),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s14,
                      AppSpacing.s14,
                      AppSpacing.s14,
                      AppSpacing.s16,
                    ),
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

class _CrystalMedallion extends StatelessWidget {
  const _CrystalMedallion({required this.asset});

  static const double _size = 100;
  static const double _edgeTrim = 1.04;

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.champagneGold.withValues(alpha: 0.35),
              blurRadius: 14,
            ),
          ],
        ),
        child: ClipOval(
          child: Transform.scale(
            scale: _edgeTrim,
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
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
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.journeyActiveCrystalLabel,
          style: _mutedText.copyWith(fontSize: AppFontSizes.s9),
        ),
        const SizedBox(height: AppSpacing.s6),
        Text(
          l10n.journeyChooseTemple,
          style: _cardText.copyWith(fontSize: AppFontSizes.s18),
        ),
        const SizedBox(height: AppSpacing.s6),
        Text(
          l10n.journeyChooseTempleHint,
          style: _cardText.copyWith(fontSize: AppFontSizes.s11),
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
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.journeyActiveCrystalLabel,
          style: _mutedText.copyWith(fontSize: AppFontSizes.s9),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          crystal.localizedName(l10n),
          style: _cardText.copyWith(
            fontSize: AppFontSizes.s22,
            letterSpacing: 1.6,
          ),
        ),
        Text(
          crystal.localizedTemple(l10n).toUpperCase(),
          style: _mutedText.copyWith(
            fontSize: AppFontSizes.s9,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          crystal.localizedFrequency(l10n),
          style: _cardText.copyWith(fontSize: AppFontSizes.s13),
        ),
        const SizedBox(height: AppSpacing.s6),
        Container(width: 42, height: 0.5, color: AppColors.champagneGold),
        const SizedBox(height: AppSpacing.s6),
        Text(
          crystal.localizedPurpose(l10n),
          style: _cardText.copyWith(fontSize: AppFontSizes.s11),
        ),
      ],
    );
  }
}

class DailyStreakCard extends ConsumerWidget {
  const DailyStreakCard({super.key});

  static const int _daysPerRow = 15;
  static const double _dayGap = AppSpacing.s4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final progress = ref.watch(journeyProgressProvider);
    return _JourneyCard(
      child: Column(
        children: [
          _CardHeading(
            icon: 'assets/images/journey_sun.svg',
            label: l10n.journeyStreakTitle,
            trailing: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/journey_flame.svg',
                  width: 16,
                  height: 16,
                  excludeFromSemantics: true,
                ),
                const SizedBox(width: AppSpacing.s6),
                Text(
                  '${progress.streak} / ${progress.cycleLength}',
                  style: _cardText.copyWith(
                    fontSize: AppFontSizes.s18,
                    height: 1,
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Text(l10n.journeyStreakDaysInARow, style: _mutedText),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s10),
          Container(
            height: 0.4,
            color: AppColors.champagneGold60.withValues(alpha: 0.7),
          ),
          const SizedBox(height: AppSpacing.s10),
          LayoutBuilder(
            builder: (context, constraints) {
              final daySize =
                  (constraints.maxWidth - _dayGap * (_daysPerRow - 1)) /
                  _daysPerRow;

              return Semantics(
                label: l10n.commonDayOfTotal(
                  progress.currentDay,
                  progress.cycleLength,
                ),
                excludeSemantics: true,
                child: Wrap(
                  spacing: _dayGap,
                  runSpacing: 8,
                  children: [
                    for (var day = 1; day <= progress.cycleLength; day++)
                      _DayDot(
                        day: day,
                        currentDay: progress.currentDay,
                        size: daySize,
                      ),
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
  const _DayDot({
    required this.day,
    required this.currentDay,
    required this.size,
  });

  final int day;
  final int currentDay;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isCompleted = day < currentDay;
    final isToday = day == currentDay;

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
            ? const [BoxShadow(color: AppColors.goldGlow, blurRadius: 4)]
            : null,
      ),
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s2),
          child: Text(
            '$day',
            style: _cardText.copyWith(
              fontSize: AppFontSizes.s10,
              height: 1,
              color: isCompleted ? AppColors.darkIndigoBlue : AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressPhotosCard extends ConsumerWidget {
  const ProgressPhotosCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final progress = ref.watch(journeyProgressProvider);
    final photos =
        ref.watch(reflectionPhotoControllerProvider).value ??
        ReflectionGallery.empty;
    final currentDay = l10n.journeyPhotoDay(progress.currentDay);
    final firstDay = l10n.journeyPhotoDay(1);
    final currentBytes = progress.currentDay == 1
        ? photos.before
        : photos.later;
    return _JourneyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading(
            icon: 'assets/images/journey_image.svg',
            label: l10n.journeyPhotosTitle,
            trailing: Semantics(
              button: true,
              label: l10n.journeyPhotosViewAllSemantics,
              excludeSemantics: true,
              child: InkWell(
                onTap: () => _openProgressPhotos(context),
                borderRadius: BorderRadius.circular(AppRadii.r6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s4,
                    vertical: AppSpacing.s2,
                  ),
                  child: Text(
                    l10n.journeyPhotosViewAll,
                    style: _cardText.copyWith(
                      fontSize: AppFontSizes.s10_5,
                      color: AppColors.champagneGold60,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            l10n.journeyPhotosSubtitle,
            style: _cardText.copyWith(fontSize: AppFontSizes.s11),
          ),
          const SizedBox(height: AppSpacing.s10),
          Row(
            children: [
              Expanded(
                child: _ProgressPortrait(
                  asset: 'assets/images/journey_before.png',
                  bytes: photos.before,
                  day: firstDay,
                  label: l10n.journeyPhotoBefore,
                  semanticLabel: l10n.journeyPhotoBeforeSemantics(firstDay),
                ),
              ),
              Container(
                width: 24,
                height: 0.6,
                color: AppColors.champagneGold80,
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: _ProgressPortrait(
                  asset: 'assets/images/journey_current.png',
                  bytes: currentBytes,
                  day: currentDay,
                  label: l10n.journeyPhotoCurrent,
                  semanticLabel: photos.canCapture
                      ? l10n.journeyPhotoCaptureSemantics
                      : l10n.journeyPhotoCurrentSemantics(currentDay),
                  onTap: photos.canCapture
                      ? () => _captureProgressPhoto(context, ref)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _openProgressPhotos(BuildContext context) {
  Navigator.of(
    context,
    rootNavigator: true,
  ).push(MaterialPageRoute<void>(builder: (_) => const ProgressPhotosScreen()));
}

Future<void> _captureProgressPhoto(BuildContext context, WidgetRef ref) async {
  final bytes = await Navigator.of(context, rootNavigator: true)
      .push<Uint8List>(
        MaterialPageRoute(builder: (_) => const FaceCameraScreen()),
      );
  if (bytes == null) return;
  await ref.read(reflectionPhotoControllerProvider.notifier).capture(bytes);
}

class _ProgressPortrait extends StatelessWidget {
  const _ProgressPortrait({
    required this.asset,
    required this.day,
    required this.label,
    required this.semanticLabel,
    this.bytes,
    this.onTap,
  });

  static const double _size = 62;

  final String asset;
  final Uint8List? bytes;
  final String day;
  final String label;
  final String semanticLabel;
  final VoidCallback? onTap;

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
            child: Semantics(
              button: onTap != null,
              label: semanticLabel,
              child: GestureDetector(
                onTap: onTap,
                child: bytes == null
                    ? Image.asset(
                        asset,
                        fit: BoxFit.cover,
                        excludeFromSemantics: true,
                      )
                    : Image.memory(
                        bytes!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        excludeFromSemantics: true,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(day, style: _mutedText.copyWith(fontSize: AppFontSizes.s9)),
              Text(
                label,
                style: _cardText.copyWith(fontSize: AppFontSizes.s12),
              ),
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
    final l10n = AppLocalizations.of(context);
    final title = crystal == null
        ? l10n.journeyChooseCrystal
        : '${crystal.localizedName(l10n)} · ${crystal.localizedFrequency(l10n)}';

    return Semantics(
      button: true,
      label: l10n.journeyContinuesSemantics(title),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => _openCrystal(context, crystal),
        child: _JourneyCard(
          child: Column(
            children: [
              _CardHeading(
                icon: 'assets/images/journey_lock.svg',
                label: l10n.journeyContinuesTitle,
              ),
              const SizedBox(height: AppSpacing.s10),
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
                  const SizedBox(width: AppSpacing.s13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: _cardText.copyWith(
                            fontSize: AppFontSizes.s12_5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          l10n.journeyContinuesSubtitle,
                          style: _mutedText.copyWith(
                            fontSize: AppFontSizes.s9_5,
                          ),
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
