"""
Genera un banco grande de ejercicios centrados en ESCALAS, con dificultad
creciente (nivel 1..5). Salida: assets/content/ejercicios_escalas.json

Tipos usados (todos jugables ya): opcion_multiple, verdadero_falso, completar.

Uso:  python tools/gen_ejercicios.py
"""

import json
import os
import random

random.seed(7)

BASE = {'C': 'DO', 'D': 'RE', 'E': 'MI', 'F': 'FA', 'G': 'SOL', 'A': 'LA', 'B': 'SI'}


def esp(n: str) -> str:
    s = BASE[n[0]]
    acc = n[1:]
    s += {'': '', '#': '♯', 'b': '♭', '##': '♯♯', 'bb': '♭♭'}[acc]
    return s


MAJ = {
    'C': ['C', 'D', 'E', 'F', 'G', 'A', 'B'],
    'G': ['G', 'A', 'B', 'C', 'D', 'E', 'F#'],
    'D': ['D', 'E', 'F#', 'G', 'A', 'B', 'C#'],
    'A': ['A', 'B', 'C#', 'D', 'E', 'F#', 'G#'],
    'E': ['E', 'F#', 'G#', 'A', 'B', 'C#', 'D#'],
    'B': ['B', 'C#', 'D#', 'E', 'F#', 'G#', 'A#'],
    'F#': ['F#', 'G#', 'A#', 'B', 'C#', 'D#', 'E#'],
    'F': ['F', 'G', 'A', 'Bb', 'C', 'D', 'E'],
    'Bb': ['Bb', 'C', 'D', 'Eb', 'F', 'G', 'A'],
    'Eb': ['Eb', 'F', 'G', 'Ab', 'Bb', 'C', 'D'],
    'Ab': ['Ab', 'Bb', 'C', 'Db', 'Eb', 'F', 'G'],
    'Db': ['Db', 'Eb', 'F', 'Gb', 'Ab', 'Bb', 'C'],
    'Gb': ['Gb', 'Ab', 'Bb', 'Cb', 'Db', 'Eb', 'F'],
}
ACC_COUNT = {'C': 0, 'G': 1, 'D': 2, 'A': 3, 'E': 4, 'B': 5, 'F#': 6,
             'F': 1, 'Bb': 2, 'Eb': 3, 'Ab': 4, 'Db': 5, 'Gb': 6}
ACC_KIND = {'C': 'ninguna'}
for k in ['G', 'D', 'A', 'E', 'B', 'F#']:
    ACC_KIND[k] = 'sostenidos'
for k in ['F', 'Bb', 'Eb', 'Ab', 'Db', 'Gb']:
    ACC_KIND[k] = 'bemoles'
REL_MINOR = {'C': 'A', 'G': 'E', 'D': 'B', 'A': 'F#', 'E': 'C#', 'B': 'G#',
             'F#': 'D#', 'F': 'D', 'Bb': 'G', 'Eb': 'C', 'Ab': 'F', 'Db': 'Bb', 'Gb': 'Eb'}
DEG_NAMES = {2: 'supertónica', 3: 'mediante', 4: 'subdominante',
             5: 'dominante', 6: 'superdominante', 7: 'sensible'}
KEYS = list(MAJ.keys())

banco = []
_contador = [0]


def add(nivel, tipo, enunciado, explicacion, **extra):
    _contador[0] += 1
    item = {
        'id': f'esc-gen-{_contador[0]:04d}',
        'nivel': nivel,
        'tipo': tipo,
        'enunciado': enunciado,
        'explicacion': explicacion,
    }
    item.update(extra)
    banco.append(item)


def mezclar_opciones(correcta_texto, distractores):
    opciones = [correcta_texto] + list(distractores)
    random.shuffle(opciones)
    return opciones, opciones.index(correcta_texto)


# ------------------------------------------------------------------ NIVEL 1
add(1, 'completar',
    'Completa la fórmula de la escala mayor (T = tono, ST = semitono).',
    'La escala mayor es T-T-ST-T-T-T-ST. Los semitonos caen entre 3-4 y 7-8.',
    texto='T - T - ___ - T - T - T - ___', respuestas=['ST', 'ST'])

