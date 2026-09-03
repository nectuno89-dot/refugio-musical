"""
Genera un set amplio de LECCIONES de escalas, en 5 niveles de dificultad.
Cada lección: título, objetivo, intro (1-2 párrafos) y 6 ejercicios.
Salida: assets/content/lecciones.json

Uso:  python tools/gen_lecciones.py
"""

import json
import os
import random

random.seed(11)

BASE = {'C': 'DO', 'D': 'RE', 'E': 'MI', 'F': 'FA', 'G': 'SOL', 'A': 'LA', 'B': 'SI'}


def esp(n):
    return BASE[n[0]] + {'': '', '#': '♯', 'b': '♭'}[n[1:]]


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
REL_MINOR = {'C': 'A', 'G': 'E', 'D': 'B', 'A': 'F#', 'E': 'C#', 'B': 'G#',
             'F#': 'D#', 'F': 'D', 'Bb': 'G', 'Eb': 'C', 'Ab': 'F', 'Db': 'Bb', 'Gb': 'Eb'}
DEG = {2: 'supertónica', 3: 'mediante', 4: 'subdominante', 5: 'dominante',
       6: 'superdominante', 7: 'sensible'}
SHARP_KEYS = ['G', 'D', 'A', 'E', 'B', 'F#']
FLAT_KEYS = ['F', 'Bb', 'Eb', 'Ab', 'Db', 'Gb']


def om(enun, correcta, distr, expl):
    ops = [correcta] + list(distr)
    random.shuffle(ops)
    return {'tipo': 'opcion_multiple', 'enunciado': enun, 'opciones': ops,
            'correcta': ops.index(correcta), 'explicacion': expl}


def vf(enun, val, expl):
    return {'tipo': 'verdadero_falso', 'enunciado': enun, 'correcta': bool(val),
            'explicacion': expl}


def cp(enun, texto, resp, expl):
    return {'tipo': 'completar', 'enunciado': enun, 'texto': texto,
            'respuestas': list(resp), 'explicacion': expl}


def grado_om(k, g):
    esc = MAJ[k]
    correcta = esp(esc[g - 1])
    distr = random.sample([esp(x) for x in esc if esp(x) != correcta], 3)
    return om(f'En {esp(k)} mayor, ¿qué nota es el {g}º grado ({DEG[g]})?',
              correcta, distr,
              f'{esp(k)} mayor: {"  ".join(esp(x) for x in esc)}. El {g}º grado es {correcta}.')


def completar_mayor(k):
    e = [esp(x) for x in MAJ[k]]
    return cp(f'Completa la escala de {esp(k)} mayor.',
              f'{e[0]}, {e[1]}, ___, {e[3]}, {e[4]}, ___, {e[6]}',
              [e[2], e[5]], f'{esp(k)} mayor: {"  ".join(e)}.')


lecciones = []

# --- bloques de ejemplo para la introducción didáctica -------------------
PASOS = {
    'mayor': [2, 2, 1, 2, 2, 2, 1],
    'menor natural': [2, 1, 2, 2, 1, 2, 2],
    'menor armónica': [2, 1, 2, 2, 1, 3, 1],
    'menor melódica': [2, 1, 2, 2, 2, 2, 1],
    'pentatónica mayor': [2, 2, 3, 2, 3],
    'pentatónica menor': [3, 2, 2, 3, 2],
    'dórico': [2, 1, 2, 2, 2, 1, 2],
    'mixolidio': [2, 2, 1, 2, 2, 1, 2],
    'frigio': [1, 2, 2, 2, 1, 2, 2],
    'lidio': [2, 2, 2, 1, 2, 2, 1],
    'blues': [3, 2, 1, 1, 3, 2],
}
IDX = {'DO': 0, 'RE': 2, 'MI': 4, 'FA': 5, 'SOL': 7, 'LA': 9, 'SI': 11}


def b_texto(t):
    return {'tipo': 'texto', 'texto': t}


def b_escala(tonica, nombre, nota=None):
    return {'tipo': 'escala', 'tonicaIdx': IDX[tonica], 'pasos': PASOS[nombre],
            'nota': nota or f'{nombre[0].upper()}{nombre[1:]} de {tonica}'}


def b_nota(midi, nota):
    return {'tipo': 'nota', 'midi': midi, 'nota': nota}


def b_audio(archivo, nota):
    return {'tipo': 'audio', 'archivo': archivo, 'nota': nota}


