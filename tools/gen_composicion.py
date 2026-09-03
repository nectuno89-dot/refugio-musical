# -*- coding: utf-8 -*-
"""
gen_composicion.py — construye assets/content/composicion.json, el contenido
de la sección "Componer" (curso didáctico: motivo, frase, formas, armonía,
melodía, ritmo, textura, orquestación, oficio).

Cada módulo: {id, parte, titulo, resumen, bloques[], verTambien[]}.
Tipos de bloque:
  texto    -> {texto}                      ('## ' al inicio = subtítulo)
  clave    -> {titulo, texto}              (recuadro destacado)
  lista    -> {items:[...]}
  diagrama -> {nombre, pie, alto?}         (lib/diagramas.dart)
  audio    -> {archivo, titulo}            (assets/audio/<archivo>.wav)
  escala   -> {tonicaIdx, pasos, titulo}   (pentagrama + escuchar)
  nota     -> {midi, titulo}

Uso:  python tools/gen_composicion.py
"""

import json
import os

RUTA = os.path.join(os.path.dirname(__file__), '..', 'assets', 'content',
                    'composicion.json')

T = lambda s: {'tipo': 'texto', 'texto': s}
C = lambda titulo, s: {'tipo': 'clave', 'titulo': titulo, 'texto': s}
L = lambda *items: {'tipo': 'lista', 'items': list(items)}
D = lambda nombre, pie='', alto=200: {
    'tipo': 'diagrama', 'nombre': nombre, 'pie': pie, 'alto': alto}
A = lambda archivo, titulo: {'tipo': 'audio', 'archivo': archivo,
                             'titulo': titulo}
ESC = lambda idx, pasos, titulo: {
    'tipo': 'escala', 'tonicaIdx': idx, 'pasos': pasos, 'titulo': titulo}

MAYOR = [2, 2, 1, 2, 2, 2, 1]

MODULOS = []


def M(id, parte, titulo, resumen, bloques, verTambien=None):
    MODULOS.append({
        'id': id,
        'parte': parte,
        'titulo': titulo,
        'resumen': resumen,
        'bloques': bloques,
        'verTambien': verTambien or [],
    })


# =========================================================================
#  PARTE 1 · FUNDAMENTOS
# =========================================================================
M('intro', 'Fundamentos',
  'Qué es componer',
  'Componer es tomar decisiones sobre el sonido en el tiempo. No hace falta '
  'inspiración mágica: hace falta un método y mucho probar.',
  [
    T('Componer es **organizar el sonido en el tiempo con una intención**. '
      'No es esperar a que llegue una melodía perfecta: es tomar una idea '
      'pequeña —dos compases, un ritmo, un giro de acordes— y **trabajarla** '
      'hasta que sostiene una pieza entera.'),
    T('## Los materiales'),
    T('Todo lo que decides al componer cae en uno de estos cinco terrenos, '
      'que ya conoces de la teoría:'),
    L('**Melodía** — la línea principal, lo que se canta o se silba.',
      '**Armonía** — los acordes y cómo se encadenan; el "color" y la '
      'tensión.',
      '**Ritmo** — las duraciones, los acentos, el groove.',
      '**Timbre** — con qué suena cada cosa y cómo se combinan.',
      '**Forma** — el plano a gran escala: qué se repite, qué contrasta, '
      'cuándo llega el clímax.'),
    C('Regla de oro', 'Repetición para que se entienda; contraste para que no '
      'aburra; variación para tener las dos cosas a la vez. Casi toda la '
      'música vive de dosificar estos tres ingredientes.'),
    T('## El proceso'),
    T('Un flujo habitual, aunque cada quien lo adapta:'),
    L('**Idea** — una semilla: un motivo, un ritmo, una progresión, un '
      'ambiente.',
      '**Boceto** — la extiendes rápido y sin juzgar: una melodía sobre unos '
      'acordes, un esquema de secciones.',
      '**Desarrollo** — la transformas: secuencias, variaciones, contrastes, '
      'transiciones.',
      '**Forma** — ordenas las secciones, decides proporciones y el punto '
      'culminante.',
      '**Revisión** — dejas reposar, escuchas con oídos frescos, quitas lo '
      'que sobra, terminas.'),
    T('## Empezar con límites'),
    T('La página en blanco paraliza. Ponte **restricciones** a propósito: '
      '"una melodía de 8 compases, solo con notas de la escala de DO, en 3/4, '
      'que empiece y acabe en la tónica". Los límites no cierran puertas: '
      'te dan por dónde empezar a empujar.'),
    C('En esta sección', 'Cada módulo explica una herramienta concreta —del '
      'motivo a la forma sonata— con un diagrama animado y ejemplos que '
      'suenan. Léelos en orden o salta al que necesites.'),
  ],
  ['wiki-teoria-formas', 'wiki-teoria-armonia', 'wiki-historia-teoria-evolucion']),


