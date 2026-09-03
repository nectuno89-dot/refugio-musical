"""
Genera el banco de ejercicios de SOLFEO (lectura de notas, ritmo, compás,
alteraciones), en 5 niveles, con una breve teoría por nivel.
Salida: assets/content/ejercicios_solfeo.json

Uso:  python tools/gen_solfeo.py
"""

import json
import os
import random

random.seed(3)

# ---------------------------------------------------------------------------
#  Posiciones del pentagrama en clave de sol: nota MIDI -> nombre.
#  (líneas y espacios sin líneas adicionales, más un par de notas con
#  líneas adicionales, igual que dibuja Pentagrama/_escalon en la app)
# ---------------------------------------------------------------------------
NOMBRES = {
    60: 'DO', 62: 'RE', 64: 'MI', 65: 'FA', 67: 'SOL',
    69: 'LA', 71: 'SI', 72: 'DO', 74: 'RE', 76: 'MI', 77: 'FA', 81: 'LA',
}
# Posiciones "de línea" (para explicar) vs "de espacio"
LINEAS = [64, 67, 71, 74, 77]      # MI SOL SI RE FA (de abajo arriba)
ESPACIOS = [65, 69, 72, 76]        # FA LA DO MI (de abajo arriba)
LEDGER = [60, 81]                  # DO central (abajo) y LA (arriba)

TODAS_POSICIONES = LINEAS + ESPACIOS + LEDGER

banco = []
_contador = [0]


def add(nivel, tipo, enunciado, explicacion, **extra):
    _contador[0] += 1
    item = {
        'id': f'sol-gen-{_contador[0]:04d}',
        'nivel': nivel,
        'tipo': tipo,
        'enunciado': enunciado,
        'explicacion': explicacion,
    }
    item.update(extra)
    banco.append(item)


def opciones_nota(correcta):
    otras = [n for n in set(NOMBRES.values()) if n != correcta]
    return [correcta] + random.sample(otras, 3)


def leer_nota(nivel, midi, pista=''):
    correcta = NOMBRES[midi]
    ops = opciones_nota(correcta)
    random.shuffle(ops)
    en_linea = midi in LINEAS or midi in LEDGER
    ayuda = ('Fíjate: esta nota está sobre una LÍNEA del pentagrama '
             '(o sobre una línea adicional).' if en_linea else
             'Fíjate: esta nota está en un ESPACIO del pentagrama.')
    ayuda += ' Líneas (abajo→arriba): MI SOL SI RE FA. Espacios: FA LA DO MI.'
    add(nivel, 'leer_nota',
        '¿Qué nota está escrita en el pentagrama?',
        f'Es {correcta}.' + (f' {pista}' if pista else ''),
        midi=midi, opciones=ops, correcta=ops.index(correcta), pista=ayuda)


def om(nivel, enun, correcta, distr, expl):
    ops = [correcta] + list(distr)
    random.shuffle(ops)
    add(nivel, 'opcion_multiple', enun, expl, opciones=ops, correcta=ops.index(correcta))


def vf(nivel, enun, val, expl):
    add(nivel, 'verdadero_falso', enun, expl, correcta=bool(val))


def cp(nivel, enun, texto, resp, expl):
    add(nivel, 'completar', enun, expl, texto=texto, respuestas=list(resp))


# =========================================================== NIVEL 1 — Sonido y pentagrama
om(1, '¿Cuál de estas NO es una propiedad del sonido?', 'el precio',
   ['la altura', 'la duración', 'el timbre'], 'Altura, duración, intensidad y timbre: esas son las cuatro.')
om(1, 'Si un sonido es agudo o grave, hablamos de su...', 'altura',
   ['duración', 'intensidad', 'timbre'], 'La altura depende de la frecuencia de la vibración.')
om(1, 'El "color" que distingue una guitarra de un piano tocando la misma nota es el...', 'timbre',
   ['tono', 'compás', 'silencio'], 'El timbre es la propiedad que identifica la fuente del sonido.')
