"""
expand_lecciones.py — reescribe en profundidad la INTRODUCCIÓN de cada lección
de escalas (assets/content/lecciones.json), con el mismo listón que la wiki:
explicación detallada y amena, de lo más básico a lo avanzado, con diagramas
animados, ejemplos que suenan y recuadros de idea clave.

NO toca los ejercicios: solo sustituye `objetivo` (opcional) e `intro` por una
lista de bloques que renderiza VisorBloques (bloques_didacticos.dart):
  texto ('## ' = subtítulo, **negrita**), clave, lista, tabla, pasos,
  diagrama, escala, nota, audio.

Uso:  python tools/expand_lecciones.py      (ejecutar DESPUÉS de gen_lecciones.py)
Idempotente: se puede volver a correr.
"""

import json
import os

# ---------------------------------------------------------------------------
#  Constructores de bloque
# ---------------------------------------------------------------------------
def T(s):        return {'tipo': 'texto', 'texto': s}
def H(s):        return {'tipo': 'texto', 'texto': '## ' + s}
def K(tit, s):   return {'tipo': 'clave', 'titulo': tit, 'texto': s}
def LI(*items):  return {'tipo': 'lista', 'items': list(items)}
def TB(tit, *filas): return {'tipo': 'tabla', 'titulo': tit, 'filas': [list(f) for f in filas]}
def PS(tit, *pasos): return {'tipo': 'pasos', 'titulo': tit, 'pasos': list(pasos)}
def D(nombre, pie='', alto=200): return {'tipo': 'diagrama', 'nombre': nombre, 'pie': pie, 'alto': alto}
def AU(archivo, tit): return {'tipo': 'audio', 'archivo': archivo, 'titulo': tit}

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
    'locrio': [1, 2, 2, 1, 2, 2, 2],
    'blues': [3, 2, 1, 1, 3, 2],
    'disminuida': [2, 1, 2, 1, 2, 1, 2, 1],
    'tonos enteros': [2, 2, 2, 2, 2, 2],
    'cromática': [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
}
IDX = {'DO': 0, 'DO#': 1, 'RE': 2, 'MIb': 3, 'MI': 4, 'FA': 5, 'FA#': 6,
       'SOL': 7, 'LAb': 8, 'LA': 9, 'SIb': 10, 'SI': 11}


def ESC(tonica, patron, tit):
    return {'tipo': 'escala', 'tonicaIdx': IDX[tonica], 'pasos': PASOS[patron],
            'titulo': tit}


def NT(midi, tit):
    return {'tipo': 'nota', 'midi': midi, 'titulo': tit}


# ===========================================================================
#  INTROS  (id de lección -> lista de bloques)
# ===========================================================================
INTROS = {}
OBJETIVOS = {}

# ---------------------------------------------------------- NIVEL 1
INTROS['lec-1-1'] = [
    T('Pon una canción que te guste y quédate solo con la melodía: la voz que tararearías. '
      'Si vas anotando las notas distintas que usa y las ordenas de grave a aguda, casi siempre '
      'te salen **siete**, y se repiten una y otra vez en octavas más altas o más bajas. Ese '
      'puñado de notas ordenadas es una **escala**: la despensa de la que la canción saca casi todo.'),
    H('Qué es y qué no es'),
    T('Una escala es una **serie de notas ordenadas por altura**, de una tónica a su octava, '
      'que se recorre por **grados conjuntos** (de una nota a la siguiente, sin saltarse ninguna). '
      'No es una melodía —la melodía salta, repite y elige—; la escala es solo el material '
      'ordenado, como el abecedario respecto a las palabras.'),
    LI('**Tónica**: la nota en la que la escala empieza y a la que todo parece querer volver. Es el centro de gravedad.',
       '**Grado**: la posición de cada nota dentro de la escala (1º, 2º, 3º…). Pensar en grados, y no en nombres de nota, es lo que te deja tocar lo mismo en cualquier tono.',
       '**Octava**: al llegar otra vez a la tónica, una octava más arriba, la escala "cierra" y vuelve a empezar.'),
    K('La idea que lo cambia todo',
      'Lo que le da carácter a una escala **no son las notas**, sino el **patrón de distancias** '
      'entre ellas: cuáles están pegadas y cuáles separadas. Cambia el patrón y, con las mismas '
      'siete notas, tienes otra escala que suena distinta.'),
    H('Escúchalo'),
    T('Aquí tienes la escala mayor de DO, subiendo. Fíjate en cómo la última nota "pide" cerrar '
      'en la primera: esa sensación de reposo al llegar a la tónica es la esencia de la tonalidad.'),
    AU('escala_mayor', 'Escala mayor de DO (ascendente)'),
    T('Y ahora la menor natural desde LA: **exactamente las mismas siete notas** que la de DO '
      'mayor, pero empezando en otro sitio. El patrón cambia y el color pasa de luminoso a '
      'melancólico. Ese es todo el truco.'),
    AU('escala_menor_natural', 'Menor natural de LA (mismas notas, otro centro)'),
    H('Para ir un poco más lejos'),
    T('En la práctica, "escala" se usa con dos sentidos: el **conjunto de notas** de una '
      'tonalidad (su despensa) y una **digitación concreta** que practicas al instrumento '
      '(subir y bajar en un tramo). Las dos cosas importan, pero la de este curso es la primera: '
      'entender qué notas hay y por qué, para luego elegirlas con criterio al tocar o componer.'),
    T('Más adelante verás escalas de 5 notas (pentatónicas), de 6 (tonos enteros), de 8 '
      '(disminuida) e incluso de 12 (cromática). Todas siguen la misma lógica: **una tónica y '
      'un patrón de distancias**.'),
]
OBJETIVOS['lec-1-1'] = 'Entender qué es una escala, qué la distingue de una melodía y por qué el patrón manda sobre las notas.'

INTROS['lec-1-2'] = [
    T('Toda la música occidental está construida con dos ladrillos de distancia: el **tono** y '
      'el **semitono**. Si los distingues de oído y sabes dónde caen, ya puedes construir '
      'cualquier escala. Así de importante es esta lección tan cortita.'),
    H('El semitono: el paso más pequeño'),
    T('El **semitono** es la menor distancia que usa nuestra música: de una tecla del piano a la '
      'de al lado, sea blanca o negra, sin saltarte ninguna. En la guitarra, un traste. Es el '
      '"clic" mínimo entre dos alturas.'),
    T('El **tono** es, sencillamente, **dos semitonos seguidos**. De DO a RE hay un tono porque '
      'entre medias está la tecla negra DO♯. De MI a FA, en cambio, solo hay un semitono: no hay '
      'ninguna tecla en medio.'),
    D('teclado_octava',
      'En una octava de piano, los únicos semitonos entre teclas blancas son MI–FA y SI–DO.',
      alto=180),
    K('Los dos semitonos que tienes que memorizar',
      'Entre **MI y FA** y entre **SI y DO** solo hay un semitono. En todos los demás pares de '
      'notas naturales seguidas (DO-RE, RE-MI, FA-SOL, SOL-LA, LA-SI) hay un tono. Sabiendo esto '
      'ya no necesitas el piano delante.'),
    H('La octava, medida en semitonos'),
    T('Si subes de DO a DO tocando **todas** las teclas, blancas y negras, das exactamente '
      '**12 pasos de semitono**. Por eso decimos que la octava se divide en 12 semitonos '
      'iguales: es la cuadrícula sobre la que se dibujan todas las escalas.'),
    NT(64, 'MI'),
    NT(65, 'FA — a solo un semitono de MI'),
    H('Un matiz para quien ya toca'),
    T('En la afinación de hoy (temperamento igual) todos los semitonos miden lo mismo: 100 '
      '"cents". Históricamente no era así —un DO♯ y un RE♭ podían sonar distintos— y en '
      'instrumentos sin trastes o al cantar aún se ajusta un poco la entonación según el '
      'contexto. Para leer y construir escalas, sin embargo, la cuadrícula de 12 semitonos '
      'iguales es la referencia.'),
]
OBJETIVOS['lec-1-2'] = 'Distinguir tono y semitono, saber dónde están los semitonos naturales y ver la octava como 12 semitonos.'

