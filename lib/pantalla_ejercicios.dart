// ===========================================================================
//  pantalla_ejercicios.dart — el "recorrido" de ejercicios de una materia
//  (escalas, solfeo...). Cada ejercicio es un escalón en una ruta visual.
//  · Progreso guardado; "Continuar recorrido" salta al primer pendiente.
//  · Cada nivel: banner + teoría (hoja) + ruta de escalones.
//  · Reiniciar recorrido (solo el de ESTA materia).
// ===========================================================================

import 'dart:convert';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'animaciones.dart';
import 'ejercicio.dart';
import 'gamificacion.dart';
import 'progreso.dart';
import 'ruta_pasos.dart';
import 'tema.dart';

// ---------------------------------------------------------------------------
//  Una materia = un archivo de ejercicios + cómo se llaman sus niveles.
// ---------------------------------------------------------------------------
class Materia {
  final String titulo;
  final String assetPath;
  final Map<int, String> nombresNivel;

  const Materia({
    required this.titulo,
    required this.assetPath,
    required this.nombresNivel,
  });
}

const materiaEscalas = Materia(
  titulo: 'Ejercicios · Escalas',
  assetPath: 'assets/content/ejercicios_escalas.json',
  nombresNivel: {
    1: 'Fundamentos',
    2: 'Tonalidades y armaduras',
    3: 'Dominio de la escala',
    4: 'Menores y modos',
    5: 'Aplicación e improvisación',
  },
);

const materiaSolfeo = Materia(
  titulo: 'Ejercicios · Solfeo',
  assetPath: 'assets/content/ejercicios_solfeo.json',
  nombresNivel: {
    1: 'Sonido y pentagrama',
    2: 'Lectura de notas',
    3: 'Figuras y valores',
    4: 'El compás',
    5: 'Alteraciones y matices',
  },
);

class _CargaMateria {
  final List<Ejercicio> ejercicios;
  final Map<int, List<String>> teoria;
  _CargaMateria(this.ejercicios, this.teoria);
}

Future<_CargaMateria> _cargarMateria(String assetPath) async {
  final texto = await rootBundle.loadString(assetPath);
  final data = jsonDecode(texto) as Map<String, dynamic>;
  final lista = (data['ejercicios'] as List)
      .map((e) => Ejercicio.fromJson(e as Map<String, dynamic>))
      .toList();
  lista.sort((a, b) {
    final n = a.nivel.compareTo(b.nivel);
    return n != 0 ? n : a.id.compareTo(b.id);
  });
  final teoriaRaw = data['teoria'] as Map<String, dynamic>? ?? {};
  final teoria = <int, List<String>>{
    for (final entry in teoriaRaw.entries)
      int.parse(entry.key):
          (entry.value as List).map((x) => x as String).toList(),
  };
  return _CargaMateria(lista, teoria);
}

// ---------------------------------------------------------------------------
//  Pantalla principal
// ---------------------------------------------------------------------------
class PantallaEjercicios extends StatefulWidget {
  final Materia materia;
  const PantallaEjercicios({super.key, required this.materia});

  @override
  State<PantallaEjercicios> createState() => _PantallaEjerciciosState();
}