def _ejemplos_auto(titulo):
    """Un par de ejemplos interactivos deducidos del título de la lección."""
    t = titulo.lower()
    if 'tono y semitono' in t:
        return [b_nota(64, 'MI y FA: entre ellas solo hay un semitono'),
                b_nota(65, 'FA')]
    if 'menor armónica' in t:
        return [b_escala('LA', 'menor armónica'),
                b_audio('escala_menor_armonica', 'Escúchala: el salto grande entre 6º y 7º')]
    if 'menor melódica' in t:
        return [b_escala('LA', 'menor melódica')]
    if 'menor natural' in t or 'relativas' in t:
        return [b_escala('LA', 'menor natural'),
                b_audio('escala_menor_natural', 'LA menor natural')]
    if 'pentatón' in t or 'blues' in t:
        return [b_escala('DO', 'pentatónica mayor'),
                b_audio('escala_pentatonica', 'Pentatónica: 5 notas, "todo suena bien"')]
    if 'dórico' in t or 'mixolidio' in t:
        return [b_audio('modo_dorico', 'Modo dórico (RE a RE)'),
                b_audio('modo_mixolidio', 'Modo mixolidio (SOL a SOL)')]
    if 'frigio' in t or 'lidio' in t or 'locrio' in t:
        return [b_audio('modo_frigio', 'Modo frigio (MI a MI)'),
                b_audio('modo_lidio', 'Modo lidio (FA a FA)')]
    if 'modo' in t:
        return [b_audio('escala_mayor', 'Escala mayor (jónico)'),
                b_audio('modo_dorico', 'El mismo material desde el 2º grado: dórico')]
    if 'dominante' in t:
        return [b_audio('modo_mixolidio', 'Mixolidio: la escala del acorde de dominante'),
                b_audio('cadencia_autentica', 'Cadencia V-I')]
    if 'círculo de quintas' in t or 'sostenidos' in t:
        return [b_escala('SOL', 'mayor', 'SOL mayor: aparece FA♯')]
    if 'bemoles' in t:
        return [b_escala('FA', 'mayor', 'FA mayor: aparece SI♭')]
    # por defecto: la escala mayor en el pentagrama, para oírla y verla
    return [b_escala('DO', 'mayor'),
            b_audio('escala_mayor', 'DO mayor, ascendente')]


def L(nivel, n, titulo, objetivo, intro, ejercicios, ejemplos=None):
    assert len(ejercicios) == 6, f'{titulo}: {len(ejercicios)} ejercicios'
    for i, ej in enumerate(ejercicios, 1):
        ej['id'] = f'lecx-{nivel}-{n}-{i:02d}'
        ej['nivel'] = nivel
    bloques = [b_texto(t) for t in intro]
    bloques += ejemplos if ejemplos is not None else _ejemplos_auto(titulo)
    lecciones.append({
        'id': f'lec-{nivel}-{n}', 'nivel': nivel, 'titulo': titulo,
        'objetivo': objetivo, 'intro': bloques, 'ejercicios': ejercicios,
    })


# =========================================================== NIVEL 1
L(1, 1, '¿Qué es una escala?',
  'Entender qué es una escala y qué la distingue de otra.',
  ['Una escala es una fila de notas ordenadas: subes de una en una, sin saltarte ninguna, siguiendo siempre el mismo patrón de pasos (unos de tono y otros de semitono).',
   'Ese patrón, y no las notas concretas, es lo que le da su carácter: cambia el patrón y cambia el "color" de la escala.'],
  [
      om('¿Qué define el carácter de una escala?', 'el patrón de tonos y semitonos',
         ['el instrumento con que se toca', 'el volumen', 'la duración de las notas'],
         'El mismo grupo de notas con otro patrón es otra escala distinta.'),
      om('¿Cuántas notas distintas tiene una escala diatónica (mayor o menor)?', '7',
         ['5', '6', '8'], 'Siete; la octava repite la tónica.'),
      vf('La octava repite la nota tónica.', True, 'Por eso la escala "cierra" al llegar a ella.'),
      om('La nota en la que la escala empieza y descansa es la...', 'tónica',
         ['dominante', 'sensible', 'mediante'], 'La tónica es el centro de gravedad.'),
      cp('Una escala se recorre por grados ___ (notas seguidas, sin saltos).',
         'grados ___', ['conjuntos'], 'Grados conjuntos = de una nota a la siguiente.'),
      vf('Dos escalas con las mismas notas pero distinto patrón suenan igual.', False,
         'El patrón de tonos/semitonos cambia por completo el sonido.'),
  ])