add(1, 'completar',
    'Completa la fórmula de la escala menor natural.',
    'Menor natural: T-ST-T-T-ST-T-T.',
    texto='T - ___ - T - T - ___ - T - T', respuestas=['ST', 'ST'])

o, c = mezclar_opciones('Entre 3-4 y 7-8', ['Entre 1-2 y 5-6', 'Entre 2-3 y 6-7', 'Entre 4-5 y 7-8'])
add(1, 'opcion_multiple',
    '¿Entre qué grados están los semitonos de la escala mayor?',
    'Semitonos entre el 3º y 4º grado, y entre el 7º (sensible) y el 8º (tónica).',
    opciones=o, correcta=c)

o, c = mezclar_opciones('Un semitono', ['Un tono', 'Un tono y medio', 'Dos tonos'])
add(1, 'opcion_multiple', 'Entre MI y FA (teclas blancas contiguas) hay:',
    'MI-FA y SI-DO son los dos semitonos naturales del teclado.',
    opciones=o, correcta=c)

o, c = mezclar_opciones('La tónica', ['La dominante', 'La sensible', 'La mediante'])
add(1, 'opcion_multiple',
    '¿Cómo se llama el primer grado de la escala, la nota de reposo?',
    'La tónica (I) es el centro de gravedad de la escala.', opciones=o, correcta=c)

o, c = mezclar_opciones('7', ['5', '6', '8'])
add(1, 'opcion_multiple',
    '¿Cuántas notas distintas tiene una escala diatónica (mayor o menor)?',
    'Siete notas distintas; la octava repite la tónica.', opciones=o, correcta=c)

add(1, 'verdadero_falso',
    'La escala mayor y su relativa menor comparten exactamente las mismas notas.',
    'Sí: misma armadura. La relativa menor empieza en el 6º grado de la mayor.',
    correcta=True)

add(1, 'completar',
    'La escala pentatónica mayor se obtiene quitando de la escala mayor los grados ___ y ___.',
    'Se quitan la 4ª y la 7ª: así desaparecen las notas que crean más tensión.',
    texto='grados ___ y ___', respuestas=['4', '7'])

o, c = mezclar_opciones('DO RE MI FA SOL LA SI', ['DO RE MI FA SOL LA SI DO',
    'DO MI SOL DO', 'DO REb MI FA SOL LAb SI'])
add(1, 'opcion_multiple', '¿Cuál es la escala de DO mayor?', 'DO mayor no lleva alteraciones.',
    opciones=o, correcta=c)
o, c = mezclar_opciones('tónica', ['sensible', 'dominante', 'subdominante'])
add(1, 'opcion_multiple', 'La escala empieza y termina (una octava después) en la...', '',
    opciones=o, correcta=c)
add(1, 'verdadero_falso', 'Entre DO y RE hay un tono.', 'Sí; hay una tecla negra (DO♯/RE♭) en medio.',
    correcta=True)
add(1, 'verdadero_falso', 'Entre SI y DO hay un tono.', 'No: es un semitono (no hay tecla negra en medio).',
    correcta=False)
o, c = mezclar_opciones('7', ['5', '6', '8'])
add(1, 'opcion_multiple', '¿Cuántas notas distintas tiene la escala mayor antes de repetir la octava?', '',
    opciones=o, correcta=c)
o, c = mezclar_opciones('el 6º grado', ['el 3º grado', 'el 5º grado', 'el 2º grado'])
add(1, 'opcion_multiple', 'La relativa menor de una escala mayor empieza en...',
    'A una 3ª menor por debajo de la tónica mayor.', opciones=o, correcta=c)
add(1, 'completar', 'La menor natural tiene la fórmula T-___-T-T-___-T-T.',
    'Menor natural: T-ST-T-T-ST-T-T.', texto='T-___-T-T-___-T-T', respuestas=['ST', 'ST'])
o, c = mezclar_opciones('cromática', ['pentatónica', 'diatónica', 'mayor'])
add(1, 'opcion_multiple', '¿Qué escala usa las 12 notas, todas a distancia de semitono?', '',
    opciones=o, correcta=c)

