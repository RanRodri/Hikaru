import 'dart:async';
import 'dart:developer';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/backend/cognito_session.dart';
import 'core/design_system/theme/app_theme.dart';
import 'core/localization/locale_controller.dart';
import 'core/localization/supported_locales.dart';
import 'core/media/remote_image.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'features/auth/application/sign_out.dart';
import 'features/auth/data/session_inactivity.dart';
import 'l10n/app_localizations.dart';

class HikaruApp extends ConsumerStatefulWidget {
  const HikaruApp({super.key});

  @override
  ConsumerState<HikaruApp> createState() => _HikaruAppState();
}

class _HikaruAppState extends ConsumerState<HikaruApp>
    with WidgetsBindingObserver {
  StreamSubscription<AuthHubEvent>? _authEvents;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cognitoSessionExpired.addListener(_handleSessionExpired);
    // Amplify's own token refreshes (API, Storage) report an expired
    // session only through the Hub.
    if (Amplify.isConfigured) {
      _authEvents = Amplify.Hub.listen(HubChannel.Auth, (event) {
        if (event.type == AuthHubEventType.sessionExpired) {
          cognitoSessionExpired.value = true;
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cognitoSessionExpired.removeListener(_handleSessionExpired);
    unawaited(_authEvents?.cancel());
    super.dispose();
  }

  /// Cognito ended the session (30-day refresh token, user removed or
  /// disabled). Straight to Login, explaining why. The phone's progress is
  /// kept: it is sent once the same member signs back in.
  void _handleSessionExpired() {
    if (!cognitoSessionExpired.value || !mounted) return;
    final router = ref.read(appRouterProvider);
    final path = router.routerDelegate.currentConfiguration.uri.path;
    // The splash decides on its own; the auth screens are already there.
    const stay = {
      AppRoutes.splash,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.confirmSignUp,
      AppRoutes.resetPassword,
    };
    if (stay.contains(path)) return;
    router.go(AppRoutes.loginSessionExpired);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _handleResumed();
      case AppLifecycleState.paused:
        // Only `paused`: on the way back the app also passes through
        // `inactive`, which would erase the idle time before it is measured.
        ref.read(sessionInactivityProvider).touch();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  /// Back in the foreground.
  ///
  /// An open session continues, and a cold start is decided by the splash.
  /// A session Cognito already rejected, or one left idle for 48 hours,
  /// cannot remain on Home or any other member screen.
  Future<void> _handleResumed() async {
    try {
      final inactivity = ref.read(sessionInactivityProvider);
      final session = await readCognitoSession();
      if (!mounted) return;
      final path = ref
          .read(appRouterProvider)
          .routerDelegate
          .currentConfiguration
          .uri
          .path;

      if (session == CognitoSessionState.expired) {
        await _endSession(AppRoutes.loginSessionExpired);
        return;
      }
      if (session != CognitoSessionState.active) {
        await inactivity.clear();
        if (!mounted || !AppRoutes.requiresSession(path)) return;
        await _endSession(AppRoutes.login);
        return;
      }
      if (await inactivity.hasExpired()) {
        await _endSession(AppRoutes.login);
        return;
      }
      await inactivity.touch();
    } catch (error, stackTrace) {
      log(
        'Session inactivity check',
        name: 'hikaru.auth',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _endSession(String route) async {
    await ref.read(memberSignOutProvider)();
    if (!mounted) return;
    ref.read(appRouterProvider).go(route);
  }

  @override
  Widget build(BuildContext context) {
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
      builder: (context, child) =>
          _FallbackImagePrimer(child: child ?? const SizedBox.shrink()),
    );
  }
}

/// Decodes every lightweight background while the splash is on screen. Later
/// routes use the same AssetImage keys, so their first frame already has a
/// photo even on a slow or offline first launch.
class _FallbackImagePrimer extends StatefulWidget {
  const _FallbackImagePrimer({required this.child});

  final Widget child;

  @override
  State<_FallbackImagePrimer> createState() => _FallbackImagePrimerState();
}

class _FallbackImagePrimerState extends State<_FallbackImagePrimer> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    for (final asset in RemoteImages.fallbacks.values) {
      unawaited(precacheImage(AssetImage(asset), context));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
