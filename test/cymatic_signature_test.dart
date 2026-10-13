import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/features/crystals/domain/crystal.dart';
import 'package:hikaru/features/resonance_chamber/domain/cymatic_audio.dart';
import 'package:hikaru/features/resonance_chamber/presentation/cymatic_signature.dart';

void main() {
  test('every crystal shares the 8-fold cymatic', () {
    for (final crystal in Crystal.values) {
      expect(CymaticMotif.of(crystal).folds, 8);
      expect(CymaticMotif.of(crystal).rings, inInclusiveRange(3, 4));
    }
    expect(
      cymaticColorJourney(Crystal.redJasper),
      lessThan(cymaticColorJourney(Crystal.jade)),
    );
  });

  test('a higher frequency shortens the cymatic cycle', () {
    expect(
      cymaticCycle(Crystal.redJasper),
      lessThan(cymaticCycle(Crystal.jade)),
    );
    expect(cymaticHertz(Crystal.redJasper), 639);
    expect(cymaticHertz(Crystal.whiteQuartz), 528);
  });

  testWidgets('play starts the cymatic and pause settles it', (tester) async {
    final key = GlobalKey<CymaticSignatureState>();
    await tester.pumpWidget(_CymaticHost(signatureKey: key));

    expect(key.currentState!.isAnimating, isFalse);
    expect(key.currentState!.motion, 0);
    expect(key.currentState!.phase, 0);
    expect(key.currentState!.colorProgress, 1);

    await tester.tap(find.text('PLAY'));
    await tester.pump();
    expect(key.currentState!.isAnimating, isTrue);

    await tester.pump(const Duration(milliseconds: 500));
    final phaseWhilePlaying = key.currentState!.phase;
    final colorWhilePlaying = key.currentState!.colorProgress;
    expect(phaseWhilePlaying, greaterThan(0));
    expect(key.currentState!.motion, greaterThan(0));
    expect(colorWhilePlaying, greaterThan(0));
    expect(colorWhilePlaying, lessThan(1));

    await tester.pump(const Duration(milliseconds: 400));
    expect(key.currentState!.phase, greaterThan(phaseWhilePlaying));

    await tester.tap(find.text('PAUSE'));
    await tester.pump();
    final frozenPhase = key.currentState!.phase;
    final frozenColor = key.currentState!.colorProgress;
    expect(key.currentState!.isAnimating, isTrue);

    await tester.pump(const Duration(milliseconds: 200));
    expect(key.currentState!.phase, frozenPhase);
    expect(key.currentState!.colorProgress, frozenColor);
    expect(key.currentState!.motion, greaterThan(0));
    expect(key.currentState!.motion, lessThan(1));

    await tester.pump(cymaticSettleDuration);
    expect(key.currentState!.motion, 0);
    expect(key.currentState!.phase, frozenPhase);
    expect(key.currentState!.isAnimating, isFalse);
  });

  testWidgets('reduced motion keeps the cymatic settled while playing', (
    tester,
  ) async {
    final key = GlobalKey<CymaticSignatureState>();
    await tester.pumpWidget(
      _CymaticHost(signatureKey: key, playing: true, reduceMotion: true),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(key.currentState!.isAnimating, isFalse);
    expect(key.currentState!.motion, 0);
    expect(key.currentState!.phase, 0);
    expect(key.currentState!.colorProgress, 1);
  });

  testWidgets('a real envelope follows playback and settles on pause', (
    tester,
  ) async {
    final key = GlobalKey<CymaticSignatureState>();
    final position = ValueNotifier<Duration>(Duration.zero);
    addTearDown(position.dispose);
    final envelope = CymaticEnvelope(
      rms: Float32List.fromList(const [0.05, 0.95, 0.95, 0.2, 0.05]),
      low: Float32List.fromList(const [0.2, 0.1, 0.1, 0.2, 0.4]),
      mid: Float32List.fromList(const [0.5, 0.2, 0.2, 0.4, 0.4]),
      high: Float32List.fromList(const [0.3, 0.7, 0.7, 0.4, 0.2]),
    );

    await tester.pumpWidget(
      _CymaticHost(
        signatureKey: key,
        envelope: envelope,
        playbackPosition: position,
      ),
    );
    await tester.tap(find.text('PLAY'));
    await tester.pump();
    expect(key.currentState!.isAnimating, isTrue);

    await tester.pump(const Duration(milliseconds: 180));
    final phaseWhilePlaying = key.currentState!.phase;
    expect(phaseWhilePlaying, greaterThan(0));
    expect(key.currentState!.motion, greaterThan(0));

    await tester.tap(find.text('PAUSE'));
    await tester.pump();
    await tester.pump(cymaticSettleDuration);
    expect(key.currentState!.motion, 0);
    expect(key.currentState!.isAnimating, isFalse);
    final settledPhase = key.currentState!.phase;

    await tester.pump(const Duration(milliseconds: 200));
    expect(key.currentState!.phase, settledPhase);
    expect(key.currentState!.isAnimating, isFalse);
  });
}

class _CymaticHost extends StatefulWidget {
  const _CymaticHost({
    required this.signatureKey,
    this.playing = false,
    this.reduceMotion = false,
    this.envelope,
    this.playbackPosition,
  });

  final GlobalKey<CymaticSignatureState> signatureKey;
  final bool playing;
  final bool reduceMotion;
  final CymaticEnvelope? envelope;
  final ValueNotifier<Duration>? playbackPosition;

  @override
  State<_CymaticHost> createState() => _CymaticHostState();
}

class _CymaticHostState extends State<_CymaticHost> {
  late bool _playing = widget.playing;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(disableAnimations: widget.reduceMotion),
          child: child!,
        );
      },
      home: Scaffold(
        body: Column(
          children: [
            SizedBox(
              width: 240,
              height: 240,
              child: CymaticSignature(
                key: widget.signatureKey,
                crystal: Crystal.jade,
                playing: _playing,
                showSeal: true,
                envelope: widget.envelope,
                playbackPosition: widget.playbackPosition,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _playing = !_playing),
              child: Text(_playing ? 'PAUSE' : 'PLAY'),
            ),
          ],
        ),
      ),
    );
  }
}
