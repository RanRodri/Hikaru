import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../crystals/domain/crystal.dart';
import '../domain/cymatic_audio.dart';
import '../domain/cymatic_plate_profiles.g.dart';
import 'cymatic_plate.dart';

/// Crystal-specific Chladni plate signature generated from its four partials.
final class CymaticMotif {
  const CymaticMotif._(this.profile);

  final CymaticPlateProfile profile;

  int get symmetry => profile.symmetry;
  List<int> get modes => profile.modes;
  List<double> get weights => profile.weights;
  String get lutAsset => profile.lutAsset;

  static final Map<Crystal, CymaticMotif> _byCrystal = {
    for (final crystal in Crystal.values)
      crystal: CymaticMotif._(crystal.cymaticPlateProfile),
  };

  static CymaticMotif of(Crystal crystal) => _byCrystal[crystal]!;

  @override
  bool operator ==(Object other) =>
      other is CymaticMotif && other.profile == profile;

  @override
  int get hashCode => profile.hashCode;
}

/// Simulated fallback pulse. The display-only 528/639 Hz value is deliberately
/// not used to choose or animate a plate mode.
Duration cymaticCycle(Crystal _) => const Duration(milliseconds: 4200);

/// Hikaru gold, turquoise, and indigo keep cycling for the whole playback.
Duration cymaticColorJourney(Crystal _) => const Duration(seconds: 20);

const Duration cymaticSettleDuration = Duration(milliseconds: 800);

/// A circular Chladni plate. With a CYM envelope it follows the real track;
/// CYM2 drives all twelve physical modes independently, while CYM1 is
/// expanded compatibly. Without an envelope it retains a simulated pulse.
class CymaticSignature extends StatefulWidget {
  const CymaticSignature({
    super.key,
    required this.crystal,
    required this.playing,
    this.semanticLabel,
    this.envelope,
    this.playbackPosition,
  });

  final Crystal crystal;
  final bool playing;
  final String? semanticLabel;

  /// Precomputed loudness and modal envelope. Null keeps the simulated pulse.
  final CymaticEnvelope? envelope;

  /// Player position sampled against [envelope]. Ignored without an envelope.
  final ValueListenable<Duration>? playbackPosition;

  @override
  State<CymaticSignature> createState() => CymaticSignatureState();
}

