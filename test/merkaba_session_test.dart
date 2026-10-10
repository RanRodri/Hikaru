import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiraku/features/merkaba/domain/merkaba_session.dart';
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
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Breath Builds the Merkaba'), findsOneWidget);
    expect(find.text('Lotus Mudra'), findsOneWidget);
    expect(find.text('Inhale'), findsOneWidget);
    expect(find.bySemanticsLabel('Seated woman in meditation'), findsOneWidget);
  });
}
