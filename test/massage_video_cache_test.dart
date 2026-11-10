import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
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
}
