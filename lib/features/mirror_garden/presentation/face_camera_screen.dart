import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_font_sizes.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../l10n/app_localizations.dart';

/// In-app face camera. Opens on the front lens and captures with a swipe up
/// or the shutter.
class FaceCameraScreen extends StatefulWidget {
  const FaceCameraScreen({super.key});

  @override
  State<FaceCameraScreen> createState() => _FaceCameraScreenState();
}

class _FaceCameraScreenState extends State<FaceCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  var _opening = false;
  var _busy = false;
  var _failed = false;
  var _pull = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _openFrontCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      final controller = _controller;
      _controller = null;
      controller?.dispose();
      return;
    }
    if (state == AppLifecycleState.resumed) _openFrontCamera();
  }

  Future<void> _openFrontCamera() async {
    if (_opening) return;
    _opening = true;
    final previous = _controller;
    _controller = null;
    await previous?.dispose();

    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        setState(() => _failed = true);
        return;
      }

      final front = cameras.where(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      final description = front.isEmpty ? cameras.first : front.first;
      final controller = CameraController(
        description,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      try {
        await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      } catch (_) {}
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    } finally {
      _opening = false;
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _busy) return;
    if (controller.value.isTakingPicture) return;

    setState(() => _busy = true);
    try {
      final file = await controller.takePicture();
      var bytes = await file.readAsBytes();
      if (controller.description.lensDirection == CameraLensDirection.front) {
        bytes = await _mirrorBytes(bytes);
      }
      if (!mounted) return;
      Navigator.of(context).pop(bytes);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() => _pull = (_pull - details.delta.dy).clamp(0, 96));
  }

  void _handleDragEnd(DragEndDetails details) {
    final take = _pull > 56 || (details.primaryVelocity ?? 0) < -650;
    setState(() => _pull = 0);
    if (take) _capture();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = _controller;

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (controller != null && controller.value.isInitialized)
            GestureDetector(
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              onVerticalDragCancel: () => setState(() => _pull = 0),
              child: _CameraPreview(controller: controller),
            )
          else if (_failed)
            _CameraMessage(
              message: l10n.mirrorPhotoError,
              closeLabel: l10n.mirrorCameraCloseSemantics,
              onClose: () => Navigator.of(context).pop(),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: AppColors.champagneGold),
            ),
          if (controller != null && controller.value.isInitialized)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: _busy
                            ? null
                            : () => Navigator.of(context).pop(),
                        tooltip: l10n.mirrorCameraCloseSemantics,
                        icon: const Icon(Icons.close, color: AppColors.white),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      l10n.mirrorCameraHint,
                      textAlign: TextAlign.center,
                      style: AppTypography.subheadline.copyWith(
                        color: AppColors.champagneGold,
                        fontSize: AppFontSizes.s11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Transform.translate(
                      offset: Offset(0, -_pull),
                      child: _Shutter(
                        busy: _busy,
                        label: l10n.mirrorCameraCaptureSemantics,
                        onPressed: _capture,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CameraPreview extends StatelessWidget {
  const _CameraPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    var scale = size.aspectRatio * controller.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    Widget preview = Transform.scale(
      scale: scale,
      child: Center(child: CameraPreview(controller)),
    );
    if (controller.description.lensDirection == CameraLensDirection.front) {
      preview = Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(-1, 1, 1),
        child: preview,
      );
    }
    return preview;
  }
}

class _Shutter extends StatelessWidget {
  const _Shutter({
    required this.busy,
    required this.label,
    required this.onPressed,
  });

  final bool busy;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: busy ? null : onPressed,
        child: Container(
          width: 74,
          height: 74,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.champagneGold, width: 3),
          ),
          child: busy
              ? const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.champagneGold,
                  ),
                )
              : Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

class _CameraMessage extends StatelessWidget {
  const _CameraMessage({
    required this.message,
    required this.closeLabel,
    required this.onClose,
  });

  final String message;
  final String closeLabel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.white,
                fontSize: AppFontSizes.s16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            TextButton(
              onPressed: onClose,
              child: Text(
                closeLabel,
                style: AppTypography.subheadline.copyWith(
                  color: AppColors.champagneGold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Uint8List> _mirrorBytes(Uint8List bytes) async {
  try {
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 1080);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final width = image.width.toDouble();
    canvas.translate(width, 0);
    canvas.scale(-1, 1);
    canvas.drawImage(image, Offset.zero, Paint());
    final picture = recorder.endRecording();
    final flipped = await picture.toImage(image.width, image.height);
    final data = await flipped.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    flipped.dispose();
    if (data == null) return bytes;
    return data.buffer.asUint8List();
  } catch (_) {
    return bytes;
  }
}