# =========================================================================
#  PARTE 2 · LA IDEA Y SU DESARROLLO
# =========================================================================
M('motivo', 'La idea y su desarrollo',
  'El motivo: la semilla de una pieza',
  'Un motivo es una célula de pocas notas, reconocible, que puede generar '
  'música entera si sabes transformarla.',
  [
    T('Un **motivo** es la unidad musical más pequeña con identidad propia: '
      'unas pocas notas con un perfil melódico y un ritmo reconocibles. Las '
      '**cuatro notas** iniciales de la Quinta Sinfonía de Beethoven '
      '(tres cortas y una larga, bajando una tercera) impregnan los cuatro '
      'movimientos de la obra.'),
    A('comp_motivo', 'El motivo de la Quinta y tres transformaciones'),
    T('En ese audio oyes el motivo original y luego **la misma idea '
      'cambiada**: repetida un grado más abajo, con el salto invertido '
      '(sube en vez de bajar) y "aumentada" (el doble de lenta). Sigue '
      'siendo el mismo motivo.'),
    T('## Cómo se transforma un motivo'),
    L('**Repetición** — dilo otra vez, igual. Fija la idea en el oído.',
      '**Transposición** — el mismo dibujo empezando en otra nota.',
      '**Secuencia** — repeticiones encadenadas que suben o bajan por grados '
      '(el recurso más productivo del Barroco).',
      '**Inversión** — das la vuelta a los intervalos: lo que subía, baja.',
      '**Retrogradación** — el motivo leído de atrás hacia delante.',
      '**Aumentación / disminución** — el mismo motivo al doble o a la mitad '
      'de velocidad.',
      '**Fragmentación** — te quedas solo con un trozo (a menudo el final) y '
      'lo repites.',
      '**Ampliación** — añades notas o alargas un salto.',
      '**Ornamentación** — rellenas con notas de paso, floreos, adornos.',
      '**Cambio de armonía** — el mismo motivo sobre otro acorde suena nuevo.'),
    C('Truco', 'Escribe tu motivo en una esquina del papel. Cada vez que te '
      'atasques, aplícale una transformación de la lista y sigue. La pieza '
      '"se escribe sola" cuando el material es coherente.'),
    T('## Motivo rítmico'),
    T('El motivo no tiene por qué ser melódico: puede ser **solo un ritmo** '
      '(corto-corto-corto-largo). Un ritmo característico, repetido y '
      'variado, da unidad aunque cambien las notas. Gran parte de la música '
      'de cine y del rock funciona así.'),
    D('jerarquia_frase',
      'De la célula a la obra: el motivo forma frases, las frases forman '
      'períodos, y los períodos forman secciones.', 210),
  ],
  ['wiki-teoria-formas', 'wiki-comp-beethoven', 'wiki-comp-brahms']),


M('frase', 'La idea y su desarrollo',
  'Frase, período y la estructura de 8 compases',
  'La música respira en frases. Dos frases que se responden —una que '
  'pregunta y otra que contesta— forman el ladrillo de casi todo.',
  [
    T('Una **frase** es una unidad musical con sentido completo, como una '
      'oración hablada. Suele durar **4 compases** y termina en una '
      'cadencia (una fórmula de reposo). La música "respira" al final de '
      'cada frase.'),
    T('## Antecedente y consecuente'),
    T('El esquema más común: una primera frase (**antecedente**) que acaba '
      'en una **semicadencia** —reposa en la dominante, queda "abierta", '
      'como una pregunta— y una segunda frase (**consecuente**) que empieza '
      'igual pero acaba en una **cadencia auténtica** —reposa en la tónica, '
      '"cierra", como una respuesta—. Juntas forman un **período** de 8 '
      'compases.'),
    D('antecedente_consecuente',
      'El antecedente pregunta y deja la frase en el aire; el consecuente '
      'responde y la cierra.', 190),
    C('Por qué funciona', 'El oído reconoce enseguida "esto ya lo oí, pero '
      'ahora termina distinto". Repetición (el arranque igual) + contraste '
      '(el final): las dos fuerzas a la vez.'),
    T('## La "sentence" (frase-oración)'),
    T('Otra construcción clásica de 8 compases, muy usada por Mozart y '
      'Beethoven: **presentación** (2 compases con una idea básica + 2 '
      'compases repitiéndola, quizá transportada) → **continuación** '
      '(fragmentación y aceleración: trozos más cortos, armonía más rápida) '
      '→ **cadencia** (2 compases de cierre). Va de lo estable a lo '
      'inestable a la resolución.'),
    T('## Frases irregulares'),
    T('4 + 4 es el molde, no la ley. Las frases se **alargan** '
      '(prolongando una cadencia, repitiendo el final) o se **acortan** '
      '(elidiendo, empalmando el final de una con el principio de la '
      'siguiente). Una frase de 5 o de 7 compases bien hecha suena natural; '
      'lo importante es que el oído la perciba como una unidad.'),
  ],
  ['wiki-teoria-formas', 'wiki-teoria-armonia', 'wiki-comp-mozart']),


