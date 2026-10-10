import 'package:flutter_test/flutter_test.dart';
import 'package:hiraku/features/merkaba/domain/merkaba_session.dart';

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
}
