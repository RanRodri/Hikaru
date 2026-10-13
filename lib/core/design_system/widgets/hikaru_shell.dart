import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';
import '../tokens/app_colors.dart';
import 'hikaru_header.dart';
import 'hikaru_navigation_bar.dart';

typedef HikaruScaledBuilder =
    Widget Function(BuildContext context, double scale);

class HikaruShell extends StatelessWidget {
  const HikaruShell({
    super.key,
    required this.active,
    required this.builder,
    this.backgroundAsset = gardenBackground,
    this.dimBackground = false,
  });

  static const double designWidth = 390;
  static const String gardenBackground =
      'assets/images/harmony_garden_background.png';

  /// Neutral landscape with no figure. Journal uses it.
  static const String journalLandscape = 'assets/images/sanctuary_hero.png';
  static const Map<HikaruDestination, String> _destinationRoutes = {
    HikaruDestination.home: AppRoutes.home,
    HikaruDestination.journey: AppRoutes.journey,
    HikaruDestination.library: AppRoutes.library,
    HikaruDestination.settings: AppRoutes.profile,
  };

  static const Map<HikaruDestination, int> _branchIndex = {
    HikaruDestination.home: 0,
    HikaruDestination.journey: 1,
    HikaruDestination.library: 2,
    HikaruDestination.settings: 3,
  };

  final HikaruDestination active;
  final HikaruScaledBuilder builder;
  final String backgroundAsset;
  final bool dimBackground;

  void _handleDestinationSelected(
    BuildContext context,
    HikaruDestination destination,
  ) {
    final route = _destinationRoutes[destination];
    if (route == null) return;

    final location = GoRouterState.of(context).uri.path;
    final shell = StatefulNavigationShell.maybeOf(context);
    if (shell == null) {
      if (location == route) return;
      context.go(route);
      return;
    }

    final index = _branchIndex[destination];
    if (index == null) return;
    final onThisBranch = shell.currentIndex == index;
    if (onThisBranch && location == route) return;
    shell.goBranch(index, initialLocation: onThisBranch);
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / designWidth;

          return Stack(
            fit: StackFit.expand,
            children: [
              Image(
                image: AssetImage(backgroundAsset),
                fit: BoxFit.cover,
                excludeFromSemantics: true,
              ),
              if (dimBackground) const _BackgroundDim(),
              builder(context, scale),
              Positioned(
                left: 0,
                right: 0,
                bottom: HikaruNavigationBar.height + insets.bottom,
                height: 84,
                child: const _NavTransition(),
              ),
              Positioned(
                top: insets.top,
                left: 0,
                right: 0,
                child: const HikaruHeader(),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: HikaruNavigationBar(
                  active: active,
                  onSelected: (destination) =>
                      _handleDestinationSelected(context, destination),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BackgroundDim extends StatelessWidget {
  const _BackgroundDim();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkIndigoBlue.withValues(alpha: 0.35),
              AppColors.darkIndigoBlue.withValues(alpha: 0.6),
              AppColors.darkIndigoBlue.withValues(alpha: 0.7),
            ],
            stops: const [0, 0.35, 1],
          ),
        ),
      ),
    );
  }
}

class _NavTransition extends StatelessWidget {
  const _NavTransition();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.indigoBlue.withValues(alpha: 0),
              AppColors.indigoBlue.withValues(alpha: 0.25),
            ],
          ),
        ),
      ),
    );
  }
}
