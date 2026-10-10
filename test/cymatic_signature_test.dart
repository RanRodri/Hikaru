import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiraku/features/crystals/domain/crystal.dart';
import 'package:hiraku/features/resonance_chamber/presentation/cymatic_signature.dart';

void main() {
  test('each crystal has its own cymatic motif', () {
    final motifs = {
      for (final crystal in Crystal.values) CymaticMotif.of(crystal),
    };

    expect(motifs, hasLength(Crystal.values.length));
    expect(
      motifs.map((motif) => motif.petals).toSet(),
      hasLength(Crystal.values.length),
    );
    expect(CymaticMotif.of(Crystal.whiteQuartz).petals, 8);
    expect(CymaticMotif.of(Crystal.jade).rings, 4);
    expect(CymaticMotif.of(Crystal.obsidian).petals, 12);
    expect(CymaticMotif.of(Crystal.redJasper).rings, 3);
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

    await tester.tap(find.text('PLAY'));
    await tester.pump();
    expect(key.currentState!.isAnimating, isTrue);

    await tester.pump(const Duration(milliseconds: 500));
    final phaseWhilePlaying = key.currentState!.phase;
    expect(phaseWhilePlaying, greaterThan(0));
    expect(key.currentState!.motion, greaterThan(0));

    await tester.pump(const Duration(milliseconds: 400));
    expect(key.currentState!.phase, greaterThan(phaseWhilePlaying));

    await tester.tap(find.text('PAUSE'));
    await tester.pump();
    final frozenPhase = key.currentState!.phase;
    expect(key.currentState!.isAnimating, isTrue);

    await tester.pump(const Duration(milliseconds: 200));
    expect(key.currentState!.phase, frozenPhase);
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
  });
}

class _CymaticHost extends StatefulWidget {
  const _CymaticHost({
    required this.signatureKey,
    this.playing = false,
    this.reduceMotion = false,
  });

  final GlobalKey<CymaticSignatureState> signatureKey;
  final bool playing;
  final bool reduceMotion;

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