L(1, 2, 'Tono y semitono',
  'Distinguir las dos distancias básicas y saber dónde están los semitonos naturales.',
  ['El semitono es el paso más pequeño que existe en nuestra música: de una tecla del piano a la de al lado. Dos semitonos seguidos son un tono.',
   'En el teclado, entre MI-FA y entre SI-DO solo hay un semitono: no hay tecla negra en medio.'],
  [
      om('Entre MI y FA hay...', 'un semitono', ['un tono', 'un tono y medio', 'dos tonos'],
         'MI-FA y SI-DO son los semitonos naturales.'),
      om('Entre DO y RE hay...', 'un tono', ['un semitono', 'un tono y medio', 'dos tonos'],
         'Hay una tecla negra (DO#) en medio.'),
      om('Un tono equivale a...', 'dos semitonos', ['medio semitono', 'tres semitonos', 'cuatro semitonos'],
         'Por definición.'),
      vf('Entre SI y DO hay un tono.', False, 'Es un semitono (no hay tecla negra entre ellos).'),
      cp('La escala mayor tiene semitonos entre los grados 3-4 y ___-8.', '3-4 y ___-8',
         ['7'], 'Entre el 7º (sensible) y el 8º (tónica).'),
      om('¿Cuántos semitonos hay en una octava?', '12', ['7', '8', '10'],
         'La octava se divide en 12 semitonos iguales.'),
  ])

L(1, 3, 'La fórmula de la escala mayor',
  'Memorizar T-T-ST-T-T-T-ST y aplicarla.',
  ['La escala mayor sigue siempre el mismo patrón: T - T - ST - T - T - T - ST.',
   'Aplicándolo desde cualquier nota obtienes su escala mayor, con las alteraciones que hagan falta.'],
  [
      cp('Completa la fórmula de la escala mayor.', 'T - T - ___ - T - T - T - ___',
         ['ST', 'ST'], 'Los semitonos caen entre 3-4 y 7-8.'),
      om('¿Entre qué grados caen los semitonos de la escala mayor?', 'entre 3-4 y 7-8',
         ['entre 1-2 y 5-6', 'entre 2-3 y 6-7', 'entre 4-5 y 7-8'], ''),
      completar_mayor('C'),
      completar_mayor('G'),
      completar_mayor('F'),
      vf('La fórmula de la escala mayor cambia según la tónica.', False,
         'El patrón es siempre el mismo; lo que cambian son las alteraciones necesarias.'),
  ])

L(1, 4, 'Los grados y sus nombres',
  'Nombrar cada grado por su función y localizarlo en una tonalidad.',
  ['Cada grado tiene nombre según su función: I tónica, IV subdominante, V dominante, VII sensible.',
   'Pensar en grados (números) en vez de notas te deja tocar lo mismo en cualquier tonalidad.'],
  [
      om('El V grado se llama...', 'dominante', ['subdominante', 'mediante', 'sensible'],
         'El V crea tensión que pide resolver en la tónica.'),
      om('El IV grado se llama...', 'subdominante', ['dominante', 'supertónica', 'sensible'],
         'El IV da semiestabilidad.'),
      om('El VII grado, a un semitono de la tónica, se llama...', 'sensible',
         ['subtónica', 'mediante', 'dominante'], 'Si está a un tono, se llama subtónica.'),
      grado_om('C', 5),
      grado_om('G', 4),
      grado_om('D', 7),
  ])

L(1, 5, 'La escala menor natural',
  'Conocer su fórmula y su relación con la mayor.',
  ['La menor natural es el "menor por defecto": T - ST - T - T - ST - T - T. Suena melancólica.',
   'Comparte todas sus notas con una escala mayor: su relativa, una 3ª menor por encima.'],
  [
      cp('Completa la fórmula de la escala menor natural.', 'T - ___ - T - T - ___ - T - T',
         ['ST', 'ST'], 'Menor natural: T-ST-T-T-ST-T-T.'),
      om('La relativa menor de DO mayor es...', 'LA menor',
         ['MI menor', 'RE menor', 'SOL menor'], 'Una 3ª menor por debajo de DO.'),
      om('La relativa menor de SOL mayor es...', 'MI menor',
         ['SI menor', 'RE menor', 'LA menor'], ''),
      om('La relativa menor de FA mayor es...', 'RE menor',
         ['SOL menor', 'DO menor', 'LA menor'], ''),
      vf('La menor natural tiene sensible (7º grado a un semitono de la tónica).', False,
         'Tiene subtónica: su 7º grado está a un tono. Por eso se inventó la menor armónica.'),
      vf('Una escala mayor y su relativa menor comparten armadura.', True, ''),
  ])