# =========================================================================
#  PARTE 3 · LA FORMA
# =========================================================================
M('formas-pequenas', 'La forma',
  'Formas pequeñas: binaria, ternaria, rondó, variaciones',
  'Cuatro moldes que resuelven cómo ordenar unas cuantas secciones para que '
  'una pieza breve tenga unidad y variedad.',
  [
    T('Cuando ya tienes un par de ideas contrastantes (llámalas **A** y '
      '**B**), necesitas un **plan** para ordenarlas. Estas son las plantas '
      'más habituales de la música breve.'),
    D('formas_pequenas',
      'Cuatro maneras de ordenar unas pocas secciones. A = idea principal, '
      'B y C = contrastes.', 210),
    T('## Binaria (A B)'),
    T('Dos secciones, a menudo con cada mitad repetida (‖: A :‖ ‖: B :‖). '
      'En la música barroca la sección A suele **modular** de la tónica a '
      'la dominante, y la B hace el **camino de vuelta**. Es la forma de '
      'casi todas las danzas de una suite.'),
    T('## Ternaria (A B A)'),
    T('Vas a un contraste y **regresas** al material inicial. El da capo del '
      'aria barroca, el minueto con su trío, el scherzo. La vuelta de A '
      'puede venir adornada o abreviada. Es la forma más "satisfactoria" '
      'para el oído: se cierra el círculo.'),
    T('## Rondó (A B A C A …)'),
    T('Un **estribillo** (A) que reaparece entre episodios distintos '
      '(B, C, D…). Da sensación de vuelta a casa una y otra vez; muy usado '
      'en finales alegres de sonatas y sinfonías.'),
    T('## Tema y variaciones'),
    T('Enuncias un **tema** y luego lo transformas una y otra vez '
      'conservando su esqueleto (su melodía, su bajo o su longitud). Cada '
      'variación cambia algo: el ritmo, el registro, el modo (mayor↔menor), '
      'la textura, el carácter.'),
    A('comp_tema', 'El tema (8 compases)'),
    A('comp_variacion', 'Una variación: la misma melodía, más adornada'),
    C('Cuando lo que se repite es el bajo', 'Si la idea fija es una línea '
      'de bajo corta que se repite sin parar y las variaciones ocurren '
      'encima, se llama **passacaglia** o **chacona** (el final de la 4.ª '
      'Sinfonía de Brahms, la Chacona para violín solo de Bach).'),
  ],
  ['wiki-teoria-formas', 'wiki-comp-haydn', 'wiki-comp-brahms']),


M('sonata', 'La forma',
  'La forma sonata: un argumento con la tonalidad',
  'El plan del primer movimiento clásico: plantea un conflicto de '
  'tonalidades, lo desarrolla y lo resuelve.',
  [
    T('La **forma sonata** es el plan más influyente de la música '
      'instrumental de los últimos 250 años: rige el primer movimiento de '
      'sonatas, cuartetos, sinfonías y conciertos. Su idea genial es '
      'convertir la **tonalidad en argumento dramático**.'),
    D('forma_sonata',
      'Tres grandes bloques. La exposición plantea una tensión de '
      'tonalidades; el desarrollo la agita; la reexposición la resuelve '
      'trayendo todo a la tónica.', 220),
    T('## Exposición'),
    L('**Primer tema**, en la tónica: enérgico, afirmativo.',
      '**Puente** (o transición): modula, lleva la música a otra tonalidad.',
      '**Segundo tema**, en la dominante (o en la relativa mayor si la obra '
      'es menor): más lírico, contrastante.',
      '**Codeta**: cierra la exposición con firmeza. Solía repetirse entera.'),
    T('## Desarrollo'),
    T('La zona de **máxima inestabilidad**. Los temas se **fragmentan**, se '
      '**combinan**, se llevan por tonalidades lejanas, se someten a '
      'secuencias y a contrapunto. No suele haber material nuevo: se '
      '"discute" el que ya conocemos. Termina en una **retransición** que '
      'prepara la vuelta, casi siempre sobre un pedal de dominante.'),
    T('## Reexposición'),
    T('Vuelven el primer tema, el puente y el segundo tema **en el mismo '
      'orden**, pero ahora **todo en la tónica**. Ese es el golpe maestro: '
      'la tensión estructural de la exposición (dos tonalidades en pugna) '
      'se **resuelve** al escuchar el segundo tema, por fin, en casa. Puede '
      'cerrar una **coda**.'),
    C('Escúchalo así', 'No sigas los temas como melodías bonitas: sigue '
      '**dónde está la música**. "Ya salimos de la tónica… estamos lejos… '
      'volvemos… y ahora esto que antes sonaba en otro tono suena en el de '
      'casa". Ese viaje es la obra.'),
  ],
  ['wiki-teoria-formas', 'wiki-historia-clasicismo', 'wiki-comp-beethoven']),


