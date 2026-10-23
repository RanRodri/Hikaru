import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hikaru/core/router/app_routes.dart';
import 'package:hikaru/features/journey/application/reflection_photo_controller.dart';
import 'package:hikaru/features/journey/domain/reflection_photo.dart';
import 'package:hikaru/features/mirror_garden/presentation/mirror_garden_screen.dart';
import 'package:hikaru/l10n/app_localizations.dart';

void main() {
  testWidgets('continue keeps the reflection as the first progress photo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final captured = <Uint8List>[];
    final photo = Uint8List.fromList(_png);
    final router = _router(initialPreview: photo);
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(captured, router));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('CONTINUE'));
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    expect(captured, [photo]);
    expect(find.text('CRYSTAL READY'), findsOneWidget);
  });

  testWidgets('skip leaves the progress photos untouched', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final captured = <Uint8List>[];
    final router = _router(initialPreview: Uint8List.fromList(_png));
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(captured, router));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('SKIP FOR NOW'));
    await tester.tap(find.text('SKIP FOR NOW'));
    await tester.pumpAndSettle();

    expect(captured, isEmpty);
    expect(find.text('CRYSTAL READY'), findsOneWidget);
  });
}

GoRouter _router({Uint8List? initialPreview}) {
  return GoRouter(
    initialLocation: AppRoutes.mirrorGarden,
    routes: [
      GoRoute(
        path: AppRoutes.mirrorGarden,
        builder: (context, state) =>
            MirrorGardenScreen(initialPreview: initialPreview),
      ),
      GoRoute(
        path: AppRoutes.resonanceChamber,
        builder: (context, state) => const Text('CRYSTAL READY'),
      ),
    ],
  );
}

Widget _app(List<Uint8List> captured, GoRouter router) {
  return ProviderScope(
    overrides: [
      reflectionPhotoControllerProvider.overrideWith(
        () => _RecordingPhotos(captured),
      ),
    ],
    child: MaterialApp.router(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

class _RecordingPhotos extends ReflectionPhotoController {
  _RecordingPhotos(this.captured);

  final List<Uint8List> captured;

  @override
  Future<ReflectionGallery> build() async => ReflectionGallery.empty;

  @override
  Future<void> capture(Uint8List bytes) async {
    captured.add(bytes);
  }
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