vf(1, 'El sonido se transmite en el vacío.', False, 'Necesita un medio material: aire, agua o un sólido.')
om(1, 'Los tres elementos fundamentales de la música son melodía, armonía y...', 'ritmo',
   ['timbre', 'compás', 'clave'], 'Ritmo = organización de los sonidos en el tiempo.')
om(1, 'Cuando cantamos o tarareamos una canción, notas una detrás de otra, eso es...', 'melodía',
   ['armonía', 'timbre', 'silencio'], 'Sonidos sucesivos = melodía. Simultáneos = armonía.')
om(1, '¿Cuántas líneas tiene un pentagrama?', 'Cinco', ['Cuatro', 'Seis', 'Siete'], 'Penta = cinco.')
om(1, '¿Cuántos espacios tiene un pentagrama (entre sus líneas)?', 'Cuatro', ['Tres', 'Cinco', 'Seis'],
   'Cinco líneas dejan cuatro espacios entre ellas.')
om(1, 'El pentagrama se numera y se lee...', 'de abajo hacia arriba', ['de arriba hacia abajo',
   'de izquierda a derecha únicamente', 'no se numera'], 'La línea 1 es siempre la de más abajo.')
om(1, 'Si una nota está más arriba en el pentagrama, suena...', 'más aguda', ['más grave', 'más larga', 'más fuerte'],
   'La altura sube al subir en el pentagrama.')
om(1, '¿Para qué sirven las líneas adicionales?', 'para notas que no caben en el pentagrama',
   ['para marcar el compás', 'para indicar el tempo', 'para separar instrumentos'],
   'Son pequeñas extensiones del pentagrama, arriba o abajo.')
om(1, 'La clave, al principio del pentagrama, indica...', 'el nombre de las notas',
   ['el tempo', 'la dinámica', 'el compás'], 'Fija qué nota corresponde a cada línea y espacio.')
om(1, 'La clave de sol se usa sobre todo para...', 'registros agudos', ['registros graves',
   'solo percusión', 'solo el bajo'], 'La clave de fa es la que cubre los registros graves.')
om(1, '¿Cuántas notas naturales hay?', 'Siete', ['Cinco', 'Seis', 'Doce'],
   'DO RE MI FA SOL LA SI: siete nombres, que se repiten en cada octava.')
cp(1, 'Completa el nombre de las notas en orden: DO, RE, MI, ___, SOL, LA, ___',
   'DO, RE, MI, ___, SOL, LA, ___', ['FA', 'SI'], 'La secuencia completa es DO RE MI FA SOL LA SI.')
leer_nota(1, 67, 'Está en la 2ª línea del pentagrama: la más usada como referencia.')
leer_nota(1, 64, 'Está en la línea de más abajo del pentagrama.')
leer_nota(1, 60, 'Es el DO central, en una línea adicional debajo del pentagrama.')
vf(1, 'La clave de sol dibuja una espiral que rodea la 2ª línea, donde va la nota SOL.', True,
   'De ahí su nombre: fija esa línea como SOL.')
vf(1, 'Todas las claves sitúan las notas exactamente en el mismo lugar.', False,
   'Cada clave (sol, fa, do) desplaza las notas a un registro distinto.')

# =========================================================== NIVEL 2 — Lectura de notas
for midi in LINEAS:
    leer_nota(2, midi)
for midi in ESPACIOS:
    leer_nota(2, midi)
leer_nota(2, 60, 'DO central: 1ª línea adicional por debajo del pentagrama.')
leer_nota(2, 81, 'LA agudo: 1ª línea adicional por encima del pentagrama.')
om(2, 'Las notas en las LÍNEAS del pentagrama (clave de sol), de abajo arriba, son...',
   'MI SOL SI RE FA', ['DO MI SOL SI RE', 'FA LA DO MI', 'SOL SI RE FA LA'],
   'Un truco de memoria: "Mi Sol Si Re Fa" (frases mnemotécnicas ayudan a recordarlo).')