INTROS['lec-1-3'] = [
    T('La **escala mayor** es la escala más importante de toda la música occidental: es la vara '
      'de medir con la que se explican casi todas las demás. Y cabe en una sola fórmula que vas '
      'a llevar contigo el resto de tu vida musical.'),
    H('La fórmula'),
    PS('El patrón de la escala mayor (7 saltos, 8 grados)',
       'T', 'T', 'ST', 'T', 'T', 'T', 'ST'),
    T('Se lee: **tono – tono – semitono – tono – tono – tono – semitono**. Aplica ese patrón '
      'desde cualquier nota y obtienes su escala mayor, con las alteraciones (sostenidos o '
      'bemoles) que hagan falta para que los pasos cuadren.'),
    D('escalera_mayor',
      'Los dos semitonos de la escala mayor caen siempre entre los grados 3-4 y 7-8.',
      alto=210),
    H('Por qué esos semitonos importan tanto'),
    T('El semitono entre el **7º grado y la tónica** es el que crea la **sensible**: esa nota '
      'que suena "a medio resolver" y que empuja con fuerza hacia la tónica. El semitono entre '
      'el **3º y el 4º** marca el límite del acorde de tónica. Cambia de sitio uno de esos dos '
      'semitonos y ya no tienes una escala mayor: tienes un modo o una escala menor.'),
    T('Construyamos una que no sea DO. En **SOL mayor** el patrón obliga a subir el FA: sale '
      'FA♯. Escúchala:'),
    ESC('SOL', 'mayor', 'SOL mayor — aparece FA♯ para respetar la fórmula'),
    K('Una letra por grado',
      'Al construir una escala, usa **cada letra una sola vez**: SOL-LA-SI-DO-RE-MI-FA♯, no '
      'SOL-LA-SI-DO-RE-MI-SOL♭. Aunque FA♯ y SOL♭ suenen igual, escribir dos veces "SOL" y '
      'ningún "FA" hace la escala ilegible.'),
    H('Para quien quiera afinar el oído'),
    T('El "brillo" de la escala mayor viene sobre todo de su **3º grado mayor** (dos tonos '
      'sobre la tónica). Si bajas solo esa nota un semitono, sin tocar nada más, la escala se '
      'vuelve menor y todo el color cambia. Prueba a cantarlo: es el experimento más revelador '
      'de la teoría básica.'),
]
OBJETIVOS['lec-1-3'] = 'Memorizar T-T-ST-T-T-T-ST, aplicarlo desde cualquier nota y entender qué hace cada semitono.'

INTROS['lec-1-4'] = [
    T('Dentro de una escala, cada nota tiene un **papel**, no solo un nombre. Aprender esos '
      'papeles —los **grados**— es lo que te permite entender una progresión de acordes, '
      'transportar una canción a otro tono o improvisar sin perderte.'),
    H('Los siete grados y sus nombres'),
    D('grados_nombres',
      'Cada grado tiene nombre según su función. La tónica reposa, la dominante tensiona.',
      alto=200),
    TB('Grado · nombre · a qué suena',
       ['I — tónica', 'reposo total; el hogar'],
       ['II — supertónica', 'inestable; suele ir hacia el V'],
       ['III — mediante', 'a medio camino entre I y V; tiñe de mayor o menor'],
       ['IV — subdominante', 'se aleja del hogar con suavidad'],
       ['V — dominante', 'máxima tensión; pide volver al I'],
       ['VI — superdominante', 'reposo "en la sombra"; tónica de la relativa menor'],
       ['VII — sensible', 'a un semitono del I; empuja hacia la tónica']),
    K('Piensa en números, no en notas',
      'Un "I–IV–V–I" es la misma progresión en DO, en MI o en FA♯: solo cambian las notas '
      'concretas. Los músicos de estudio se pasan cifrados en números romanos justamente '
      'porque así una idea sirve en cualquier tonalidad.'),
    H('Sensible o subtónica'),
    T('Ese 7º grado se llama **sensible** solo cuando está **a un semitono** de la tónica '
      '(como en la escala mayor). Si está a un tono entero —como en la menor natural— se llama '
      '**subtónica** y empuja mucho menos. Esa diferencia es la razón de que exista la escala '
      'menor armónica, que verás en el nivel 4.'),
    H('Un apunte para más adelante'),
    T('Los grados también nombran acordes: el "acorde de dominante" es el que se construye '
      'sobre el V grado, y el "de tónica" sobre el I. Cuando oigas "esto es un II–V–I", ya '
      'sabes que se está hablando de supertónica → dominante → tónica.'),
]
OBJETIVOS['lec-1-4'] = 'Nombrar cada grado por su función, localizarlo en una tonalidad y empezar a pensar en números romanos.'

INTROS['lec-1-5'] = [
    T('Si la escala mayor es el "sí" luminoso, la **menor natural** es el "pero" melancólico. '
      'Es la escala menor por defecto, la que oyes en casi toda la música triste, oscura o '
      'nostálgica, y está a un solo cambio de la mayor.'),
    H('Su fórmula'),
    PS('Patrón de la menor natural',
       'T', 'ST', 'T', 'T', 'ST', 'T', 'T'),
    T('Los semitonos ahora caen entre los grados **2-3** y **5-6**. Comparada con la mayor, la '
      'menor natural tiene la **3ª, la 6ª y la 7ª bemoles**. La 3ª bemol es la que más se nota: '
      'es la que "apaga la luz".'),
    ESC('LA', 'menor natural', 'LA menor natural'),
    AU('escala_menor_natural', 'Escúchala entera'),
    H('Relativas: la misma despensa, otra puerta de entrada'),
    T('Toda escala mayor tiene una **relativa menor** que usa **exactamente sus mismas notas**, '
      'empezando por el **6º grado** de la mayor. DO mayor y LA menor son relativas. SOL mayor '
      'y MI menor. FA mayor y RE menor.'),
    D('relativas',
      'DO mayor va del grado 1 al 8; su relativa LA menor usa las mismas notas desde el 6º.',
      alto=190),
    K('Comparten armadura',
      'Como usan las mismas notas, una tonalidad mayor y su relativa menor **tienen la misma '
      'armadura** (los mismos sostenidos o bemoles al principio del pentagrama). Por eso, al '
      'ver una armadura, siempre hay dos tonalidades posibles: una mayor y su relativa menor.'),
    H('El punto débil de la menor natural'),
    T('Su 7º grado es **subtónica**, no sensible: está a un tono de la tónica y no "tira" hacia '
      'ella. Eso hace que las cadencias suenen blandas. La solución histórica fue subir esa '
      'nota a mano cuando hacía falta —y así nació la **menor armónica**—, pero eso ya es '
      'materia del nivel 4.'),
]
OBJETIVOS['lec-1-5'] = 'Conocer la fórmula de la menor natural, su color y su relación de "relativa" con la mayor.'

