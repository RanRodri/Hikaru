import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../domain/massage_ritual.dart';

class MassageScreen extends StatefulWidget {
  const MassageScreen({super.key, required this.surface});

  final MassageSurface surface;

  @override
  State<MassageScreen> createState() => _MassageScreenState();
}

class _MassageScreenState extends State<MassageScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;
  Duration _lastTick = Duration.zero;
  bool _playing = false;
  int _zoneIndex = 0;
  MassagePressure _pressure = MassagePressure.light;

  List<MassageZone> get _zones => zonesFor(widget.surface);

  MassageZone get _zone => _zones[_zoneIndex];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_handleTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _handleTick(Duration sinceStart) {
    if (!_playing) return;
    final delta = sinceStart - _lastTick;
    _lastTick = sinceStart;
    setState(() => _elapsed += delta);
  }

  void _handlePlayPause() {
    if (_playing) {
      setState(() => _playing = false);
      _ticker.stop();
      return;
    }
    setState(() => _playing = true);
    _lastTick = Duration.zero;
    _ticker.start();
  }

  void _handleRestart() {
    _ticker.stop();
    setState(() {
      _playing = false;
      _elapsed = Duration.zero;
    });
  }

  void _handleNextZone() {
    if (_zoneIndex >= _zones.length - 1) return;
    setState(() {
      _zoneIndex += 1;
      _elapsed = Duration.zero;
    });
  }

  void _handleZoneSelected(int index) {
    setState(() => _zoneIndex = index);
  }

  void _handlePressure(MassagePressure pressure) {
    setState(() => _pressure = pressure);
  }

  @override
  Widget build(BuildContext context) {
    final isFace = widget.surface == MassageSurface.face;
    final steps = guidedStepsFor(widget.surface, _zone);

    return Scaffold(
      backgroundColor: AppColors.darkIndigoBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _Control(label: 'BACK', onPressed: () => context.pop()),
              ),
              Text(
                'HIKARU MASSAGE',
                textAlign: TextAlign.center,
                style: AppTypography.subheadline.copyWith(
                  color: AppColors.champagneGold,
                  fontSize: 12,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isFace ? 'FACIAL' : 'BODY',
                textAlign: TextAlign.center,
                style: AppTypography.title.copyWith(
                  color: AppColors.white,
                  fontSize: 28,
                ),
              ),
              Text(
                'SCULPT · LIFT · AWAKEN',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.fog,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              const _VideoPlaceholder(),
              const SizedBox(height: 16),
              Text(
                _zone.name,
                textAlign: TextAlign.center,
                style: AppTypography.headline.copyWith(
                  color: AppColors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                massageStrokeGuidance,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.fog,
                  fontSize: 12,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                formatMassageClock(_elapsed),
                textAlign: TextAlign.center,
                style: AppTypography.title.copyWith(
                  color: AppColors.champagneGold,
                  fontSize: 28,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Control(label: 'RESTART', onPressed: _handleRestart),
                  _Control(
                    label: _playing ? 'PAUSE' : 'PLAY',
                    onPressed: _handlePlayPause,
                  ),
                  _Control(
                    label: 'NEXT',
                    onPressed: _zoneIndex >= _zones.length - 1
                        ? null
                        : _handleNextZone,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var index = 0; index < _zones.length; index++)
                    _ChoiceChip(
                      label: _zones[index].name,
                      selected: index == _zoneIndex,
                      onPressed: () => _handleZoneSelected(index),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'PRESSURE',
                textAlign: TextAlign.center,
                style: AppTypography.subheadline.copyWith(
                  color: AppColors.champagneGold,
                  fontSize: 10,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final pressure in MassagePressure.values)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _ChoiceChip(
                          label: pressure.label,
                          selected: pressure == _pressure,
                          onPressed: () => _handlePressure(pressure),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    for (final step in steps)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          step,
                          textAlign: TextAlign.center,
                          style: AppTypography.body.copyWith(
                            color: AppColors.white,
                            fontSize: 12,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                isFace ? 'FACIAL RITUAL' : 'BODY RITUAL',
                textAlign: TextAlign.center,
                style: AppTypography.footnote.copyWith(
                  color: AppColors.champagneGold,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Gua Sha video',
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.indigoBlue,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.champagneGold),
          ),
          child: Center(
            child: Text(
              'Gua Sha',
              style: AppTypography.subheadline.copyWith(
                color: AppColors.champagneGold,
                fontSize: 12,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Control extends StatelessWidget {
  const _Control({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: AppTypography.subheadline.copyWith(
          color: onPressed == null
              ? AppColors.champagneGold.withValues(alpha: 0.35)
              : AppColors.champagneGold,
          fontSize: 12,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: selected
              ? AppColors.champagneGold
              : AppColors.champagneGold.withValues(alpha: 0),
          foregroundColor: selected ? AppColors.darkIndigoBlue : AppColors.fog,
          shape: const StadiumBorder(
            side: BorderSide(color: AppColors.champagneGold),
          ),
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(
          label,
          style: AppTypography.body.copyWith(
            color: selected ? AppColors.darkIndigoBlue : AppColors.fog,
            fontSize: 11,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