class CymaticSignatureState extends State<CymaticSignature>
    with TickerProviderStateMixin {
  late final AnimationController _phase;
  late final AnimationController _energy;
  late final AnimationController _color;
  final CymaticPlateVisual _visual = CymaticPlateVisual();
  final _PlateEnvelopeFollower _follower = _PlateEnvelopeFollower();
  final List<double> _modalSample = List.filled(cymaticModeCount, 0);
  final Stopwatch _clock = Stopwatch();

  bool _reduceMotion = false;
  bool _synced = false;
  bool _reactive = false;
  Ticker? _ticker;
  Duration? _lastTick;
  Duration _anchor = Duration.zero;
  Duration _anchorClock = Duration.zero;
  Duration _lastPublish = Duration.zero;
  CymaticPlateResources? _resources;
  int _resourceRequest = 0;

  double get phase => _phase.value;
  double get motion => _reduceMotion ? 0 : _energy.value;
  double get colorProgress => _color.value;

  bool get isAnimating =>
      _phase.isAnimating ||
      _energy.isAnimating ||
      _color.isAnimating ||
      (_ticker?.isActive ?? false);

  bool get _usesEnvelope =>
      widget.envelope != null && widget.envelope!.frames > 0;

  CymaticPlateProfile get _profile => widget.crystal.cymaticPlateProfile;

  @override
  void initState() {
    super.initState();
    _phase = AnimationController(
      vsync: this,
      duration: cymaticCycle(widget.crystal),
    );
    _energy = AnimationController(vsync: this, duration: cymaticSettleDuration);
    _color = AnimationController(
      vsync: this,
      duration: cymaticColorJourney(widget.crystal),
    );
    _clock.start();
    for (final controller in [_phase, _energy, _color]) {
      controller.addListener(_publish);
    }
    widget.playbackPosition?.addListener(_onPosition);
    _onPosition();
    _publish();
    _loadResources();
  }

  Future<void> _loadResources() async {
    final request = ++_resourceRequest;
    final crystal = widget.crystal;
    final resources = await loadCymaticPlate(crystal);
    if (!mounted || request != _resourceRequest || crystal != widget.crystal) {
      return;
    }
    setState(() => _resources = resources);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final changed = reduceMotion != _reduceMotion;
    _reduceMotion = reduceMotion;
    if (!_synced || changed) {
      _synced = true;
      _sync();
    }
  }

  @override
  void didUpdateWidget(CymaticSignature oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.crystal != widget.crystal) {
      _phase.duration = cymaticCycle(widget.crystal);
      _color.duration = cymaticColorJourney(widget.crystal);
      _resources = null;
      _follower.reset();
      _loadResources();
    }
    if (oldWidget.playbackPosition != widget.playbackPosition) {
      oldWidget.playbackPosition?.removeListener(_onPosition);
      widget.playbackPosition?.addListener(_onPosition);
      _onPosition();
    }
    if (oldWidget.playing != widget.playing ||
        oldWidget.crystal != widget.crystal ||
        oldWidget.envelope != widget.envelope) {
      _sync();
    }
  }

  void _onPosition() {
    _anchor = widget.playbackPosition?.value ?? Duration.zero;
    _anchorClock = _clock.elapsed;
  }

  Duration _estimatedPosition() {
    final extra = widget.playing
        ? _clock.elapsed - _anchorClock
        : Duration.zero;
    final position = _anchor + extra;
    return position.isNegative ? Duration.zero : position;
  }

  void _publish() {
    final now = _clock.elapsed;
    final dt =
        (now - _lastPublish).inMicroseconds / Duration.microsecondsPerSecond;
    _lastPublish = now;
    _visual.motion = motion;
    _visual.detailPhase = _phase.value;
    _visual.colorProgress = _color.value;
    if (!_reactive) _applySimulated(dt);

    if (_reactive &&
        !widget.playing &&
        !_reduceMotion &&
        _energy.value <= 0.001 &&
        !_energy.isAnimating) {
      _settleEnvelope();
    }
  }

  void _applySimulated(double _) {
    final wave = 0.5 - 0.5 * math.cos(_phase.value * math.pi * 2);
    final presence = 0.18 + 0.82 * motion;
    _visual.level = (0.08 + 0.62 * wave * presence).clamp(0.0, 1.0);
    for (var mode = 0; mode < cymaticModeCount; mode++) {
      final octave = mode % 3;
      final drift =
          0.5 + 0.5 * math.sin((_phase.value + mode * 0.071) * math.pi * 2);
      final octaveFalloff = 1 - octave * 0.08;
      _visual.amplitudes[mode] =
          ((0.42 + 0.5 * drift * presence) * octaveFalloff).clamp(0.0, 1.0);
    }
    _visual.normInv = _mixNormInv(_profile, _visual.amplitudes);
  }

  void _settleEnvelope() {
    _follower.reset();
    _reactive = false;
    _applySimulated(0);
    _stopTicker();
  }

  void _sync() {
    if (_reduceMotion) {
      _stopTicker();
      _follower.reset();
      _reactive = false;
      _phase
        ..stop()
        ..value = 0;
      _energy
        ..stop()
        ..value = 0;
      _color
        ..stop()
        ..value = 0;
      _publish();
      return;
    }

    if (widget.playing) {
      _energy.animateTo(1, curve: Curves.easeInOut);
      if (!_color.isAnimating) {
        _color.repeat(period: cymaticColorJourney(widget.crystal));
      }
      if (_usesEnvelope) {
        _reactive = true;
        _phase.stop();
        _ensureTicker();
      } else {
        _reactive = false;
        _stopTicker();
        if (!_phase.isAnimating) _phase.repeat();
      }
      _publish();
      return;
    }

    _phase.stop();
    _color.stop();
    _energy.animateTo(0, curve: Curves.easeInOut);
    if (_usesEnvelope && _reactive) {
      _ensureTicker();
    } else {
      _reactive = false;
      _stopTicker();
    }
    _publish();
  }

  void _ensureTicker() {
    _ticker ??= createTicker(_onTick);
    if (!_ticker!.isActive) {
      _lastTick = null;
      _ticker!.start();
    }
  }

  void _stopTicker() {
    _lastTick = null;
    if (_ticker?.isActive ?? false) _ticker!.stop();
  }

  void _onTick(Duration elapsed) {
    final dt = _lastTick == null
        ? 1 / 60
        : (elapsed - _lastTick!).inMicroseconds /
              Duration.microsecondsPerSecond;
    _lastTick = elapsed;

    if (!widget.playing && _energy.value <= 0.001 && !_energy.isAnimating) {
      _settleEnvelope();
      return;
    }

    final envelope = widget.envelope;
    if (envelope == null) {
      _settleEnvelope();
      return;
    }

    if (widget.playing) {
      final position = _estimatedPosition();
      final window = envelope.sampleAt(position);
      envelope.sampleModesAt(position, _modalSample, legacyWindow: window);
      _follower.follow(window, _modalSample, dt);
    } else {
      _follower.release(dt);
    }

    _visual.level = _follower.level;
    for (var mode = 0; mode < cymaticModeCount; mode++) {
      _visual.amplitudes[mode] = _follower.amplitudes[mode];
    }
    _visual.normInv = _mixNormInv(_profile, _visual.amplitudes);

    // Updating an idle controller notifies the CustomPainter without rebuilding
    // the screen. Coefficients change, but no angular phase is introduced.
    final speed = dt.clamp(0.0, 0.05) * (0.1 + 0.28 * _visual.level);
    _phase.value = (_phase.value + speed) % 1;
  }

  @override
  void dispose() {
    _resourceRequest++;
    widget.playbackPosition?.removeListener(_onPosition);
    _ticker?.dispose();
    _phase.dispose();
    _energy.dispose();
    _color.dispose();
    _clock.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repaint = Listenable.merge([_phase, _energy, _color]);
    final profile = _profile;
    final resources = _resources;
    final mediaQuery = MediaQuery.of(context);
    final lowResolution =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) &&
        mediaQuery.devicePixelRatio <= 2.0;

    final painter = resources == null
        ? CymaticPlateFallbackPainter(
            repaint: repaint,
            visual: _visual,
            profile: profile,
          )
        : CymaticPlatePainter(
            repaint: repaint,
            program: resources.program,
            lut: resources.lut,
            visual: _visual,
            profile: profile,
            reducedResolution: lowResolution,
            rasterScale: lowResolution ? mediaQuery.devicePixelRatio * 0.5 : 1,
          );

    return Semantics(
      label: widget.semanticLabel,
      child: CustomPaint(painter: painter, child: const SizedBox.expand()),
    );
  }
}

