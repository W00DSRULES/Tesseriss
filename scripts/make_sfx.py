#!/usr/bin/env python3
"""Generate the two line-clear sound effects.

The v1.0 binary shipped `line_clear.wav` and `four_line.wav` as all-zero samples,
so the game was silent despite the store copy promising a chime. These are
synthesised from scratch here rather than sourced, which keeps them unambiguously
ours and lets the sounds be tweaked by editing numbers instead of hunting for
replacement audio.

Deliberately plain: decaying sine partials, no noise, no effects. The game's
palette is Satie and Debussy at low volume, so anything percussive or bright
would sit badly against it.

    python3 scripts/make_sfx.py

Writes into TesserissApp/Resources/, overwriting in place.
"""
import math
import pathlib
import struct
import wave

RATE = 44100
PEAK = 0.82  # leaves headroom so nothing clips once iOS mixes it with the music

RESOURCES = pathlib.Path(__file__).resolve().parent.parent / "TesserissApp" / "Resources"


def partial(buf, freq, amp, decay, start=0.0, detune=0.0):
    """Add one exponentially-decaying sine partial into `buf` (in place)."""
    begin = int(start * RATE)
    for i in range(begin, len(buf)):
        t = (i - begin) / RATE
        env = math.exp(-t / decay)
        if env < 1e-4:
            break
        buf[i] += amp * env * math.sin(2 * math.pi * (freq + detune) * t)


TAIL_FADE = 0.06  # seconds


def write(name, buf):
    # Ramp the last few ms to zero. The bell is still ringing at ~12% when the
    # buffer ends, and a hard truncation there is an audible click.
    fade = min(int(TAIL_FADE * RATE), len(buf))
    for i in range(fade):
        buf[len(buf) - fade + i] *= 1.0 - (i / fade)

    peak = max(abs(s) for s in buf) or 1.0
    scale = PEAK / peak
    frames = b"".join(
        struct.pack("<h", int(max(-1.0, min(1.0, s * scale)) * 32767)) for s in buf
    )
    path = RESOURCES / name
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(frames)
    print(f"{path.name}: {len(buf) / RATE:.2f}s, {len(frames)} bytes")


def line_clear():
    """1-3 rows: a soft, short wooden tick. Nearly all of it is over in 120 ms."""
    buf = [0.0] * int(0.30 * RATE)
    partial(buf, 1046.50, 1.00, 0.055)           # C6 fundamental
    partial(buf, 2093.00, 0.28, 0.030)           # one octave up, shorter
    partial(buf, 1568.00, 0.16, 0.040)           # G6, adds a little body
    return buf


def four_line():
    """Four rows at once: a two-note bell, C5 then G5, ringing for about a second."""
    buf = [0.0] * int(1.00 * RATE)
    for start, freq in ((0.00, 523.25), (0.11, 783.99)):
        partial(buf, freq, 1.00, 0.42, start=start)
        partial(buf, freq * 2, 0.34, 0.30, start=start)
        partial(buf, freq * 3, 0.13, 0.22, start=start, detune=1.5)  # slight
        partial(buf, freq * 4.2, 0.07, 0.16, start=start)            # bell shimmer
    return buf


if __name__ == "__main__":
    write("line_clear.wav", line_clear())
    write("four_line.wav", four_line())
