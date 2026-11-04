import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:hikaru/features/crystals/domain/crystal.dart';
import 'package:hikaru/features/resonance_chamber/domain/cymatic_audio.dart';
import 'package:hikaru/features/resonance_chamber/domain/cymatic_plate_profiles.g.dart';

const _tracks = <String, Crystal>{
  'white_quartz': Crystal.whiteQuartz,
  'jade': Crystal.jade,
  'obsidian': Crystal.obsidian,
  'red_jasper': Crystal.redJasper,
};

/// Decodes each crystal AAC to mono PCM and writes a CYM2 modal envelope.
///
/// The `.m4a` masters live in S3 and are not shipped in the app. Pass a source
/// directory containing them, or place them at `assets/audio/` temporarily.
///
/// Run from the repo root:
/// `dart run tool/generate_cymatic_envelopes.dart [source-directory]`.
Future<void> main(List<String> arguments) async {
  final sourceDirectory = arguments.isEmpty ? 'assets/audio' : arguments.first;
  for (final MapEntry(key: name, value: crystal) in _tracks.entries) {
    final source = '$sourceDirectory/$name.m4a';
    if (!await File(source).exists()) {
      throw StateError('Missing modal-analysis master: $source');
    }
    final pcm = await _decodeMono(source);
    final profile = crystal.cymaticPlateProfile;
    final envelope = envelopeFromPcm(
      pcm,
      modalFrequencies: profile.frequencies,
    );
    final bytes = envelope.encode();
    final destination = 'assets/audio/$name.cym';
    await File(destination).writeAsBytes(bytes, flush: true);
    stdout.writeln(
      '$destination  CYM2  ${envelope.frames} frames  '
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
