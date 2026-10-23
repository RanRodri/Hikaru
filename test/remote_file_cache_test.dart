import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/core/media/remote_file_cache.dart';

void main() {
  test('without a session there is no image', () async {
    final files = _MemoryFiles();
    var asked = false;
    final path = await _cache(
      files,
      signedUrl: (_) async {
        asked = true;
        return null;
      },
    ).resolve('assets/images/jade.png');

    expect(path, isNull);
    expect(asked, isFalse);
    expect(files.files, isEmpty);
  });

  test('a saved file opens without asking S3 again', () async {
    final files = _MemoryFiles()..files['jade.png'] = [1, 2, 3];
    var asked = false;
    final path = await _cache(
      files,
      canFetch: () async => true,
      signedUrl: (_) async {
        asked = true;
        return null;
      },
    ).resolve('jade.png');

    expect(path, 'memory/jade.png');
    expect(asked, isFalse);
  });

  test('the first view stores the signed download', () async {
    final files = _MemoryFiles();
    final signed = Uri.parse('https://files.example/jade.png?sig=1');
    String? requested;
    final path = await _cache(
      files,
      canFetch: () async => true,
      signedUrl: (storagePath) async {
        requested = storagePath;
        return signed;
      },
      readUrl: (url) async => url == signed ? [9, 8, 7] : null,
    ).resolve('assets/images/jade.png');

    expect(requested, 'crystal-images/jade.png');
    expect(files.files['jade.png'], [9, 8, 7]);
    expect(path, 'memory/jade.png');

    var askedAgain = false;
    final second = await _cache(
      files,
      canFetch: () async => true,
      signedUrl: (_) async {
        askedAgain = true;
        return null;
      },
    ).resolve('jade.png');
    expect(second, 'memory/jade.png');
    expect(askedAgain, isFalse);
  });

  test('a failed download leaves the photo empty', () async {
    final files = _MemoryFiles();
    final path = await _cache(
      files,
      canFetch: () async => true,
      signedUrl: (_) async => null,
    ).resolve('obsidian.png');

    expect(path, isNull);
    expect(files.files, isEmpty);
  });
}

RemoteFileCache _cache(
  _MemoryFiles files, {
  Future<bool> Function()? canFetch,
  required Future<Uri?> Function(String storagePath) signedUrl,
  Future<List<int>?> Function(Uri url)? readUrl,
}) {
  return RemoteFileCache(
    storagePrefix: 'crystal-images',
    canFetch: canFetch ?? () async => false,
    signedUrl: signedUrl,
    readUrl: readUrl ?? (_) async => null,
    store: files,
  );
}

class _MemoryFiles implements RemoteFileStore {
  final Map<String, List<int>> files = {};

  @override
  Future<List<int>?> read(String fileName) async => files[fileName];

  @override
  Future<String?> pathOf(String fileName) async =>
      files.containsKey(fileName) ? 'memory/$fileName' : null;

  @override
  Future<void> write(String fileName, List<int> bytes) async {
    files[fileName] = bytes;
  }
}