# ---------------------------------------------------------- NIVEL 2
INTROS['lec-2-1'] = [
    T('La **armadura** es ese grupito de sostenidos o bemoles que se escribe justo después de '
      'la clave, antes del compás. Es una convención de ahorro: en vez de poner un ♯ delante '
      'de cada FA de la obra, lo pones **una vez** en la armadura y ya vale para todos.'),
    H('Qué dice y hasta dónde llega'),
    LI('Una alteración de la armadura vale para **toda la obra**, en **todas las octavas**, hasta que un cambio de armadura diga lo contrario.',
       'Dice en qué **tonalidad** estás… casi: cada armadura sirve para **dos** tonalidades, una mayor y su relativa menor (misma armadura, distinta tónica).',
       'Las alteraciones **accidentales** (las que aparecen dentro de un compás) solo valen para ese compás; las de la armadura son permanentes.'),
    H('El orden no es libre'),
    T('Los sostenidos entran **siempre** en este orden: **FA – DO – SOL – RE – LA – MI – SI**. '
      'Los bemoles, en el orden **exactamente inverso**: **SI – MI – LA – RE – SOL – DO – FA**. '
      'Una tonalidad con 3 sostenidos tendrá FA♯, DO♯ y SOL♯: los tres primeros de la lista, '
      'sin saltarse ninguno.'),
    D('orden_alteraciones',
      'Los sostenidos aparecen en el orden FA DO SOL RE LA MI SI. Los bemoles, al revés.',
      alto=190),
    K('El truco del último sostenido',
      'En una armadura de sostenidos, el **último** sostenido es la **sensible**: la tónica '
      'mayor está **un semitono por encima**. ¿Armadura con FA♯ y DO♯? El último es DO♯, un '
      'semitono arriba está RE: es **RE mayor**.'),
    T('Y para las armaduras de bemoles: la tónica mayor es el **penúltimo bemol**. ¿SI♭, MI♭ y '
      'LA♭? El penúltimo es MI♭: es **MI♭ mayor**. (Con un solo bemol no hay penúltimo: esa es '
      'FA mayor, y hay que sabérsela.)'),
    H('Sin nada'),
    T('Sin sostenidos ni bemoles, la tonalidad mayor es **DO mayor** y la menor es **LA '
      'menor**. Son el punto de partida del círculo de quintas, que verás en dos lecciones.'),
]
OBJETIVOS['lec-2-1'] = 'Saber qué es la armadura, el orden de sus alteraciones y los trucos para leer la tonalidad de un vistazo.'

INTROS['lec-2-2'] = [
    T('Las tonalidades con **sostenidos** se ordenan subiendo de **quinta en quinta** desde DO. '
      'Cada quinta que subes añade **un sostenido más**, y siempre el siguiente de la lista '
      'FA-DO-SOL-RE-LA-MI-SI.'),
    H('La escalera de sostenidos'),
    TB('Tonalidad mayor · nº de sostenidos · cuáles',
       ['DO', '0', '—'],
       ['SOL', '1', 'FA♯'],
       ['RE', '2', 'FA♯ DO♯'],
       ['LA', '3', 'FA♯ DO♯ SOL♯'],
       ['MI', '4', 'FA♯ DO♯ SOL♯ RE♯'],
       ['SI', '5', 'FA♯ DO♯ SOL♯ RE♯ LA♯'],
       ['FA♯', '6', '+ MI♯']),
    T('¿Ves el patrón? DO → SOL → RE → LA → MI → SI → FA♯: cada paso es una **quinta justa** '
      '(siete semitonos) hacia arriba, y cada paso suma un sostenido.'),
    D('circulo_quintas',
      'La mitad derecha del círculo de quintas: cada paso horario añade un sostenido.',
      alto=230),
    K('Cómo deducirla sin tablas',
      'Para saber los sostenidos de, por ejemplo, **LA mayor**: LA está a 3 quintas de DO '
      '(DO→SOL→RE→LA), así que tiene **3 sostenidos**, y son los 3 primeros de la lista: '
      'FA♯, DO♯, SOL♯.'),
    ESC('RE', 'mayor', 'RE mayor — 2 sostenidos: FA♯ y DO♯'),
    H('Un matiz de notación'),
    T('SI mayor (5♯) y FA♯ mayor (6♯) existen y se usan, pero muchas veces se escriben como '
      'sus **enarmónicas** con bemoles (DO♭ mayor, SOL♭ mayor) si el contexto lo pide. Suenan '
      'igual; se elige la que deje la partitura más limpia.'),
]
OBJETIVOS['lec-2-2'] = 'Saber cuántos sostenidos tiene cada tonalidad sostenida y deducirlo contando quintas.'

INTROS['lec-2-3'] = [
    T('Las tonalidades con **bemoles** son la otra mitad del mapa. Se ordenan bajando de quinta '
      'en quinta desde DO (o, lo que es lo mismo, subiendo de **cuarta** en cuarta). Cada paso '
      'añade **un bemol**, siempre el siguiente del orden SI-MI-LA-RE-SOL-DO-FA.'),
    H('La escalera de bemoles'),
    TB('Tonalidad mayor · nº de bemoles · cuáles',
       ['DO', '0', '—'],
       ['FA', '1', 'SI♭'],
       ['SI♭', '2', 'SI♭ MI♭'],
       ['MI♭', '3', 'SI♭ MI♭ LA♭'],
       ['LA♭', '4', 'SI♭ MI♭ LA♭ RE♭'],
       ['RE♭', '5', 'SI♭ MI♭ LA♭ RE♭ SOL♭'],
       ['SOL♭', '6', '+ DO♭']),
    T('DO → FA → SI♭ → MI♭ → LA♭ → RE♭ → SOL♭: cada paso es una **cuarta justa** hacia arriba '
      '(o una quinta hacia abajo) y suma un bemol.'),
    ESC('FA', 'mayor', 'FA mayor — 1 bemol: SI♭'),
    K('El truco del penúltimo bemol',
      'En una armadura de bemoles, la tónica mayor es **el penúltimo bemol de la armadura**. '
      '¿SI♭, MI♭, LA♭, RE♭? El penúltimo es LA♭: **LA♭ mayor**. La única que hay que '
      'memorizar aparte es FA mayor (un solo bemol).'),
    H('Sostenidos o bemoles: ¿por qué unos y no otros?'),
    T('Una tonalidad se escribe con lo que necesita para que **cada letra aparezca una sola '
      'vez** y con el mínimo de alteraciones. FA mayor "pide" SI♭ (no LA♯) porque ya tiene un '
      'LA natural. Es la misma regla de "una letra por grado" de la lección 1-3, aplicada a la '
      'tonalidad entera.'),
]
OBJETIVOS['lec-2-3'] = 'Saber cuántos bemoles tiene cada tonalidad con bemoles y por qué se eligen bemoles y no sostenidos.'

