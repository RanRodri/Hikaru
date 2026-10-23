import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/features/resonance_chamber/data/crystal_audio_cache.dart';

void main() {
  test('without a session there is no audio', () async {
    final files = _MemoryAudioFiles();
    var asked = false;
    final path = await _cache(
      files,
      signedUrl: (_) async {
        asked = true;
        return null;
      },
    ).resolve('audio/jade.m4a');

    expect(path, isNull);
    expect(asked, isFalse);
    expect(files.files, isEmpty);
  });

  test('a saved file plays without asking S3 again', () async {
    final files = _MemoryAudioFiles()..files['jade.m4a'] = [1, 2, 3];
    var asked = false;
    final path = await _cache(
      files,
      canFetch: () async => true,
      signedUrl: (_) async {
        asked = true;
        return null;
      },
    ).resolve('audio/jade.m4a');

    expect(path, 'memory/jade.m4a');
    expect(asked, isFalse);
  });

  test('the first play stores the signed download', () async {
    final files = _MemoryAudioFiles();
    final signed = Uri.parse('https://files.example/jade.m4a?sig=1');
    String? requested;
    final path = await _cache(
      files,
      canFetch: () async => true,
      signedUrl: (storagePath) async {
        requested = storagePath;
        return signed;
      },
      readUrl: (url) async => url == signed ? [9, 8, 7] : null,
    ).resolve('audio/jade.m4a');

    expect(requested, 'crystal-audio/jade.m4a');
    expect(files.files['jade.m4a'], [9, 8, 7]);
    expect(path, 'memory/jade.m4a');

    var askedAgain = false;
    final second = await _cache(
      files,
      canFetch: () async => true,
      signedUrl: (_) async {
        askedAgain = true;
        return null;
      },
    ).resolve('audio/jade.m4a');
    expect(second, 'memory/jade.m4a');
    expect(askedAgain, isFalse);
  });

  test('a failed download leaves the track silent', () async {
    final files = _MemoryAudioFiles();
    final path = await _cache(
      files,
      canFetch: () async => true,
      signedUrl: (_) async => null,
    ).resolve('audio/obsidian.m4a');

    expect(path, isNull);
    expect(files.files, isEmpty);
  });
}

CrystalAudioCache _cache(
  AudioFileStore store, {
  Future<bool> Function()? canFetch,
  Future<Uri?> Function(String storagePath)? signedUrl,
  Future<List<int>?> Function(Uri url)? readUrl,
}) {
  return CrystalAudioCache(
    store: store,
    canFetch: canFetch ?? () async => false,
    signedUrl: signedUrl ?? (_) async => null,
    readUrl: readUrl ?? (_) async => null,
  );
}

class _MemoryAudioFiles implements AudioFileStore {
  final Map<String, List<int>> files = {};

  @override
  Future<String?> pathOf(String fileName) async =>
      files.containsKey(fileName) ? 'memory/$fileName' : null;

  @override
  Future<List<int>?> read(String fileName) async => files[fileName];

  @override
  Future<void> write(String fileName, List<int> bytes) async {
    files[fileName] = bytes;
  }
}
