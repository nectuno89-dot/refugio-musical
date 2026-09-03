// ===========================================================================
//  tutorial.dart — mini-tutorial en diapositivas que aparece la primera vez
//  que se abre una pantalla. Se cierra con "Entendido" o "Saltar", y tiene un
//  enlace para desactivar todos los tutoriales.
// ===========================================================================

import 'package:flutter/material.dart';

import 'animaciones.dart';
import 'onboarding.dart';
import 'tema.dart';

class PasoTutorial {
  final IconData icono;
  final String titulo;
  final String texto;
  const PasoTutorial(this.icono, this.titulo, this.texto);
}

// ---------------------------------------------------------------------------
//  Contenido de los tutoriales (también se pueden reproducir desde Ajustes).
// ---------------------------------------------------------------------------
const tutInicio = <PasoTutorial>[
  PasoTutorial(Icons.self_improvement, 'Bienvenido a tu refugio musical',
      'Aquí tienes todo para aprender música desde cero: lecciones guiadas, '
      'ejercicios, un explorador de escalas y una wiki enorme.'),
  PasoTutorial(Icons.school, 'Empieza por las Lecciones',
      'Están las primeras de la lista. Te explican cada idea paso a paso, con '
      'ejemplos que suenan. Cuando termines una, practica con los ejercicios.'),
  PasoTutorial(Icons.bolt, 'A tu ritmo',
      'Tu progreso se guarda solo. Puedes volver, repetir y reiniciar cuando '
      'quieras. Toca el engranaje (arriba a la derecha) para los ajustes.'),
];

const tutLecciones = <PasoTutorial>[
  PasoTutorial(Icons.auto_stories, 'Aprende paso a paso',
      'Cada lección empieza con una introducción —teoría y ejemplos— y luego '
      'trae unos ejercicios para practicar lo que acabas de ver.'),
  PasoTutorial(Icons.volume_up, 'Escucha los ejemplos',
      'Pulsa "Escuchar" en las tarjetas para oír las escalas y las notas. '
      'Repítelo las veces que necesites: así se memoriza.'),
  PasoTutorial(Icons.stairs, 'Cinco niveles',
      'Las lecciones se agrupan en 5 niveles. Abre o cierra cada uno tocando '
      'su barra de color.'),
];

const tutEjercicio = <PasoTutorial>[
  PasoTutorial(Icons.check_circle_outline, 'Responde y comprueba',
      'Elige tu respuesta y pulsa COMPROBAR. Verás si has acertado y una '
      'explicación breve antes de continuar.'),
  PasoTutorial(Icons.lightbulb_outline, '¿Atascado? Usa la Pista',
      'El botón "Pista" te orienta sin darte la respuesta. Piénsalo con la '
      'ayuda y vuelve a intentarlo.'),
  PasoTutorial(Icons.piano, 'Teclado de apoyo',
      'Con "Mostrar teclado" puedes tocar notas para comprobar tus ideas '
      'mientras resuelves. No cuenta para la respuesta.'),
];

const tutEscalas = <PasoTutorial>[
  PasoTutorial(Icons.travel_explore, 'Explora cualquier escala',
      'Elige una tónica y una escala. La verás en el pentagrama y en el '
      'teclado, con sus notas resaltadas.'),
  PasoTutorial(Icons.play_circle_outline, 'Escúchala',
      'Pulsa "Reproducir escala" para oírla entera, o toca las teclas una a '
      'una para explorarla a tu ritmo.'),
];

const tutComponer = <PasoTutorial>[
  PasoTutorial(Icons.edit_note, 'Un curso para componer',
      'De la idea más pequeña —un motivo— a la forma completa de una pieza. '
      'Cada módulo es una herramienta concreta que puedes usar hoy.'),
  PasoTutorial(Icons.gesture, 'Diagramas animados',
      'Cada concepto trae un diagrama que se dibuja solo. Toca el icono ↻ de '
      'la esquina para verlo trazarse otra vez.'),
  PasoTutorial(Icons.graphic_eq, 'Todo suena',
      'Pulsa "Escuchar" en las tarjetas para oír motivos, progresiones y '
      'melodías. Escuchar y comparar es como se aprende a componer.'),
];