# =========================================================================
#  PARTE 4 · MELODÍA Y ARMONÍA
# =========================================================================
M('armonia', 'Melodía y armonía',
  'Armonía para componer: progresiones que funcionan',
  'No necesitas inventar acordes raros. Necesitas entender qué hace cada '
  'acorde y encadenarlos con dirección.',
  [
    T('Al componer, la armonía hace dos cosas: **sostiene** la melodía y '
      '**crea un discurso** de tensión y reposo. Para eso basta con pensar '
      'en **funciones**, no en acordes sueltos.'),
    D('funciones_tonales',
      'Cada acorde de la tonalidad cumple una función: reposo (tónica), '
      'alejamiento (subdominante) o tensión (dominante). El discurso típico '
      'va T → S → D → T.', 190),
    T('## Progresiones que casi siempre funcionan'),
    L('**I – V – vi – IV** — cuatro acordes que giran sin cerrar; base de '
      'cientos de canciones pop.',
      '**ii – V – I** — subdominante → dominante → tónica en su forma más '
      'pura; la célula del jazz.',
      '**I – vi – IV – V** — la progresión "de los 50", del doo-wop.',
      '**i – ♭VII – ♭VI – V** — la cadencia andaluza (LAm–SOL–FA–MI), de '
      'sabor español y flamenco.',
      '**I – IV – I – V** / **I – IV – V** — la lógica del blues y del rock '
      'primitivo.'),
    A('comp_prog_pop', 'I – V – vi – IV  (DO – SOL – LAm – FA)'),
    A('comp_prog_25', 'ii – V – I  (Dm7 – G7 – Cmaj7)'),
    A('comp_andaluza', 'Cadencia andaluza  (LAm – SOL – FA – MI)'),
    T('## El bajo es una melodía'),
    T('El error más común del principiante: mover los acordes "en bloque", '
      'todos a la vez, con el bajo saltando de fundamental en fundamental. '
      'Haz que **el bajo camine** por grados conjuntos siempre que puedas '
      '(usando inversiones), y que las voces internas se muevan poco. La '
      'armonía suena mil veces mejor solo con eso.'),
    T('## Ritmo armónico'),
    T('Es **cada cuánto cambia el acorde**. Un acorde por compás suena '
      'estable; dos por compás, más movido; medio compás cada cuatro '
      'compases, muy en calma. Acelerar el ritmo armónico hacia una '
      'cadencia aumenta la tensión; frenarlo relaja.'),
    D('circulo_quintas',
      'El círculo de quintas: tonalidades vecinas (a un paso) se diferencian '
      'en una sola alteración, y modular entre ellas suena natural.', 220),
  ],
  ['wiki-teoria-armonia', 'wiki-teoria-tonalidad', 'wiki-teoria-cifrado',
   'wiki-cur-progresion']),


M('cadencias', 'Melodía y armonía',
  'Cadencias: cómo puntuar la música',
  'Las cadencias son los signos de puntuación de la armonía: dicen si una '
  'frase termina, hace una pausa o se queda en el aire.',
  [
    T('Una **cadencia** es una fórmula de dos o tres acordes que marca el '
      'final de una frase. Elegir la cadencia adecuada es como elegir entre '
      'punto, coma o puntos suspensivos.'),
    D('cadencias',
      'Las tres cadencias sobre las que se construye casi todo el discurso '
      'tonal.', 180),
    T('## Las principales'),
    L('**Auténtica (V → I)** — el punto final. **Perfecta** si los dos '
      'acordes van en estado fundamental y la melodía cae en la tónica; '
      '**imperfecta** si hay inversiones o la melodía acaba en otra nota.',
      '**Plagal (IV → I)** — la cadencia "amén": más blanda, sin sensible. '
      'Buena para epílogos y codas.',
      '**Semicadencia (… → V)** — termina en la dominante. Deja la frase '
      '"abierta": es la coma. Cierra el antecedente de un período.',
      '**Rota o de engaño (V → vi)** — la dominante promete la tónica y '
      'entrega su sustituto. Aplaza el reposo; sirve para alargar una frase '
      'o crear sorpresa.',
      '**Frigia (iv⁶ → V, en menor)** — giro descendente, muy barroco, para '
      'enlazar hacia una sección en la dominante.'),
    A('cadencia_autentica', 'Cadencia auténtica  V – I'),
    A('cadencia_plagal', 'Cadencia plagal  IV – I'),
    A('cadencia_rota', 'Cadencia rota  V – vi'),
    C('Consejo de forma', 'Reserva la **auténtica perfecta** para los '
      'finales importantes (el de una sección, el de la obra). Si la usas en '
      'cada frase, la música suena a lista de puntos y pierde impulso. Para '
      'los finales de frase intermedios, usa semicadencias e imperfectas.'),
  ],
  ['wiki-teoria-armonia', 'wiki-teoria-cifrado', 'wiki-teoria-tonalidad']),


M('melodia', 'Melodía y armonía',
  'Cómo escribir una buena melodía',
  'Una melodía memorable tiene forma: un contorno claro, una nota más alta '
  'que las demás, tensión que se resuelve y sitio para respirar.',
  [
    T('No hay fórmula para "la melodía perfecta", pero las melodías que se '
      'recuerdan comparten rasgos concretos que sí se pueden trabajar.'),
    T('## Contorno'),
    T('El **dibujo** que traza la melodía en el aire. Cuatro perfiles '
      'básicos, que puedes combinar:'),
    D('contorno_melodico',
      'Arco (sube y baja), onda (ondula), escalera (asciende o desciende por '
      'grados) y zigzag (alterna saltos). Una buena melodía suele tener un '
      'contorno reconocible.', 210),
    L('**Arco** — sube hacia un punto y vuelve. El más natural para una '
      'frase cantada.',
      '**Onda** — ondula alrededor de una nota central; sensación de calma.',
      '**Escalera** — grados conjuntos en una dirección; sensación de '
      'esfuerzo o de meta.',
      '**Zigzag** — saltos alternos; enérgico, pero cansa si abusas.'),
    T('## La nota clímax'),
    T('Toda buena melodía tiene **una sola nota más alta**, y llega **una '
      'vez**, cerca de un punto fuerte de la frase (a menudo hacia sus dos '
      'tercios). Si tocas la nota más alta cinco veces, ninguna es el '
      'clímax. Guárdala.'),
    T('## Notas del acorde y notas de paso'),
    T('En los tiempos fuertes, apóyate en **notas del acorde** que suena '
      'debajo: dan estabilidad. Entre ellas, muévete con **notas de paso y '
      'floreos** por grados conjuntos: dan fluidez. Una melodía que solo usa '
      'notas del acorde suena a arpegio; una que las ignora, suena '
      'desafinada.'),
    A('comp_notas_paso', 'Primero solo notas del acorde; luego, con notas de '
      'paso'),
    T('## Tensión y reposo'),
    T('Aleja la melodía de la tónica para crear ganas de volver; acércala y '
      'resuélvela en la tónica para dar descanso. La **sensible** (el 7.º '
      'grado) "tira" hacia la tónica: úsala para prometer el final. Reserva '
      'la tónica en tiempo fuerte para los momentos de cierre.'),
    T('## Respiración'),
    T('Deja **silencios**. Una melodía sin huecos agobia y no se puede '
      'cantar. Piensa dónde respiraría alguien al cantarla, y pon ahí una '
      'nota larga o un silencio. Esos huecos son también donde el '
      'acompañamiento puede "contestar".'),
    C('Prueba de fuego', 'Si puedes **cantarla de memoria** al día '
      'siguiente de haberla escrito, vas bien. Si necesitas la partitura '
      'para recordarla, probablemente le falta forma.'),
  ],
  ['wiki-teoria-escalas', 'wiki-teoria-intervalos', 'wiki-teoria-ornamentacion',
   'wiki-cur-earworms']),