# ------------------------------------------------------------------ NIVEL 2  (armaduras)
for k in KEYS:
    n = ACC_COUNT[k]
    o, c = mezclar_opciones(str(n), [str(x) for x in {0, 1, 2, 3, 4, 5, 6} - {n}][:3])
    add(2, 'opcion_multiple',
        f'¿Cuántas alteraciones tiene la armadura de {esp(k)} mayor?',
        f'{esp(k)} mayor lleva {n} {ACC_KIND[k] if n else "alteraciones"}.',
        opciones=o, correcta=c)

    if k != 'C':
        o, c = mezclar_opciones(ACC_KIND[k], [x for x in ['sostenidos', 'bemoles', 'ninguna'] if x != ACC_KIND[k]])
        add(2, 'opcion_multiple',
            f'La armadura de {esp(k)} mayor está formada por...',
            f'{esp(k)} mayor usa {ACC_KIND[k]}.', opciones=o, correcta=c)

# nota alterada concreta (tonos con 1 alteración)
UNA_ALT = {'G': 'F#', 'F': 'Bb', 'D': 'C#', 'Bb': 'Eb'}
for k, alt in UNA_ALT.items():
    add(2, 'completar',
        f'La única nota alterada de {esp(k)} mayor es ___.',
        f'{esp(k)} mayor solo altera {esp(alt)}.',
        texto='___', respuestas=[esp(alt), alt.replace('#', '♯').replace('b', '♭')])

# relativa: qué mayor comparte notas con tal menor
for k in KEYS:
    rm = REL_MINOR[k]
    o, c = mezclar_opciones(f'{esp(k)} mayor',
                            [f'{esp(x)} mayor' for x in random.sample([y for y in KEYS if y != k], 3)])
    add(2, 'opcion_multiple',
        f'La escala de {esp(rm)} menor natural usa las mismas notas que...',
        f'{esp(rm)} menor es la relativa de {esp(k)} mayor (misma armadura).',
        opciones=o, correcta=c)

# ------------------------------------------------------------------ NIVEL 3  (grados, pertenencia, completar)
# Grados: para cada tonalidad, dos grados que rotan (además del V y el VII,
# los más importantes). Antes eran 6 por tonalidad -> demasiado repetitivo.
for i, k in enumerate(KEYS):
    escala = MAJ[k]
    extra = (i % 5) + 3  # 3,4,5,6,7 rotando -> variedad sin inflar
    for grado in dict.fromkeys([5, extra]):  # 1-2 por tonalidad
        correcta = esp(escala[grado - 1])
        otras = [esp(x) for x in escala if esp(x) != correcta]
        o, c = mezclar_opciones(correcta, random.sample(otras, 3))
        add(3, 'opcion_multiple',
            f'En {esp(k)} mayor, ¿qué nota es el/la {grado}º grado ({DEG_NAMES[grado]})?',
            f'{esp(k)} mayor: {"  ".join(esp(x) for x in escala)}. El {grado}º grado es {correcta}.',
            opciones=o, correcta=c)

# Pertenencia (verdadero_falso): 2 por tonalidad, solo en las 9 tonalidades
# más habituales.
CROMA = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
CORE = ['C', 'G', 'D', 'A', 'E', 'F', 'Bb', 'Eb', 'Ab']
for k in CORE:
    setnotas = {esp(x) for x in MAJ[k]}
    reales = list(CROMA)
    random.shuffle(reales)
    for nb in reales[:2]:
        pertenece = esp(nb) in setnotas
        add(3, 'verdadero_falso',
            f'¿Pertenece la nota {esp(nb)} a la escala de {esp(k)} mayor?',
            f'{esp(k)} mayor contiene: {"  ".join(esp(x) for x in MAJ[k])}.',
            correcta=pertenece)

# Completar la escala (dos huecos: 3º y 6º grado): las 9 tonalidades núcleo.
for k in CORE:
    e = [esp(x) for x in MAJ[k]]
    texto = f'{e[0]}, {e[1]}, ___, {e[3]}, {e[4]}, ___, {e[6]}'
    add(3, 'completar',
        f'Completa la escala de {esp(k)} mayor.',
        f'{esp(k)} mayor: {"  ".join(e)}.',
        texto=texto, respuestas=[e[2], e[5]])