# =========================================================== NIVEL 2
L(2, 1, 'La armadura',
  'Saber qué es la armadura y el orden de sus alteraciones.',
  ['La armadura es el grupito de sostenidos o bemoles que se escribe justo después de la clave. Valen para toda la obra y son los que dicen en qué tonalidad estás.',
   'Los sostenidos entran en el orden FA-DO-SOL-RE-LA-MI-SI; los bemoles, en el orden inverso.'],
  [
      om('¿Qué indica la armadura?', 'la tonalidad', ['el tempo', 'el compás', 'la dinámica'], ''),
      om('¿En qué orden entran los sostenidos?', 'FA DO SOL RE LA MI SI',
         ['SI MI LA RE SOL DO FA', 'DO RE MI FA SOL LA SI', 'FA SOL LA SI DO RE MI'], ''),
      om('¿En qué orden entran los bemoles?', 'SI MI LA RE SOL DO FA',
         ['FA DO SOL RE LA MI SI', 'DO SI LA SOL FA MI RE', 'MI LA RE SOL DO FA SI'],
         'Es el orden inverso al de los sostenidos.'),
      vf('Una alteración de la armadura solo vale para el primer compás.', False,
         'Vale para toda la obra, en todas las octavas.'),
      om('Un solo sostenido (FA#) en la armadura corresponde a...', 'SOL mayor',
         ['RE mayor', 'DO mayor', 'FA mayor'], ''),
      om('Sin sostenidos ni bemoles, la tonalidad mayor es...', 'DO mayor',
         ['SOL mayor', 'FA mayor', 'RE mayor'], ''),
  ])

L(2, 2, 'Tonalidades con sostenidos',
  'Saber cuántos sostenidos tiene cada tonalidad sostenida.',
  ['Las tonalidades con sostenidos suben por quintas desde DO: SOL (1), RE (2), LA (3), MI (4), SI (5), FA# (6).',
   'Cada nueva tonalidad añade el siguiente sostenido del orden FA-DO-SOL-RE-LA-MI-SI.'],
  [om(f'¿Cuántos sostenidos tiene {esp(k)} mayor?', str(ACC_COUNT[k]),
      [str(x) for x in sorted({0, 1, 2, 3, 4, 5, 6} - {ACC_COUNT[k]})][:3],
      f'{esp(k)} mayor lleva {ACC_COUNT[k]} sostenidos.') for k in SHARP_KEYS])

L(2, 3, 'Tonalidades con bemoles',
  'Saber cuántos bemoles tiene cada tonalidad con bemoles.',
  ['Las tonalidades con bemoles bajan por quintas (o suben por cuartas) desde DO: FA (1), SIb (2), MIb (3), LAb (4), REb (5), SOLb (6).',
   'Cada una añade el siguiente bemol del orden SI-MI-LA-RE-SOL-DO-FA.'],
  [om(f'¿Cuántos bemoles tiene {esp(k)} mayor?', str(ACC_COUNT[k]),
      [str(x) for x in sorted({0, 1, 2, 3, 4, 5, 6} - {ACC_COUNT[k]})][:3],
      f'{esp(k)} mayor lleva {ACC_COUNT[k]} bemoles.') for k in FLAT_KEYS])

L(2, 4, 'Escalas relativas',
  'Emparejar cada mayor con su relativa menor y viceversa.',
  ['Una mayor y una menor son relativas si comparten armadura y notas. La menor está en el 6º grado de la mayor.',
   'Sirve para cambiar de color (mayor ↔ menor) sin cambiar de notas.'],
  [
      om('Relativa menor de DO mayor:', 'LA menor', ['RE menor', 'MI menor', 'SOL menor'], ''),
      om('Relativa menor de RE mayor:', 'SI menor', ['SOL menor', 'FA# menor', 'MI menor'], ''),
      om('Relativa menor de SIb mayor:', 'SOL menor', ['DO menor', 'RE menor', 'LA menor'], ''),
      om('Relativa mayor de LA menor:', 'DO mayor', ['SOL mayor', 'FA mayor', 'MI mayor'], ''),
      om('Relativa mayor de MI menor:', 'SOL mayor', ['RE mayor', 'LA mayor', 'DO mayor'], ''),
      vf('DO mayor y LA menor tienen la misma armadura.', True, 'Ninguna alteración.'),
  ])

L(2, 5, 'El círculo de quintas',
  'Usar el círculo para relacionar tonalidades.',
  ['El círculo de quintas ordena las 12 tonalidades por quintas justas. En sentido horario se suma un sostenido; en el otro, un bemol.',
   'Tonalidades vecinas en el círculo se parecen, y modular entre ellas suena suave.'],
  [
      om('Al avanzar una quinta justa (sentido horario), la armadura...', 'gana un sostenido',
         ['gana un bemol', 'no cambia', 'pierde dos sostenidos'], ''),
      om('Partiendo de DO, una quinta justa arriba está...', 'SOL', ['FA', 'RE', 'LA'], ''),
      om('Partiendo de DO, una quinta justa abajo (o cuarta arriba) está...', 'FA',
         ['SOL', 'SIb', 'RE'], ''),
      om('¿Cuántas tonalidades mayores hay en total?', '12', ['7', '8', '15'], ''),
      vf('FA# mayor y SOLb mayor suenan igual (son enarmónicas).', True, ''),
      om('Vecina de RE mayor con un sostenido más:', 'LA mayor',
         ['SOL mayor', 'MI mayor', 'DO mayor'], 'RE(2#) → LA(3#).'),
  ])