M('por-que-suenan', 'Melodía y armonía',
  'Por qué suenan bien los acordes',
  'La octava, la quinta y la tercera mayor no son un invento: están dentro '
  'de cada sonido, en la serie de armónicos.',
  [
    T('Cuando una cuerda o una columna de aire vibra, no suena a una sola '
      'frecuencia: suena la **fundamental** y, más flojos, sus múltiplos '
      'enteros. Esa colección es la **serie de armónicos**, y de ella sale '
      'buena parte de la armonía que usamos.'),
    D('serie_armonicos',
      'Los primeros armónicos de un DO grave. La naturaleza "regala", en '
      'este orden, la octava, la quinta y la tercera mayor.', 210),
    T('## Consonancia = proporción simple'),
    T('Dos notas suenan tanto más "fundidas" cuanto más simple es la '
      'proporción entre sus frecuencias: octava 2:1, quinta 3:2, cuarta '
      '4:3, tercera mayor 5:4. Son justo los primeros escalones de la '
      'serie. Las **disonancias** (segunda, séptima, tritono) tienen '
      'proporciones complejas y por eso "piden" resolver.'),
    C('Para componer', 'Si quieres un acorde estable y luminoso, apílalo con '
      'octavas, quintas y terceras mayores en el registro medio-agudo (como '
      'la serie). Si quieres tensión, mete segundas y séptimas cerca del '
      'grave, donde el oído las nota más ásperas.'),
    T('## El 7.º armónico y el temperamento'),
    T('Algunos armónicos no caen exactamente donde el piano los pondría: el '
      '7.º (un SI♭) suena 31 *cents* más bajo. Por eso el temperamento '
      'igual es un **compromiso**: afina todo un poco "mal" para que '
      'cualquier tonalidad sea usable. Al componer para voces o cuerdas, '
      'esa flexibilidad de afinación es una herramienta expresiva.'),
  ],
  ['wiki-teoria-acustica', 'wiki-teoria-intervalos', 'wiki-teoria-temperamento']),


M('modos-color', 'Melodía y armonía',
  'Modos y color: componer sin la dominante',
  'Cambiar la nota que actúa de centro cambia el "sabor" de las mismas '
  'siete notas. Los modos dan colores que la tonalidad mayor-menor no '
  'tiene.',
  [
    T('Un **modo** es una escala definida por la nota que se toma como '
      'centro. Con las mismas siete notas, según cuál sea la tónica, '
      'obtienes siete colores distintos.'),
    D('modos_brillo',
      'Los siete modos ordenados de más brillante (Lidio) a más oscuro '
      '(Locrio). Cada paso baja una nota un semitono. A la derecha, la nota '
      'que identifica cada modo.', 220),
    ESC(0, [2, 2, 2, 1, 2, 2, 1],
        'Modo lidio sobre DO (la 4ª sube: FA♯). Suena luminoso y suspendido.'),
    ESC(0, [2, 1, 2, 2, 2, 1, 2],
        'Modo dórico sobre DO (menor, pero con la 6ª mayor: LA natural).'),
    T('## Cómo componer modal'),
    L('**Pon un pedal** o un acorde que no se mueva: fija el centro. Sin '
      'él, el oído "recoloca" la tónica en el mayor o menor de siempre.',
      '**Empieza y reposa** en la tónica del modo.',
      '**Haz sonar mucho la nota característica** (la 4ª aumentada del '
      'lidio, la 2ª menor del frigio, la 7ª menor del mixolidio…), y en '
      'tiempo fuerte.',
      '**Evita la cadencia V–I funcional**: si fuerzas la sensible, '
      'destruyes el ambiente modal y vuelves a la tonalidad.'),
    C('Dónde se usa', 'Jazz modal (dórico en "So What"), folk celta '
      '(mixolidio), música española y flamenca (frigio, a menudo con la 3ª '
      'mayor), y bandas sonoras (el lidio para el asombro; el frigio y el '
      'locrio para la amenaza).'),
  ],
  ['wiki-teoria-modos', 'wiki-teoria-escalas', 'wiki-historia-jazz']),


