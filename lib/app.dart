import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/design_system/theme/app_theme.dart';
import 'core/router/app_router.dart';

class HikaruApp extends ConsumerWidget {
  const HikaruApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Hikaru Lift',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