om(2, 'Las notas en los ESPACIOS del pentagrama (clave de sol), de abajo arriba, son...',
   'FA LA DO MI', ['MI SOL SI RE', 'DO MI SOL SI', 'SOL SI RE FA'],
   'Se puede recordar como la palabra "FA-LA-DO-MI".')
om(2, 'El DO central (DO4) se escribe...', 'en una línea adicional debajo del pentagrama',
   ['en la 3ª línea', 'en el espacio central', 'en la 1ª línea'],
   'Es un DO tan grave (para la clave de sol) que necesita salir del pentagrama hacia abajo.')
vf(2, 'Cuanto más lejos del pentagrama esté una nota (más líneas adicionales), más extrema es su altura.', True,
   'Más líneas adicionales = más aguda o más grave.')

# =========================================================== NIVEL 3 — Figuras y valores
om(3, '¿Cuál es la figura de mayor duración?', 'la redonda', ['la blanca', 'la negra', 'la corchea'],
   'Redonda = 2 blancas = 4 negras = 8 corcheas = 16 semicorcheas.')
om(3, 'Una blanca equivale a...', '2 negras', ['3 negras', '4 negras', '1 negra'], '')
om(3, 'Una negra equivale a...', '2 corcheas', ['3 corcheas', '4 corcheas', '1 corchea'], '')
om(3, 'Una corchea equivale a...', '2 semicorcheas', ['3 semicorcheas', '4 semicorcheas', '1 semicorchea'], '')
cp(3, 'Una redonda equivale a ___ negras.', 'Una redonda equivale a ___ negras.', ['4'], '')
cp(3, 'Una redonda equivale a ___ corcheas.', 'Una redonda equivale a ___ corcheas.', ['8'], '')
om(3, 'El silencio equivalente a una negra se llama...', 'silencio de negra',
   ['silencio de blanca', 'silencio de corchea', 'no existe'], 'Cada figura tiene su silencio con la misma duración.')
vf(3, 'Cada figura tiene un silencio equivalente con su misma duración.', True, '')
om(3, 'El puntillo, a la derecha de una nota, añade...', 'la mitad del valor de la figura',
   ['el doble del valor', 'un tercio del valor', 'un cuarto del valor'], '')
om(3, 'En 4/4, ¿cuánto dura una negra con puntillo?', '1,5 tiempos',
   ['1 tiempo', '2 tiempos', '0,5 tiempos'],
   'Negra (1 tiempo) + la mitad de su valor (0,5) = 1,5 tiempos.')
om(3, 'La ligadura que une dos notas de la MISMA altura...', 'suma sus duraciones en un solo sonido',
   ['las toca staccato', 'las repite', 'no afecta al ritmo'], 'Es la ligadura de valor (o de prolongación).')
vf(3, 'La ligadura de expresión une notas de distinta altura para tocarlas unidas (legato).', True, '')
om(3, 'Un tresillo mete 3 notas en el espacio de...', '2 notas iguales', ['4 notas iguales',
   '1 nota', '5 notas'], 'Por eso es un valor "irregular": rompe la división normal.')
cp(3, 'Completa el orden de las figuras, de mayor a menor duración.',
   '___, blanca, negra, ___', ['redonda', 'corchea'],
   'De mayor a menor: redonda, blanca, negra, corchea, semicorchea.')
om(3, '¿Cuántos tiempos dura, en 4/4, una negra + una corchea + una corchea?', '2 tiempos',
   ['1 tiempo', '3 tiempos', '4 tiempos'], '1 (negra) + 0,5 + 0,5 (dos corcheas) = 2.')
om(3, '¿Cuántos tiempos dura, en 4/4, una blanca + una negra?', '3 tiempos',
   ['2 tiempos', '4 tiempos', '1 tiempo'], '2 (blanca) + 1 (negra) = 3.')
