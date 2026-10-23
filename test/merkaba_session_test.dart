import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/features/merkaba/data/merkaba_progress_repository.dart';
import 'package:hikaru/features/merkaba/domain/merkaba_session.dart';
import 'package:hikaru/features/merkaba/presentation/merkaba_painter.dart';
import 'package:hikaru/features/merkaba/presentation/merkaba_screen.dart';
import 'package:hikaru/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('breath phases follow the 4-4-6 cycle', () {
    expect(merkabaFrameAt(Duration.zero).phase, BreathPhase.inhale);
    expect(merkabaFrameAt(Duration.zero).phaseSecondsRemaining, 4);
    expect(merkabaFrameAt(const Duration(seconds: 4)).phase, BreathPhase.hold);
    expect(merkabaFrameAt(const Duration(seconds: 4)).phaseSecondsRemaining, 4);
    expect(
      merkabaFrameAt(const Duration(seconds: 8)).phase,
      BreathPhase.exhale,
    );
    expect(merkabaFrameAt(const Duration(seconds: 8)).phaseSecondsRemaining, 6);
    expect(
      merkabaFrameAt(const Duration(seconds: 14)).phase,
      BreathPhase.inhale,
    );
    expect(formatMerkabaClock(const Duration(seconds: 65)), '01:05');
    expect(merkabaFrameAt(Duration.zero).completedCycles, 0);
    expect(merkabaFrameAt(Duration.zero).cycleProgress, 0);
    expect(merkabaFrameAt(const Duration(seconds: 7)).completedCycles, 0);
    expect(
      merkabaFrameAt(const Duration(seconds: 7)).cycleProgress,
      closeTo(0.5, 0.001),
    );
    expect(merkabaFrameAt(const Duration(seconds: 14)).completedCycles, 1);
    expect(merkabaFrameAt(const Duration(seconds: 28)).completedCycles, 2);
    expect(merkabaFrameAt(Duration.zero).sessionProgress, 0);
    expect(
      merkabaFrameAt(const Duration(seconds: 150)).sessionProgress,
      closeTo(0.5, 0.001),
    );
    expect(merkabaFrameAt(merkabaDuration).sessionProgress, 1);
    expect(merkabaFrameAt(merkabaDuration).completedCycles, 21);
    expect(merkabaTotalBreaths, 21);
    expect(merkabaFrameAt(Duration.zero).breathLevel, 0);
    expect(merkabaFrameAt(const Duration(seconds: 2)).breathLevel, 0.5);
    expect(merkabaFrameAt(const Duration(seconds: 6)).breathLevel, 1);
    expect(merkabaFrameAt(const Duration(seconds: 11)).breathLevel, 0.5);
  });

  test('scenes change at the brief timestamps', () {
    expect(merkabaFrameAt(Duration.zero).scene.mudra, 'Gyan Mudra');
    expect(
      merkabaFrameAt(const Duration(seconds: 39)).scene.title,
      'Human Blueprint',
    );
    expect(
      merkabaFrameAt(const Duration(seconds: 40)).scene.title,
      'Air Becomes the Vehicle',
    );
    expect(
      merkabaFrameAt(const Duration(seconds: 40)).scene.mudra,
      'Vayu Mudra',
    );
    expect(
      merkabaFrameAt(const Duration(seconds: 90)).scene.mudra,
      'Lotus Mudra',
    );
    expect(
      merkabaFrameAt(const Duration(seconds: 219)).scene.title,
      'Breath Builds the Merkaba',
    );
    expect(merkabaScenes, hasLength(5));
    expect(
      merkabaFrameAt(const Duration(seconds: 220)).scene.mudra,
      'Akash Mudra',
    );
    expect(merkabaFrameAt(const Duration(seconds: 270)).scene.mudra, 'Anjali');
    expect(merkabaFrameAt(merkabaDuration).isFinished, isTrue);
    expect(merkabaFrameAt(merkabaDuration).scene.title, 'The Heart Blossoms');
  });

  test('the seated woman portrait decodes', () async {
    final data = await rootBundle.load(merkabaWomanAsset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    expect(frame.image.width, 900);
    expect(frame.image.height, 720);
    final bytes = await frame.image.toByteData();
    expect(bytes, isNotNull);
    final heart = _rgba(bytes!, frame.image.width, 450, 344);
    expect(heart.$4, greaterThan(200), reason: 'heart stays opaque');
    expect(heart.$1 + heart.$2, greaterThan(400), reason: 'heart is bright');
    frame.image.dispose();
  });

  testWidgets('reduced motion keeps the woman and the mid-session scene', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: MerkabaMeditationScreen(
              initialElapsed: Duration(seconds: 154),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(merkabaWomanAsset),
        tester.element(
          find.byWidgetPredicate(
            (widget) =>
                widget is Image &&
                widget.image is AssetImage &&
                (widget.image as AssetImage).assetName == merkabaWomanAsset,
          ),
        ),
      );
    });
    await tester.pump();

    expect(find.text('Breath Builds the Merkaba'), findsOneWidget);
    expect(find.text('SCENE 3 OF 5'), findsOneWidget);
    expect(find.text('Lotus Mudra'), findsOneWidget);
    expect(find.text('11 / 21'), findsOneWidget);
    expect(find.text('Cycle 0%'), findsOneWidget);
    expect(find.text('Inhale'), findsOneWidget);
    expect(_mudraSvg('assets/images/mudras/lotus.svg'), findsOneWidget);
    expect(_mudraSvg('assets/images/mudras/gyan.svg'), findsNothing);
    expect(find.bySemanticsLabel('Session progress'), findsOneWidget);
    expect(find.bySemanticsLabel('Seated woman in meditation'), findsOneWidget);
  });

  testWidgets('scene one keeps the Gyan mudra over the whole opening', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: MerkabaMeditationScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Human Blueprint'), findsOneWidget);
    expect(find.text('Gyan Mudra'), findsOneWidget);
    expect(find.text('0 / 21'), findsOneWidget);
    expect(_mudraSvg('assets/images/mudras/gyan.svg'), findsOneWidget);
    expect(find.bySemanticsLabel('Session progress'), findsOneWidget);
  });

  testWidgets('finishing the session records it and REPEAT restarts', (
    tester,
  ) async {
    final progress = InMemoryMerkabaProgressRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          merkabaProgressRepositoryProvider.overrideWithValue(progress),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: MerkabaMeditationScreen(
              initialElapsed: Duration(minutes: 4, seconds: 59),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Silence.'), findsOneWidget);
    final finished = await progress.history();
    expect(finished, hasLength(1));
    expect(finished.single.completed, isTrue);
    expect(finished.single.completedCycles, 21);

    await tester.tap(find.text('REPEAT'));
    await tester.pump();
    expect(find.text('Human Blueprint'), findsOneWidget);
    expect(find.text('0 / 21'), findsOneWidget);
    expect(find.text('PAUSE'), findsOneWidget);

    await tester.tap(find.text('PAUSE'));
    await tester.pump(const Duration(seconds: 3));
    expect(await progress.history(), hasLength(1));
  });

  testWidgets('leaving mid-session stores the cycles so far', (tester) async {
    final progress = InMemoryMerkabaProgressRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          merkabaProgressRepositoryProvider.overrideWithValue(progress),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: MerkabaMeditationScreen(
              initialElapsed: Duration(seconds: 28),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('2 / 21'), findsOneWidget);

    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.tap(find.text('PAUSE'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    final history = await progress.history();
    expect(history, hasLength(1));
    expect(history.single.completed, isFalse);
    expect(history.single.completedCycles, 2);
    expect(await progress.readResume(), const Duration(seconds: 28));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          merkabaProgressRepositoryProvider.overrideWithValue(progress),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: MerkabaMeditationScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('00:28 / 05:00'), findsOneWidget);
    expect(find.text('2 / 21'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
  });

  test('session history persists date, cycles, and completion', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final repository = SharedPreferencesMerkabaProgressRepository(
      SharedPreferencesAsync(),
    );
    final started = DateTime.utc(2026, 10, 13, 16);
    await repository.recordSession(
      MerkabaSessionRecord(
        date: started,
        completedCycles: 11,
        completed: false,
      ),
    );
    await repository.recordSession(
      MerkabaSessionRecord(
        date: started.add(const Duration(days: 1)),
        completedCycles: 21,
        completed: true,
      ),
    );

    final history = await repository.history();
    expect(history, hasLength(2));
    expect(history.first.date.toUtc(), started);
    expect(history.first.completedCycles, 11);
    expect(history.first.completed, isFalse);
    expect(history.last.completedCycles, 21);
    expect(history.last.completed, isTrue);
  });
}

Finder _mudraSvg(String asset) => find.byWidgetPredicate(
  (widget) =>
      widget is SvgPicture &&
      widget.bytesLoader is SvgAssetLoader &&
      (widget.bytesLoader as SvgAssetLoader).assetName == asset,
);

(int, int, int, int) _rgba(ByteData bytes, int width, int x, int y) {
  final offset = (y * width + x) * 4;
  return (
    bytes.getUint8(offset),
    bytes.getUint8(offset + 1),
    bytes.getUint8(offset + 2),
    bytes.getUint8(offset + 3),
  );
}