# =========================================================================
#  PARTE 5 · RITMO Y TEXTURA
# =========================================================================
M('ritmo-groove', 'Ritmo y textura',
  'Ritmo y groove: construir por capas',
  'El ritmo se compone como la melodía: con un motivo, repetición, '
  'variación y tensión contra el compás.',
  [
    T('El **ritmo** tiene tres capas que conviene no mezclar: el **pulso** '
      '(la palpitación regular), el **compás** (cómo se agrupan los pulsos, '
      'con acentos fuertes y débiles) y el **ritmo** propiamente dicho (el '
      'patrón concreto de duraciones, que puede ir a favor o en contra del '
      'compás).'),
    T('## Un motivo rítmico'),
    T('Igual que hay motivos melódicos, hay **motivos rítmicos**: un patrón '
      'breve y reconocible (por ejemplo, "corchea con puntillo + '
      'semicorchea") que repites y varías a lo largo de la pieza. Da unidad '
      'aunque cambien las notas.'),
    T('## Tensión contra el compás'),
    L('**Síncopa** — una nota empieza en parte débil y se prolonga sobre la '
      'fuerte siguiente, robándole el acento.',
      '**Contratiempo** — atacas la parte débil y dejas la fuerte en '
      'silencio.',
      '**Anacrusa** — una o más notas débiles antes del primer tiempo '
      'fuerte; da impulso al arranque.',
      '**Hemiola** — durante unos compases el ritmo suena en 3 donde el '
      'compás dice 2 (o al revés).',
      '**Ostinato** — un patrón corto que se repite sin cambiar, como base '
      'sobre la que ocurre lo demás.'),
    C('El groove', 'En la música popular, el "groove" es el encaje exacto '
      'entre bajo y batería, con micro-adelantos y micro-retrasos '
      'deliberados. Se construye **por capas**: primero el bombo y la caja, '
      'luego el bajo (dialogando con el bombo), luego el resto. Si el '
      'esqueleto de dos capas ya mueve el pie, vas bien.'),
    T('## Compases irregulares'),
    T('5/8, 7/8, 5/4… suman grupos desiguales de 2 y 3 (un 7/8 puede ser '
      '2+2+3). Muy usados en la música balcánica, en Bartók y en el rock '
      'progresivo. Para componerlos, siente la agrupación (LARGO-corto-'
      'corto…), no cuentes las corcheas una a una.'),
  ],
  ['wiki-teoria-ritmo', 'wiki-historia-jazz', 'wiki-danza-social-latina']),


M('textura', 'Ritmo y textura',
  'Textura y acompañamiento',
  'Cuántas voces suenan a la vez y qué hace cada una: melodía, bajo, '
  'armonía y ritmo son cuatro papeles, no cuatro instrumentos.',
  [
    T('La **textura** es el "tejido" del sonido: cuántas líneas suenan a la '
      'vez y qué relación tienen. Cambiar de textura es uno de los recursos '
      'más eficaces para articular una forma.'),
    T('## Los cuatro papeles'),
    T('En casi cualquier arreglo hay cuatro funciones, que pueden repartirse '
      'entre pocos o muchos instrumentos:'),
    L('**Melodía** — la línea principal.',
      '**Bajo** — la nota más grave; define el acorde y camina como una '
      'segunda melodía.',
      '**Armonía** — las notas que rellenan el acorde (acordes tenidos, '
      'pads, guitarra rasgueada).',
      '**Ritmo** — la capa que marca el pulso y el groove (batería, '
      'percusión, un patrón repetido).'),
    T('## Tipos de acompañamiento'),
    L('**Acordes en bloque** — todo el acorde a la vez; sencillo y sólido.',
      '**Bajo de Alberti** — el acorde desplegado en un patrón fijo '
      '(grave-agudo-medio-agudo); el sonido del Clasicismo.',
      '**Arpegios** — el acorde nota a nota; fluido, "de guitarra".',
      '**Contrapunto simple** — una segunda voz con vida melódica propia '
      'que dialoga con la melodía.',
      '**Pedal / drone** — una nota fija sostenida bajo todo lo demás.'),
    T('## Densidad como recurso'),
    T('Empieza con poco (voz y un instrumento), añade capas hacia el '
      'estribillo o el clímax, y **quita capas** en un puente o una estrofa '
      'íntima. El contraste de densidad cuenta tanto como el de melodía.'),
    D('formas_pequenas',
      'La textura suele cambiar entre secciones: A más llena, B más '
      'desnuda, y así se marca la forma.', 210),
  ],
  ['wiki-teoria-textura', 'wiki-teoria-contrapunto', 'wiki-teoria-timbre']),


