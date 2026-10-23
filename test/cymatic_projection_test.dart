import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/core/design_system/theme/app_theme.dart';
import 'package:hikaru/core/media/remote_image.dart';
import 'package:hikaru/features/crystals/domain/crystal.dart';
import 'package:hikaru/features/resonance_chamber/data/cymatic_headphones_prompts.dart';
import 'package:hikaru/features/resonance_chamber/presentation/crystal_resonance_screen.dart';
import 'package:hikaru/features/resonance_chamber/presentation/cymatic_signature.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:hikaru/l10n/app_localizations.dart';

void main() {
  late List<List<String>> orientations;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    orientations = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'SystemChrome.setPreferredOrientations') {
            orientations.add([
              for (final value in call.arguments as List<Object?>)
                value.toString(),
            ]);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('play opens the headphones note, then a rotatable cymatic', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpCrystal(tester);

    expect(_remoteImage('jade.png'), findsOneWidget);
    expect(find.bySemanticsLabel('JADE crystal'), findsOneWidget);
    expect(find.textContaining('immersive experience'), findsNothing);
    expect(find.bySemanticsLabel('Cymatic'), findsNothing);
    expect(find.bySemanticsLabel('Exit'), findsNothing);

    await tester.ensureVisible(find.bySemanticsLabel('Play frequency'));
    await tester.tap(find.bySemanticsLabel('Play frequency'));
    await tester.pumpAndSettle();

    expect(find.textContaining('immersive experience'), findsOneWidget);
    expect(find.text("I'M READY"), findsOneWidget);
    expect(find.text('CONTINUE WITHOUT HEADPHONES'), findsOneWidget);
    expect(find.byIcon(Icons.headphones_outlined), findsOneWidget);
    expect(find.bySemanticsLabel('Cymatic'), findsNothing);

    await tester.tap(find.text("I'M READY"));
    await _pumpUntil(tester, find.bySemanticsLabel('Cymatic'));

    expect(find.textContaining('immersive experience'), findsNothing);
    expect(_remoteImage('jade.png'), findsNothing);
    expect(find.bySemanticsLabel('Exit'), findsNothing);
    expect(find.bySemanticsLabel('Pause'), findsNothing);
    expect(_assetImage('assets/images/merkaba_starry_night.jpg'), findsNothing);
    expect(orientations.last, [
      'DeviceOrientation.portraitUp',
      'DeviceOrientation.landscapeLeft',
      'DeviceOrientation.landscapeRight',
    ]);

    expect(tester.getSize(find.byType(CymaticSignature)), const Size(390, 844));
    expect(
      tester.widget<CymaticSignature>(find.byType(CymaticSignature)).style,
      CymaticStyle.kaleidoscope,
    );
    expect(
      await SharedPreferencesAsync().getInt(
        CymaticHeadphonesPrompts.storageKey,
      ),
      1,
    );

    tester.view.physicalSize = const Size(844, 390);
    await tester.pump();

    expect(tester.getSize(find.byType(CymaticSignature)), const Size(844, 390));

    await tester.tap(find.bySemanticsLabel('Cymatic'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.bySemanticsLabel('Pause'), findsOneWidget);
    expect(find.bySemanticsLabel('Exit'), findsOneWidget);
    expect(find.text('JADE'), findsOneWidget);
    expect(find.text('${Crystal.jade.hertz} Hz'), findsOneWidget);
    expect(
      tester.getCenter(find.bySemanticsLabel('Exit')).dx,
      greaterThan(tester.getCenter(find.byType(CymaticSignature)).dx),
    );

    await tester.tap(find.bySemanticsLabel('Pause'));
    await tester.pump();
    expect(find.bySemanticsLabel('Play'), findsOneWidget);
    expect(find.bySemanticsLabel('Cymatic'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Exit'));
    tester.view.physicalSize = const Size(390, 844);
    await _pumpUntil(tester, find.bySemanticsLabel('Play frequency'));

    expect(find.bySemanticsLabel('Cymatic'), findsNothing);
    expect(find.bySemanticsLabel('Exit'), findsNothing);
    expect(_remoteImage('jade.png'), findsOneWidget);
    expect(find.text('JADE'), findsWidgets);
    expect(orientations.last, ['DeviceOrientation.portraitUp']);
  });

  testWidgets('the headphones note still reminds after earlier confirms', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await SharedPreferencesAsync().setInt(
      CymaticHeadphonesPrompts.storageKey,
      CymaticHeadphonesPrompts.showLimit,
    );
    await _pumpCrystal(tester);

    await tester.ensureVisible(find.bySemanticsLabel('Play frequency'));
    await tester.tap(find.bySemanticsLabel('Play frequency'));
    await tester.pumpAndSettle();

    expect(find.text("I'M READY"), findsOneWidget);
    expect(find.text('CONTINUE WITHOUT HEADPHONES'), findsOneWidget);
    expect(find.byIcon(Icons.headphones_outlined), findsOneWidget);
    expect(find.bySemanticsLabel('Cymatic'), findsNothing);
  });
}

Future<void> _pumpCrystal(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CrystalResonanceScreen(crystal: Crystal.jade),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (var frame = 0; frame < 20; frame++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for $finder');
}

Finder _remoteImage(String fileName) => find.byWidgetPredicate(
  (widget) => widget is RemoteImage && widget.fileName == fileName,
);

Finder _assetImage(String asset) => find.byWidgetPredicate(
  (widget) =>
      widget is Image &&
      widget.image is AssetImage &&
      (widget.image as AssetImage).assetName == asset,
);
