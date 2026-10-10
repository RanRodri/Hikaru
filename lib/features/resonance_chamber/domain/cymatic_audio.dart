import 'dart:math' as math;
import 'dart:typed_data';

/// One analysis frame: loudness plus how the energy is split across bands.
class CymaticWindow {
  const CymaticWindow({
    required this.rms,
    required this.low,
    required this.mid,
    required this.high,
  });

  static const silent = CymaticWindow(rms: 0, low: 0, mid: 0, high: 0);

  /// Root-mean-square amplitude, 0–1 of full scale (or of the file peak after
  /// the envelope normalizes it).
  final double rms;

  /// Share of band power below ~280 Hz. The three shares sum to 1, or 0 in silence.
  final double low;

  /// Share of band power from ~280 Hz to ~1.4 kHz.
  final double mid;

  /// Share of band power from ~1.4 kHz to ~4.2 kHz.
  final double high;
}

/// Goertzel bands and RMS for one PCM window. Samples are in -1..1.
CymaticWindow analyzeCymaticWindow(
  List<double> samples, {
  int sampleRate = CymaticEnvelope.analysisRate,
}) {
  if (samples.isEmpty) return CymaticWindow.silent;

  var square = 0.0;
  for (final sample in samples) {
    square += sample * sample;
  }
  final rms = math.sqrt(square / samples.length);

  final low = _bandPower(samples, sampleRate, 40, 280);
  final mid = _bandPower(samples, sampleRate, 280, 1400);
  final high = _bandPower(samples, sampleRate, 1400, 4200);
  final total = low + mid + high;
  if (total < 1e-8) {
    return CymaticWindow(rms: rms, low: 0, mid: 0, high: 0);
  }
  return CymaticWindow(
    rms: rms,
    low: low / total,
    mid: mid / total,
    high: high / total,
  );
}

double _bandPower(
  List<double> samples,
  int sampleRate,
  double minHz,
  double maxHz,
) {
  final bins = samples.length;
  if (bins < 4 || sampleRate <= 0) return 0;
  final nyquist = bins ~/ 2 - 1;
  final first = (minHz * bins / sampleRate).ceil().clamp(1, nyquist);
  final last = (maxHz * bins / sampleRate).floor().clamp(first, nyquist);
  var power = 0.0;
  for (var bin = first; bin <= last; bin++) {
    power += _goertzelPower(samples, bin);
  }
  return power;
}

double _goertzelPower(List<double> samples, int bin) {
  final coeff = 2 * math.cos(2 * math.pi * bin / samples.length);
  var s1 = 0.0;
  var s2 = 0.0;
  for (final sample in samples) {
    final s0 = sample + coeff * s1 - s2;
    s2 = s1;
    s1 = s0;
  }
  return s1 * s1 + s2 * s2 - coeff * s1 * s2;
}

/// Compact RMS and band envelope for one crystal track.
///
/// Built offline from the bundled AAC so playback can look the energy up by
/// position. Nothing is captured from the microphone.
class CymaticEnvelope {
  CymaticEnvelope({
    required this.rms,
    required this.low,
    required this.mid,
    required this.high,
    this.hopSamples = analysisHop,
    this.rate = analysisRate,
  });

  static const int analysisRate = 16000;
  static const int analysisHop = 320;
  static const int analysisWindow = 256;
  static const int _magic = 0x43594D31;
  static const int _version = 1;
  static const int _headerBytes = 16;

  final Float32List rms;
  final Float32List low;
  final Float32List mid;
  final Float32List high;
  final int hopSamples;
  final int rate;

  int get frames => rms.length;

  Duration get duration {
    if (frames == 0 || rate <= 0) return Duration.zero;
    final microseconds = frames * hopSamples * 1000000 ~/ rate;
    return Duration(microseconds: microseconds);
  }

  CymaticWindow sampleAt(Duration position) {
    if (frames == 0 || rate <= 0) return CymaticWindow.silent;
    final frameMicros = hopSamples * 1000000 / rate;
    final period = frames * frameMicros;
    if (period <= 0) return CymaticWindow.silent;
    var wrapped = position.inMicroseconds % period;
    if (wrapped < 0) wrapped += period;
    final exact = wrapped / frameMicros;
    final index = exact.floor() % frames;
    final next = (index + 1) % frames;
    final t = exact - exact.floor();
    return CymaticWindow(
      rms: _lerp(rms[index], rms[next], t),
      low: _lerp(low[index], low[next], t),
      mid: _lerp(mid[index], mid[next], t),
      high: _lerp(high[index], high[next], t),
    );
  }