# =========================================================== NIVEL 3
L(3, 1, 'Construir escalas mayores',
  'Construir de memoria cualquier escala mayor.',
  ['Para construir una escala mayor: parte de la tónica y aplica T-T-ST-T-T-T-ST, poniendo una letra por grado.',
   'Si un paso no cuadra con teclas blancas, usa la alteración necesaria (nunca repitas letra).'],
  [completar_mayor('D'), completar_mayor('A'), completar_mayor('Bb'),
   completar_mayor('Eb'), completar_mayor('E'),
   om('Además de FA#, ¿qué otra nota altera RE mayor?', 'DO#', ['SOL#', 'SIb', 'MIb'],
      'RE mayor: RE MI FA♯ SOL LA SI DO♯.')])

L(3, 2, 'Los grados en cualquier tono',
  'Localizar cualquier grado en varias tonalidades.',
  ['Localizar un grado es contar: el V es la 5ª nota de la escala, el VII la 7ª.',
   'Con práctica lo haces de memoria en las 12 tonalidades.'],
  [grado_om('A', 3), grado_om('E', 5), grado_om('Bb', 6),
   grado_om('F', 2), grado_om('Eb', 4), grado_om('B', 7)])

L(3, 3, '¿La nota pertenece a la escala?',
  'Decidir al instante si una nota está o no en una escala mayor.',
  ['Saber si una nota está en la escala es clave para improvisar sin "notas equivocadas".',
   'Truco: reconstruye mentalmente la escala y comprueba.'],
  [
      vf('¿Pertenece FA♯ a la escala de SOL mayor?', True, 'SOL mayor: SOL LA SI DO RE MI FA♯.'),
      vf('¿Pertenece DO♯ a la escala de FA mayor?', False, 'FA mayor: FA SOL LA SI♭ DO RE MI.'),
      vf('¿Pertenece SI♭ a la escala de FA mayor?', True, ''),
      vf('¿Pertenece SOL♯ a la escala de LA mayor?', True, 'LA mayor: LA SI DO♯ RE MI FA♯ SOL♯.'),
      vf('¿Pertenece FA natural a la escala de RE mayor?', False, 'RE mayor lleva FA♯, no FA.'),
      vf('¿Pertenece MI♭ a la escala de SI♭ mayor?', True, 'SI♭ mayor: SI♭ DO RE MI♭ FA SOL LA.'),
  ])

L(3, 4, 'Pentatónica mayor y menor',
  'Formar las pentatónicas y ver su relación.',
  ['La pentatónica mayor es la escala mayor sin la 4ª ni la 7ª: 5 notas que "siempre suenan bien".',
   'La pentatónica menor es su relativa: las mismas notas empezando por el 6º grado.'],
  [
      cp('La pentatónica mayor quita de la escala mayor los grados ___ y ___.',
         'grados ___ y ___', ['4', '7'], ''),
      om('¿Cuántas notas tiene una escala pentatónica?', '5', ['4', '6', '7'], ''),
      cp('Completa la pentatónica mayor de DO.',
         f'{esp("C")}, {esp("D")}, ___, {esp("G")}, ___',
         [esp('E'), esp('A')], 'DO pentatónica mayor: DO RE MI SOL LA.'),
      cp('Completa la pentatónica mayor de SOL.',
         f'{esp("G")}, {esp("A")}, ___, {esp("D")}, ___',
         [esp('B'), esp('E')], 'SOL pentatónica mayor: SOL LA SI RE MI.'),
      om('La pentatónica menor de LA usa las mismas notas que la pentatónica mayor de...',
         'DO', ['SOL', 'FA', 'RE'], 'LA y DO son relativas.'),
      vf('La pentatónica menor es muy usada para solos de rock y blues.', True, ''),
  ])

