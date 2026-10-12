import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiraku/core/design_system/theme/app_theme.dart';
import 'package:hiraku/features/crystals/application/selected_crystal_controller.dart';
import 'package:hiraku/features/crystals/domain/crystal.dart';
import 'package:hiraku/features/resonance_chamber/presentation/resonance_chamber_screen.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('hero crystal follows the selected crystal', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const ResonanceChamberScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Your crystal in the garden'), findsOneWidget);
    expect(_sceneImage('resonance_crystal.png'), findsOneWidget);

    await container
        .read(selectedCrystalProvider.notifier)
        .select(Crystal.redJasper);
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('RED JASPER crystal'), findsOneWidget);
    expect(find.bySemanticsLabel('Your crystal in the garden'), findsNothing);
    expect(_sceneImage('jasper.png'), findsOneWidget);
    expect(find.text('639 Hz'), findsOneWidget);
    expect(find.text('Metabolic Flow • Vitality • Grounding'), findsOneWidget);
    expect(find.text('1. METABOLIC & VASCULAR FLOW'), findsOneWidget);
    expect(find.text('1. NERVOUS SYSTEM REGULATION'), findsNothing);
    expect(
      find.bySemanticsLabel('Assigned crystal RED JASPER'),
      findsOneWidget,
    );

    await container.read(selectedCrystalProvider.notifier).select(Crystal.jade);
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('JADE crystal'), findsOneWidget);
    expect(find.bySemanticsLabel('RED JASPER crystal'), findsNothing);
    expect(_sceneImage('jade.png'), findsOneWidget);
    expect(find.text('528 Hz'), findsOneWidget);
    expect(find.text('1. NERVOUS SYSTEM REGULATION'), findsOneWidget);
    expect(find.text(Crystal.compositionCredit), findsOneWidget);
    expect(find.bySemanticsLabel('Assigned crystal JADE'), findsOneWidget);

    for (final (crystal, asset) in [
      (Crystal.obsidian, 'obsidian.png'),
      (Crystal.whiteQuartz, 'resonance_crystal.png'),
    ]) {
      await container.read(selectedCrystalProvider.notifier).select(crystal);
      await tester.pumpAndSettle();
      expect(_sceneImage(asset), findsOneWidget);
    }
  });
}

Finder _sceneImage(String fileName) => find.byWidgetPredicate(
  (widget) =>
      widget is Image &&
      widget.image is AssetImage &&
      (widget.image as AssetImage).assetName == 'assets/images/$fileName',
);
