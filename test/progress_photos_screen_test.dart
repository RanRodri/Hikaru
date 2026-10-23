import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/features/journey/application/reflection_photo_controller.dart';
import 'package:hikaru/features/journey/application/ritual_cycle_controller.dart';
import 'package:hikaru/features/journey/domain/journey_progress.dart';
import 'package:hikaru/features/journey/domain/reflection_photo.dart';
import 'package:hikaru/features/journey/presentation/journey_cards.dart';
import 'package:hikaru/l10n/app_localizations.dart';

void main() {
  testWidgets('view all lists every progress photo and opens one', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final photo = Uint8List.fromList(_png);
    await tester.pumpWidget(
      _app(
        gallery: ReflectionGallery(
          before: photo,
          later: photo,
          canCapture: false,
          shots: [
            ReflectionShot(dayNumber: 1, bytes: photo),
            ReflectionShot(dayNumber: 2, bytes: photo),
            ReflectionShot(dayNumber: 4, bytes: photo),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('View all'));
    await tester.pumpAndSettle();

    expect(find.text('DAY 2'), findsOneWidget);
    expect(find.text('Before'), findsWidgets);
    expect(find.text('Current'), findsWidgets);
    expect(find.bySemanticsLabel('Progress photo, DAY 2'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Progress photo, DAY 2'));
    await tester.pumpAndSettle();

    expect(find.text('DAY 2'), findsWidgets);
    await tester.tap(find.text('BACK').last);
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Progress photo, DAY 2'), findsOneWidget);
  });

  testWidgets('view all explains an empty cycle', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(gallery: ReflectionGallery.empty));
    await tester.pumpAndSettle();

    await tester.tap(find.text('View all'));
    await tester.pumpAndSettle();

    expect(
      find.text('Your photos will appear here as the cycle unfolds.'),
      findsOneWidget,
    );
  });
}

Widget _app({required ReflectionGallery gallery}) {
  return ProviderScope(
    overrides: [
      journeyProgressProvider.overrideWithValue(
        const JourneyProgress(currentDay: 4, cycleLength: 30),
      ),
      reflectionPhotoControllerProvider.overrideWith(
        () => _FixedGallery(gallery),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: ProgressPhotosCard()),
    ),
  );
}

class _FixedGallery extends ReflectionPhotoController {
  _FixedGallery(this.gallery);

  final ReflectionGallery gallery;

  @override
  Future<ReflectionGallery> build() async => gallery;
}

const List<int> _png = [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];