# ¿Qué escala mayor forman estas notas? (identificar por notas)
for k in ['G', 'D', 'A', 'F', 'Bb', 'Eb']:
    notas = '  '.join(esp(x) for x in MAJ[k])
    distr = [f'{esp(x)} mayor' for x in random.sample([y for y in KEYS if y != k], 3)]
    o, c = mezclar_opciones(f'{esp(k)} mayor', distr)
    add(3, 'opcion_multiple',
        f'Estas notas forman una escala mayor: {notas}. ¿Cuál es?',
        f'Empieza y termina en {esp(k)} y sigue T-T-ST-T-T-T-ST.',
        opciones=o, correcta=c)

# ------------------------------------------------------------------ NIVEL 4  (modos y menores)
MODOS = [
    ('dórico', 'la 6ª mayor', 'menor natural con la 6ª mayor', 2),
    ('frigio', 'la 2ª menor (b2)', 'menor natural con la 2ª bemol', 3),
    ('lidio', 'la 4ª aumentada (#4)', 'mayor con la 4ª aumentada', 4),
    ('mixolidio', 'la 7ª menor (b7)', 'mayor con la 7ª bemol', 5),
    ('locrio', 'la 5ª disminuida (b5)', 'muy inestable: 2ª y 5ª bemoles', 7),
]
for nombre, rasgo, desc, grado in MODOS:
    o, c = mezclar_opciones(rasgo, [r for (n2, r, d2, g2) in MODOS if r != rasgo][:3])
    add(4, 'opcion_multiple',
        f'¿Cuál es la nota característica del modo {nombre}?',
        f'El modo {nombre} es {desc}.', opciones=o, correcta=c)
    o, c = mezclar_opciones(f'{grado}º', [f'{g}º' for g in [1, 2, 3, 4, 5, 6, 7] if g != grado][:3])
    add(4, 'opcion_multiple',
        f'¿Desde qué grado de la escala mayor se obtiene el modo {nombre}?',
        f'El modo {nombre} sale de tocar la escala mayor empezando por su {grado}º grado.',
        opciones=o, correcta=c)

add(4, 'verdadero_falso', 'El modo eólico es idéntico a la escala menor natural.',
    'Sí: el 6º modo griego (eólico) coincide con la menor natural.', correcta=True)

add(4, 'completar',
    'La escala menor armónica se diferencia de la natural en que sube el ___ grado.',
    'Sube el 7º grado para crear sensible y poder hacer una cadencia fuerte (V7-i).',
    texto='el ___ grado', respuestas=['7', 'séptimo', 'septimo'])

add(4, 'completar',
    'Al ascender, la escala menor melódica sube los grados ___ y ___.',
    'Sube el 6º y el 7º; al descender (versión clásica) vuelve a la menor natural.',
    texto='grados ___ y ___', respuestas=['6', '7'])

o, c = mezclar_opciones('mixolidio', ['dórico', 'lidio', 'frigio'])
add(4, 'opcion_multiple',
    '¿Qué modo se obtiene tocando la escala mayor desde su 5º grado?',
    'Desde el 5º grado sale el mixolidio (mayor con 7ª menor). Es la escala del acorde de dominante.',
    opciones=o, correcta=c)

for grado, modo in [(2, 'dórico'), (3, 'frigio'), (4, 'lidio'), (6, 'eólico'), (7, 'locrio')]:
    o, c = mezclar_opciones(modo, [m for _, m in
        [(2, 'dórico'), (3, 'frigio'), (4, 'lidio'), (6, 'eólico'), (7, 'locrio')] if m != modo][:3])
    add(4, 'opcion_multiple',
        f'¿Qué modo se obtiene tocando la escala mayor desde su {grado}º grado?',
        f'Desde el {grado}º grado sale el {modo}.', opciones=o, correcta=c)