const tutWiki = <PasoTutorial>[
  PasoTutorial(Icons.menu_book, 'Una enciclopedia musical',
      'Teoría, historia, instrumentos, compositores, teatro, producción, mitos '
      'y curiosidades: 169 artículos explicados a fondo.'),
  PasoTutorial(Icons.search, 'Busca sin miedo a escribir mal',
      'El buscador es tolerante: encuentra resultados aunque falten acentos o '
      'no escribas el título exacto, y si no está, te ofrece buscarlo en la web.'),
  PasoTutorial(Icons.list_alt, 'Índice dentro de cada artículo',
      'En los artículos largos hay un recuadro "En este artículo": toca un '
      'apartado y saltas directo a él.'),
];

/// Muestra el tutorial [clave] si todavía no se ha visto y los tutoriales
/// están activados. Márcalo como visto en cuanto se abre.
Future<void> mostrarTutorial(
  BuildContext context,
  String clave,
  List<PasoTutorial> pasos,
) async {
  if (!Onboarding.pendiente(clave)) return;
  await Onboarding.marcarVisto(clave);
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.74),
    builder: (_) => _DialogoTutorial(pasos: pasos),
  );
}

/// Igual que [mostrarTutorial] pero sin comprobar "pendiente": se usa desde
/// Ajustes para reproducir un tutorial a demanda.
Future<void> reproducirTutorial(
        BuildContext context, List<PasoTutorial> pasos) =>
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.74),
      builder: (_) => _DialogoTutorial(pasos: pasos),
    );

class _DialogoTutorial extends StatefulWidget {
  final List<PasoTutorial> pasos;
  const _DialogoTutorial({required this.pasos});

  @override
  State<_DialogoTutorial> createState() => _DialogoTutorialState();
}

class _DialogoTutorialState extends State<_DialogoTutorial> {
  final _pc = PageController();
  int _i = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  bool get _ultimo => _i >= widget.pasos.length - 1;

  void _siguiente() {
    if (_ultimo) {
      Navigator.of(context).pop();
    } else {
      _pc.nextPage(
          duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.pal.superficie,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: context.pal.borde),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---- Cabecera: Saltar ----
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Saltar'),
              ),
            ),
            // ---- Diapositivas ----
            SizedBox(
              height: 300,
              child: PageView.builder(
                controller: _pc,
                onPageChanged: (v) => setState(() => _i = v),
                itemCount: widget.pasos.length,
                itemBuilder: (_, k) => _Diapositiva(paso: widget.pasos[k]),
              ),
            ),
            const SizedBox(height: 12),
            // ---- Puntos ----
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var k = 0; k < widget.pasos.length; k++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: k == _i ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: k == _i ? context.pal.acento : context.pal.borde,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            // ---- Botón principal ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BotonRebote(
                onTap: _siguiente,
                child: FilledButton(
                  onPressed: _siguiente,
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(46)),
                  child: Text(_ultimo ? '¡Entendido!' : 'Siguiente'),
                ),
              ),
            ),
            // ---- Desactivar todos ----
            TextButton(
              onPressed: () async {
                await Onboarding.setHabilitado(false);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text('No volver a mostrar los tutoriales',
                  style: TextStyle(fontSize: 12, color: context.pal.textoTenue)),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _Diapositiva extends StatelessWidget {
  final PasoTutorial paso;
  const _Diapositiva({required this.paso});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Latido(
            max: 1.06,
            periodo: const Duration(milliseconds: 2400),
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [context.pal.acento, Color(0xFF4F46E5)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.pal.acento.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(paso.icono, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            paso.titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: context.pal.texto),
          ),
          const SizedBox(height: 10),
          Text(
            paso.texto,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13.5, color: context.pal.textoTenue, height: 1.45),
          ),
        ],
      ),
    );
  }
}
