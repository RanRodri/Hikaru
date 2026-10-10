import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

enum HikaruDestination { home, journey, sanctuary, library, settings }

class HikaruNavigationBar extends StatelessWidget {
  const HikaruNavigationBar({
    super.key,
    required this.active,
    required this.onSelected,
  });

  static const double height = 70;
  static const Color _activeColor = Color(0xFFFFE6AC);

  final HikaruDestination active;
  final ValueChanged<HikaruDestination> onSelected;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(58, 42, 16, 0.25),
                Color.fromRGBO(10, 11, 23, 0.5),
              ],
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
                  horizontal: 9,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final destination in HikaruDestination.values)
                      destination == HikaruDestination.sanctuary
                          ? _SanctuaryButton(
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

  static const Map<HikaruDestination, String> _labels = {
    HikaruDestination.home: 'Home',
    HikaruDestination.journey: 'Journey',
    HikaruDestination.library: 'Library',
    HikaruDestination.settings: 'Settings',
  };

  final HikaruDestination destination;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = active ? HikaruNavigationBar._activeColor : AppColors.white;

    return Semantics(
      button: true,
      selected: active,
      label: _labels[destination],
      excludeSemantics: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 66,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                _icons[destination]!,
                width: 21,
                height: 21,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(height: 4),
              Text(
                _labels[destination]!,
                maxLines: 1,
                style: AppTypography.headline.copyWith(
                  color: color,
                  fontSize: 8.5,
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
  const _SanctuaryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Sanctuary',
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