o, c = mezclar_opciones('DO mayor', ['RE mayor', 'SOL mayor', 'FA mayor'])
add(4, 'opcion_multiple', 'RE dórico usa las mismas notas que...',
    'RE es el 2º grado de DO mayor.', opciones=o, correcta=c)
o, c = mezclar_opciones('DO mayor', ['MI mayor', 'LA mayor', 'SOL mayor'])
add(4, 'opcion_multiple', 'MI frigio usa las mismas notas que...',
    'MI es el 3er grado de DO mayor.', opciones=o, correcta=c)
add(4, 'verdadero_falso', 'La menor armónica tiene un salto de 2ª aumentada entre los grados 6 y 7.',
    'Sí: por eso suena "oriental".', correcta=True)

# identificar la escala por sus notas
for k in KEYS:
    notas = '  '.join(esp(x) for x in MAJ[k])
    distr = [f'{esp(x)} mayor' for x in random.sample([y for y in KEYS if y != k], 3)]
    o, c = mezclar_opciones(f'{esp(k)} mayor', distr)
    add(4, 'opcion_multiple',
        f'Estas notas forman una escala mayor: {notas}. ¿Cuál es?',
        f'Empiezan y terminan en {esp(k)} y siguen la fórmula T-T-ST-T-T-T-ST: {esp(k)} mayor.',
        opciones=o, correcta=c)

# ------------------------------------------------------------------ NIVEL 5  (pentatónica / blues / aplicación)
for k in KEYS:
    penta = [esp(MAJ[k][i]) for i in (0, 1, 2, 4, 5)]
    texto = f'{penta[0]}, {penta[1]}, ___, {penta[3]}, ___'
    add(5, 'completar',
        f'Completa la pentatónica mayor de {esp(k)} (escala mayor sin 4ª ni 7ª).',
        f'Pentatónica mayor de {esp(k)}: {"  ".join(penta)}.',
        texto=texto, respuestas=[penta[2], penta[4]])

for k in KEYS:
    rmp = esp(REL_MINOR[k])
    o, c = mezclar_opciones(f'{esp(k)} mayor',
                            [f'{esp(x)} mayor' for x in random.sample([y for y in KEYS if y != k], 3)])
    add(5, 'opcion_multiple',
        f'La pentatónica menor de {rmp} usa las mismas notas que la pentatónica mayor de...',
        f'{rmp} pentatónica menor = {esp(k)} pentatónica mayor (son relativas).',
        opciones=o, correcta=c)

add(5, 'opcion_multiple',
    '¿Qué nota añade la escala de blues a la pentatónica menor?',
    'La "blue note": la 5ª bemol (b5), que roza con la 5ª justa y da el color del blues.',
    **dict(zip(['opciones', 'correcta'], mezclar_opciones('la 5ª bemol (b5)',
        ['la 2ª mayor', 'la 6ª mayor', 'la 7ª mayor']))))

add(5, 'verdadero_falso',
    'Sobre un acorde de dominante (por ejemplo G7) encaja bien la escala mixolidia de su tónica.',
    'Sí: el mixolidio es la escala natural del acorde 7 (dominante).',
    correcta=True)

add(5, 'opcion_multiple',
    'Para mejorar de verdad con las escalas, lo más útil es...',
    'Aplicarlas: hacer variaciones de melodías y pequeños solos escritos, no solo memorizarlas.',
    **dict(zip(['opciones', 'correcta'], mezclar_opciones(
        'usarlas para armar frases y variaciones',
        ['memorizarlas todas antes de tocar', 'estudiar solo su nombre', 'evitar tocarlas hasta dominarlas']))))

o, c = mezclar_opciones('la pentatónica menor', ['la escala cromática', 'la escala de tonos enteros', 'el modo locrio'])
add(5, 'opcion_multiple', 'Para un solo de blues o rock, la escala más segura para empezar es...',
    'Evita las notas que más chocan.', opciones=o, correcta=c)
o, c = mezclar_opciones('DO pentatónica mayor', ['SOL pentatónica mayor', 'FA pentatónica mayor', 'RE pentatónica mayor'])
add(5, 'opcion_multiple', 'LA pentatónica menor usa las mismas notas que...',
    'LA y DO son relativas.', opciones=o, correcta=c)