class _PantallaEjerciciosState extends State<PantallaEjercicios> {
  List<Ejercicio> lista = [];
  Map<int, List<String>> teoria = {};
  Set<String> completados = {};
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final m = await _cargarMateria(widget.materia.assetPath);
    final c = await Progreso.cargar();
    setState(() {
      lista = m.ejercicios;
      teoria = m.teoria;
      completados = c;
      cargando = false;
    });
  }

  int get _primerPendiente {
    for (var i = 0; i < lista.length; i++) {
      if (!completados.contains(lista[i].id)) return i;
    }
    return lista.length;
  }

  Future<void> _correrDesde(int inicio) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CorrerEjercicios(lista: lista, inicio: inicio),
      ),
    );
    _cargar();
  }

  Future<void> _confirmarReinicio() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reiniciar recorrido'),
        content: Text(
            'Se borrará tu progreso en "${widget.materia.titulo}" (el de otras secciones no se toca). ¿Continuar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reiniciar')),
        ],
      ),
    );
    if (ok == true) {
      await Progreso.reiniciar(lista.map((e) => e.id));
      _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final acento = Theme.of(context).colorScheme.primary;
    final hechos = lista.where((e) => completados.contains(e.id)).length;
    final total = lista.length;
    final pendiente = _primerPendiente;
    final niveles = lista.map((e) => e.nivel).toSet().toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.materia.titulo),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Reiniciar recorrido',
            icon: const Icon(Icons.restart_alt),
            onPressed: _confirmarReinicio,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$hechos / $total completados',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('${(total == 0 ? 0 : hechos * 100 ~/ total)} %'),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : hechos / total,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed:
                      pendiente >= total ? null : () => _correrDesde(pendiente),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(pendiente >= total
                      ? '¡Recorrido completo!'
                      : 'Continuar recorrido'),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(46)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom),
              children: [
                for (final nivel in niveles)
                  _CasillaNivel(
                    nivel: nivel,
                    nombre: widget.materia.nombresNivel[nivel] ?? '',
                    teoria: teoria[nivel] ?? const [],
                    acento: acento,
                    primerPendiente: pendiente,
                    ejercicios: [
                      for (var i = 0; i < lista.length; i++)
                        if (lista[i].nivel == nivel) (i, lista[i]),
                    ],
                    completados: completados,
                    onAbrir: _correrDesde,
                    abiertoInicial: nivel == niveles.first,
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Un nivel: banner + teoría + ruta de escalones
// ---------------------------------------------------------------------------
class _CasillaNivel extends StatefulWidget {
  final int nivel;
  final String nombre;
  final List<String> teoria;
  final Color acento;
  final int primerPendiente;
  final List<(int, Ejercicio)> ejercicios;
  final Set<String> completados;
  final void Function(int indiceGlobal) onAbrir;
  final bool abiertoInicial;

  const _CasillaNivel({
    required this.nivel,
    required this.nombre,
    required this.teoria,
    required this.acento,
    required this.primerPendiente,
    required this.ejercicios,
    required this.completados,
    required this.onAbrir,
    required this.abiertoInicial,
  });

  @override
  State<_CasillaNivel> createState() => _CasillaNivelState();
}

class _CasillaNivelState extends State<_CasillaNivel> {
  late bool _abierto = widget.abiertoInicial;

  void _verTeoria() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.8,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.fromLTRB(
              20, 0, 20, 28 + MediaQuery.paddingOf(ctx).bottom),
          children: [
            Text('Nivel ${widget.nivel} · ${widget.nombre}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            const Text('Teoría',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final p in widget.teoria)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(p, style: const TextStyle(height: 1.4)),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hechos = widget.ejercicios
        .where((p) => widget.completados.contains(p.$2.id))
        .length;
    final total = widget.ejercicios.length;
    final completo = hechos == total;
    final acento = widget.acento;

    final pasos = <Paso>[
      for (var k = 0; k < widget.ejercicios.length; k++)
        () {
          final (indiceGlobal, e) = widget.ejercicios[k];
          final done = widget.completados.contains(e.id);
          final actual = indiceGlobal == widget.primerPendiente;
          return Paso(
            estado: done
                ? EstadoPaso.completado
                : actual
                    ? EstadoPaso.actual
                    : EstadoPaso.disponible,
            numero: k + 1,
            onTap: () => widget.onAbrir(indiceGlobal),
          );
        }(),
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
          // ---- Banner del nivel ----
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
                          value: total == 0 ? 0 : hechos / total,
                          minHeight: 5,
                        ),
                        const SizedBox(height: 2),
                        Text('$hechos / $total',
                            style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  if (widget.teoria.isNotEmpty)
                    IconButton(
                      tooltip: 'Teoría del nivel',
                      icon: const Icon(Icons.menu_book),
                      onPressed: _verTeoria,
                    ),
                  Icon(_abierto ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          // ---- Ruta de escalones ----
          if (_abierto) RutaPasos(pasos: pasos, acento: acento),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Runner: va pasando ejercicios uno tras otro desde 'inicio'.
// ---------------------------------------------------------------------------
class _CorrerEjercicios extends StatefulWidget {
  final List<Ejercicio> lista;
  final int inicio;
  const _CorrerEjercicios({required this.lista, required this.inicio});

  @override
  State<_CorrerEjercicios> createState() => _CorrerEjerciciosState();
}

class _CorrerEjerciciosState extends State<_CorrerEjercicios> {
  late int i = widget.inicio;
  int aciertos = 0;
  final _confeti =
      ConfettiController(duration: const Duration(milliseconds: 900));

  @override
  void dispose() {
    _confeti.dispose();
    super.dispose();
  }

  Future<void> _terminado(bool acierto) async {
    if (acierto) {
      await Progreso.marcarCompletado(widget.lista[i].id);
      aciertos++;
      final nuevos = await Gamificacion.ejercicioAcertado();
      if (mounted) avisarLogros(context, nuevos);
    }
    if (!mounted) return;
    setState(() => i++);
    if (i >= widget.lista.length) _confeti.play();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.lista.length;

    if (i >= total) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recorrido')),
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Latido(
                    max: 1.12,
                    child: Icon(Icons.check_circle,
                        size: 84, color: context.pal.exito),
                  ),
                  const SizedBox(height: 12),
                  Text('¡Terminaste todos!',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Acertaste $aciertos en esta sesión.'),
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

    final e = widget.lista[i];
    return Scaffold(
      appBar: AppBar(
        title: Text('Ejercicio ${i + 1} / $total'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (i + 1) / total,
          ),
        ),
      ),
      body: VistaEjercicio(
        key: ValueKey(e.id),
        ejercicio: e,
        esUltimo: i + 1 >= total,
        etiquetaFinal: 'TERMINAR',
        onTerminado: _terminado,
      ),
    );
  }
}
