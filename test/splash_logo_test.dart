import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/features/splash/presentation/splash_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('splash symbol plays the full 10 s animation', () async {
    final data = await rootBundle.load('assets/images/splash_symbol.webp');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    addTearDown(codec.dispose);

    expect(codec.frameCount, 241);

    var total = Duration.zero;
    for (var i = 0; i < codec.frameCount; i++) {
      final frame = await codec.getNextFrame();
      total += frame.duration;
      frame.image.dispose();
    }
    expect(total.inMilliseconds, inInclusiveRange(9900, 10200));
  });

  testWidgets('splash destination waits until the symbol is decoded', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var arrived = false;
    container.read(splashDestinationProvider.future).then((_) {
      arrived = true;
    });
    await tester.pump();
    expect(arrived, isFalse);

    container.read(splashSymbolReadyProvider).complete();
    await tester.pump(splashMinimumDuration - const Duration(milliseconds: 1));
    expect(arrived, isFalse);

    await tester.pump(const Duration(milliseconds: 1));
    expect(arrived, isTrue);
  });
}
