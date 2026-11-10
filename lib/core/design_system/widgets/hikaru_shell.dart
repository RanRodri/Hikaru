import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../media/remote_image.dart';
import '../../../features/journey/presentation/ritual_cycle_routes.dart';
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
    this.backgroundScale = 1,
    this.backgroundOffsetY = 0,
  });

  static const double designWidth = 390;
  static const String gardenBackground = RemoteImages.harmonyGarden;

  /// Garden sunset with no figure. Journey and Settings use it.
  static const String sunsetGarden = RemoteImages.sunsetGarden;
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

  /// Optional photographic crop adjustments, in design pixels. Home uses
  /// these to lift the woman without changing other shell screens.
  final double backgroundScale;
  final double backgroundOffsetY;

  void _handleDestinationSelected(
    BuildContext context,
    HikaruDestination destination,
  ) {
    if (destination == HikaruDestination.sanctuary) {
      // Straight to the first step still waiting today.
      context.go(cycleEntryRoute(context));
      return;
    }

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
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(0, backgroundOffsetY * scale),
                  child: Transform.scale(
                    scale: backgroundScale,
                    child: RemoteImage(
                      fileName: backgroundAsset,
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
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
              AppColors.indigoBlue.withValues(alpha: 0.3),
              AppColors.indigoBlue.withValues(alpha: 0.5),
              AppColors.indigoBlue.withValues(alpha: 0.62),
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