INTROS['lec-2-4'] = [
    T('Ya lo insinuamos en el nivel 1: cada tonalidad mayor tiene una **menor** que es su '
      'sombra. Comparten notas y armadura; solo cambia **cuál es la tónica**. Dominar estas '
      'parejas te deja moverte entre el modo mayor y el menor sin cambiar de "casa".'),
    H('Cómo se emparejan'),
    LI('La relativa **menor** de una mayor está en su **6º grado** (o, lo que es lo mismo, una 3ª menor por debajo de la tónica mayor).',
       'La relativa **mayor** de una menor está en su **3er grado** (una 3ª menor por encima).',
       'Las dos comparten **la misma armadura**.'),
    D('relativas',
      'Misma fila de notas, dos lecturas: DO mayor desde el 1º, LA menor desde el 6º.',
      alto=190),
    TB('Pares relativos más habituales',
       ['DO mayor', 'LA menor'],
       ['SOL mayor', 'MI menor'],
       ['RE mayor', 'SI menor'],
       ['FA mayor', 'RE menor'],
       ['SI♭ mayor', 'SOL menor'],
       ['MI♭ mayor', 'DO menor']),
    K('Relativa no es lo mismo que homónima',
      'La **relativa** de DO mayor es LA menor (mismas notas, otra tónica). La **homónima** '
      'de DO mayor es DO menor (misma tónica, otras notas: cambian 3 alteraciones). No las '
      'confundas: pasar a la relativa es sutil; pasar a la homónima es un giro dramático.'),
    T('Un uso práctico: muchas canciones "pop tristes" alternan un estribillo en mayor con '
      'estrofas en su relativa menor. Como las notas son las mismas, el cambio suena natural, '
      'pero el centro de gravedad —y la emoción— se desplaza.'),
]
OBJETIVOS['lec-2-4'] = 'Emparejar cada mayor con su relativa menor, distinguir relativa de homónima y usarlo al oído.'

INTROS['lec-2-5'] = [
    T('El **círculo de quintas** es el mapa que ordena las 12 tonalidades por parentesco. Si '
      'te lo sabes, sabes qué tonalidades se parecen, hacia dónde suena natural modular y por '
      'qué ciertas progresiones de acordes "giran" hacia delante.'),
    H('Cómo está montado'),
    T('Coloca DO arriba del todo. Ve girando **en el sentido de las agujas del reloj** '
      'subiendo una **quinta justa** cada vez: SOL, RE, LA, MI, SI, FA♯… Cada paso horario '
      '**añade un sostenido**. Si giras al revés (por cuartas) vas sumando **bemoles**: '
      'FA, SI♭, MI♭…'),
    D('circulo_quintas',
      'Cada casilla vecina se diferencia en una sola alteración. Abajo, las enarmónicas se tocan.',
      alto=250),
    LI('**Vecinas = casi iguales.** DO y SOL solo se diferencian en un FA♯. Modular a la tonalidad de al lado suena suave.',
       '**Enfrente = lo más lejano.** DO y FA♯ están a 6 alteraciones: modular ahí es un salto grande y llamativo.',
       'La **relativa menor** de cada mayor está escrita justo dentro, en el mismo radio.'),
    K('Por qué "gira"',
      'El movimiento de acorde más fuerte es **bajar una quintra** (V→I). Encadenar esos '
      'movimientos (vi→ii→V→I) es recorrer el círculo en sentido antihorario: por eso esas '
      'progresiones suenan como si cayeran hacia el hogar.'),
    H('Un apunte fino'),
    T('En la afinación real de hoy el círculo **cierra**: doce quintas justas dan (casi) siete '
      'octavas exactas y FA♯ = SOL♭. Con la afinación pura no cerraría del todo —sobra una '
      'coma diminuta, la "coma pitagórica"—, y ese pequeño desajuste es la razón de que '
      'usemos el temperamento igual.'),
]
OBJETIVOS['lec-2-5'] = 'Usar el círculo de quintas para relacionar tonalidades, entender la modulación suave y de dónde sale.'

# ---------------------------------------------------------- NIVEL 3
INTROS['lec-3-1'] = [
    T('Hasta ahora reconocías escalas mayores; ahora vas a **construirlas de memoria**, sin '
      'piano y sin dudar. Es una habilidad puramente mecánica: con el método correcto sale '
      'sola en un par de semanas.'),
    H('El método, paso a paso'),
    LI('**1.** Escribe las **siete letras** desde la tónica, cada una una vez: p. ej. para RE → RE MI FA SOL LA SI DO.',
       '**2.** Recorre el patrón **T-T-ST-T-T-T-ST** comprobando la distancia real entre cada par.',
       '**3.** Donde la distancia no cuadre, **altera la nota** (♯ o ♭) para arreglarla, sin cambiar de letra.'),
    T('Ejemplo con RE: RE→MI es tono (bien). MI→FA es semitono, pero el patrón pide **tono**: '
      'subimos a **FA♯**. FA♯→SOL es semitono (bien, toca ST). SOL→LA, LA→SI, SI→DO♯ (arreglado '
      'igual que FA), DO♯→RE semitono. Resultado: **RE MI FA♯ SOL LA SI DO♯**.'),
    D('escalera_mayor',
      'El patrón es siempre el mismo; lo único que cambia son las alteraciones que hacen falta.',
      alto=200),
    ESC('MIb', 'mayor', 'MI♭ mayor — sale SI♭, MI♭, LA♭'),
    K('Nunca mezcles ♯ y ♭ en la misma escala mayor',
      'Una escala mayor lleva **o todo sostenidos o todo bemoles**, nunca los dos. Si te salen '
      'mezclados, casi seguro has repetido o saltado una letra. Vuelve al paso 1.'),
    H('Atajos, una vez que dominas el método'),
    LI('Las tonalidades **sostenidas** añaden siempre FA♯, luego DO♯, luego SOL♯… (orden fijo).',
       'Las **bemoles** añaden SI♭, luego MI♭, luego LA♭…',
       'El **penúltimo bemol** nombra la tonalidad; el **último sostenido** está un semitono bajo la tónica.'),
]
OBJETIVOS['lec-3-1'] = 'Construir de memoria cualquier escala mayor con el método de "una letra por grado + arreglar distancias".'

INTROS['lec-3-2'] = [
    T('Localizar un grado es **contar**: el V es la 5ª nota de la escala, el VII la 7ª. Suena '
      'tonto, pero hacerlo **rápido y sin errores en las 12 tonalidades** es lo que separa a '
      'quien "sabe teoría" de quien la **usa** tocando.'),
    H('Entrenar la cuenta'),
    T('Dos formas de llegar al mismo sitio, y conviene tener las dos:'),
    LI('**Contando desde la tónica**: I-II-III-IV-V… hasta el grado que buscas. Seguro, pero lento al principio.',
       '**Por intervalos de memoria**: el III es una 3ª mayor sobre la tónica; el V, una 5ª justa; el VII, una 7ª mayor. Cuando interiorizas los intervalos, el grado aparece solo.'),
    D('grados_nombres',
      'I, IV y V son los tres pilares. Sitúalos primero y el resto cae alrededor.',
      alto=190),
    K('Primero los tres pilares',
      'En cualquier tono, aprende **primero** dónde están el **I, el IV y el V**. Son los tres '
      'acordes de casi toda la música popular y el esqueleto de la tonalidad. El II, III, VI y '
      'VII se colocan enseguida entre ellos.'),
    T('Ejemplo en LA mayor: la escala es LA-SI-DO♯-RE-MI-FA♯-SOL♯. El I es LA, el IV es RE '
      '(4ª nota), el V es MI (5ª nota). El VII, la sensible, es SOL♯: a un semitono de LA.'),
    H('Para quien improvisa'),
    T('Pensar en grados te deja tocar una idea aprendida en DO directamente en cualquier otro '
      'tono: si sabes que tu frase va "V–VI–I", la trasladas sin volver a aprenderla. Es la '
      'base de tocar "de oído" con criterio.'),
]
OBJETIVOS['lec-3-2'] = 'Localizar cualquier grado en varias tonalidades, deprisa, contando y por intervalos.'

