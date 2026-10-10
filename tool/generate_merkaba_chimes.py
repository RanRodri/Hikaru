#!/usr/bin/env python3
"""Write the three placeholder Merkaba chimes as small 16-bit WAV files.

Inhale is a short clear chime, hold is a quiet sustained shimmer, and exhale
is a lower warm chime. These are synthesized stand-ins, not recorded bells.
"""

import math
import struct
import wave
from pathlib import Path

RATE = 22050
OUT = Path("assets/audio")


def _envelope(t: float, attack: float, decay: float, hold: float) -> float:
    if t < attack:
        return t / attack
    if t < attack + hold:
        return 1.0
    return math.exp(-(t - attack - hold) / decay)


def _render(
    duration: float,
    partials: list[tuple[float, float]],
    attack: float,
    decay: float,
    hold: float,
    gain: float,
) -> list[float]:
    count = int(RATE * duration)
    samples = []
    for index in range(count):
        t = index / RATE
        level = _envelope(t, attack, decay, hold)
        sample = 0.0
        for frequency, amplitude in partials:
            sample += amplitude * math.sin(2 * math.pi * frequency * t)
        samples.append(max(-1.0, min(1.0, gain * level * sample)))
    return samples


def _write(name: str, samples: list[float]) -> None:
    path = OUT / name
    with wave.open(str(path), "w") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(RATE)
        frames = b"".join(
            struct.pack("<h", int(sample * 32767)) for sample in samples
        )
        handle.writeframes(frames)
    print(f"{path} {path.stat().st_size} bytes")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    _write(
        "merkaba_inhale.wav",
        _render(
            0.7,
            [(880, 1.0), (1320, 0.4), (1760, 0.18)],
            attack=0.01,
            decay=0.22,
            hold=0.0,
            gain=0.35,
        ),
    )
    _write(
        "merkaba_hold.wav",
        _render(
            1.1,
            [(740, 0.6), (988, 0.35), (1480, 0.12)],
            attack=0.18,
            decay=0.28,
            hold=0.45,
            gain=0.12,
        ),
    )
    _write(
        "merkaba_exhale.wav",
        _render(
            0.85,
            [(392, 1.0), (494, 0.45), (588, 0.2)],
            attack=0.02,
            decay=0.32,
            hold=0.0,
            gain=0.32,
        ),
    )


if __name__ == "__main__":
    main()
