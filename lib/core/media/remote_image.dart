import 'dart:async';
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

  /// Lightweight copies bundled with the app. They are visible immediately;
  /// S3 replaces them with the full-resolution file when it is ready.
  static const Map<String, String> fallbacks = {
    harmonyGarden: 'assets/images/fallback_harmony_garden_background.jpg',
    sunsetGarden: 'assets/images/fallback_garden_sunset_reflections.jpg',
    library: 'assets/images/fallback_library.jpg',
    listeningRoom: 'assets/images/fallback_listening_room.jpg',
    listeningRoomQuiz: 'assets/images/fallback_listening_room_quiz.jpg',
    ritualReady: 'assets/images/fallback_ritual_ready.jpg',
    mirrorGarden: 'assets/images/fallback_mirror_garden.jpg',
    resonanceCrystal: 'assets/images/fallback_resonance_crystal.jpg',
    jade: 'assets/images/fallback_jade.jpg',
    jasper: 'assets/images/fallback_jasper.jpg',
    obsidian: 'assets/images/fallback_obsidian.jpg',
  };

  static String? fallbackFor(String asset) {
    final slash = asset.lastIndexOf('/');
    final name = slash >= 0 ? asset.substring(slash + 1) : asset;
    return fallbacks[name];
  }

  /// Screens a new member reaches after the Listening Room opens.
  static const afterListeningRoom = [ritualReady, mirrorGarden];

  /// Backgrounds of Home and the tabs reached from it.
  static const homeTabs = [harmonyGarden, sunsetGarden, library];
}

/// Shows a cached S3 image. Until the file is on the device, the parent
/// color shows through, and the photo fades in when it arrives instead of
/// popping onto a screen that was already showing its content.
class RemoteImage extends ConsumerWidget {
  const RemoteImage({
    super.key,
    required this.fileName,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  });

  static const Duration fadeDuration = Duration(milliseconds: 450);

  final String fileName;
  final BoxFit fit;
  final String? semanticLabel;
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A prefetch can finish after this widget's own first request returned
    // null. Watching the cache events makes that late success repaint.
    ref.watch(remoteImageReadyEventProvider);
    final remembered = ref.watch(remoteImageCacheProvider).cachedPath(fileName);
    final path =
        remembered ??
        ref.watch(remoteImagePathProvider(fileName)).asData?.value;
    final fallbackAsset = RemoteImages.fallbackFor(fileName);
    final fallback = fallbackAsset == null
        ? const ColoredBox(color: Color(0xFF0A0B17))
        : Image.asset(
            fallbackAsset,
            fit: fit,
            alignment: Alignment.center,
            excludeFromSemantics: true,
            gaplessPlayback: true,
          );

    final Widget image = Stack(
      fit: StackFit.expand,
      children: [
        fallback,
        if (path != null)
          Image.file(
            File(path),
            fit: fit,
            alignment: Alignment.center,
            excludeFromSemantics: true,
            gaplessPlayback: true,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: fadeDuration,
                curve: Curves.easeOut,
                child: child,
              );
            },
            // Keep the local fallback visible. On the first corrupt copy,
            // remove it and make one clean request; never loop forever.
            errorBuilder: (_, _, _) {
              unawaited(() async {
                final retry = await ref
                    .read(remoteImageCacheProvider)
                    .discardCorrupt(fileName);
                if (retry && context.mounted) {
                  ref.invalidate(remoteImagePathProvider(fileName));
                }
              }());
              return const SizedBox.shrink();
            },
          ),
      ],
    );

    if (excludeFromSemantics) return ExcludeSemantics(child: image);
    final label = semanticLabel;
    if (label == null) return image;
    return Semantics(label: label, child: image);
  }
}