INTROS['lec-3-3'] = [
    T('"¿Esta nota está en la escala o no?" es la pregunta que te haces cien veces al minuto '
      'cuando improvisas o armonizas. Responderla al instante es lo que hace que no toques '
      '"notas equivocadas".'),
    H('El método rápido'),
    LI('**Reconstruye** mentalmente la escala mayor de la tonalidad (método de la lección 3-1).',
       'Comprueba si la nota, con su alteración exacta, **aparece en esa lista**.',
       'Ojo a las **enarmónicas**: en RE mayor hay FA♯, así que "FA natural" **no** pertenece, aunque "FA" a secas te despiste.'),
    T('Ejemplos: ¿pertenece FA♯ a SOL mayor? SOL mayor = SOL LA SI DO RE MI **FA♯** → sí. '
      '¿Pertenece DO♯ a FA mayor? FA mayor = FA SOL LA SI♭ DO RE MI → no (ahí el DO es '
      'natural).'),
    ESC('SOL', 'mayor', 'SOL mayor — repásala para tenerla fresca'),
    K('El truco de la armadura',
      'Si te sabes la **armadura** de la tonalidad, ya sabes qué notas están alteradas. '
      'RE mayor tiene FA♯ y DO♯: **cualquier** FA o DO de esa tonalidad es sostenido; todo '
      'lo demás, natural. No hace falta reconstruir la escala entera.'),
    H('Notas "de dentro" y "de fuera"'),
    T('Las notas de la escala se llaman **diatónicas**; las de fuera, **cromáticas**. Las '
      'cromáticas no están prohibidas —de hecho dan mucho color como notas de paso o de '
      'aproximación—, pero conviene usarlas **a propósito**, sabiendo que estás saliendo un '
      'momento de la tonalidad, y no por error.'),
]
OBJETIVOS['lec-3-3'] = 'Decidir al instante si una nota pertenece a una escala mayor, usando la armadura y cuidando las enarmónicas.'

INTROS['lec-3-4'] = [
    T('La **pentatónica** es la escala de cinco notas más usada del planeta: está en el blues, '
      'el rock, el folk, la música celta, la china, la andina… Y hay un motivo: **quitando dos '
      'notas de la escala mayor, quitas casi todos los choques**.'),
    H('Cómo se forma la pentatónica mayor'),
    T('Coge la escala mayor y **elimina el 4º y el 7º grado**. Te quedan los grados '
      '**1-2-3-5-6**: cinco notas que casi nunca suenan "mal" unas contra otras.'),
    D('pentatonica',
      'La pentatónica mayor es la escala mayor sin su 4º ni su 7º grado.',
      alto=190),
    ESC('DO', 'pentatónica mayor', 'DO pentatónica mayor: DO RE MI SOL LA'),
    AU('escala_pentatonica', 'Escúchala: todo "encaja"'),
    T('¿Por qué al quitar la 4ª y la 7ª desaparecen los problemas? Porque entre esas dos notas '
      'está el **tritono** de la tonalidad (el intervalo más tenso), y porque el 4º grado '
      'choca con la 3ª del acorde de tónica. Sin ellos, la escala se vuelve "a prueba de fallos".'),
    H('La pentatónica menor es su relativa'),
    T('La **pentatónica menor** usa las mismas cinco notas empezando por el **6º grado**. La '
      'pentatónica menor de LA = la pentatónica mayor de DO. Es la escala reina para solos de '
      'rock y blues.'),
    ESC('LA', 'pentatónica menor', 'LA pentatónica menor: LA DO RE MI SOL'),
    K('No es "hacer trampa"',
      'Empezar por la pentatónica no es un atajo de principiante: guitarristas de primerísimo '
      'nivel viven en ella. Lo que cambia con la experiencia es **qué haces** con esas cinco '
      'notas: fraseo, ritmo, silencios, bends… La escala es la misma.'),
]
OBJETIVOS['lec-3-4'] = 'Formar las pentatónicas mayor y menor, entender por qué "siempre suenan bien" y su relación de relativas.'

INTROS['lec-3-5'] = [
    T('Dos escalas que no definen una tonalidad pero que dan muchísimo color: la de **blues** '
      'y la **cromática**. Las dos se usan sobre todo como fuente de notas expresivas, no como '
      'centro.'),
    H('La escala de blues'),
    T('Es la **pentatónica menor más una nota**: la **"blue note"**, que es la **5ª bemol**. '
      'Se toca casi siempre de paso, rozando entre la 4ª y la 5ª justa, y ese roce es el '
      'sonido del blues.'),
    ESC('LA', 'blues', 'LA blues: LA DO RE MI♭ MI SOL'),
    K('La blue note se desliza',
      'La 5ª bemol del blues rara vez se sostiene: se **ataca y se resuelve** enseguida a la '
      '4ª o a la 5ª justa. En la guitarra suele hacerse con un bend de medio tono. Sostenerla '
      'suena más a "escala de estudio" que a blues.'),
    H('La escala cromática'),
    T('Son las **12 notas**, todas a distancia de semitono. No tiene tónica ni carácter '
      'propio: por eso **no define ninguna tonalidad**. Su papel es adornar —notas de paso, '
      'bordaduras, aproximaciones a una nota importante— y crear tensión momentánea.'),
    AU('escala_cromatica', 'Escala cromática (las 12 notas)'),
    T('Usada entera y seguida suena a ejercicio o a dibujo animado. Usada en dosis pequeñas '
      '—un par de notas cromáticas para "colarte" en la nota buena— es una de las herramientas '
      'más elegantes que hay.'),
]
OBJETIVOS['lec-3-5'] = 'Conocer la escala de blues y la cromática, su "blue note" y para qué sirven realmente.'

