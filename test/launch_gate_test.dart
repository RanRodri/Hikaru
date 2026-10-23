import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/core/router/app_routes.dart';
import 'package:hikaru/features/splash/data/launch_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('intro plays once, then splash leads to login or home', () {
    expect(
      routeAfterSplash(introSeen: false, sessionOpen: false),
      AppRoutes.sanctuary,
    );
    expect(
      routeAfterSplash(introSeen: true, sessionOpen: false),
      AppRoutes.login,
    );
    expect(
      routeAfterSplash(introSeen: true, sessionOpen: true),
      AppRoutes.home,
    );
  });

  test('sign-in keeps the session open for the next launch', () async {
    final gate = LaunchGate(SharedPreferencesAsync());
    expect(await gate.introSeen(), isFalse);
    expect(await gate.sessionOpen(), isFalse);

    await gate.markIntroSeen();
    await gate.openSession();

    expect(await gate.introSeen(), isTrue);
    expect(await gate.sessionOpen(), isTrue);
  });
}
