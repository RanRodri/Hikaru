import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/features/journey/application/reflection_photo_controller.dart';
import 'package:hikaru/features/journey/application/ritual_cycle_controller.dart';
import 'package:hikaru/features/journey/data/reflection_photo_gateway.dart';
import 'package:hikaru/features/journey/data/reflection_photo_repository.dart';
import 'package:hikaru/features/journey/data/ritual_cycle_gateway.dart';
import 'package:hikaru/features/journey/domain/reflection_photo.dart';
import 'package:hikaru/features/journey/domain/ritual_cycle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('day 1 is stored once and uploaded with the private path', () async {
    final harness = _Harness();
    final container = harness.container();
    final controller = container.read(
      reflectionPhotoControllerProvider.notifier,
    );

    await controller.capture(Uint8List.fromList([1, 2, 3]));
    final first = await container.read(
      reflectionPhotoControllerProvider.future,
    );

    expect(first.before, [1, 2, 3]);
    expect(first.later, isNull);
    expect(first.shots.map((shot) => shot.dayNumber), [1]);
    expect(first.canCapture, isFalse);
    expect(harness.photos.uploaded.single, contains('/day-1.jpg'));
    expect(harness.photos.created.single.dayNumber, 1);
    expect(harness.cycles.created, hasLength(1));

    await controller.capture(Uint8List.fromList([4, 5, 6]));
    final second = await container.read(
      reflectionPhotoControllerProvider.future,
    );
    expect(second.before, [1, 2, 3]);
    expect(harness.photos.uploaded, hasLength(1));
    expect(harness.photos.created, hasLength(1));
  });

  test('a later day becomes the current photo and keeps day 1', () async {
    final harness = _Harness();
    final container = harness.container();
    final controller = container.read(
      reflectionPhotoControllerProvider.notifier,
    );

    await controller.capture(Uint8List.fromList([1]));
    harness.clock.advance(const Duration(days: 1));
    await controller.capture(Uint8List.fromList([9, 9]));

    final gallery = await container.read(
      reflectionPhotoControllerProvider.future,
    );
    expect(gallery.before, [1]);
    expect(gallery.later, [9, 9]);
    expect(gallery.shots.map((shot) => shot.dayNumber), [1, 2]);
    expect(gallery.currentDayNumber, 2);
    expect(gallery.canCapture, isTrue);
    expect(harness.photos.created.map((photo) => photo.dayNumber), [1, 2]);
    expect(harness.photos.uploaded.last, contains('/day-2.jpg'));
  });

  test('without a session the photo stays local and uploads later', () async {
    final harness = _Harness()..photos.online = false;
    final first = harness.container();
    await first
        .read(reflectionPhotoControllerProvider.notifier)
        .capture(Uint8List.fromList([7, 7]));

    final offline = await first.read(reflectionPhotoControllerProvider.future);
    expect(offline.before, [7, 7]);
    expect(harness.photos.uploaded, isEmpty);
    expect(harness.photos.created, isEmpty);

    harness.photos.online = true;
    final second = harness.container();
    final synced = await second.read(reflectionPhotoControllerProvider.future);
    expect(synced.before, [7, 7]);
    expect(harness.photos.uploaded, hasLength(1));
    expect(harness.photos.created, hasLength(1));
  });

  test('png bytes keep a png object name', () {
    final name = reflectionObjectName('cycle', 3, [
      0x89,
      0x50,
      0x4E,
      0x47,
      1,
      2,
      3,
      4,
    ]);
    expect(name, 'cycle/day-3.png');
    expect(reflectionContentType([1, 2, 3]), 'image/jpeg');
  });
}

class _Harness {
  _Harness()
    : clock = _Clock(DateTime(2026, 10, 23, 9)),
      photos = _PhotoGateway(),
      cycles = _CycleGateway(),
      files = _MemoryFiles();

  final _Clock clock;
  final _PhotoGateway photos;
  final _CycleGateway cycles;
  final _MemoryFiles files;

  ProviderContainer container() {
    final container = ProviderContainer(
      overrides: [
        ritualClockProvider.overrideWithValue(clock.now),
        ritualCycleGatewayProvider.overrideWithValue(cycles),
        reflectionPhotoGatewayProvider.overrideWithValue(photos),
        reflectionPhotoRepositoryProvider.overrideWith(
          (ref) =>
              ReflectionPhotoRepository(SharedPreferencesAsync(), files: files),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }
}

class _Clock {
  _Clock(this._now);
  DateTime _now;
  DateTime now() => _now;
  void advance(Duration step) => _now = _now.add(step);
}

class _CycleGateway implements RitualCycleGateway {
  final created = <String>[];

  @override
  Future<void> createCycle(RitualCycle cycle) async => created.add(cycle.id);

  @override
  Future<CycleProgress?> fetchActive(DateTime today) async => null;

  @override
  Future<void> saveDay(
    RitualCycle cycle, {
    required DateTime date,
    required DailyRitualFlags flags,
  }) async {}

  @override
  Future<void> updateCycle(
    RitualCycle cycle, {
    required int currentDay,
  }) async {}
}

class _PhotoGateway implements ReflectionPhotoGateway {
  var online = true;
  final uploaded = <String>[];
  final created = <_Row>[];

  @override
  Future<bool> create({
    required String id,
    required String cycleId,
    required int dayNumber,
    required String storageKey,
    required DateTime uploadedAt,
  }) async {
    if (!online) return false;
    created.add(
      _Row(
        id: id,
        cycleId: cycleId,
        dayNumber: dayNumber,
        storageKey: storageKey,
      ),
    );
    return true;
  }

  @override
  Future<Uint8List?> download(String storageKey) async => null;

  @override
  Future<List<RemoteReflection>> fetchCycle(String cycleId) async => [
    for (final row in created)
      if (row.cycleId == cycleId)
        RemoteReflection(
          id: row.id,
          dayNumber: row.dayNumber,
          storageKey: row.storageKey,
        ),
  ];

  @override
  Future<bool> update({
    required String id,
    required String storageKey,
    required DateTime uploadedAt,
  }) async {
    if (!online) return false;
    final index = created.indexWhere((row) => row.id == id);
    if (index < 0) return false;
    final row = created[index];
    created[index] = _Row(
      id: row.id,
      cycleId: row.cycleId,
      dayNumber: row.dayNumber,
      storageKey: storageKey,
    );
    return true;
  }

  @override
  Future<String?> upload({
    required String cycleId,
    required int dayNumber,
    required Uint8List bytes,
  }) async {
    if (!online) return null;
    final key =
        'reflection-photos/identity/${reflectionObjectName(cycleId, dayNumber, bytes)}';
    uploaded.add(key);
    return key;
  }
}

class _Row {
  const _Row({
    required this.id,
    required this.cycleId,
    required this.dayNumber,
    required this.storageKey,
  });

  final String id;
  final String cycleId;
  final int dayNumber;
  final String storageKey;
}

class _MemoryFiles implements ReflectionPhotoFiles {
  final files = <String, Uint8List>{};

  @override
  Future<Uint8List?> read(String cycleId, int dayNumber) async =>
      files['$cycleId-$dayNumber'];

  @override
  Future<void> write(String cycleId, int dayNumber, Uint8List bytes) async {
    files['$cycleId-$dayNumber'] = bytes;
  }
}