# ---------------------------------------------------------- NIVEL 4
INTROS['lec-4-1'] = [
    T('La **menor natural** tenía un problema: su 7º grado no empuja hacia la tónica. La '
      '**menor armónica** lo arregla de la forma más directa posible: **sube ese 7º grado un '
      'semitono** para fabricar una sensible. Un cambio pequeño, consecuencias enormes.'),
    H('Qué cambia exactamente'),
    PS('Patrón de la menor armónica (fíjate en el salto de 3 semitonos)',
       'T', 'ST', 'T', 'T', 'ST', 'T+ST', 'ST'),
    T('Respecto de la natural, solo se altera el **7º grado**, que sube. Pero al subirlo, entre '
      'el **6º (que sigue bemol) y el 7º (ahora natural)** aparece un salto de **tres '
      'semitonos**: la famosa **2ª aumentada**, con ese sabor "oriental" o flamenco.'),
    D('menor_armonica',
      'Subir el 7º grado crea la sensible; el hueco entre el 6º y el 7º se agranda a 2ª aumentada.',
      alto=200),
    ESC('LA', 'menor armónica', 'LA menor armónica: LA SI DO RE MI FA SOL♯'),
    AU('escala_menor_armonica', 'Escúchala: el salto grande entre el 6º y el 7º'),
    H('Para qué sirve de verdad'),
    T('Con la sensible recuperada, el acorde del **V grado** deja de ser menor y pasa a ser '
      '**V7 mayor**: el acorde de dominante "de verdad", que empuja con fuerza hacia el acorde '
      'menor de tónica (i). Esa cadencia **V7 → i** es la razón de ser de toda la escala.'),
    K('Se usa "a trozos"',
      'Casi nadie toca la menor armónica entera como melodía: suena rara por la 2ª aumentada. '
      'Lo habitual es usar la **menor natural** para la melodía y "encender" la **sensible** '
      'solo en el momento de la cadencia, sobre el acorde de dominante.'),
    T('Dónde la oirás sin buscarla: música flamenca y española, metal neoclásico, bandas '
      'sonoras "épicas" y buena parte de la música clásica en modo menor desde el Barroco.'),
]
OBJETIVOS['lec-4-1'] = 'Entender qué altera la menor armónica respecto de la natural, la 2ª aumentada y para qué sirve el V7.'

INTROS['lec-4-2'] = [
    T('La **menor melódica** es el segundo arreglo de la menor natural. En vez de crear un '
      'salto raro, **suaviza el camino a la tónica subiendo el 6º y el 7º grado a la vez**, '
      'solo al ascender.'),
    H('Su doble cara (uso clásico)'),
    LI('**Subiendo**: se elevan el **6º y el 7º** grados. Queda "una escala mayor con la 3ª bemol".',
       '**Bajando**: se vuelve a la **menor natural** (6º y 7º otra vez bemoles), porque ya no hace falta empujar a ningún sitio.'),
    ESC('LA', 'menor melódica', 'LA menor melódica ascendente: LA SI DO RE MI FA♯ SOL♯'),
    T('Comparada con la escala **mayor** de la misma tónica, la melódica ascendente solo se '
      'diferencia en **una nota**: la 3ª, que está bemol. De ahí su color agridulce, ni del '
      'todo triste ni del todo alegre.'),
    K('En el jazz se usa "recta"',
      'El jazz se salta la doble cara: usa la **melódica ascendente igual subiendo y '
      'bajando**. Es una de las escalas más rentables que existen porque de sus siete modos '
      'salen sonidos clave: el **superlocrio (alterada)** sobre dominantes tensos y el '
      '**lidio ♭7** sobre dominantes "brillantes".'),
    D('modos_brillo',
      'La menor melódica genera su propia familia de siete modos, igual que la escala mayor.',
      alto=250),
    H('Un apunte de nomenclatura'),
    T('"Menor melódica" a secas suele significar **ascendente** cuando se habla de armonía '
      'moderna. Si alguien dice "melódica descendente", te está hablando literalmente de la '
      'menor natural.'),
]
OBJETIVOS['lec-4-2'] = 'Conocer la menor melódica, su doble forma clásica y su uso "recto" en el jazz.'

INTROS['lec-4-3'] = [
    T('Los **modos griegos** son, ni más ni menos, las **siete escalas que salen de tocar la '
      'escala mayor empezando por cada uno de sus grados**. Mismas notas, siete centros de '
      'gravedad distintos, siete colores.'),
    H('De dónde sale cada uno'),
    D('modos_siete',
      'Una sola escala (teclas blancas), siete modos según por qué nota empieces.',
      alto=260),
    TB('Grado de partida · modo · en una frase',
       ['1º', 'Jónico', '= la escala mayor'],
       ['2º', 'Dórico', 'menor con la 6ª mayor'],
       ['3º', 'Frigio', 'menor con la 2ª menor (sabor español)'],
       ['4º', 'Lidio', 'mayor con la 4ª aumentada (flota)'],
       ['5º', 'Mixolidio', 'mayor con la 7ª menor (blues, rock)'],
       ['6º', 'Eólico', '= la menor natural'],
       ['7º', 'Locrio', 'inestable; 2ª y 5ª bemoles']),
    K('Nota característica',
      'Cada modo tiene **una nota** que lo delata frente a la mayor o la menor "normal": el '
      'lidio su 4ª aumentada, el mixolidio su 7ª menor, el dórico su 6ª mayor, el frigio su '
      '2ª menor. Esa nota es la que hay que hacer sonar para que el modo se reconozca.'),
    H('El error clásico'),
    T('"RE dórico" **no** es la escala de RE mayor. Es tocar las notas de **DO mayor** '
      'tomando **RE como centro**. Todos los modos de una tonalidad comparten notas y '
      'armadura; lo que cambia es sobre qué nota reposas y qué acorde suena debajo.'),
    T('Escúchalo: primero la escala mayor (jónico) y luego el mismo material desde el 2º grado '
      '(dórico). Las notas no cambian; el ambiente, sí.'),
    AU('modo_dorico', 'Modo dórico (RE a RE, notas de DO mayor)'),
]
OBJETIVOS['lec-4-3'] = 'Saber qué son los modos griegos, de qué grado sale cada uno y qué nota característica lo identifica.'

INTROS['lec-4-4'] = [
    T('De los siete modos, dos se usan tanto en jazz, funk, rock y pop que merecen lección '
      'propia: el **dórico** y el **mixolidio**. Son los "modos de trabajo".'),
    H('Dórico: el menor que no se hunde'),
    T('El dórico es una **escala menor con la 6ª mayor**. Esa 6ª subida le quita el dramatismo '
      'de la menor natural: suena melancólico pero **con energía**, ideal para vampiros de dos '
      'acordes, funk y soul.'),
    ESC('RE', 'dórico', 'RE dórico (notas de DO mayor, centro en RE)'),
    T('Dónde vive: "So What" de Miles Davis, "Oye como va", muchísimo groove de guitarra '
      'rítmica. Sobre un acorde **m7** que dura y dura, el dórico es la primera opción.'),
    H('Mixolidio: la escala de la dominante y del blues'),
    T('El mixolidio es una **escala mayor con la 7ª menor**. Esa 7ª bemol es exactamente lo que '
      'hace "de dominante" a un acorde 7 (como G7). Es la escala natural sobre los acordes de '
      'dominante que **no** resuelven, y el esqueleto del rock y el blues mayor.'),
    ESC('SOL', 'mixolidio', 'SOL mixolidio (notas de DO mayor, centro en SOL)'),
    AU('modo_mixolidio', 'Modo mixolidio (SOL a SOL)'),
    D('modos_brillo',
      'El dórico y el mixolidio están en la zona media: ni tan brillantes como el lidio ni tan oscuros como el frigio.',
      alto=250),
    K('Regla rápida',
      'Sobre un acorde **m7** que se queda quieto → prueba **dórico**. Sobre un acorde **7** '
      'que se queda quieto (blues, vamp) → prueba **mixolidio**. Son el 80 % de los casos.'),
]
OBJETIVOS['lec-4-4'] = 'Reconocer y usar el dórico y el mixolidio: qué los define y sobre qué acordes encajan.'

