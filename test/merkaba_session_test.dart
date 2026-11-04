import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/features/merkaba/data/merkaba_progress_repository.dart';
import 'package:hikaru/features/merkaba/domain/merkaba_session.dart';
import 'package:hikaru/features/merkaba/presentation/merkaba_painter.dart';
import 'package:hikaru/features/merkaba/presentation/merkaba_screen.dart';
import 'package:hikaru/features/merkaba/presentation/merkaba_video.dart';
import 'package:hikaru/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Video that never loads, so the screen shows the painted fallback.
class _FailedVideo extends MerkabaVideoPlayback {
  @override
  MerkabaVideoStatus get status => MerkabaVideoStatus.failed;
  @override
  void load() {}
  @override
  Future<void> play(Duration clock) async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> seek(Duration clock) async {}
  @override
  Future<void> sync(Duration clock) async {}
  @override
  Future<void> keepForNextTime() async {}
  @override
  Widget buildView() => const SizedBox.shrink();
}

Widget _app(Widget screen, {MerkabaProgressRepository? progress}) {
  return ProviderScope(
    overrides: [
      merkabaVideoPlaybackFactoryProvider.overrideWithValue(
        (_) => _FailedVideo(),
      ),
      if (progress != null)
        merkabaProgressRepositoryProvider.overrideWithValue(progress),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: screen,
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('breath phases follow the 4-4-6 cycle', () {
    expect(merkabaFrameAt(Duration.zero).phase, BreathPhase.inhale);
    expect(merkabaFrameAt(const Duration(seconds: 4)).phase, BreathPhase.hold);
    expect(
      merkabaFrameAt(const Duration(seconds: 8)).phase,
      BreathPhase.exhale,
    );
    expect(
      merkabaFrameAt(const Duration(seconds: 14)).phase,
      BreathPhase.inhale,
    );
    expect(formatMerkabaClock(const Duration(seconds: 65)), '01:05');
    expect(merkabaFrameAt(const Duration(seconds: 28)).completedCycles, 2);
    expect(merkabaTotalBreaths, 21);
    expect(merkabaFrameAt(const Duration(seconds: 2)).breathLevel, 0.5);
    expect(merkabaFrameAt(const Duration(seconds: 6)).breathLevel, 1);
    expect(merkabaFrameAt(const Duration(seconds: 11)).breathLevel, 0.5);
  });

  test('mudras change at the brief timestamps', () {
    String mudraAt(int seconds) =>
        merkabaFrameAt(Duration(seconds: seconds)).scene.mudra;
    expect(mudraAt(0), 'Gyan Mudra');
    expect(mudraAt(39), 'Gyan Mudra');
    expect(mudraAt(40), 'Vayu Mudra');
    expect(mudraAt(90), 'Lotus Mudra');
    expect(mudraAt(219), 'Lotus Mudra');
    expect(mudraAt(220), 'Akash Mudra');
    expect(mudraAt(270), 'Anjali');
    expect(merkabaFrameAt(merkabaDuration).isFinished, isTrue);
  });

  test('the seated woman portrait decodes', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final data = await rootBundle.load(merkabaWomanAsset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    expect(frame.image.width, 900);
    expect(frame.image.height, 720);
    frame.image.dispose();
  });

  testWidgets('shows the mudra, breath text and counter without video', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const MerkabaMeditationScreen(initialElapsed: Duration(seconds: 154)),
      ),
    );
    await tester.pump();

    expect(find.text('Lotus'), findsOneWidget);
    expect(find.text('Inhale'), findsOneWidget);
    expect(find.text('11 / 21'), findsOneWidget);
    expect(find.text('02:26'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('finishing records the session and shows its real length', (
    tester,
  ) async {
    final progress = InMemoryMerkabaProgressRepository();
    var now = DateTime.utc(2026, 11, 4, 10);
    await tester.pumpWidget(
      _app(
        MerkabaMeditationScreen(
          initialElapsed: const Duration(minutes: 4, seconds: 59),
          clock: () => now,
        ),
        progress: progress,
      ),
    );

    await tester.tap(find.text('PLAY'));
    await tester.pump();
    // Ten seconds pass on the wall clock (a pause in the middle, say).
    now = now.add(const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Silence.'), findsOneWidget);
    expect(find.text('05:09'), findsOneWidget);
    final finished = await progress.history();
    expect(finished, hasLength(1));
    expect(finished.single.completed, isTrue);
    expect(finished.single.completedCycles, 21);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('session history persists date, cycles, and completion', () async {
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
    final history = await repository.history();
    expect(history, hasLength(1));
    expect(history.first.completedCycles, 11);
  });
}
