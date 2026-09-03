// ===========================================================================
//  pantalla_leccion.dart — lecciones por nivel (casillas desplegables) y
//  ejecución de una lección: intro -> ejercicios -> resultado.
// ===========================================================================

import 'dart:convert';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'animaciones.dart';
import 'bloques_didacticos.dart';
import 'ejercicio.dart';
import 'gamificacion.dart';
import 'progreso.dart';
import 'ruta_pasos.dart';
import 'tema.dart';
import 'tutorial.dart';

// ---------------------------------------------------------------------------
//  Modelo
// ---------------------------------------------------------------------------
class Leccion {
  final String id;
  final int nivel;
  final String titulo;
  final String objetivo;
  // Bloques de la introducción didáctica (los renderiza VisorBloques):
  //   texto / clave / lista / tabla / pasos / diagrama / escala / nota / audio.
  // Ver bloques_didacticos.dart para la forma de cada uno.
  final List<Map<String, dynamic>> intro;
  final List<Ejercicio> ejercicios;

  Leccion({
    required this.id,
    required this.nivel,
    required this.titulo,
    required this.objetivo,
    required this.intro,
    required this.ejercicios,
  });

  factory Leccion.fromJson(Map<String, dynamic> j) {
    final raw = (j['intro'] as List?) ?? const [];
    final intro = <Map<String, dynamic>>[
      for (final b in raw)
        if (b is String)
          {'tipo': 'texto', 'texto': b}
        else
          (b as Map<String, dynamic>),
    ];
    return Leccion(
      id: j['id'] as String,
      nivel: (j['nivel'] as num?)?.toInt() ?? 1,
      titulo: j['titulo'] as String,
      objetivo: j['objetivo'] as String? ?? '',
      intro: intro,
      ejercicios: (j['ejercicios'] as List)
          .map((e) => Ejercicio.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

Future<List<Leccion>> cargarLecciones() async {
  final texto = await rootBundle.loadString('assets/content/lecciones.json');
  final data = jsonDecode(texto) as Map<String, dynamic>;
  final lista = (data['lecciones'] as List)
      .map((l) => Leccion.fromJson(l as Map<String, dynamic>))
      .toList();
  lista.sort((a, b) {
    final n = a.nivel.compareTo(b.nivel);
    return n != 0 ? n : a.id.compareTo(b.id);
  });
  return lista;
}

// ---------------------------------------------------------------------------
//  Lista de lecciones (casillas por nivel)
// ---------------------------------------------------------------------------
class PantallaListaLecciones extends StatefulWidget {
  const PantallaListaLecciones({super.key});

  @override
  State<PantallaListaLecciones> createState() => _PantallaListaLeccionesState();
}

class _PantallaListaLeccionesState extends State<PantallaListaLecciones> {
  List<Leccion> lecciones = [];
  Set<String> completadas = {};
  bool cargando = true;

  static const _nombresNivel = {
    1: 'Fundamentos',
    2: 'Tonalidades y armaduras',
    3: 'Dominio de la escala',
    4: 'Menores y modos',
    5: 'Aplicación e improvisación',
  };

  @override
  void initState() {
    super.initState();
    _cargar();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) mostrarTutorial(context, 'lecciones', tutLecciones);
    });
  }

  Future<void> _cargar() async {
    final l = await cargarLecciones();
    final c = await Progreso.cargar();
    setState(() {
      lecciones = l;
      completadas = c;
      cargando = false;
    });
  }

  Future<void> _abrir(Leccion l) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PantallaLeccion(leccion: l)),
    );
    _cargar(); // refrescar ✓ al volver
  }

  @override
  Widget build(BuildContext context) {
    final acento = Theme.of(context).colorScheme.primary;
    final niveles = lecciones.map((l) => l.nivel).toSet().toList()..sort();
    final pendiente = lecciones
        .cast<Leccion?>()
        .firstWhere((l) => !completadas.contains(l!.id), orElse: () => null);

    return Scaffold(
      appBar: AppBar(title: const Text('Lecciones'), centerTitle: true),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.only(
                  bottom: 24 + MediaQuery.paddingOf(context).bottom),
              children: [
                for (final nivel in niveles)
                  _CasillaNivelLecciones(
                    nivel: nivel,
                    nombre: _nombresNivel[nivel] ?? '',
                    acento: acento,
                    lecciones:
                        lecciones.where((l) => l.nivel == nivel).toList(),
                    completadas: completadas,
                    pendienteId: pendiente?.id,
                    onAbrir: _abrir,
                    abiertoInicial: nivel == niveles.first,
                  ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

class _CasillaNivelLecciones extends StatefulWidget {
  final int nivel;
  final String nombre;
  final Color acento;
  final List<Leccion> lecciones;
  final Set<String> completadas;
  final String? pendienteId;
  final void Function(Leccion) onAbrir;
  final bool abiertoInicial;

  const _CasillaNivelLecciones({
    required this.nivel,
    required this.nombre,
    required this.acento,
    required this.lecciones,
    required this.completadas,
    required this.pendienteId,
    required this.onAbrir,
    required this.abiertoInicial,
  });

  @override
  State<_CasillaNivelLecciones> createState() => _CasillaNivelLeccionesState();
}

class _CasillaNivelLeccionesState extends State<_CasillaNivelLecciones> {
  late bool _abierto = widget.abiertoInicial;

  @override
  Widget build(BuildContext context) {
    final hechas =
        widget.lecciones.where((l) => widget.completadas.contains(l.id)).length;
    final total = widget.lecciones.length;
    final completo = hechas == total;
    final acento = widget.acento;

    final pasos = <Paso>[
      for (final l in widget.lecciones)
        Paso(
          estado: widget.completadas.contains(l.id)
              ? EstadoPaso.completado
              : l.id == widget.pendienteId
                  ? EstadoPaso.actual
                  : EstadoPaso.disponible,
          icono: widget.completadas.contains(l.id) ? null : Icons.menu_book,
          onTap: () => widget.onAbrir(l),
        ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        color: context.pal.superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.pal.borde),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _abierto = !_abierto),
            child: Container(
              color: (completo ? const Color(0xFF16A34A) : acento)
                  .withValues(alpha: 0.12),
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        completo ? const Color(0xFF16A34A) : acento,
                    foregroundColor: Colors.white,
                    child: completo
                        ? const Icon(Icons.check, size: 18)
                        : Text('${widget.nivel}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NIVEL ${widget.nivel} · ${widget.nombre.toUpperCase()}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12.5),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: total == 0 ? 0 : hechas / total,
                          minHeight: 5,
                        ),
                        const SizedBox(height: 2),
                        Text('$hechas / $total',
                            style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  Icon(_abierto ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_abierto) ...[
            RutaPasos(pasos: pasos, acento: acento),
            // etiquetas de las lecciones bajo la ruta
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  for (var k = 0; k < widget.lecciones.length; k++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text('${k + 1}. ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: context.pal.textoTenue)),
                          Expanded(
                            child: Text(widget.lecciones[k].titulo,
                                style: const TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Ejecución de una lección
// ---------------------------------------------------------------------------
class PantallaLeccion extends StatefulWidget {
  final Leccion leccion;
  const PantallaLeccion({super.key, required this.leccion});

  @override
  State<PantallaLeccion> createState() => _PantallaLeccionState();
}

class _PantallaLeccionState extends State<PantallaLeccion> {
  int indice = -1; // -1 = intro, 0..n-1 = ejercicios, n = resultado
  int aciertos = 0;
  int evaluados = 0;
  bool _guardada = false;

  final _confeti =
      ConfettiController(duration: const Duration(milliseconds: 900));

  List<Ejercicio> get ejercicios => widget.leccion.ejercicios;

  @override
  void dispose() {
    _confeti.dispose();
    super.dispose();
  }

  void _terminado(bool acierto) {
    final e = ejercicios[indice];
    setState(() {
      if (e.soportado) {
        evaluados++;
        if (acierto) aciertos++;
      }
      indice++;
    });
    if (indice >= ejercicios.length && !_guardada) {
      _guardada = true;
      Progreso.marcarCompletado(widget.leccion.id);
      Gamificacion.leccionCompletada().then((nuevos) {
        if (mounted) avisarLogros(context, nuevos);
      });
      _confeti.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.leccion;

    if (indice == -1) {
      return Scaffold(
        appBar: AppBar(title: Text(l.titulo)),
        body: ListView(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, 20 + MediaQuery.paddingOf(context).bottom),
          children: [
            Text(l.objetivo,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700, height: 1.35)),
            const SizedBox(height: 16),
            VisorBloques(bloques: l.intro),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              style:
                  FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: () => setState(() => indice = 0),
              child: const Text('EMPEZAR'),
            ),
          ),
        ),
      );
    }

    if (indice >= ejercicios.length) {
      return Scaffold(
        appBar: AppBar(title: Text(l.titulo)),
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Latido(
                    max: 1.12,
                    child: Icon(Icons.emoji_events,
                        size: 84, color: context.pal.aviso),
                  ),
                  const SizedBox(height: 12),
                  Text('¡Lección completada!',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Aciertos: $aciertos / $evaluados'),
                  Text('XP: ${aciertos * 10}',
                      style: TextStyle(
                          color: context.pal.exito, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  BotonRebote(
                    onTap: () => Navigator.pop(context),
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Volver'),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confeti,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 26,
                maxBlastForce: 22,
                gravity: 0.28,
                colors: [context.pal.acento, context.pal.exito, context.pal.aviso, Colors.white],
              ),
            ),
          ],
        ),
      );
    }

    final e = ejercicios[indice];
    return Scaffold(
      appBar: AppBar(
        title: LinearProgressIndicator(
          value: (indice + 1) / ejercicios.length,
        ),
      ),
      body: VistaEjercicio(
        key: ValueKey('lec-${l.id}-$indice'),
        ejercicio: e,
        esUltimo: indice + 1 >= ejercicios.length,
        etiquetaFinal: 'VER RESULTADO',
        onTerminado: _terminado,
      ),
    );
  }
}
