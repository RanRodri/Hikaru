import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiraku/features/merkaba/domain/merkaba_session.dart';
import 'package:hiraku/features/merkaba/presentation/merkaba_painter.dart';
import 'package:hiraku/features/merkaba/presentation/merkaba_screen.dart';

void main() {
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
  });

  test('scenes change at the brief timestamps', () {
    expect(merkabaFrameAt(Duration.zero).scene.mudra, 'Gyan Mudra');
    expect(
      merkabaFrameAt(const Duration(seconds: 39)).scene.title,
      'Human Blueprint',
    );
    expect(
      merkabaFrameAt(const Duration(seconds: 40)).scene.title,
      'Breath Creates the Star',
    );
    expect(
      merkabaFrameAt(const Duration(seconds: 90)).scene.mudra,
      'Vayu Mudra',
    );
    expect(
      merkabaFrameAt(const Duration(seconds: 140)).scene.mudra,
      'Lotus Mudra',
    );
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
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MerkabaMeditationScreen(
            initialElapsed: Duration(seconds: 154),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(merkabaWomanAsset),
        tester.element(find.byType(Image)),
      );
    });
    await tester.pump();

    expect(find.text('Breath Builds the Merkaba'), findsOneWidget);
    expect(find.text('Lotus Mudra'), findsOneWidget);
    expect(find.text('Inhale'), findsOneWidget);
    expect(find.bySemanticsLabel('Seated woman in meditation'), findsOneWidget);
  });
}

(int, int, int, int) _rgba(ByteData bytes, int width, int x, int y) {
  final offset = (y * width + x) * 4;
  return (
    bytes.getUint8(offset),
    bytes.getUint8(offset + 1),
    bytes.getUint8(offset + 2),
    bytes.getUint8(offset + 3),
  );
}
