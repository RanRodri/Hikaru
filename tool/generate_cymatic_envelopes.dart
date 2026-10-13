import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:hiraku/features/resonance_chamber/domain/cymatic_audio.dart';

const _tracks = ['white_quartz', 'jade', 'obsidian', 'red_jasper'];

/// Decodes each bundled crystal AAC to mono PCM and writes a `.cym` envelope.
///
/// Run from the repo root: `dart run tool/generate_cymatic_envelopes.dart`.
Future<void> main() async {
  for (final name in _tracks) {
    final source = 'assets/audio/$name.m4a';
    final pcm = await _decodeMono(source);
    final envelope = envelopeFromPcm(pcm);
    final bytes = envelope.encode();
    final destination = 'assets/audio/$name.cym';
    await File(destination).writeAsBytes(bytes, flush: true);
    stdout.writeln(
      '$destination  ${envelope.frames} frames  '
      '${envelope.duration.inMilliseconds} ms  ${bytes.length} bytes',
    );
  }
}

Future<Int16List> _decodeMono(String path) async {
  final process = await Process.start('ffmpeg', [
    '-v',
    'error',
    '-i',
    path,
    '-ac',
    '1',
    '-ar',
    '${CymaticEnvelope.analysisRate}',
    '-f',
    's16le',
    'pipe:1',
  ]);
  final error = StringBuffer();
  final errorDone = process.stderr
      .transform(utf8.decoder)
      .listen(error.write)
      .asFuture<void>();
  final builder = BytesBuilder(copy: false);
  await for (final chunk in process.stdout) {
    builder.add(chunk);
  }
  await errorDone;
  final code = await process.exitCode;
  if (code != 0) {
    throw Exception('ffmpeg failed for $path ($code): $error');
  }
  final bytes = builder.takeBytes();
  if (bytes.length.isOdd) {
    throw Exception('ffmpeg returned an odd number of PCM bytes for $path');
  }
  final aligned = Uint8List.fromList(bytes);
  return aligned.buffer.asInt16List();
}