vf(3, 'La semicorchea dura la mitad que la corchea.', True, '')
vf(3, 'La blanca dura menos que la negra.', False, 'La blanca dura el doble que la negra.')
om(3, 'Un doble puntillo añade...', 'la mitad del primer puntillo, además del puntillo simple',
   ['el doble del valor original', 'nada extra', 'solo se usa en compases compuestos'],
   'Cada puntillo añade la mitad del valor anterior (el de la figura, luego el del primer puntillo).')

# =========================================================== NIVEL 4 — El compás
om(4, 'En una fórmula de compás como 3/4, el número de ABAJO indica...',
   'qué figura vale un tiempo', ['cuántos compases hay', 'el tempo exacto', 'la tonalidad'],
   '4 = negra, 8 = corchea, 2 = blanca vale un tiempo.')
om(4, 'En una fórmula de compás como 3/4, el número de ARRIBA indica...',
   'cuántos tiempos hay por compás', ['qué figura vale un tiempo', 'el tempo', 'la dinámica'], '')
om(4, 'Un compás simple es aquel cuyo pulso se divide de forma natural en...', 'dos partes',
   ['tres partes', 'cuatro partes', 'cinco partes'], '2/4, 3/4 y 4/4 son compases simples.')
om(4, 'Un compás compuesto es aquel cuyo pulso se divide de forma natural en...', 'tres partes',
   ['dos partes', 'cuatro partes', 'una parte'], '6/8, 9/8 y 12/8 son compuestos.')
om(4, 'En 6/8, ¿cuántos pulsos (tiempos) hay por compás?', '2', ['3', '6', '4'],
   'Cada pulso es una negra con puntillo (3 corcheas); 6 corcheas = 2 pulsos.')
om(4, 'En 3/4, ¿cuál es el tiempo más acentuado (fuerte)?', 'el primero', ['el segundo',
   'el tercero', 'ninguno'], 'El primer tiempo de cada compás es siempre el más fuerte.')
vf(4, 'En 4/4, el 3er tiempo se considera semifuerte.', True, '')
om(4, 'La síncopa ocurre cuando una nota...', 'empieza en tiempo débil y se prolonga sobre el fuerte',
   ['empieza y termina en el tiempo fuerte', 'es siempre muy larga', 'no tiene ritmo definido'], '')
om(4, 'El contratiempo es un ataque en la parte débil seguido de...', 'silencio en la parte fuerte',
   ['otro ataque más fuerte', 'una ligadura', 'un calderón'],
   'A diferencia de la síncopa, no se prolonga sobre el tiempo fuerte: éste queda en silencio.')
vf(4, 'La síncopa y el contratiempo son exactamente lo mismo.', False,
   'La síncopa prolonga el sonido sobre el tiempo fuerte; el contratiempo deja ese tiempo en silencio.')
om(4, 'Un tresillo de corcheas mete 3 corcheas en el tiempo de...', '2 corcheas (una negra)',
   ['4 corcheas', '1 corchea', '6 corcheas'], '')
om(4, 'Un compás de amalgama (como 5/8 o 7/8) combina...', 'grupos simples y compuestos desiguales',
   ['solo grupos simples', 'solo grupos compuestos', 'ningún grupo, es libre'],
   '5/8 puede agruparse 2+3 o 3+2; 7/8, por ejemplo 2+2+3.')
cp(4, 'En 6/8, cada pulso equivale a una negra con ___.', 'una negra con ___', ['puntillo'], '')
om(4, '¿Cuál de estos es un compás compuesto?', '9/8', ['3/4', '2/4', '4/4'], '')
om(4, '¿Cuál de estos es un compás simple?', '2/4', ['6/8', '9/8', '12/8'], '')
vf(4, 'En un compás simple, el pulso se subdivide naturalmente en tres.', False,
   'Eso es lo propio del compás compuesto; el simple se subdivide en dos.')
