"""
synth.py — síntesis de sonido cálida y con reverb, compartida por los
generadores de audio. Requiere numpy.

Objetivo: un timbre suave, con cuerpo y cola de sala, cómodo para cantar
encima (nota sostenida y afinada, no un "bip" seco).
"""

import wave

import numpy as np

SR = 44100

# Armónicos: fundamental fuerte, caída suave, sin brillo agresivo.
_PARTIALS = [
    (1, 1.00), (2, 0.55), (3, 0.30), (4, 0.16),
    (5, 0.09), (6, 0.05), (7, 0.03), (8, 0.02),
]
_INHARM = 0.00035          # ligera inarmonicidad (color de cuerda)
_DETUNE_CENTS = (-5.0, 0.0, 5.0)  # coro sutil: 3 voces desafinadas un pelín


def _freq(midi: float) -> float:
    return 440.0 * (2.0 ** ((midi - 69) / 12.0))


def _env(n: int, attack=0.008, decay_db=32.0) -> np.ndarray:
    """Ataque rápido + caída exponencial natural (tipo cuerda pulsada).
    Sin meseta de sostenido: así, al encadenar notas, cada una destaca sobre
    la cola de la anterior en vez de acumularse en una pared de sonido.
    """
    e = np.zeros(n)
    a = max(1, int(SR * attack))
    e[:a] = np.linspace(0.0, 1.0, a)
    t2 = np.arange(n - a) / SR
    total_s = (n - a) / SR
    rate = (decay_db / 8.6859) / max(total_s, 0.1)  # -decay_db al final
    e[a:] = np.exp(-rate * t2)
    # micro-fade final para evitar clic al terminar el archivo
    f = min(int(SR * 0.02), n // 4)
    e[-f:] *= np.linspace(1.0, 0.0, f)
    return e


def _tone(midi: float, dur: float) -> np.ndarray:
    n = int(SR * dur)
    t = np.arange(n) / SR
    f0 = _freq(midi)
    out = np.zeros(n)
    for cents in _DETUNE_CENTS:
        f = f0 * (2.0 ** (cents / 1200.0))
        voice = np.zeros(n)
        for k, amp in _PARTIALS:
            fk = f * k * np.sqrt(1.0 + _INHARM * k * k)
            if fk > SR * 0.45:
                break
            voice += amp * np.sin(2.0 * np.pi * fk * t + np.random.rand() * 6.28)
        out += voice
    out *= _env(n) / len(_DETUNE_CENTS)
    return out


def _reverb_ir(tail=0.85, tau=0.34) -> np.ndarray:
    n = int(SR * tail)
    t = np.arange(n) / SR
    ir = np.random.randn(n) * np.exp(-t / tau)
    # suavizado (lowpass) para que la cola no silbe
    k = 24
    ir = np.convolve(ir, np.ones(k) / k, mode='same')
    ir[:int(SR * 0.005)] = 0.0  # pre-delay pequeño
    # ventana final: la cola de la IR baja a cero suavemente (si no, "chasca")
    w = int(SR * 0.20)
    ir[-w:] *= np.linspace(1.0, 0.0, w) ** 2
    ir /= np.max(np.abs(ir)) + 1e-9
    return ir


_IR = None


def _fftconv(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    n = len(a) + len(b) - 1
    nfft = 1 << (n - 1).bit_length()
    out = np.fft.irfft(np.fft.rfft(a, nfft) * np.fft.rfft(b, nfft), nfft)
    return out[:n]


def _reverb(sig: np.ndarray, wet=0.20) -> np.ndarray:
    global _IR
    if _IR is None:
        rng = np.random.get_state()
        np.random.seed(42)
        _IR = _reverb_ir()
        np.random.set_state(rng)
    wetsig = _fftconv(sig, _IR)
    dry = np.concatenate([sig, np.zeros(len(wetsig) - len(sig))])
    mix = (1.0 - wet) * dry + wet * wetsig
    return mix


def _fade_tail(sig: np.ndarray, ms=60.0) -> np.ndarray:
    """Baja a cero los últimos 'ms' milisegundos para que el archivo no
    termine de golpe (lo que produce un 'clic')."""
    f = min(int(SR * ms / 1000.0), len(sig) // 2)
    if f > 0:
        sig = sig.copy()
        sig[-f:] *= np.linspace(1.0, 0.0, f) ** 1.5
    return sig


def render_note(midi: float, dur=2.4) -> np.ndarray:
    return _fade_tail(_normalize(_reverb(_tone(midi, dur))))


def render_events(eventos, dur_total: float) -> np.ndarray:
    """eventos: lista de (t_inicio_s, t_dur_s, [midi, ...])."""
    n = int(SR * dur_total)
    buf = np.zeros(n)
    for (ts, td, notas) in eventos:
        start = int(ts * SR)
        for m in notas:
            tn = _tone(m, td)
            end = min(n, start + len(tn))
            buf[start:end] += tn[:end - start]
    return _fade_tail(_normalize(_reverb(buf)))


def _normalize(sig: np.ndarray, peak=0.32) -> np.ndarray:
    m = np.max(np.abs(sig))
    return sig * (peak / m) if m > 1e-9 else sig


def save_wav(path: str, sig: np.ndarray) -> None:
    data = np.clip(sig, -1.0, 1.0)
    pcm = (data * 32767).astype('<i2').tobytes()
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm)
