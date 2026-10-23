import 'dart:developer';
import 'dart:typed_data';

import 'package:amplify_flutter/amplify_flutter.dart' show UUID;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/reflection_photo_gateway.dart';
import '../data/reflection_photo_repository.dart';
import '../domain/reflection_photo.dart';
import 'ritual_cycle_controller.dart';

final reflectionPhotoControllerProvider =
    AsyncNotifierProvider<ReflectionPhotoController, ReflectionGallery>(
      ReflectionPhotoController.new,
    );

/// Face photos of the open cycle.
///
/// The bytes are saved on the device first. With a session they are uploaded
/// to the private `reflection-photos/` prefix, which the bucket encrypts.
/// Day 1 is never replaced. A later day becomes the current photo.
class ReflectionPhotoController extends AsyncNotifier<ReflectionGallery> {
  @override
  Future<ReflectionGallery> build() async {
    final progress = await ref.watch(ritualCycleControllerProvider.future);
    await _flushPending();
    final cycle = progress.cycle;
    final now = ref.read(ritualClockProvider)();
    if (cycle == null || !cycle.isOpenOn(now)) {
      return ReflectionGallery.empty;
    }
    await _adoptRemote(cycle.id);
    return _gallery(cycle.id, cycle.dayNumber(now));
  }

  Future<void> capture(Uint8List bytes) async {
    await future;
    if (bytes.isEmpty) return;
    final cycles = ref.read(ritualCycleControllerProvider.notifier);
    final cycle = await cycles.stageOpenCycle();
    final now = ref.read(ritualClockProvider)();
    final day = cycle.dayNumber(now);
    final repository = ref.read(reflectionPhotoRepositoryProvider);
    final existing = await repository.readCycle(cycle.id);
    if (!canCaptureReflectionDay(existing, day)) return;

    final prior = reflectionOnDay(existing, day);
    final entry = ReflectionEntry(
      id: prior?.id ?? UUID.getUUID(),
      cycleId: cycle.id,
      dayNumber: day,
      storageKey: prior?.storageKey,
      pendingUpload: true,
    );
    try {
      await repository.writeBytes(cycle.id, day, bytes);
      await repository.save(entry);
    } catch (error, stackTrace) {
      log(
        'Reflection photo save',
        name: 'hikaru.media',
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }
    state = AsyncData(await _gallery(cycle.id, day));
    final publish = cycles.hasStagedCycle;
    cycles.publishStagedCycle();
    if (publish) return;
    await _flushEntry(entry);
    state = AsyncData(await _gallery(cycle.id, day));
  }

  Future<void> _flushPending() async {
    final pending = await ref.read(reflectionPhotoRepositoryProvider).readAll();
    for (final entry in pending) {
      if (!entry.pendingUpload) continue;
      await _flushEntry(entry);
    }
  }

  Future<void> _flushEntry(ReflectionEntry entry) async {
    final repository = ref.read(reflectionPhotoRepositoryProvider);
    final gateway = ref.read(reflectionPhotoGatewayProvider);
    final bytes = await repository.readBytes(entry.cycleId, entry.dayNumber);
    if (bytes == null) return;

    final storageKey = await gateway.upload(
      cycleId: entry.cycleId,
      dayNumber: entry.dayNumber,
      bytes: bytes,
    );
    if (storageKey == null) return;

    final remote = await gateway.fetchCycle(entry.cycleId);
    final match = remote
        .where((photo) => photo.dayNumber == entry.dayNumber)
        .firstOrNull;
    final uploadedAt = DateTime.now();
    final saved = match == null
        ? await gateway.create(
            id: entry.id,
            cycleId: entry.cycleId,
            dayNumber: entry.dayNumber,
            storageKey: storageKey,
            uploadedAt: uploadedAt,
          )
        : await gateway.update(
            id: match.id,
            storageKey: storageKey,
            uploadedAt: uploadedAt,
          );
    if (!saved) return;
    await repository.save(
      entry.copyWith(
        id: match?.id ?? entry.id,
        storageKey: storageKey,
        pendingUpload: false,
      ),
    );
  }

  /// Downloads photos that exist in the backend and not yet on the device.
  Future<void> _adoptRemote(String cycleId) async {
    final repository = ref.read(reflectionPhotoRepositoryProvider);
    final remote = await ref
        .read(reflectionPhotoGatewayProvider)
        .fetchCycle(cycleId);
    final local = await repository.readCycle(cycleId);
    for (final photo in remote) {
      final known = reflectionOnDay(local, photo.dayNumber);
      if (known != null && !known.pendingUpload) {
        final bytes = await repository.readBytes(cycleId, photo.dayNumber);
        if (bytes != null) continue;
      }
      if (known != null && known.pendingUpload) continue;
      final bytes = await ref
          .read(reflectionPhotoGatewayProvider)
          .download(photo.storageKey);
      if (bytes == null) continue;
      await repository.writeBytes(cycleId, photo.dayNumber, bytes);
      await repository.save(
        ReflectionEntry(
          id: photo.id,
          cycleId: cycleId,
          dayNumber: photo.dayNumber,
          storageKey: photo.storageKey,
          pendingUpload: false,
        ),
      );
    }
  }

  Future<ReflectionGallery> _gallery(String cycleId, int today) async {
    final repository = ref.read(reflectionPhotoRepositoryProvider);
    final entries = [...await repository.readCycle(cycleId)]
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    final shots = <ReflectionShot>[];
    for (final entry in entries) {
      final bytes = await repository.readBytes(cycleId, entry.dayNumber);
      if (bytes == null) continue;
      shots.add(ReflectionShot(dayNumber: entry.dayNumber, bytes: bytes));
    }
    ReflectionShot? before;
    ReflectionShot? later;
    for (final shot in shots) {
      if (shot.dayNumber == 1) before = shot;
      if (shot.dayNumber > 1) later = shot;
    }
    return ReflectionGallery(
      before: before?.bytes,
      later: later?.bytes,
      canCapture: canCaptureReflectionDay(entries, today),
      shots: shots,
    );
  }
}