om(4, 'El primer tiempo de cualquier compás se llama...', 'tiempo fuerte (o tético)',
   ['tiempo débil', 'anacrusa', 'coda'], '')
om(4, 'Una anacrusa es...', 'una nota o notas antes del primer tiempo fuerte',
   ['el final de la obra', 'un silencio largo', 'un cambio de tonalidad'],
   'Muchas melodías empiezan "en el aire", antes del primer compás completo.')

# =========================================================== NIVEL 5 — Alteraciones y matices
om(5, 'El sostenido (♯) hace que una nota suba...', 'un semitono', ['un tono', 'una tercera', 'una octava'], '')
om(5, 'El bemol (♭) hace que una nota baje...', 'un semitono', ['un tono', 'una quinta', 'una octava'], '')
om(5, 'El becuadro (♮) sirve para...', 'anular una alteración anterior', ['subir dos semitonos',
   'bajar dos semitonos', 'repetir la nota'], '')
vf(5, 'Dos notas enarmónicas suenan igual pero se escriben distinto.', True, 'Ej.: DO♯ y RE♭.')
om(5, 'Las alteraciones de la ARMADURA (junto a la clave) valen para...', 'toda la obra',
   ['solo el primer compás', 'solo esa octava', 'nada, son decorativas'], '')
om(5, 'Una alteración ACCIDENTAL (dentro de la obra) vale para...', 'ese compás',
   ['toda la obra', 'toda la página', 'nunca vale, hay que repetirla siempre'], '')
om(5, 'Una alteración "de precaución" (o de cortesía) se usa para...', 'recordar la altura y evitar confusión',
   ['cambiar la tonalidad', 'marcar el tempo', 'indicar dinámica'], '')
om(5, '¿En qué orden entran los sostenidos en la armadura?', 'FA DO SOL RE LA MI SI',
   ['SI MI LA RE SOL DO FA', 'DO RE MI FA SOL LA SI', 'FA SOL LA SI DO RE MI'], '')
om(5, '¿En qué orden entran los bemoles en la armadura?', 'SI MI LA RE SOL DO FA',
   ['FA DO SOL RE LA MI SI', 'DO SI LA SOL FA MI RE', 'MI LA RE SOL DO FA SI'],
   'Es el orden inverso al de los sostenidos.')
om(5, 'Las barras de repetición (::) indican...', 'repetir el fragmento entre ellas',
   ['un cambio de compás', 'una alteración', 'el final de la obra'], '')
om(5, '"Da Capo" (D.C.) significa...', 'volver al principio de la obra',
   ['volver al signo', 'saltar a la coda', 'repetir solo un compás'], '')
om(5, '"Dal Segno" (D.S.) significa...', 'volver al signo (𝄋)', ['volver al principio',
   'saltar a la coda directamente', 'repetir dos veces'], '')
om(5, 'De más suave a más fuerte, el orden correcto es...', 'pp, p, mf, f, ff',
   ['ff, f, mf, p, pp', 'p, pp, f, ff, mf', 'mf, p, f, pp, ff'], '')
om(5, 'Un crescendo indica...', 'aumentar poco a poco la intensidad', ['bajar poco a poco',
   'acelerar el tempo', 'cambiar de tonalidad'], '')
om(5, 'El staccato indica que la nota se toca...', 'breve y separada', ['unida a la siguiente',
   'muy fuerte', 'muy larga'], '')
om(5, 'El legato indica que las notas se tocan...', 'unidas, sin cortes', ['separadas',
   'con acento', 'en silencio'], '')
om(5, 'Un calderón (fermata) sobre una nota indica...', 'prolongar su duración a voluntad',
   ['tocarla más corta', 'repetirla', 'bajarla un semitono'], '')
om(5, 'De más lento a más rápido, ¿cuál es el orden correcto?', 'Largo, Andante, Allegro',
   ['Allegro, Andante, Largo', 'Andante, Largo, Allegro', 'Allegro, Largo, Andante'], '')
