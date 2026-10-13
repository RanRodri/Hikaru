#!/usr/bin/env python3
"""Synthesize proposed Merkaba chimes for approval.

These files are not the ones the app plays. The bundled chimes stay in
assets/audio until the proposal is accepted. Inhale is one clear strike over
4 s, hold is a soft shimmer for 4 s, and exhale is a warmer, lower strike
over 6 s. The peaks are set so that, at the app's mix (chime 0.35, breath
0.6, ambient 0.2), the strikes sit under the breath and the shimmer stays
near the ambient bed.
"""

import argparse
import math
import struct
import wave
from pathlib import Path

RATE = 44100


def _strike(
    duration: float,
    partials: list[tuple[float, float, float]],
    attack: float,
    gain: float,
) -> list[float]:
    count = int(RATE * duration)
    samples = [0.0] * count
    for frequency, amplitude, decay in partials:
        for index in range(count):
            t = index / RATE
            if t < attack:
                envelope = t / attack
            else:
                envelope = math.exp(-(t - attack) / decay)
            samples[index] += (
                gain * amplitude * envelope * math.sin(2 * math.pi * frequency * t)
            )
    return samples


def _shimmer(duration: float) -> list[float]:
    count = int(RATE * duration)
    rise = 0.55
    release = 0.7
    samples = []
    for index in range(count):
        t = index / RATE
        if t < rise:
            envelope = t / rise
        elif t > duration - release:
            envelope = max(0.0, (duration - t) / release)
        else:
            envelope = 1.0
        # Two close highs beat slowly. A third tone adds a quiet sparkle.
        tone = (
            0.62 * math.sin(2 * math.pi * 1568 * t)
            + 0.5 * math.sin(2 * math.pi * 1574.5 * t)
            + 0.18 * math.sin(2 * math.pi * 2093 * t)
        )
        samples.append(0.045 * envelope * tone)
    return samples


def _normalize(samples: list[float], peak_db: float) -> list[float]:
    peak = max(abs(sample) for sample in samples) or 1.0
    target = 10 ** (peak_db / 20)
    scale = target / peak
    return [max(-1.0, min(1.0, sample * scale)) for sample in samples]


def _write(path: Path, samples: list[float]) -> None:
    with wave.open(str(path), "w") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(RATE)
        handle.writeframes(
            b"".join(struct.pack("<h", int(sample * 32767)) for sample in samples)
        )
    print(f"{path} {len(samples) / RATE:.3f}s")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("out", type=Path)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)

    inhale = _normalize(
        _strike(
            4.0,
            [
                (1046.5, 1.0, 1.35),
                (2093.0, 0.42, 0.85),
                (3135.9, 0.16, 0.45),
                (4186.0, 0.06, 0.28),
            ],
            attack=0.008,
            gain=0.55,
        ),
        peak_db=-8.0,
    )
    hold = _normalize(_shimmer(4.0), peak_db=-12.0)
    exhale = _normalize(
        _strike(
            6.0,
            [
                (196.0, 1.0, 2.4),
                (392.0, 0.55, 1.7),
                (587.3, 0.28, 1.1),
                (784.0, 0.12, 0.7),
            ],
            attack=0.012,
            gain=0.5,
        ),
        peak_db=-8.0,
    )
    _write(args.out / "merkaba-chime-inhale-proposed.wav", inhale)
    _write(args.out / "merkaba-chime-hold-proposed.wav", hold)
    _write(args.out / "merkaba-chime-exhale-proposed.wav", exhale)


if __name__ == "__main__":
    main()