  Uint8List encode() {
    final bytes = Uint8List(_headerBytes + frames * 4);
    final data = ByteData.sublistView(bytes);
    data.setUint32(0, _magic);
    data.setUint16(4, _version);
    data.setUint16(6, hopSamples);
    data.setUint32(8, rate);
    data.setUint32(12, frames);
    for (var frame = 0; frame < frames; frame++) {
      final offset = _headerBytes + frame * 4;
      bytes[offset] = _unit8(rms[frame]);
      bytes[offset + 1] = _unit8(low[frame]);
      bytes[offset + 2] = _unit8(mid[frame]);
      bytes[offset + 3] = _unit8(high[frame]);
    }
    return bytes;
  }

  static CymaticEnvelope? decode(Uint8List bytes) {
    if (bytes.length < _headerBytes) return null;
    final data = ByteData.sublistView(bytes);
    if (data.getUint32(0) != _magic || data.getUint16(4) != _version) {
      return null;
    }
    final hop = data.getUint16(6);
    final rate = data.getUint32(8);
    final frames = data.getUint32(12);
    if (hop == 0 || rate == 0 || bytes.length < _headerBytes + frames * 4) {
      return null;
    }
    final rms = Float32List(frames);
    final low = Float32List(frames);
    final mid = Float32List(frames);
    final high = Float32List(frames);
    for (var frame = 0; frame < frames; frame++) {
      final offset = _headerBytes + frame * 4;
      rms[frame] = bytes[offset] / 255;
      low[frame] = bytes[offset + 1] / 255;
      mid[frame] = bytes[offset + 2] / 255;
      high[frame] = bytes[offset + 3] / 255;
    }
    return CymaticEnvelope(
      rms: rms,
      low: low,
      mid: mid,
      high: high,
      hopSamples: hop,
      rate: rate,
    );
  }
}

/// `audio/white_quartz.m4a` → `assets/audio/white_quartz.cym`.
String cymaticEnvelopeAsset(String audioAsset) {
  final slash = audioAsset.lastIndexOf('/');
  final name = slash >= 0 ? audioAsset.substring(slash + 1) : audioAsset;
  final dot = name.lastIndexOf('.');
  final stem = dot > 0 ? name.substring(0, dot) : name;
  return 'assets/audio/$stem.cym';
}

/// Builds an envelope from mono 16-bit PCM. RMS is scaled so the 99th
/// percentile is 1, which keeps a quiet track and a loud one in the same range.
CymaticEnvelope envelopeFromPcm(
  Int16List pcm, {
  int sampleRate = CymaticEnvelope.analysisRate,
  int hopSamples = CymaticEnvelope.analysisHop,
  int windowSamples = CymaticEnvelope.analysisWindow,
}) {
  if (pcm.isEmpty || hopSamples <= 0 || windowSamples <= 0) {
    return CymaticEnvelope(
      rms: Float32List(0),
      low: Float32List(0),
      mid: Float32List(0),
      high: Float32List(0),
      hopSamples: hopSamples <= 0 ? CymaticEnvelope.analysisHop : hopSamples,
      rate: sampleRate <= 0 ? CymaticEnvelope.analysisRate : sampleRate,
    );
  }

  final frames = math.max(1, pcm.length ~/ hopSamples);
  final rms = Float32List(frames);
  final low = Float32List(frames);
  final mid = Float32List(frames);
  final high = Float32List(frames);
  final window = List<double>.filled(windowSamples, 0);

  for (var frame = 0; frame < frames; frame++) {
    final end = math.min(pcm.length, frame * hopSamples + windowSamples);
    final start = math.max(0, end - windowSamples);
    for (var index = 0; index < windowSamples; index++) {
      final source = start + index;
      window[index] = source < end ? pcm[source] / 32768.0 : 0;
    }
    final analyzed = analyzeCymaticWindow(window, sampleRate: sampleRate);
    rms[frame] = analyzed.rms;
    low[frame] = analyzed.low;
    mid[frame] = analyzed.mid;
    high[frame] = analyzed.high;
  }

  final ranked = Float32List.fromList(rms)..sort();
  final peak = ranked[(0.99 * (ranked.length - 1)).round()];
  final scale = peak > 1e-6 ? peak : 1.0;
  for (var frame = 0; frame < frames; frame++) {
    rms[frame] = (rms[frame] / scale).clamp(0.0, 1.0);
  }

  return CymaticEnvelope(
    rms: rms,
    low: low,
    mid: mid,
    high: high,
    hopSamples: hopSamples,
    rate: sampleRate,
  );
}

