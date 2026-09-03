"""
gen_ui.py — sonidos muy cortos de interfaz (feedback de toque).
Salida: assets/audio/tap.wav

Uso:  python tools/gen_ui.py
"""

import os
import wave

import numpy as np

SR = 44100
SALIDA = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio')
os.makedirs(SALIDA, exist_ok=True)


def _save(path, sig, peak=0.16):
    sig = np.asarray(sig, dtype=float)
    m = np.max(np.abs(sig)) + 1e-9
    sig = np.clip(sig * (peak / m), -1.0, 1.0)
    pcm = (sig * 32767).astype('<i2').tobytes()
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm)


def tap():
    """Un 'tic' suave y muy breve (~38 ms): un tono corto + una pizca de aire."""
    n = int(SR * 0.038)
    t = np.arange(n) / SR
    # cuerpo tonal: dos senos cercanos, decaimiento rápido
    env = np.exp(-t * 150.0)
    body = (np.sin(2 * np.pi * 1280 * t) * 0.8 +
            np.sin(2 * np.pi * 1920 * t) * 0.3) * env
    # textura: ruido filtrado, aún más corto
    ne = np.exp(-t * 420.0)
    noise = np.random.RandomState(7).randn(n)
    noise = np.convolve(noise, np.ones(6) / 6, mode='same') * ne * 0.25
    sig = body + noise
    # ataque de 2 ms y micro-fade de salida para que no chasque
    a = int(SR * 0.002)
    sig[:a] *= np.linspace(0.0, 1.0, a)
    f = int(SR * 0.004)
    sig[-f:] *= np.linspace(1.0, 0.0, f)
    return sig


_save(os.path.join(SALIDA, 'tap.wav'), tap())
print('Generado tap.wav en', os.path.normpath(SALIDA))