INTROS['lec-4-5'] = [
    T('Cerramos los modos con los tres de carácter más marcado: **frigio**, **lidio** y '
      '**locrio**. Se reconocen al instante por su nota característica.'),
    H('Frigio: el sabor español'),
    T('Menor con la **2ª bemol**. Esa 2ª pegada a la tónica da un aire flamenco, árabe, '
      'oscuro. Es la base del "por medio" del flamenco y de mucho metal. Si además subes su '
      '3ª (frigio mayor / "dominante frigio"), tienes literalmente el sonido de la guitarra '
      'flamenca.'),
    ESC('MI', 'frigio', 'MI frigio (notas de DO mayor, centro en MI)'),
    AU('modo_frigio', 'Modo frigio (MI a MI)'),
    H('Lidio: el sonido "de película"'),
    T('Mayor con la **4ª aumentada**. Esa 4ª elevada "estira" la escala hacia arriba y le da '
      'una luz flotante, de ensueño, sin gravedad. Es el sonido de John Williams, de "Los '
      'Simpson", de mucha banda sonora luminosa.'),
    ESC('FA', 'lidio', 'FA lidio (notas de DO mayor, centro en FA)'),
    AU('modo_lidio', 'Modo lidio (FA a FA)'),
    H('Locrio: el inestable'),
    T('El único modo con la **5ª disminuida**: su propio acorde de tónica es un **m7♭5** '
      '(semidisminuido), que no reposa. Casi no se usa como centro de una pieza; su sitio '
      'natural es **sobre el acorde del VII grado** en un II-V-I menor.'),
    ESC('SI', 'locrio', 'SI locrio (notas de DO mayor, centro en SI)'),
    K('Cómo memorizarlos por brillo',
      'De más brillante a más oscuro: **Lidio → Jónico → Mixolidio → Dórico → Eólico → Frigio '
      '→ Locrio**. Cada paso "baja" una nota de la escala un semitono. Es la forma más '
      'ordenada de tener los siete en la cabeza.'),
    D('modos_brillo', 'Los siete modos ordenados por brillo, del más claro al más oscuro.', alto=250),
]
OBJETIVOS['lec-4-5'] = 'Identificar frigio, lidio y locrio por su nota característica y ordenar los siete modos por brillo.'

# ---------------------------------------------------------- NIVEL 5
INTROS['lec-5-1'] = [
    T('Ya sabes qué es cada modo. Ahora vas a **usarlos para improvisar** sobre una progresión '
      'diatónica: la idea es que **cada acorde de la tonalidad tiene su modo**, y todos usan '
      'las mismas siete notas.'),
    H('El reparto en el campo mayor'),
    TB('Grado · acorde · modo para improvisar',
       ['I', 'maj7', 'jónico'],
       ['II', 'm7', 'dórico'],
       ['III', 'm7', 'frigio'],
       ['IV', 'maj7', 'lidio'],
       ['V', '7', 'mixolidio'],
       ['VI', 'm7', 'eólico'],
       ['VII', 'm7♭5', 'locrio']),
    D('modos_siete',
      'Una sola tonalidad, siete acordes, siete modos: cambian el centro y la nota que resaltas.',
      alto=260),
    K('Lo que de verdad cambia',
      'Si sobre TODA la progresión tocas simplemente la escala de la tonalidad, ya estás '
      '"dentro". El trabajo modal fino consiste en **apuntar a la nota característica y a las '
      'notas del acorde de turno**: en el IV, hacer sonar la 4ª aumentada (lidio); en el V, '
      'la 7ª menor (mixolidio); etc.'),
    H('Para llevártelo al instrumento'),
    LI('Coge una canción con acordes solo diatónicos (muchísimo pop lo es).',
       'Improvisa con la escala de la tonalidad, sin pensar en modos.',
       'Después, en cada acorde, busca **su** nota característica y apóyate en ella. Ahí empiezas a oír los modos "de dentro".'),
    T('El siguiente nivel —acordes prestados, dominantes secundarias, modulación— rompe el '
      'reparto limpio y obliga a cambiar de escala sobre la marcha. Pero eso llega **después** '
      'de tener este esquema mecánico.'),
]
OBJETIVOS['lec-5-1'] = 'Asociar cada grado del campo mayor con su modo y entender qué cambia al improvisar modalmente.'

INTROS['lec-5-2'] = [
    T('El acorde de **dominante** (el "7": G7, C7…) es el más rico en tensión y el que más '
      'opciones de escala admite. Elegir bien según lo que hace después es de las decisiones '
      'más jugosas al improvisar.'),
    H('El menú, de menos a más tensión'),
    TB('Situación · escala · qué aporta',
       ['dominante que se queda (blues, vamp)', 'mixolidio', 'el sonido "natural", sin drama'],
       ['dominante que resuelve a mayor', 'mixolidio o alterada', 'de suave a muy tenso'],
       ['dominante que resuelve a menor', 'mixolidio ♭9 ♭13 (frigio mayor)', 'oscuro, "español"'],
       ['dominante muy alterado (♭9 ♯9 ♯11 ♭13)', 'alterada (superlocrio)', 'máxima tensión'],
       ['dominante simétrico', 'disminuida (ST-T)', 'tensión "de suspense", cine']),
    T('Todas comparten el corazón del acorde: la **3ª mayor** y la **7ª menor**, que forman el '
      '**tritono**. Ese tritono es lo que "pide resolver". Lo que cambia de una escala a otra '
      'son las **tensiones** (9ª, 11ª, 13ª y sus alteraciones).'),
    AU('cadencia_autentica', 'Cadencia V–I: la resolución del tritono'),
    D('funciones_tonales',
      'La dominante es la zona de tensión; toda esta lección va de cómo colorear ese momento.',
      alto=210),
    K('La escala alterada, en una frase',
      'Es la **menor melódica un semitono por encima** de la tónica del acorde. Para G7 '
      'alterado → LA♭ melódica. Contiene TODAS las tensiones alteradas del acorde (♭9, ♯9, '
      '♯11, ♭13) y ninguna nota "neutra".'),
    H('Consejo práctico'),
    T('No hace falta memorizar las cinco de golpe. Empieza dominando el **mixolidio** en las '
      '12 tonalidades. Añade la **alterada** cuando quieras el sonido "jazz tenso". El resto, '
      'con el tiempo.'),
]
OBJETIVOS['lec-5-2'] = 'Elegir la escala adecuada sobre un acorde de dominante según a dónde resuelve y cuánta tensión quieres.'