L(3, 5, 'Blues y cromática',
  'Conocer la escala de blues y la cromática y para qué sirven.',
  ['La escala de blues es la pentatónica menor más la "blue note" (5ª bemol) de paso.',
   'La cromática usa las 12 notas: sirve para adornos y notas de paso, no define tonalidad.'],
  [
      om('¿Qué nota añade la escala de blues a la pentatónica menor?', 'la 5ª bemol (blue note)',
         ['la 2ª mayor', 'la 6ª mayor', 'la 7ª mayor'], ''),
      om('¿Cuántas notas tiene la escala cromática?', '12', ['7', '8', '10'], ''),
      vf('La escala cromática define por sí sola una tonalidad.', False,
         'No tiene centro; se usa para notas de paso y adornos.'),
      cp('La escala de blues = pentatónica ___ + blue note.', 'pentatónica ___',
         ['menor'], ''),
      om('El roce característico del blues se da entre la b5 y la...', '5ª justa',
         ['3ª mayor', 'tónica', '7ª mayor'], ''),
      vf('En la cromática todos los pasos son de un semitono.', True, ''),
  ])

# =========================================================== NIVEL 4
L(4, 1, 'La escala menor armónica',
  'Entender qué cambia respecto de la natural y para qué sirve.',
  ['La menor armónica sube el 7º grado de la natural para crear sensible: así aparece el V7 y una cadencia fuerte hacia el i.',
   'Entre el b6 y el 7 se forma un salto de 2ª aumentada, con sabor "oriental".'],
  [
      cp('La menor armónica sube el ___ grado respecto de la natural.', 'el ___ grado',
         ['7', 'séptimo', 'septimo'], ''),
      om('¿Qué acorde de dominante genera la menor armónica?', 'V7 (mayor con 7ª menor)',
         ['Vm7', 'Vmaj7', 'V sus4'], 'Al subir la sensible, el V pasa a ser 7 y empuja a la tónica.'),
      om('El salto de 2ª aumentada de la menor armónica está entre los grados...', '6 y 7',
         ['1 y 2', '3 y 4', '5 y 6'], ''),
      vf('La menor armónica tiene sensible.', True, 'Justo eso la diferencia de la natural.'),
      cp('Completa DO menor armónica: DO RE MI♭ FA SOL LA♭ ___', 'LA♭ ___', ['SI'],
         'El 7º grado sube: SI natural (sensible).'),
      vf('La menor armónica se escucha mucho en flamenco y en metal neoclásico.', True, ''),
  ])

L(4, 2, 'La escala menor melódica',
  'Conocer su forma y su uso en el jazz.',
  ['La menor melódica sube el 6º y el 7º al ascender (en la clásica; en el jazz se usa igual subiendo y bajando).',
   'Es como una escala mayor con la 3ª bemol, y de ella salen muchos modos de jazz.'],
  [
      cp('Al ascender, la menor melódica sube los grados ___ y ___.', 'grados ___ y ___',
         ['6', '7'], ''),
      om('La menor melódica se parece a una escala mayor con...', 'la 3ª bemol',
         ['la 5ª bemol', 'la 7ª bemol', 'la 2ª bemol'], ''),
      vf('En la práctica clásica, al descender la melódica vuelve a la menor natural.', True, ''),
      cp('Completa DO menor melódica: DO RE MI♭ FA SOL LA ___', 'LA ___', ['SI'], ''),
      om('De la menor melódica sale el "lidio b7", muy usado sobre acordes...', 'de dominante (7)',
         ['menores 7', 'maj7', 'semidisminuidos'], ''),
      vf('La menor melódica ascendente tiene sensible.', True, ''),
  ])

L(4, 3, 'Los modos griegos',
  'Saber qué son y de qué grado sale cada uno.',
  ['Los modos griegos son las 7 escalas que salen de tocar la escala mayor empezando por cada uno de sus grados.',
   'Cada modo tiene una "nota característica" que lo identifica.'],
  [
      om('¿Cuántos modos griegos hay?', '7', ['5', '6', '12'], 'Uno por cada grado de la escala.'),
      om('El modo del 1er grado (= escala mayor) es...', 'jónico',
         ['dórico', 'eólico', 'lidio'], ''),
      om('El modo del 6º grado (= menor natural) es...', 'eólico',
         ['frigio', 'dórico', 'locrio'], ''),
      om('El modo que sale del 5º grado es...', 'mixolidio',
         ['lidio', 'dórico', 'frigio'], 'Es la escala del acorde de dominante.'),
      vf('Todos los modos de DO (jónico a locrio) usan solo teclas blancas.', True, ''),
      cp('El modo del 2º grado se llama ___.', '___', ['dórico', 'dorico'], ''),
  ])

