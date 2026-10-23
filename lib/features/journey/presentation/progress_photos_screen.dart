import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../application/reflection_photo_controller.dart';
import '../application/ritual_cycle_controller.dart';
import '../domain/reflection_photo.dart';

/// Every progress photo of the open cycle.
class ProgressPhotosScreen extends ConsumerWidget {
  const ProgressPhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final photos =
        ref.watch(reflectionPhotoControllerProvider).value ??
        ReflectionGallery.empty;
    final currentDay = ref.watch(journeyProgressProvider).currentDay;
    final shots = photos.shots;

    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s12,
                AppSpacing.s20,
                0,
              ),
              child: _BackButton(onPressed: () => Navigator.of(context).pop()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s8,
              ),
              child: Text(
                l10n.journeyPhotosTitle,
                style: AppTypography.headline.copyWith(
                  color: AppColors.white,
                  fontSize: AppFontSizes.s16,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
              child: Text(
                l10n.journeyPhotosSubtitle,
                style: AppTypography.body.copyWith(
                  color: AppColors.fog,
                  fontSize: AppFontSizes.s13,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Expanded(
              child: shots.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s20,
                      ),
                      child: Text(
                        l10n.journeyPhotosEmpty,
                        style: AppTypography.body.copyWith(
                          color: AppColors.champagneGold40,
                          fontSize: AppFontSizes.s13,
                          height: 1.4,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s20,
                        0,
                        AppSpacing.s20,
                        AppSpacing.s24,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: AppSpacing.s16,
                            crossAxisSpacing: AppSpacing.s12,
                            childAspectRatio: 0.68,
                          ),
                      itemCount: shots.length,
                      itemBuilder: (context, index) {
                        final shot = shots[index];
                        final day = l10n.journeyPhotoDay(shot.dayNumber);
                        final role = _photoRole(
                          l10n,
                          shot: shot,
                          gallery: photos,
                          today: currentDay,
                        );
                        return _PhotoTile(
                          shot: shot,
                          day: day,
                          role: role,
                          semanticLabel: role == null
                              ? l10n.journeyPhotoGallerySemantics(day)
                              : shot.dayNumber == 1
                              ? l10n.journeyPhotoBeforeSemantics(day)
                              : l10n.journeyPhotoCurrentSemantics(day),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

String? _photoRole(
  AppLocalizations l10n, {
  required ReflectionShot shot,
  required ReflectionGallery gallery,
  required int today,
}) {
  if (shot.dayNumber == 1) return l10n.journeyPhotoBefore;
  if (today > 1 && shot.dayNumber == gallery.currentDayNumber) {
    return l10n.journeyPhotoCurrent;
  }
  return null;
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.shot,
    required this.day,
    required this.role,
    required this.semanticLabel,
  });

  final ReflectionShot shot;
  final String day;
  final String? role;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    ProgressPhotoViewer(shot: shot, day: day, role: role),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppRadii.r16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.r16),
                    border: Border.all(
                      color: AppColors.champagneGold80,
                      width: 0.8,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.r16),
                    child: Image.memory(
                      shot.bytes,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      gaplessPlayback: true,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                day,
                style: AppTypography.footnote.copyWith(
                  color: AppColors.champagneGold40,
                  fontSize: AppFontSizes.s10,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                role ?? '',
                style: AppTypography.headline.copyWith(
                  color: AppColors.white,
                  fontSize: AppFontSizes.s13,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.commonBack,
      excludeSemantics: true,
      child: Material(
        color: AppColors.darkIndigoBlue.withValues(alpha: 0.45),
        shape: StadiumBorder(
          side: BorderSide(
            color: AppColors.champagneGold.withValues(alpha: 0.6),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            child: Text(
              l10n.commonBack,
              style: AppTypography.footnote.copyWith(
                color: AppColors.champagneGold,
                fontSize: AppFontSizes.s11,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One progress photo, large enough to compare with the others.
class ProgressPhotoViewer extends StatelessWidget {
  const ProgressPhotoViewer({
    super.key,
    required this.shot,
    required this.day,
    this.role,
  });

  final ReflectionShot shot;
  final String day;
  final String? role;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s12,
                AppSpacing.s20,
                AppSpacing.s12,
              ),
              child: _BackButton(onPressed: () => Navigator.of(context).pop()),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
                child: Semantics(
                  label: role == null
                      ? l10n.journeyPhotoGallerySemantics(day)
                      : shot.dayNumber == 1
                      ? l10n.journeyPhotoBeforeSemantics(day)
                      : l10n.journeyPhotoCurrentSemantics(day),
                  image: true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.r20),
                    child: Image.memory(
                      shot.bytes,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      gaplessPlayback: true,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s16,
                AppSpacing.s20,
                AppSpacing.s24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day,
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.champagneGold40,
                      fontSize: AppFontSizes.s11,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (role != null)
                    Text(
                      role!,
                      style: AppTypography.headline.copyWith(
                        color: AppColors.white,
                        fontSize: AppFontSizes.s18,
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
