import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hikaru/features/massage/application/massage_video_preheat.dart';
import 'package:hikaru/features/massage/data/massage_video_source.dart';

void main() {
  late Directory directory;
  late DateTime now;
  late int signatures;

  MassageVideoSource source({
    Future<int> Function(Uri url, File target, bool Function() shouldStop)?
    download,
  }) {
    return MassageVideoSource(
      directory: () async => directory,
      clock: () => now,
      signedUrl: (path) async {
        signatures += 1;
        return Uri.parse('https://cdn.test/$path?n=$signatures');
      },
      publicUrl: (path) => Uri.parse('https://public.test/$path'),
      download:
          download ??
          (url, file, shouldStop) async {
            if (shouldStop()) return 0;
            await file.writeAsBytes([1, 2, 3]);
            return 3;
          },
    );
  }

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('hikaru-massage');
    now = DateTime(2026, 11, 10, 12);
    signatures = 0;
  });

  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test('a signed address is reused for fifty minutes', () async {
    final videos = source();

    final first = await videos.resolve('Merkaba/ritual_face.mp4');
    final second = await videos.resolve('Merkaba/ritual_body.mp4');
    final again = await videos.resolve('Merkaba/ritual_face.mp4');

    expect(first, isA<MassageStreamedVideo>());
    expect(
      (first as MassageStreamedVideo).url.toString(),
      'https://cdn.test/Merkaba/ritual_face.mp4?n=1',
    );
    expect((again as MassageStreamedVideo).url, (first).url);
    expect(signatures, 2);
    expect((second as MassageStreamedVideo).url.toString(), contains('n=2'));

    now = now.add(MassageVideoSource.signedUrlLifetime);
    await videos.resolve('Merkaba/ritual_face.mp4');
    expect(signatures, 3);
  });

  test('a prepared video plays from the phone without signing again', () async {
    final videos = source();

    await videos.prepare(['Merkaba/ritual_face.mp4']);
    final signedBeforeOpen = signatures;
    final location = await videos.resolve('Merkaba/ritual_face.mp4');

    expect(location, isA<MassageCachedVideo>());
    expect(await (location as MassageCachedVideo).file.readAsBytes(), [
      1,
      2,
      3,
    ]);
    expect(signatures, signedBeforeOpen);
  });

  test('the video that is playing is not downloaded until it closes', () async {
    final started = <String>[];
    final videos = source(
      download: (url, file, shouldStop) async {
        started.add(url.path);
        if (shouldStop()) return 0;
        await file.writeAsBytes([9]);
        return 1;
      },
    );

    await videos.resolve('Merkaba/ritual_face.mp4');
    await videos.prepare([
      'Merkaba/ritual_face.mp4',
      'Merkaba/ritual_body.mp4',
    ]);

    expect(started, ['/Merkaba/ritual_body.mp4']);
    expect(File('${directory.path}/ritual_body.mp4').existsSync(), isTrue);
    expect(File('${directory.path}/ritual_face.mp4').existsSync(), isFalse);

    videos.releasePlayback('Merkaba/ritual_face.mp4');
    await videos.prepare(['Merkaba/ritual_face.mp4']);
    expect(File('${directory.path}/ritual_face.mp4').existsSync(), isTrue);
  });

  test('ritual videos download at the same time', () async {
    final bothStarted = Completer<void>();
    final release = Completer<void>();
    var running = 0;
    final videos = source(
      download: (url, file, shouldStop) async {
        running += 1;
        if (running == 2 && !bothStarted.isCompleted) bothStarted.complete();
        await release.future;
        if (shouldStop()) return 0;
        await file.writeAsBytes([1]);
        return 1;
      },
    );

    final pending = videos.prepare([
      'Merkaba/ritual_face.mp4',
      'Merkaba/ritual_body.mp4',
    ]);
    await bothStarted.future.timeout(const Duration(seconds: 2));
    release.complete();
    await pending;

    expect(File('${directory.path}/ritual_face.mp4').existsSync(), isTrue);
    expect(File('${directory.path}/ritual_body.mp4').existsSync(), isTrue);
  });

  test('the player opens before the file is saved', () async {
    final opened = <MassageVideoLocation>[];
    final saved = Completer<void>();
    final videos = source(
      download: (url, file, shouldStop) async {
        expect(opened, isNotEmpty);
        await file.writeAsBytes([4]);
        if (!saved.isCompleted) saved.complete();
        return 4;
      },
    );
    final preheat = MassageVideoPreheat(
      videos,
      open: (location) async {
        opened.add(location);
        return null;
      },
    );

    preheat.warm(['Merkaba/ritual_face.mp4']);
    await saved.future.timeout(const Duration(seconds: 2));
    expect(opened.single, isA<MassageStreamedVideo>());
    final file = File('${directory.path}/ritual_face.mp4');
    final deadline = DateTime.now().add(const Duration(seconds: 2));
    while (!file.existsSync() && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(file.existsSync(), isTrue);
  });
}
