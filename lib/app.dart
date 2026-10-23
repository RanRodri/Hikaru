import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/design_system/theme/app_theme.dart';
import 'core/localization/locale_controller.dart';
import 'core/localization/supported_locales.dart';
import 'core/router/app_router.dart';
import 'l10n/app_localizations.dart';

class HikaruApp extends ConsumerWidget {
  const HikaruApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // English unless the user picked another language. It also applies while
    // the stored preference loads; the app rebuilds once a choice is found.
    final locale = ref.watch(localeControllerProvider).value ?? defaultLocale;

    return MaterialApp.router(
      title: 'Hikaru Lift',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
