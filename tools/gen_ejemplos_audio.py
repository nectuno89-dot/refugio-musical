"""
Ejemplos sonoros para la wiki (escalas, modos, cadencias, tritono), con el
mismo timbre cálido que el teclado (tools/synth.py).
Salida: assets/audio/*.wav

Uso:  python tools/gen_ejemplos_audio.py
"""

import os

import synth

SALIDA = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio')
os.makedirs(SALIDA, exist_ok=True)


def seq(midis, paso=0.42, dur=0.7):
    ev = [(i * paso, dur, [m]) for i, m in enumerate(midis)]
    return ev, len(midis) * paso + dur + 1.1


EJEMPLOS = {}

EJEMPLOS['escala_mayor'] = seq([60, 62, 64, 65, 67, 69, 71, 72])
EJEMPLOS['escala_menor_natural'] = seq([57, 59, 60, 62, 64, 65, 67, 69])
EJEMPLOS['escala_menor_armonica'] = seq([57, 59, 60, 62, 64, 65, 68, 69])
EJEMPLOS['modo_dorico'] = seq([62, 64, 65, 67, 69, 71, 72, 74])
EJEMPLOS['modo_frigio'] = seq([64, 65, 67, 69, 71, 72, 74, 76])
EJEMPLOS['modo_lidio'] = seq([65, 67, 69, 71, 72, 74, 76, 77])
EJEMPLOS['modo_mixolidio'] = seq([67, 69, 71, 72, 74, 76, 77, 79])
EJEMPLOS['escala_pentatonica'] = seq([60, 62, 64, 67, 69, 72])
EJEMPLOS['escala_tonos_enteros'] = seq([60, 62, 64, 66, 68, 70, 72])
EJEMPLOS['escala_cromatica'] = ([(i * 0.22, 0.4, [60 + i]) for i in range(13)],
                                13 * 0.22 + 0.4 + 1.1)

EJEMPLOS['tritono'] = ([
    (0.0, 0.8, [60]),
    (0.9, 0.8, [66]),
    (1.9, 1.8, [60, 66]),
], 5.0)

EJEMPLOS['cadencia_autentica'] = ([
    (0.0, 1.2, [55, 59, 62, 65]),
    (1.3, 2.2, [48, 60, 64, 67]),
], 4.7)
EJEMPLOS['cadencia_plagal'] = ([
    (0.0, 1.2, [53, 57, 60, 65]),
    (1.3, 2.2, [48, 60, 64, 67]),
], 4.7)
EJEMPLOS['cadencia_rota'] = ([
    (0.0, 1.2, [55, 59, 62, 65]),
    (1.3, 2.2, [57, 60, 64, 67]),
], 4.7)

# --- efectos de feedback ---
# acierto: arpegio ascendente breve y brillante
EJEMPLOS['ok'] = ([
    (0.00, 0.16, [72]),
    (0.09, 0.16, [76]),
    (0.18, 0.16, [79]),
    (0.27, 0.55, [84]),
], 1.7)
# error: golpe grave y disonante, corto
EJEMPLOS['mal'] = ([
    (0.0, 0.32, [38, 39, 41]),
], 1.5)

for nombre, (eventos, dur) in EJEMPLOS.items():
    synth.save_wav(os.path.join(SALIDA, nombre + '.wav'),
                   synth.render_events(eventos, dur))

print(f'Generados {len(EJEMPLOS)} ejemplos en {os.path.normpath(SALIDA)}')