/// Independent attack/release smoothing for RMS and the twelve plate modes.
/// Attack approaches its target in about 60 ms; release takes about 300 ms.
final class _PlateEnvelopeFollower {
  static const double _attackSeconds = 0.06;
  static const double _releaseSeconds = 0.30;
  static final List<double> _silence = List.filled(cymaticModeCount, 0);

  double level = 0;
  final List<double> amplitudes = List.filled(cymaticModeCount, 0);

  void reset() {
    level = 0;
    for (var index = 0; index < amplitudes.length; index++) {
      amplitudes[index] = 0;
    }
  }

  void follow(CymaticWindow window, List<double> modalAmplitudes, double dt) {
    _approach(window.rms.clamp(0.0, 1.0), modalAmplitudes, dt);
  }

  void release(double dt) => _approach(0, _silence, dt);

  void _approach(double targetLevel, List<double> targetAmplitudes, double dt) {
    level = _smooth(level, targetLevel, dt);
    for (var index = 0; index < amplitudes.length; index++) {
      amplitudes[index] = _smooth(
        amplitudes[index],
        targetAmplitudes[index],
        dt,
      );
    }
  }

  static double _smooth(double current, double target, double dt) {
    final seconds = target > current ? _attackSeconds : _releaseSeconds;
    final alpha = 1 - math.exp(-dt.clamp(0.0, 0.05) / seconds);
    return current + (target - current) * alpha;
  }
}

double _mixNormInv(CymaticPlateProfile profile, List<double> amplitudes) {
  var energy = 0.0;
  for (var layer = 0; layer < 12; layer++) {
    final angularRms = profile.modes[layer] == 0 ? 1.0 : math.sqrt(0.5);
    final coefficient =
        profile.weights[layer] *
        math.pow(amplitudes[layer].clamp(0.0, 1.0), 1.5);
    final rms = coefficient * profile.radialRms[layer] * angularRms;
    energy += rms * rms;
  }
  if (energy <= 1e-10) return 1;
  return (1 / math.sqrt(energy)).clamp(0.25, 24.0);
}
