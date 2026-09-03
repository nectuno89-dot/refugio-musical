"""
Ejemplos sonoros para la sección "Componer".
Salida: assets/audio/comp_*.wav   (mismo timbre que el teclado)

Uso:  python tools/gen_composicion_audio.py
"""

import os

import synth

SALIDA = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio')
os.makedirs(SALIDA, exist_ok=True)


def linea(midis, paso=0.34, dur=0.5, t0=0.0):
    return [(t0 + i * paso, dur, [m]) for i, m in enumerate(midis)]


def acordes(secuencia, paso=1.1, dur=1.5, t0=0.0):
    return [(t0 + i * paso, dur, list(a)) for i, a in enumerate(secuencia)]


EJ = {}

# --- El motivo de la Quinta de Beethoven y tres transformaciones ---
# original (sol-sol-sol-mib) · repetido un grado abajo · invertido · aumentado
mot = [67, 67, 67, 63]
EJ['comp_motivo'] = (
    linea(mot, paso=0.16, dur=0.22, t0=0.0) +
    linea([65, 65, 65, 60], paso=0.16, dur=0.22, t0=1.0) +          # secuencia (abajo)
    linea([67, 67, 67, 72], paso=0.16, dur=0.22, t0=2.0) +          # inversión (sube)
    linea([67, 67, 67, 63], paso=0.34, dur=0.5, t0=3.0),            # aumentación (lento)
    5.6,
)

# --- Tema simple de 8 compases (en DO mayor) y una variación adornada ---
tema = [72, 76, 79, 76, 74, 72, 71, 72]
EJ['comp_tema'] = (linea(tema, paso=0.42, dur=0.6), 8 * 0.42 + 1.2)

variacion = [72, 74, 76, 77, 79, 78, 76, 79, 74, 76, 72, 74, 71, 72, 71, 72]
EJ['comp_variacion'] = (linea(variacion, paso=0.21, dur=0.32),
                        16 * 0.21 + 1.2)

# --- Progresiones armónicas de uso común ---
# I - V - vi - IV  (DO - SOL - LAm - FA)
EJ['comp_prog_pop'] = (acordes([
    [60, 64, 67], [55, 62, 67, 71], [57, 60, 64, 69], [53, 60, 65, 69],
], paso=1.0, dur=1.4), 5.6)

# ii - V - I  (Dm7 - G7 - Cmaj7)
EJ['comp_prog_25'] = (acordes([
    [50, 57, 60, 65], [55, 59, 65, 69], [48, 55, 64, 71],
], paso=1.2, dur=1.7), 5.2)

# Cadencia andaluza:  LAm - SOL - FA - MI
EJ['comp_andaluza'] = (acordes([
    [57, 60, 64], [55, 59, 62], [53, 57, 60], [52, 56, 59, 64],
], paso=1.0, dur=1.4), 5.6)

# --- Notas del acorde frente a notas de paso (melodía sobre DO) ---
# do-mi-sol-mi (del acorde) · do-re-mi-fa-sol (con notas de paso)
EJ['comp_notas_paso'] = (
    linea([60, 64, 67, 64], paso=0.4, dur=0.55, t0=0.0) +
    linea([60, 62, 64, 65, 67], paso=0.32, dur=0.42, t0=2.2),
    5.0,
)

for nombre, (eventos, dur) in EJ.items():
    synth.save_wav(os.path.join(SALIDA, nombre + '.wav'),
                   synth.render_events(eventos, dur))

print(f'Generados {len(EJ)} ejemplos comp_* en {os.path.normpath(SALIDA)}')
