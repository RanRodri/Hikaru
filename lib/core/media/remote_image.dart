import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'remote_image_store.dart';

/// Post-login photos stored in S3 under `crystal-images/`.
abstract final class RemoteImages {
  static const harmonyGarden = 'harmony_garden_background.png';
  static const sunsetGarden = 'garden_sunset_reflections.png';
  static const library = 'library.png';
  static const listeningRoom = 'listening_room.png';
  static const listeningRoomQuiz = 'listening_room_quiz.png';
  static const ritualReady = 'ritual_ready.png';
  static const mirrorGarden = 'mirror_garden.png';
  static const resonanceCrystal = 'resonance_crystal.png';
  static const jade = 'jade.png';
  static const jasper = 'jasper.png';
  static const obsidian = 'obsidian.png';
}

/// Shows a cached S3 image. Until the file is on the device, the parent
/// color shows through.
class RemoteImage extends ConsumerWidget {
  const RemoteImage({
    super.key,
    required this.fileName,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  });

  final String fileName;
  final BoxFit fit;
  final String? semanticLabel;
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = ref.watch(remoteImagePathProvider(fileName)).asData?.value;
    final Widget image = path == null
        ? const SizedBox.expand()
        : Image.file(
            File(path),
            fit: fit,
            excludeFromSemantics: true,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const SizedBox.expand(),
          );

    if (excludeFromSemantics) return ExcludeSemantics(child: image);
    final label = semanticLabel;
    if (label == null) return image;
    return Semantics(label: label, child: image);
  }
}