L(4, 4, 'Modo dórico y modo mixolidio',
  'Reconocer los dos modos "de trabajo" más habituales.',
  ['El dórico es una escala menor con la 6ª mayor: menos triste, muy usado en jazz, funk y rock modal.',
   'El mixolidio es una escala mayor con la 7ª menor: la escala natural del acorde de dominante y del blues.'],
  [
      om('El dórico es una escala menor con...', 'la 6ª mayor',
         ['la 2ª menor', 'la 7ª mayor', 'la 5ª disminuida'], ''),
      om('El mixolidio es una escala mayor con...', 'la 7ª menor',
         ['la 4ª aumentada', 'la 6ª menor', 'la 2ª menor'], ''),
      om('RE dórico usa las notas de...', 'DO mayor', ['RE mayor', 'SOL mayor', 'FA mayor'],
         'RE es el 2º grado de DO mayor.'),
      om('SOL mixolidio usa las notas de...', 'DO mayor', ['SOL mayor', 'RE mayor', 'FA mayor'],
         'SOL es el 5º grado de DO mayor.'),
      vf('El mixolidio encaja bien sobre un acorde G7.', True, ''),
      cp('Dórico = escala menor natural con la ___ mayor.', 'la ___ mayor', ['6', 'sexta'], ''),
  ])

L(4, 5, 'Frigio, lidio y locrio',
  'Identificar estos tres modos por su nota característica.',
  ['Frigio: menor con la 2ª bemol (sabor español/flamenco). Lidio: mayor con la 4ª aumentada (sonido flotante, "de película").',
   'Locrio: el más inestable, con la 2ª y la 5ª bemoles; es la escala del acorde semidisminuido.'],
  [
      om('Nota característica del frigio:', 'la 2ª menor (b2)',
         ['la 4ª aumentada', 'la 7ª menor', 'la 6ª mayor'], ''),
      om('Nota característica del lidio:', 'la 4ª aumentada (#4)',
         ['la 2ª menor', 'la 7ª menor', 'la 5ª disminuida'], ''),
      om('Nota característica del locrio:', 'la 5ª disminuida (b5)',
         ['la 6ª mayor', 'la 3ª mayor', 'la 7ª mayor'], ''),
      om('MI frigio usa las notas de...', 'DO mayor', ['MI mayor', 'LA mayor', 'SOL mayor'],
         'MI es el 3er grado de DO mayor.'),
      vf('El lidio suena más brillante que la escala mayor normal.', True,
         'La 4ª aumentada "estira" hacia arriba.'),
      cp('El acorde del 7º grado del campo mayor (m7b5) usa el modo ___.', '___',
         ['locrio'], ''),
  ])

# =========================================================== NIVEL 5
L(5, 1, 'Un modo para cada grado (campo mayor)',
  'Asociar cada grado del campo armónico mayor con su modo de improvisación.',
  ['En el campo armónico mayor, cada grado tiene su modo: I jónico, II dórico, III frigio, IV lidio, V mixolidio, VI eólico, VII locrio.',
   'Todos usan las mismas 7 notas de la tonalidad; lo que cambia es el centro.'],
  [
      om('Modo del II grado:', 'dórico', ['frigio', 'lidio', 'eólico'], ''),
      om('Modo del IV grado:', 'lidio', ['mixolidio', 'jónico', 'dórico'], ''),
      om('Modo del V grado:', 'mixolidio', ['lidio', 'eólico', 'frigio'], ''),
      om('Modo del VI grado:', 'eólico', ['dórico', 'locrio', 'frigio'], ''),
      vf('Todos los modos de una tonalidad comparten las mismas 7 notas.', True, ''),
      cp('Modo del VII grado: ___.', '___', ['locrio'], ''),
  ])

L(5, 2, 'Escalas sobre acordes de dominante',
  'Elegir la escala adecuada para un acorde 7.',
  ['Sobre un acorde 7 (dominante) la base es el mixolidio. Para más tensión, la escala alterada o la disminuida (ST-T).',
   'Si el dominante resuelve a un acorde menor, el mixolidio b6 encaja mejor.'],
  [
      om('Escala base sobre G7:', 'SOL mixolidio',
         ['SOL jónico', 'SOL dórico', 'SOL lidio'], ''),
      om('Para un dominante muy alterado (b9, #9, #11, b13) usas la escala...', 'alterada',
         ['pentatónica mayor', 'jónica', 'menor natural'], ''),
      vf('El mixolidio contiene un tritono entre su 3ª y su 7ª.', True,
         'Ese tritono es la tensión del acorde de dominante.'),
      om('Si G7 resuelve a Cm, encaja mejor...', 'SOL mixolidio b6',
         ['SOL jónico', 'SOL lidio', 'SOL dórico'], ''),
      cp('Escala base del acorde de dominante: ___.', '___', ['mixolidio'], ''),
      vf('La escala disminuida (ST-T) también sirve sobre acordes de dominante.', True, ''),
  ])