vf(5, 'Un ritardando indica acelerar el tempo.', False, 'Ritardando = frenar; accelerando = acelerar.')
om(5, 'El trino es un adorno que consiste en...', 'alternar rápido con la nota superior',
   ['bajar un semitono', 'un silencio breve', 'repetir la nota tres veces'], '')

for midi in [67, 71, 65]:
    leer_nota(5, midi, 'Repaso: combina lectura con lo aprendido sobre matices y alteraciones.')

# ---------------------------------------------------------------------------
TEORIA = {
    1: [
        'El sonido tiene cuatro propiedades: altura (agudo/grave), duración, intensidad (volumen) y timbre (color). La música organiza sonidos en melodía (sucesivos), armonía (simultáneos) y ritmo (en el tiempo).',
        'Se escribe sobre el pentagrama: 5 líneas y 4 espacios, contados de abajo (grave) hacia arriba (agudo). La clave, al principio, fija el nombre de cada línea y espacio; la de sol es la más usada para registros agudos.',
    ],
    2: [
        'En clave de sol, las líneas (de abajo arriba) son MI-SOL-SI-RE-FA, y los espacios, FA-LA-DO-MI. El DO central, muy usado como referencia, se escribe justo debajo del pentagrama, en una línea adicional.',
        'Cuantas más líneas adicionales necesita una nota, más se aleja del registro "cómodo" del pentagrama, hacia el grave o hacia el agudo.',
    ],
    3: [
        'Las figuras indican duración relativa: redonda = 2 blancas = 4 negras = 8 corcheas = 16 semicorcheas. Cada figura tiene su silencio equivalente. El puntillo añade la mitad del valor de la figura.',
        'La ligadura de valor une dos notas de la misma altura y suma sus duraciones; la de expresión une notas de distinta altura para tocarlas ligadas (legato). Los valores irregulares (como el tresillo) meten un número distinto de notas en un espacio dado.',
    ],
    4: [
        'La fórmula de compás tiene dos números: el de arriba dice cuántos tiempos hay por compás, y el de abajo, qué figura vale un tiempo (4=negra, 8=corchea, 2=blanca). Los compases simples dividen el pulso en dos; los compuestos, en tres.',
        'El primer tiempo de cada compás es el más fuerte. La síncopa desplaza el acento prolongando una nota sobre el tiempo fuerte; el contratiempo ataca en la parte débil y deja en silencio la fuerte.',
    ],
    5: [
        'El sostenido (♯) sube un semitono, el bemol (♭) lo baja, y el becuadro (♮) anula una alteración anterior. Las de la armadura valen para toda la obra; las accidentales, solo para ese compás; las de precaución solo recuerdan una altura.',
        'La dinámica (de pp a ff) y la articulación (staccato, legato, acento) dan carácter a la música, junto con el tempo (de Largo a Presto) y signos como el calderón, que prolonga una nota a voluntad.',
    ],
}

SALIDA = os.path.join(os.path.dirname(__file__), '..', 'assets', 'content', 'ejercicios_solfeo.json')
os.makedirs(os.path.dirname(SALIDA), exist_ok=True)
data = {
    '_schema': 'Banco de ejercicios de SOLFEO (lectura, ritmo, compás, alteraciones), '
               'generado por tools/gen_solfeo.py. Mismo formato que ejercicios_escalas.json, '
               'más el tipo "leer_nota" (midi, opciones, correcta) y un mapa "teoria" por nivel.',
    'teoria': {str(k): v for k, v in TEORIA.items()},
    'ejercicios': sorted(banco, key=lambda x: (x['nivel'], x['id'])),
}
with open(SALIDA, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=1)

por_nivel = {}
for e in banco:
    por_nivel[e['nivel']] = por_nivel.get(e['nivel'], 0) + 1
print(f'Generados {len(banco)} ejercicios de solfeo -> {os.path.normpath(SALIDA)}')
print('Por nivel:', dict(sorted(por_nivel.items())))