o, c = mezclar_opciones('6 notas', ['5 notas', '7 notas', '8 notas'])
add(5, 'opcion_multiple', '¿Cuántas notas tiene la escala de tonos enteros?', '', opciones=o, correcta=c)
o, c = mezclar_opciones('8 notas', ['6 notas', '7 notas', '12 notas'])
add(5, 'opcion_multiple', '¿Cuántas notas tiene la escala disminuida?', 'Alterna tono y semitono.',
    opciones=o, correcta=c)
add(5, 'verdadero_falso', 'La escala alterada sirve para tocar sobre un acorde de dominante muy tenso (7alt).',
    'Sí: contiene b9, #9, #11 y b13.', correcta=True)
o, c = mezclar_opciones('el mixolidio', ['el jónico', 'el lidio', 'el dórico'])
add(5, 'opcion_multiple', 'La escala base para improvisar sobre G7 es...', 'G mixolidio.',
    opciones=o, correcta=c)

# ------------------------------------------------------------------ teoría por nivel
TEORIA = {
    1: [
        'Una escala es una fila de notas seguidas (sin saltos) con un patrón fijo de tonos (T) y semitonos (ST). La escala mayor es T-T-ST-T-T-T-ST; la menor natural, T-ST-T-T-ST-T-T.',
        'Cada grado tiene nombre: I tónica, IV subdominante, V dominante, VII sensible. Los semitonos de la escala mayor caen entre los grados 3-4 y 7-8.',
    ],
    2: [
        'La armadura son las alteraciones junto a la clave. Los sostenidos entran FA-DO-SOL-RE-LA-MI-SI; los bemoles al revés. Cada quinta justa en el círculo añade una alteración.',
        'Una escala mayor y su relativa menor comparten armadura y notas: la menor está en el 6º grado de la mayor (una 3ª menor por debajo).',
    ],
    3: [
        'Para construir una escala mayor: parte de la tónica y aplica T-T-ST-T-T-T-ST, una letra por grado, poniendo la alteración necesaria (nunca repitas letra).',
        'La pentatónica mayor es la escala mayor sin la 4ª ni la 7ª. La pentatónica menor es su relativa. La escala de blues añade la 5ª bemol ("blue note").',
    ],
    4: [
        'La menor armónica sube el 7º grado (crea sensible); la menor melódica sube el 6º y el 7º al ascender. Los modos griegos salen de tocar la escala mayor desde cada grado.',
        'Nota característica de cada modo: dórico 6ª mayor, frigio 2ª menor, lidio 4ª aumentada, mixolidio 7ª menor, locrio 5ª disminuida.',
    ],
    5: [
        'En el campo armónico mayor cada grado tiene su modo para improvisar (I jónico, II dórico… V mixolidio). Todos usan las mismas 7 notas de la tonalidad.',
        'Sobre un acorde de dominante (7) la base es el mixolidio; para más tensión, la escala alterada o la disminuida. Lo esencial: aplicar las escalas en frases y variaciones, no solo memorizarlas.',
    ],
}

# ------------------------------------------------------------------ guardar
SALIDA = os.path.join(os.path.dirname(__file__), '..', 'assets', 'content', 'ejercicios_escalas.json')
os.makedirs(os.path.dirname(SALIDA), exist_ok=True)
data = {
    '_schema': 'Banco de ejercicios de escalas, generado por tools/gen_ejercicios.py. '
               'Campos: id, nivel (1..5), tipo, enunciado, explicacion, pista (opcional), '
               'y según tipo: opciones+correcta / correcta / texto+respuestas. Incluye "teoria" por nivel.',
    'teoria': {str(k): v for k, v in TEORIA.items()},
    'ejercicios': sorted(banco, key=lambda x: (x['nivel'], x['id'])),
}
with open(SALIDA, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=1)

por_nivel = {}
for e in banco:
    por_nivel[e['nivel']] = por_nivel.get(e['nivel'], 0) + 1
print(f'Generados {len(banco)} ejercicios -> {os.path.normpath(SALIDA)}')
print('Por nivel:', dict(sorted(por_nivel.items())))