# =========================================================================
#  PARTE 6 · EL OFICIO
# =========================================================================
M('desarrollar', 'El oficio',
  'Desarrollar y variar: alargar una idea sin aburrir',
  'El problema real de componer no es tener ideas: es hacer que una idea '
  'dure tres minutos sin cansar.',
  [
    T('Tienes ocho compases que te gustan. ¿Cómo llegas a una pieza? '
      'Con las tres fuerzas de siempre —repetición, contraste, variación— '
      'y unas cuantas técnicas concretas para estirar el material.'),
    T('## Repetir con cambio'),
    T('La regla práctica: **nunca repitas algo exactamente más de una '
      'vez**. A la tercera, cambia algo: sube una octava, cambia la '
      'armonía debajo, añade un instrumento, quita uno, varía el final. El '
      'oído quiere reconocer y a la vez que le sorprendan un poco.'),
    T('## Técnicas de desarrollo'),
    L('**Secuencia** — repite el motivo subiendo o bajando por grados.',
      '**Fragmentación** — quédate con un trozo del motivo y repítelo, cada '
      'vez más corto: acelera la sensación.',
      '**Ampliación** — alarga una nota o un salto; hace la idea más '
      'grande.',
      '**Combinar motivos** — haz sonar dos ideas de la pieza a la vez.',
      '**Cambio de modo** — pasa la idea de mayor a menor (o al revés).',
      '**Re-armonización** — la misma melodía sobre acordes distintos.',
      '**Inversión / retrogradación** — la idea del revés.'),
    T('## Transición y retransición'),
    T('Entre dos secciones estables hace falta un puente **inestable**: '
      'armonía que modula, ritmo que se agita, dinámica que crece o '
      'decrece. Y antes de que vuelva una sección importante, una '
      '**retransición** que prepare la vuelta (a menudo un pedal de '
      'dominante y un *crescendo*). Los puentes son donde se nota el oficio.'),
    C('Cuándo parar', 'Una sección ha durado lo suficiente cuando el oyente '
      'empieza a anticipar lo que viene. Ahí, cambia. Es mejor quedarse '
      'corto que largo.'),
  ],
  ['wiki-teoria-formas', 'wiki-comp-beethoven', 'wiki-comp-brahms']),


M('orquestacion', 'El oficio',
  'Arreglo y orquestación: quién toca qué',
  'La misma música suena transparente o embarrada según cómo la repartas '
  'entre los instrumentos y las octavas.',
  [
    T('**Orquestar** (o arreglar) es decidir qué instrumento toca cada '
      'cosa, en qué octava, cuándo entra y cuándo calla. Un mismo acorde '
      'de cuatro notas puede sonar cristalino o compacto según cómo lo '
      'dispongas.'),
    T('## Principios básicos'),
    L('**Registro** — cada instrumento tiene una zona cómoda y varias con '
      'color propio. Escribir fuera de ella suena forzado (a veces lo '
      'quieres).',
      '**Espaciado** — deja más aire entre las voces graves y júntalas más '
      'arriba (como la serie de armónicos). Voces graves apretadas = barro.',
      '**Doblar** — dos instrumentos en la misma línea la refuerzan; a la '
      'octava, la ensanchan; una crea un color mixto nuevo.',
      '**Tutti y solo** — no lo toques todo siempre. Guarda el "todos a la '
      'vez" para los clímax; un solo desnudo destaca por contraste.',
      '**Melodía por encima** — normalmente la melodía debe ser la voz más '
      'aguda, o destacar por timbre y dinámica si va en medio.'),
    T('## Transparencia'),
    T('Si algo no se oye, casi nunca es cuestión de subir el volumen: es '
      'que otra cosa ocupa su mismo registro. **Haz sitio**: sube o baja '
      'una línea de octava, adelgaza el acompañamiento, silencia lo que no '
      'aporte en ese momento. Menos capas bien colocadas ganan a muchas '
      'amontonadas.'),
    C('En el ordenador', 'Todo esto vale igual con instrumentos virtuales: '
      'los mismos principios de registro, espaciado y "hacer sitio" '
      'deciden que una maqueta suene profesional o a demo.'),
  ],
  ['wiki-teoria-timbre', 'wiki-inst-familias', 'wiki-prod-mezcla']),


M('gran-escala', 'El oficio',
  'La forma a gran escala y cómo terminar',
  'Introducción, desarrollo, clímax y coda: una pieza necesita un plan de '
  'proporciones y un punto de máxima intensidad.',
  [
    T('Más allá de la frase y la sección, una pieza necesita un **plano '
      'general**: por dónde empieza, hacia dónde va y cómo cierra.'),
    T('## Las partes de una pieza'),
    L('**Introducción** — prepara el ambiente, la tonalidad, el tempo. '
      'Puede ser un compás o una sección entera. Opcional.',
      '**Cuerpo** — la exposición y el desarrollo del material (tus '
      'secciones A, B, C…).',
      '**Clímax** — el punto de **máxima intensidad**: suele estar hacia '
      'los dos tercios de la pieza, no en el centro ni al final. Se llega '
      'con registro agudo, dinámica fuerte, densidad máxima o ritmo '
      'armónico rápido.',
      '**Coda** — el cierre: confirma la tónica, baja la energía, deja al '
      'oyente en reposo. Una cadencia plagal o un pedal de tónica van bien '
      'aquí.'),
    T('## Proporciones'),
    T('Evita que todas las secciones duren lo mismo: cansa. Alarga la que '
      'lleva el peso dramático, acorta las de transición. Un recurso '
      'clásico es hacer cada sección algo más corta que la anterior hacia '
      'el final, para acelerar la sensación.'),
    T('## Cómo terminar'),
    L('**Cadencia auténtica perfecta** en la tónica: el final "de '
      'concierto".',
      '**Fundido** (*fade out*): recurso de estudio, no de partitura.',
      '**Final abierto**: acabar sin resolver, en una disonancia o en la '
      'dominante; deja inquietud.',
      '**Vuelta al principio**: cerrar con el material de la introducción, '
      'para dar sensación de círculo.'),
    C('Error común', 'No sabes cómo terminar porque la pieza en realidad ya '
      'había terminado dos minutos antes. Si te cuesta cerrar, prueba a '
      'recortar: quizá el final estaba antes de lo que creías.'),
  ],
  ['wiki-teoria-formas', 'wiki-comp-mahler', 'wiki-tm-estructura']),