L(5, 3, 'Improvisar con la pentatónica',
  'Primeros pasos para solear con seguridad.',
  ['La pentatónica menor es la escala más segura para empezar a solear en blues, rock y pop.',
   'Empieza por frases cortas, deja silencios y apóyate en las notas del acorde.'],
  [
      om('Sobre un blues en LA, la pentatónica más usada para el solo es...', 'LA pentatónica menor',
         ['LA cromática', 'LA locria', 'LA de tonos enteros'], ''),
      vf('La pentatónica menor evita las notas que más chocan; por eso "todo suena bien".', True, ''),
      om('Un buen hábito al improvisar es...', 'dejar silencios entre frases',
         ['tocar sin parar', 'usar solo notas largas', 'evitar la tónica'], ''),
      om('La pentatónica menor de MI equivale a la pentatónica mayor de...', 'SOL',
         ['DO', 'RE', 'LA'], 'MI y SOL son relativas.'),
      vf('Cuantas más notas metas por compás, mejor suena el solo.', False,
         'Sobrecargar quita forma y descanso; el oyente necesita pausas.'),
      cp('Antes de improvisar libre conviene hacer ___ de una melodía (modificarla poco a poco).',
         '___', ['variaciones'], ''),
  ])

L(5, 4, 'Escalas simétricas',
  'Conocer la disminuida y la de tonos enteros.',
  ['Las escalas simétricas repiten su patrón dentro de la octava: por eso hay muy pocas distintas.',
   'La disminuida alterna tono-semitono (8 notas); la de tonos enteros son solo tonos (6 notas).'],
  [
      om('La escala disminuida alterna...', 'tono y semitono',
         ['solo tonos', 'solo semitonos', 'tono y tercera'], ''),
      om('¿Cuántas notas tiene la escala de tonos enteros?', '6', ['5', '7', '8'], ''),
      om('¿Cuántas notas tiene la escala disminuida?', '8', ['6', '7', '12'], ''),
      vf('La escala de tonos enteros no tiene semitonos ni tritono resuelto; por eso "flota".', True, ''),
      om('La escala de tonos enteros es la escala del acorde...', 'aumentado',
         ['menor', 'disminuido', 'mayor con 7ª mayor'], ''),
      cp('La escala disminuida (con 7ª disminuida) sirve sobre el acorde ___.', '___',
         ['disminuido'], ''),
  ])

L(5, 5, 'De la escala a la frase',
  'Convertir el conocimiento de escalas en música.',
  ['Saber la escala no basta: hay que convertirla en frases. Empieza haciendo variaciones de una melodía que te guste.',
   'Usa los arpegios del acorde como "puntos de apoyo" y la escala para conectar.'],
  [
      om('El mejor entrenamiento para las escalas es...', 'aplicarlas en frases y variaciones',
         ['repetirlas de memoria', 'escribir su nombre', 'tocarlas solo muy rápido'], ''),
      vf('Los arpegios del acorde sirven como notas de apoyo dentro de la improvisación.', True, ''),
      om('Al empezar, es mejor practicar con...', 'solos y variaciones escritas',
         ['improvisación totalmente libre desde el día 1', 'solo teoría', 'solo escuchar'], ''),
      vf('Practicar escalas y arpegios en las 12 tonalidades da seguridad para improvisar en cualquiera.',
         True, ''),
      om('Un recurso para dar forma a un solo es...', 'alternar compases de frase con compases de pausa',
         ['no parar nunca', 'tocar siempre fortísimo', 'usar una sola nota'], ''),
      cp('Un buen previo a la improvisación libre es hacer ___ de una melodía.', '___',
         ['variaciones'], ''),
  ])

# =========================================================== guardar
SALIDA = os.path.join(os.path.dirname(__file__), '..', 'assets', 'content', 'lecciones.json')
data = {
    '_schema': 'Lecciones de escalas por nivel (1..5), generadas por tools/gen_lecciones.py. '
               'Cada lección: id, nivel, titulo, objetivo, intro (lista de párrafos), '
               'ejercicios (misma forma que ejercicios_escalas.json).',
    'lecciones': lecciones,
}
with open(SALIDA, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=1)

por_nivel = {}
for l in lecciones:
    por_nivel[l['nivel']] = por_nivel.get(l['nivel'], 0) + 1
print(f'Generadas {len(lecciones)} lecciones ({sum(len(x["ejercicios"]) for x in lecciones)} ejercicios) '
      f'-> {os.path.normpath(SALIDA)}')
print('Por nivel:', dict(sorted(por_nivel.items())))
