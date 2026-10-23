import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/reflection_photo.dart';

/// Bytes of a reflection photo on this device.
abstract class ReflectionPhotoFiles {
  Future<Uint8List?> read(String cycleId, int dayNumber);

  Future<void> write(String cycleId, int dayNumber, Uint8List bytes);
}

/// Saves reflection bytes under the app support directory.
class DirectoryReflectionPhotoFiles implements ReflectionPhotoFiles {
  DirectoryReflectionPhotoFiles({Future<Directory> Function()? directory})
    : _directory = directory ?? _cacheDirectory;

  final Future<Directory> Function() _directory;

  @override
  Future<Uint8List?> read(String cycleId, int dayNumber) async {
    try {
      final file = await _file(cycleId, dayNumber);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      return bytes.isEmpty ? null : bytes;
    } catch (error, stackTrace) {
      _report(error, stackTrace);
      return null;
    }
  }

  @override
  Future<void> write(String cycleId, int dayNumber, Uint8List bytes) async {
    final file = await _file(cycleId, dayNumber);
    await file.parent.create(recursive: true);
    final part = File('${file.path}.part');
    await part.writeAsBytes(bytes, flush: true);
    if (await file.exists()) await file.delete();
    await part.rename(file.path);
  }

  Future<File> _file(String cycleId, int dayNumber) async {
    final directory = await _directory();
    return File('${directory.path}/$cycleId-day-$dayNumber');
  }

  void _report(Object error, StackTrace stackTrace) {
    log(
      'Reflection photo cache',
      name: 'hikaru.media',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// Local index of reflection photos, plus the image bytes.
class ReflectionPhotoRepository {
  ReflectionPhotoRepository(this._preferences, {ReflectionPhotoFiles? files})
    : _files = files ?? DirectoryReflectionPhotoFiles();

  static const String storageKey = 'reflection_photos';

  final SharedPreferencesAsync _preferences;
  final ReflectionPhotoFiles _files;

  Future<List<ReflectionEntry>> readAll() async {
    try {
      final raw = await _preferences.getString(storageKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.map(ReflectionEntry.fromJson).nonNulls.toList();
    } catch (error, stackTrace) {
      log(
        'Reflection photo index',
        name: 'hikaru.media',
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<List<ReflectionEntry>> readCycle(String cycleId) async {
    final all = await readAll();
    return [
      for (final entry in all)
        if (entry.cycleId == cycleId) entry,
    ];
  }

  Future<void> save(ReflectionEntry entry) async {
    final all = await readAll();
    all.removeWhere(
      (current) =>
          current.cycleId == entry.cycleId &&
          current.dayNumber == entry.dayNumber,
    );
    all.add(entry);
    await _preferences.setString(
      storageKey,
      jsonEncode([for (final item in all) item.toJson()]),
    );
  }

  Future<Uint8List?> readBytes(String cycleId, int dayNumber) =>
      _files.read(cycleId, dayNumber);

  Future<void> writeBytes(String cycleId, int dayNumber, Uint8List bytes) =>
      _files.write(cycleId, dayNumber, bytes);
}

final reflectionPhotoRepositoryProvider = Provider<ReflectionPhotoRepository>(
  (ref) => ReflectionPhotoRepository(SharedPreferencesAsync()),
);

Future<Directory> _cacheDirectory() async {
  final support = await getApplicationSupportDirectory();
  return Directory('${support.path}/reflection-photos');
}