/// What the mandala should do for one analysis step.
class CymaticDrive {
  const CymaticDrive({
    required this.amplitude,
    required this.scale,
    required this.morph,
    required this.glow,
    required this.spawn,
  });

  /// Spring output, 0 at rest and 1 on a strong attack.
  final double amplitude;

  /// Overall scale, 1.0 at rest and about 1.15 on a peak.
  final double scale;

  /// 0 draws diamonds, 1 draws petals. Follows the high-band share.
  final double morph;

  /// 0–1 glow from the attack and the high band.
  final double glow;

  /// True when this step crosses an onset and should emit sparks.
  final bool spawn;
}

/// Fast attack, springy release. A steady tone settles; a rise pulses.
class CymaticFollower {
  double _fast = 0;
  double _bed = 0;
  double _amplitude = 0;
  double _velocity = 0;
  double _sinceSpawn = 1;
  bool _hot = false;
  double _low = 0;
  double _mid = 0;
  double _high = 0;

  double get amplitude => _amplitude;

  double get scale => 1 + 0.15 * _amplitude;

  void reset() {
    _fast = 0;
    _bed = 0;
    _amplitude = 0;
    _velocity = 0;
    _sinceSpawn = 1;
    _hot = false;
    _low = 0;
    _mid = 0;
    _high = 0;
  }

  CymaticDrive step({
    required double rms,
    required double low,
    required double mid,
    required double high,
    required double dt,
  }) {
    final stepDt = dt.clamp(0.0, 0.03);
    _low = low;
    _mid = mid;
    _high = high;
    _fast = _approach(_fast, rms.clamp(0.0, 1.0), 50, stepDt);
    _bed = _approach(_bed, _fast, 10, stepDt);
    final excitement = ((_fast - _bed) / (_bed * 0.05 + 0.008)).clamp(0.0, 1.0);
    _springToward(excitement, stepDt);
    _sinceSpawn += stepDt;

    final hot = excitement > 0.32 && _fast > _bed + 0.008;
    final spawn = hot && !_hot && _sinceSpawn >= 0.07;
    _hot = hot;
    if (spawn) _sinceSpawn = 0;

    final share = low + mid + high;
    final highShare = share < 1e-8 ? 0.0 : (high / share).clamp(0.0, 1.0);
    return CymaticDrive(
      amplitude: _amplitude,
      scale: 1 + 0.15 * _amplitude,
      morph: highShare,
      glow: (0.35 * _amplitude + 0.65 * highShare).clamp(0.0, 1.0),
      spawn: spawn,
    );
  }

  /// Ease the pulse back down without treating the pause as a new onset.
  CymaticDrive release(double dt) {
    return step(rms: _bed, low: _low, mid: _mid, high: _high, dt: dt);
  }

  void _springToward(double target, double dt) {
    if (dt <= 0) return;
    final rising = target > _amplitude;
    final stiffness = rising ? 1100.0 : 420.0;
    final damping = rising ? 36.0 : 22.0;
    final acceleration =
        stiffness * (target - _amplitude) - damping * _velocity;
    _velocity += acceleration * dt;
    _amplitude = (_amplitude + _velocity * dt).clamp(0.0, 1.0);
    if (_amplitude == 0 || _amplitude == 1) _velocity = 0;
  }
}

double _approach(double current, double target, double rate, double dt) {
  if (dt <= 0) return current;
  final alpha = 1 - math.exp(-rate * dt);
  return current + (target - current) * alpha;
}

double _lerp(double from, double to, double t) => from + (to - from) * t;

int _unit8(double value) => (value.clamp(0.0, 1.0) * 255).round();