INTROS['lec-5-3'] = [
    T('Toca la teoría de irse a lo práctico. La **pentatónica menor** es la escala con la que '
      'casi todo el mundo da sus primeros solos de verdad: pocas notas, ningún choque feo y un '
      'sonido inmediatamente reconocible en blues, rock y pop.'),
    H('Por dónde empezar'),
    ESC('LA', 'pentatónica menor', 'LA pentatónica menor — la de un blues en LA'),
    LI('Elige **la pentatónica menor de la tónica** de la canción (blues en LA → LA pentatónica menor).',
       'Toca **frases cortas** de 3-5 notas y **deja silencios** del mismo tamaño. El silencio es parte del solo.',
       'Apóyate en las **notas del acorde** que suena: caer en ellas al final de la frase suena "resuelto".',
       'Repite una idea y luego **varíala** un poco: así el oyente te sigue.'),
    K('Menos es más',
      'Meter muchas notas por compás no hace mejor un solo: lo satura y le quita forma. Los '
      'solos que recordamos casi siempre tienen **pocas notas, bien colocadas y con ritmo '
      'propio**. Piensa en cantarlo, no en llenarlo.'),
    T('Relación útil: la pentatónica **menor** de una nota tiene las mismas notas que la '
      'pentatónica **mayor** de su relativa. La menor de MI = la mayor de SOL. Cambiar el '
      '"centro" mental entre las dos, sobre la misma digitación, ya te da dos colores.'),
    AU('escala_pentatonica', 'La pentatónica, de referencia'),
    H('El siguiente paso'),
    T('Cuando la pentatónica te quede pequeña, añade **una** nota: la **blue note** (5ª bemol) '
      'para el blues, o la **6ª mayor** para un sonido más dulce. De una en una, para oír bien '
      'qué aporta cada una.'),
]
OBJETIVOS['lec-5-3'] = 'Dar los primeros solos con la pentatónica menor: elección de escala, frases, silencios y notas de apoyo.'

INTROS['lec-5-4'] = [
    T('Las **escalas simétricas** repiten su patrón dentro de la octava. Como el patrón se '
      'repite, hay **muy pocas distintas**: transportarlas un poco te devuelve las mismas '
      'notas. Suenan "sin gravedad", ideales para tensión y suspense.'),
    H('La escala disminuida (8 notas)'),
    T('Alterna **tono y semitono** todo el rato: T-ST-T-ST-T-ST-T-ST. Ocho notas. El patrón se '
      'repite cada 3 semitonos, así que solo existen **tres** disminuidas distintas.'),
    D('escala_disminuida',
      'Tono y semitono alternados: el patrón se repite cada 3 semitonos.',
      alto=180),
    LI('Empezando por **semitono** (ST-T): la escala del acorde de **dominante** (contiene ♭9, ♯9, ♯11, 13).',
       'Empezando por **tono** (T-ST): la escala del acorde **disminuido** (dim7).'),
    H('La escala de tonos enteros (6 notas)'),
    T('Solo **tonos**: T-T-T-T-T-T. Seis notas. Sin semitonos y sin tritono que resuelva, no '
      'hay ninguna nota que "pida" ser la tónica: por eso **flota**. Solo hay **dos** de tonos '
      'enteros distintas.'),
    D('tonos_enteros',
      'Todos los pasos iguales: la escala "sin dónde caer".',
      alto=170),
    ESC('DO', 'tonos enteros', 'DO tonos enteros: DO RE MI FA♯ SOL♯ LA♯'),
    AU('escala_tonos_enteros', 'Escúchala: pura ingravidez'),
    K('Su acorde',
      'La de tonos enteros es la escala del acorde **aumentado** (7♯5). Debussy la usó para '
      'crear atmósferas suspendidas; el cine la usa para sueños, hipnosis y flashbacks.'),
]
OBJETIVOS['lec-5-4'] = 'Conocer la disminuida y la de tonos enteros, por qué hay tan pocas y sobre qué acordes van.'

INTROS['lec-5-5'] = [
    T('Última lección, y la más importante: **saber la escala no es el objetivo**. El objetivo '
      'es convertirla en **frases** que digan algo. Una escala es vocabulario; una frase es una '
      'oración. Aquí va cómo hacer el salto.'),
    H('De la escala a la frase'),
    LI('**Empieza por variar.** Coge una melodía que te sepas y cámbiale una cosa: una nota, un ritmo, el final. Luego otra. Improvisar es, al principio, variar rápido.',
       '**Usa los arpegios como red.** Las notas del acorde (1-3-5-7) son "seguro": caer en ellas suena bien. La escala sirve para **conectar** una nota del acorde con la siguiente.',
       '**Piensa en pregunta y respuesta.** Una frase que "queda abierta" y otra que "cierra": es la estructura de casi toda melodía natural.'),
    D('antecedente_consecuente',
      'Pregunta (antecedente) y respuesta (consecuente): la unidad básica de una melodía.',
      alto=190),
    D('contorno_melodico',
      'El dibujo que traza la melodía en el aire importa tanto como las notas concretas.',
      alto=200),
    K('El entrenamiento que de verdad funciona',
      'Practicar escalas y arpegios **en las 12 tonalidades**, despacio y con buen sonido, '
      'para que estén disponibles sin pensar. Y luego dedicar el mismo tiempo a **tocar '
      'música**: variaciones, solos escritos, sacar de oído. Las escalas solas, tocadas '
      'rápido y de memoria, no enseñan a improvisar.'),
    H('Un plan de dos semanas'),
    LI('Días 1-3: una pentatónica menor por todo el mástil / teclado, muy despacio.',
       'Días 4-7: frases de 4 notas + silencio de 4 tiempos, sobre una base.',
       'Días 8-11: pregunta-respuesta; graba y escúchate.',
       'Días 12-14: coge un solo que te guste, apréndelo y cámbiale tres cosas.'),
    AU('comp_variacion', 'Un tema y una variación suya'),
    T('Si terminas este curso tocando cinco frases con criterio, has ganado. El resto es '
      'repetir el proceso toda la vida.'),
]
OBJETIVOS['lec-5-5'] = 'Convertir el conocimiento de escalas en frases: variación, arpegios de apoyo y pregunta-respuesta.'


# ===========================================================================
#  Fusión con lecciones.json
# ===========================================================================
RUTA = os.path.join(os.path.dirname(__file__), '..', 'assets', 'content', 'lecciones.json')
data = json.load(open(RUTA, encoding='utf-8'))

n_intro = n_obj = 0
for lec in data['lecciones']:
    lid = lec['id']
    if lid in INTROS:
        lec['intro'] = INTROS[lid]
        n_intro += 1
    if lid in OBJETIVOS:
        lec['objetivo'] = OBJETIVOS[lid]
        n_obj += 1

data['_schema'] = (
    'Lecciones de escalas por nivel (1..5). Base: tools/gen_lecciones.py; '
    'introducción profunda: tools/expand_lecciones.py (ejecutar DESPUÉS). '
    'Cada lección: id, nivel, titulo, objetivo, intro (bloques de VisorBloques: '
    'texto/clave/lista/tabla/pasos/diagrama/escala/nota/audio), ejercicios.')

json.dump(data, open(RUTA, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)

# Aviso de audios referenciados que no existan
audio_dir = os.path.join(os.path.dirname(RUTA), '..', 'audio')
existen = {f[:-4] for f in os.listdir(audio_dir) if f.endswith('.wav')}
faltan = set()
for lec in data['lecciones']:
    for b in lec['intro']:
        if b.get('tipo') == 'audio' and b['archivo'] not in existen:
            faltan.add(b['archivo'])

print(f'Introducciones reescritas: {n_intro}/25   ·   objetivos: {n_obj}')
n_bloques = sum(len(l['intro']) for l in data['lecciones'])
n_diag = sum(1 for l in data['lecciones'] for b in l['intro'] if b.get('tipo') == 'diagrama')
print(f'Bloques totales: {n_bloques}   ·   diagramas: {n_diag}')
if faltan:
    print('AVISO — audios referenciados que no existen:', sorted(faltan))
else:
    print('Todos los audios referenciados existen.')
print('->', os.path.normpath(RUTA))
