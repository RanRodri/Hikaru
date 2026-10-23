import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../l10n/app_localizations.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_font_sizes.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

enum HikaruDestination { home, journey, sanctuary, library, settings }

class HikaruNavigationBar extends StatelessWidget {
  const HikaruNavigationBar({
    super.key,
    required this.active,
    required this.onSelected,
    this.sanctuaryKey,
    this.barKey,
  });

  static const double height = 70;
  static const Color _activeColor = AppColors.navActive;

  final HikaruDestination active;
  final ValueChanged<HikaruDestination> onSelected;
  final Key? sanctuaryKey;
  final Key? barKey;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return KeyedSubtree(
      key: barKey,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.navShadow, AppColors.navScrim],
              ),
              border: Border(
                top: BorderSide(color: AppColors.champagneGold, width: 0.35),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SizedBox(
                height: height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s9,
                    vertical: AppSpacing.s12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final destination in HikaruDestination.values)
                        destination == HikaruDestination.sanctuary
                            ? _SanctuaryButton(
                                key: sanctuaryKey,
                                onPressed: () => onSelected(destination),
                              )
                            : _NavItem(
                                destination: destination,
                                active: destination == active,
                                onPressed: () => onSelected(destination),
                              ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.active,
    required this.onPressed,
  });

  static const Map<HikaruDestination, String> _icons = {
    HikaruDestination.home: 'assets/images/nav_home.svg',
    HikaruDestination.journey: 'assets/images/nav_journey.svg',
    HikaruDestination.library: 'assets/images/nav_library.svg',
    HikaruDestination.settings: 'assets/images/nav_settings.svg',
  };

  static String _label(AppLocalizations l10n, HikaruDestination destination) =>
      switch (destination) {
        HikaruDestination.home => l10n.navHome,
        HikaruDestination.journey => l10n.navJourney,
        HikaruDestination.library => l10n.navLibrary,
        HikaruDestination.settings => l10n.navSettings,
        HikaruDestination.sanctuary => l10n.navSanctuary,
      };

  final HikaruDestination destination;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = active ? HikaruNavigationBar._activeColor : AppColors.white;
    final label = _label(AppLocalizations.of(context), destination);

    return Semantics(
      button: true,
      selected: active,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        child: SizedBox(
          width: AppSpacing.s66,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                _icons[destination]!,
                width: 21,
                height: 21,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                label,
                maxLines: 1,
                style: AppTypography.headline.copyWith(
                  color: color,
                  fontSize: AppFontSizes.s8_5,
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

class _SanctuaryButton extends StatelessWidget {
  const _SanctuaryButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).navSanctuary,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SvgPicture.asset(
          'assets/images/nav_sanctuary.svg',
          width: 45,
          height: 45,
        ),
      ),
    );
  }
}
