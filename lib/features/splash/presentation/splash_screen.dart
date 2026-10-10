import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/widgets/radial_glow_background.dart';
import 'splash_controller.dart';
import 'splash_logo.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(splashDestinationProvider, (_, destination) {
      final route = destination.value;
      if (route == null) return;

      context.go(route);
    });

    return const Scaffold(
      body: RadialGlowBackground(child: Center(child: SplashLogo())),
    );
  }
}
