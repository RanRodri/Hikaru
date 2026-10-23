import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../l10n/app_localizations.dart';

const Color _frameShadowColor = AppColors.frameBrown;
const Color _accentGold = AppColors.accentGold;
const Color _cameraFill = AppColors.cameraNavy;

class PhotoMirror extends StatefulWidget {
  const PhotoMirror({super.key, required this.onPressed});

  static const String _portraitAsset =
      'assets/images/mirror_portrait_guide.svg';
  static const String _cameraAsset = 'assets/images/mirror_camera.svg';
  static const String _sparkleAsset = 'assets/images/mirror_sparkle.svg';

  static const double _width = 109;
  static const double _height = 249;

  final VoidCallback onPressed;

  @override
  State<PhotoMirror> createState() => _PhotoMirrorState();
}

class _PhotoMirrorState extends State<PhotoMirror>
    with SingleTickerProviderStateMixin {
  static const double _maxLift = 96;
  static const double _trigger = 52;

  late final AnimationController _return = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  var _lift = 0.0;
  var _returnFrom = 0.0;

  @override
  void initState() {
    super.initState();
    _return.addListener(() {
      setState(() => _lift = _returnFrom * (1 - _return.value));
    });
  }

  @override
  void dispose() {
    _return.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _return.stop();
    setState(() => _lift = (_lift - details.delta.dy).clamp(0, _maxLift));
  }

  void _handleDragEnd(DragEndDetails details) {
    final take = _lift >= _trigger || (details.primaryVelocity ?? 0) < -450;
    _returnFrom = _lift;
    _return.forward(from: 0);
    if (take) widget.onPressed();
  }

  void _handleDragCancel() {
    _returnFrom = _lift;
    _return.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.mirrorTakePhotoSemantics,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: widget.onPressed,
        onVerticalDragUpdate: _handleDragUpdate,
        onVerticalDragEnd: _handleDragEnd,
        onVerticalDragCancel: _handleDragCancel,
        child: Transform.translate(
          offset: Offset(0, -_lift),
          child: Container(
          width: PhotoMirror._width,
          height: PhotoMirror._height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PhotoMirror._width / 2),
            gradient: const LinearGradient(
              colors: [
                AppColors.matteChampagne,
                AppColors.champagneGold60,
                AppColors.matteChampagne,
                AppColors.champagneGold60,
                AppColors.champagneGold,
                AppColors.champagneGold60,
                AppColors.matteChampagne,
              ],
              stops: [0, 0.14, 0.29, 0.5, 0.73, 0.91, 1],
            ),
            boxShadow: const [
              BoxShadow(color: AppColors.mirrorGold, blurRadius: 4),
            ],
          ),
          child: Stack(
            children: [
              _layer(
                inset: 2,
                decoration: BoxDecoration(
                  color: _frameShadowColor,
                  borderRadius: BorderRadius.circular(AppRadii.r52_5),
                ),
              ),
              _layer(
                inset: 3.1,
                decoration: BoxDecoration(
                  color: AppColors.matteChampagne,
                  borderRadius: BorderRadius.circular(AppRadii.r51_4),
                  border: Border.all(color: AppColors.fog, width: 0.7),
                ),
              ),
              _layer(
                inset: 6.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.r48_3),
                  border: Border.all(
                    color: AppColors.champagneGold60,
                    width: 0.65,
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.mirrorNavy,
                      AppColors.mirrorSlate,
                      AppColors.cameraNavy,
                      AppColors.mirrorDeep,
                    ],
                    stops: [0, 0.46, 0.72, 1],
                  ),
                ),
              ),
              Positioned(
                left: 7.5,
                top: 50.5,
                child: SvgPicture.asset(
                  PhotoMirror._portraitAsset,
                  width: 94,
                  height: 98,
                ),
              ),
              Positioned(
                left: 32.5,
                top: 154,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _cameraFill,
                    border: Border.all(color: _accentGold, width: 1.1),
                    boxShadow: [
                      BoxShadow(
                        color: _accentGold.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 43,
                top: 167.5,
                child: SvgPicture.asset(
                  PhotoMirror._cameraAsset,
                  width: 23,
                  height: 19,
                ),
              ),
              Positioned(
                left: 18,
                top: 174,
                child: SvgPicture.asset(
                  PhotoMirror._sparkleAsset,
                  width: 5,
                  height: 9,
                ),
              ),
              Positioned(
                left: 85,
                top: 174,
                child: SvgPicture.asset(
                  PhotoMirror._sparkleAsset,
                  width: 5,
                  height: 9,
                ),
              ),
              Positioned(
                left: 15,
                top: 186,
                width: 79,
                height: 56,
                child: Center(
                  // Spanish is longer than English; scale it down to fit
                  // the mirror instead of clipping.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l10n.mirrorTakePhoto,
                      maxLines: 1,
                      style: AppTypography.footnote.copyWith(
                        color: _accentGold,
                        fontWeight: FontWeight.w400,
                        height: 1.25,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _layer({required double inset, required BoxDecoration decoration}) {
    return Positioned(
      left: inset,
      top: inset,
      right: inset,
      bottom: inset,
      child: DecoratedBox(decoration: decoration),
    );
  }
}
