"""
Genera un WAV por cada nota MIDI de C3 (48) a C6 (84).
Timbre cálido con cola de sala (ver tools/synth.py): nota sostenida y
afinada, cómoda para cantar encima.
Salida: assets/notas/n48.wav ... n84.wav

Uso:  python tools/gen_notas.py
"""

import os

import synth

MIDI_MIN = 48   # DO3
MIDI_MAX = 84   # DO6

SALIDA = os.path.join(os.path.dirname(__file__), "..", "assets", "notas")
os.makedirs(SALIDA, exist_ok=True)

for midi in range(MIDI_MIN, MIDI_MAX + 1):
    sig = synth.render_note(midi, dur=2.6)
    synth.save_wav(os.path.join(SALIDA, f"n{midi}.wav"), sig)

print(f"Generados {MIDI_MAX - MIDI_MIN + 1} archivos en {os.path.normpath(SALIDA)}")
