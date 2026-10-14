import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/features/resonance_chamber/domain/cymatic_audio.dart';

void main() {
  test('silence has no loudness and a tone lands in its band', () {
    final silence = analyzeCymaticWindow(List<double>.filled(256, 0));
    expect(silence.rms, 0);
    expect(silence.low, 0);
    expect(silence.high, 0);

    final low = analyzeCymaticWindow(_tone(200));
    final high = analyzeCymaticWindow(_tone(3000));
    expect(low.low, greaterThan(low.high));
    expect(low.rms, greaterThan(0.2));
    expect(high.high, greaterThan(high.low));
    expect(high.high, greaterThan(0.5));
  });

  test('a steady tone rests and an attack pulses then releases', () {
    final follower = CymaticFollower();
    for (var step = 0; step < 250; step++) {
      follower.step(rms: 0.05, low: 0.5, mid: 0.3, high: 0.2, dt: 0.02);
    }
    expect(follower.amplitude, lessThan(0.15));
    expect(follower.scale, lessThan(1.03));

    CymaticDrive? attack;
    var spawned = false;
    for (var step = 0; step < 8; step++) {
      attack = follower.step(
        rms: 0.85,
        low: 0.1,
        mid: 0.2,
        high: 0.7,
        dt: 0.01,
      );
      spawned = spawned || attack.spawn;
    }
    expect(attack!.amplitude, greaterThan(0.4));
    expect(attack.scale, greaterThan(1.05));
    expect(attack.scale, lessThanOrEqualTo(1.15));
    expect(attack.morph, greaterThan(0.5));
    expect(spawned, isTrue);

    CymaticDrive? held;
    for (var step = 0; step < 120; step++) {
      held = follower.step(rms: 0.85, low: 0.1, mid: 0.2, high: 0.7, dt: 0.02);
    }
    expect(held!.amplitude, lessThan(0.25));
    expect(held.spawn, isFalse);
  });

  test('separate peaks each emit a spark burst', () {
    final follower = CymaticFollower();
    var spawns = 0;
    for (var peak = 0; peak < 6; peak++) {
      for (var step = 0; step < 5; step++) {
        final drive = follower.step(
          rms: 0.9,
          low: 0.2,
          mid: 0.5,
          high: 0.3,
          dt: 0.012,
        );
        if (drive.spawn) spawns += 1;
      }
      for (var step = 0; step < 25; step++) {
        follower.step(rms: 0.04, low: 0.2, mid: 0.5, high: 0.3, dt: 0.012);
      }
    }
    expect(spawns, inInclusiveRange(4, 6));
  });

  test('the envelope stores a burst at its own timestamp', () {
    const rate = CymaticEnvelope.analysisRate;
    final pcm = Int16List(rate);
    final start = rate ~/ 2;
    final end = start + rate ~/ 10;
    for (var index = start; index < end; index++) {
      pcm[index] = (math.sin(2 * math.pi * 440 * index / rate) * 20000).round();
    }

    final envelope = envelopeFromPcm(pcm);
    final quiet = envelope.sampleAt(const Duration(milliseconds: 80));
    final loud = envelope.sampleAt(const Duration(milliseconds: 560));
    expect(loud.rms, greaterThan(quiet.rms + 0.25));
    expect(
      cymaticEnvelopeAsset('audio/red_jasper.m4a'),
      'assets/audio/red_jasper.cym',
    );

    final decoded = CymaticEnvelope.decode(envelope.encode());
    expect(decoded, isNotNull);
    expect(
      decoded!.sampleAt(const Duration(milliseconds: 560)).rms,
      closeTo(loud.rms, 1 / 255),
    );
    expect(CymaticEnvelope.decode(Uint8List(8)), isNull);

    final wrapped = decoded.sampleAt(
      decoded.duration + const Duration(milliseconds: 560),
    );
    expect(wrapped.rms, closeTo(loud.rms, 1 / 255));
  });

  test('loudness profile follows the composition from start to end', () {
    final envelope = CymaticEnvelope(
      rms: Float32List.fromList([0.1, 0.1, 0.2, 0.2, 0.8, 0.8, 0.4, 0.4]),
      low: Float32List(8),
      mid: Float32List(8),
      high: Float32List(8),
    );

    final profile = envelope.loudnessProfile(4);
    expect(profile, hasLength(4));
    expect(profile[0], closeTo(0.125, 1e-6));
    expect(profile[1], closeTo(0.25, 1e-6));
    expect(profile[2], 1);
    expect(profile[3], closeTo(0.5, 1e-6));
    expect(envelope.loudnessProfile(20), isEmpty);
  });
}

List<double> _tone(double hertz) {
  const count = 256;
  const rate = 16000;
  return List<double>.generate(
    count,
    (index) => 0.8 * math.sin(2 * math.pi * hertz * index / rate),
  );
}