M('formas-populares', 'El oficio',
  'Formas de la canción popular',
  'El blues de 12 compases, el AABA de 32, la estructura estrofa-'
  'estribillo-puente y el "drop": moldes con nombre para la música de hoy.',
  [
    T('La música popular tiene sus propios moldes de forma, tan '
      'establecidos como la sonata en su época. Conocerlos te ahorra '
      'reinventar la rueda.'),
    T('## Blues de 12 compases'),
    T('Doce compases con un esquema de acordes casi fijo: '
      '**I-I-I-I / IV-IV-I-I / V-IV-I-V**. La letra suele ser **AAB** '
      '(una frase, la misma frase, y una que responde). Base del blues, '
      'gran parte del rock and roll y muchos temas de jazz.'),
    T('## Forma de 32 compases (AABA)'),
    T('Cuatro secciones de 8 compases: **A** (el tema principal), **A** '
      '(igual, con final distinto), **B** (el "puente" o *bridge*: '
      'contrasta, suele modular) y **A** (vuelve el tema). Es el molde de '
      'los estándares de Tin Pan Alley y del *Great American Songbook*.'),
    T('## Estrofa – estribillo – puente'),
    T('La forma dominante del pop y el rock modernos: **estrofa** (avanza '
      'la historia, melodía más hablada), **pre-estribillo** (opcional, '
      'sube la tensión), **estribillo** (el gancho, lo que se repite y se '
      'recuerda), y un **puente** hacia el final que contrasta antes del '
      'último estribillo. Muchas veces el último estribillo sube medio '
      'tono.'),
    T('## El "drop" y el gancho'),
    T('En la electrónica de baile, la estructura gira en torno a la '
      'tensión: **build-up** (todo crece y se filtra) → **drop** (entra el '
      'groove completo y el bajo). En toda la música popular manda el '
      '**hook**: la frase de 2-4 segundos —melódica, rítmica o de '
      'producción— que se te queda pegada.'),
    C('Consejo', 'Elige el molde antes de escribir la letra entera: saber '
      'que "aquí va el estribillo y tiene que ser lo más pegadizo" cambia '
      'cómo escribes todo lo demás.'),
  ],
  ['wiki-teoria-formas', 'wiki-historia-popular', 'wiki-historia-jazz',
   'wiki-cur-progresion']),


M('rutina', 'El oficio',
  'Una rutina para componer',
  'Componer es un hábito, no un rayo de inspiración. Estas costumbres '
  'ayudan a empezar, a avanzar y —lo más difícil— a terminar.',
  [
    T('La inspiración existe, pero llega **mientras trabajas**, no antes. '
      'Estas son costumbres que usan muchos compositores para que aparezca '
      'más a menudo.'),
    L('**Ponte un límite y un temporizador.** "20 minutos, 8 compases, '
      'solo escala de SOL". El límite mata la página en blanco.',
      '**Boceta rápido y feo.** Primero cantidad, luego calidad. No '
      'juzgues mientras generas; ya filtrarás después.',
      '**Tócalo y cántalo en voz alta.** Lo que suena bien en la cabeza a '
      'veces no funciona; el cuerpo detecta lo que no fluye.',
      '**Grábate.** Un móvil basta. Las mejores ideas se olvidan en diez '
      'minutos.',
      '**Déjalo reposar.** Vuelve al día siguiente: oirás con claridad qué '
      'sobra y qué falta.',
      '**Roba estructuras, no notas.** Analiza una canción que te guste, '
      'copia su forma y sus proporciones, y rellénala con tu material.',
      '**Pide oídos.** Enseña un boceto a alguien y mira su cara en el '
      'segundo 20, no lo que te diga después.',
      '**Termina.** Una pieza acabada y regular enseña más que diez '
      'geniales a medias. Ponte una fecha y entrega.'),
    C('Cuando te atascas', 'Vuelve a tu motivo y aplícale una '
      'transformación de la lista del módulo 2. O cambia una restricción: '
      'otro compás, otro tempo, otra tónica. El bloqueo casi siempre es '
      'tener demasiadas opciones abiertas.'),
  ],
  ['wiki-historia-teoria-evolucion', 'wiki-comp-boulanger', 'wiki-mitos-genio']),


# =========================================================================
def main():
    data = {
        '_schema': 'composicion/1 — curso de la sección Componer',
        'modulos': MODULOS,
    }
    with open(RUTA, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    nb = sum(len(m['bloques']) for m in MODULOS)
    print(f'{len(MODULOS)} módulos, {nb} bloques -> {os.path.normpath(RUTA)}')


if __name__ == '__main__':
    main()
