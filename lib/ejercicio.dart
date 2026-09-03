// ===========================================================================
//  ejercicio.dart — modelo de Ejercicio + VistaEjercicio (widget que lo
//  presenta con COMPROBAR / feedback / CONTINUAR).
//  Lo usan tanto las lecciones como la pantalla de Ejercicios.
// ===========================================================================

import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import 'animaciones.dart';
import 'motor_audio.dart';
import 'pentagrama.dart';
import 'tema.dart';
import 'teclado_ayuda.dart';
import 'tutorial.dart';

class Ejercicio {
  final String id;
  final int nivel;
  final String tipo; // opcion_multiple | verdadero_falso | completar | leer_nota | (otros)
  final String enunciado;
  final String explicacion;
  final List<String> opciones; // opcion_multiple, leer_nota
  final int correcta; // opcion_multiple/leer_nota (índice) o -1
  final bool? correctaVF; // verdadero_falso
  final String texto; // completar (con "___")
  final List<String> respuestas; // completar
  final int? midi; // leer_nota: la nota a mostrar en el pentagrama
  final String pista; // ayuda opcional (NO da la respuesta)

  Ejercicio({
    required this.id,
    required this.nivel,
    required this.tipo,
    required this.enunciado,
    required this.explicacion,
    required this.opciones,
    required this.correcta,
    required this.correctaVF,
    required this.texto,
    required this.respuestas,
    required this.midi,
    required this.pista,
  });

  factory Ejercicio.fromJson(Map<String, dynamic> j) {
    final v = j['correcta'];
    return Ejercicio(
      id: j['id'] as String? ?? '',
      nivel: (j['nivel'] as num?)?.toInt() ?? 1,
      tipo: j['tipo'] as String,
      enunciado: j['enunciado'] as String? ?? '',
      explicacion: j['explicacion'] as String? ?? '',
      opciones:
          (j['opciones'] as List?)?.map((x) => x as String).toList() ?? const [],
      correcta: v is int ? v : -1,
      correctaVF: v is bool ? v : null,
      texto: j['texto'] as String? ?? '',
      respuestas:
          (j['respuestas'] as List?)?.map((x) => x as String).toList() ?? const [],
      midi: (j['midi'] as num?)?.toInt(),
      pista: j['pista'] as String? ?? '',
    );
  }

  bool get soportado =>
      tipo == 'opcion_multiple' ||
      tipo == 'verdadero_falso' ||
      tipo == 'completar' ||
      tipo == 'leer_nota';
}

String sinAcentos(String s) {
  const con = 'áàäâéèëêíìïîóòöôúùüûñ';
  const sin = 'aaaaeeeeiiiioooouuuun';
  var r = s.toLowerCase().trim();
  for (var i = 0; i < con.length; i++) {
    r = r.replaceAll(con[i], sin[i]);
  }
  return r;
}

// ---------------------------------------------------------------------------
//  Widget: presenta UN ejercicio y avisa al terminar.
// ---------------------------------------------------------------------------
class VistaEjercicio extends StatefulWidget {
  final Ejercicio ejercicio;
  final String etiquetaFinal; // texto del botón cuando es el último
  final bool esUltimo;
  final void Function(bool acierto) onTerminado; // se llama al pulsar CONTINUAR

  const VistaEjercicio({
    super.key,
    required this.ejercicio,
    required this.onTerminado,
    this.esUltimo = false,
    this.etiquetaFinal = 'TERMINAR',
  });

  @override
  State<VistaEjercicio> createState() => _VistaEjercicioState();
}

class _VistaEjercicioState extends State<VistaEjercicio> {
  bool comprobado = false;
  bool acierto = false;
  int? seleccion;
  bool? seleccionVF;
  late List<TextEditingController> huecos;

  bool _teclado = false;
  bool _pistaVisible = false;
  MotorAudio? _audio; // se crea solo si se abre el teclado
  final _sfx = AudioPlayer(); // sonido de acierto / error
  final _confeti = ConfettiController(duration: const Duration(milliseconds: 700));

  Ejercicio get e => widget.ejercicio;

  // Ayuda: usa la pista escrita si existe; si no, una genérica según el tipo.
  // Nunca revela la respuesta.
  String get _pistaTexto {
    if (e.pista.isNotEmpty) return e.pista;
    switch (e.tipo) {
      case 'leer_nota':
        return 'En clave de sol, las líneas (de abajo arriba) son MI-SOL-SI-RE-FA '
            'y los espacios FA-LA-DO-MI. Localiza una nota que reconozcas y cuenta '
            'hasta la que se muestra. El teclado de abajo también ayuda.';
      case 'completar':
        return 'Abre la "Teoría" del nivel (arriba) y aplica la fórmula paso a paso.';
      case 'verdadero_falso':
        return 'Busca un ejemplo concreto: si encuentras uno que contradice la frase, '
            'es falsa; si todos la cumplen, es verdadera.';
      default:
        return 'Descarta primero las opciones que sabes que están mal. Apóyate en la '
            'teoría del nivel y, si te sirve, usa el teclado.';
    }
  }

  @override
  void initState() {
    super.initState();
    final n = e.tipo == 'completar' ? e.respuestas.length : 0;
    huecos = List.generate(n, (_) => TextEditingController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) mostrarTutorial(context, 'ejercicio', tutEjercicio);
    });
  }

  @override
  void dispose() {
    for (final c in huecos) {
      c.dispose();
    }
    _audio?.libera();
    _sfx.dispose();
    _confeti.dispose();
    super.dispose();
  }

  void _alternarTeclado() {
    if (!_teclado && _audio == null) {
      _audio = MotorAudio()..inicia();
    }
    setState(() => _teclado = !_teclado);
  }

  bool get _hayRespuesta {
    switch (e.tipo) {
      case 'opcion_multiple':
      case 'leer_nota':
        return seleccion != null;
      case 'verdadero_falso':
        return seleccionVF != null;
      case 'completar':
        return huecos.every((c) => c.text.trim().isNotEmpty);
      default:
        return true;
    }
  }

  void _comprobar() {
    bool ok;
    switch (e.tipo) {
      case 'opcion_multiple':
      case 'leer_nota':
        ok = seleccion == e.correcta;
        break;
      case 'verdadero_falso':
        ok = seleccionVF == e.correctaVF;
        break;
      case 'completar':
        ok = true;
        for (var i = 0; i < e.respuestas.length; i++) {
          if (sinAcentos(huecos[i].text) != sinAcentos(e.respuestas[i])) {
            ok = false;
          }
        }
        break;
      default:
        ok = true;
    }
    setState(() {
      comprobado = true;
      acierto = ok;
    });
    if (e.soportado) {
      _sfx.stop();
      _sfx.play(AssetSource(ok ? 'audio/ok.wav' : 'audio/mal.wav'));
      if (ok) _confeti.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(e.enunciado,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 20),
                  _cuerpo(),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: [
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _pistaVisible = !_pistaVisible),
                        icon: const Icon(Icons.lightbulb_outline),
                        label:
                            Text(_pistaVisible ? 'Ocultar pista' : 'Pista'),
                      ),
                      TextButton.icon(
                        onPressed: _alternarTeclado,
                        icon: const Icon(Icons.piano),
                        label: Text(
                            _teclado ? 'Ocultar teclado' : 'Mostrar teclado'),
                      ),
                    ],
                  ),
                  if (_pistaVisible)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.pal.aviso.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: context.pal.aviso.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb, size: 18, color: context.pal.aviso),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_pistaTexto,
                                style: const TextStyle(
                                    fontSize: 13, height: 1.35)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (_teclado && _audio != null)
              TecladoAyuda(
                audio: _audio!,
                acento: Theme.of(context).colorScheme.primary,
              ),
            comprobado ? _banner() : _barra(),
          ],
        ),
        // Confeti al acertar (cae desde arriba).
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confeti,
            blastDirection: pi / 2,
            emissionFrequency: 0.0,
            numberOfParticles: 18,
            maxBlastForce: 18,
            minBlastForce: 8,
            gravity: 0.3,
            colors: [context.pal.acento, context.pal.exito, context.pal.aviso, Colors.white],
          ),
        ),
      ],
    );
  }

  Widget _cuerpo() {
    switch (e.tipo) {
      case 'opcion_multiple':
      case 'leer_nota':
        return Column(
          children: [
            if (e.tipo == 'leer_nota' && e.midi != null) ...[
              Pentagrama(
                midis: [e.midi!],
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
            ],
            for (var i = 0; i < e.opciones.length; i++)
              Card(
                color: seleccion == i
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: ListTile(
                  title: Text(e.opciones[i]),
                  onTap:
                      comprobado ? null : () => setState(() => seleccion = i),
                ),
              ),
          ],
        );
      case 'verdadero_falso':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final v in [true, false])
              ChoiceChip(
                label: Text(v ? 'Verdadero' : 'Falso'),
                selected: seleccionVF == v,
                onSelected:
                    comprobado ? null : (_) => setState(() => seleccionVF = v),
              ),
          ],
        );
      case 'completar':
        final partes = e.texto.split('___');
        final ws = <Widget>[];
        for (var i = 0; i < partes.length; i++) {
          if (partes[i].isNotEmpty) ws.add(Text(partes[i]));
          if (i < huecos.length) {
            ws.add(SizedBox(
              width: 70,
              child: TextField(
                controller: huecos[i],
                enabled: !comprobado,
                textAlign: TextAlign.center,
                onChanged: (_) => setState(() {}),
              ),
            ));
          }
        }
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 10,
          children: ws,
        );
      default:
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.amber.withValues(alpha: 0.15),
          child: Text(
            'Ejercicio de tipo "${e.tipo}": aún no disponible en el prototipo. '
            'Puedes continuar.',
          ),
        );
    }
  }

  Widget _barra() {
    final activo = _hayRespuesta;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BotonRebote(
          onTap: activo ? _comprobar : null,
          child: FilledButton(
            onPressed: activo ? _comprobar : null,
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('COMPROBAR'),
          ),
        ),
      ),
    );
  }

  Widget _banner() {
    final color = !e.soportado
        ? Colors.grey
        : acierto
            ? context.pal.exito
            : context.pal.error;
    return TweenAnimationBuilder<double>(
      key: ValueKey(comprobado),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Transform.translate(
        offset: Offset(0, (1 - t) * 30),
        child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
      ),
      child: Container(
        color: color.withValues(alpha: 0.14),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                        !e.soportado
                            ? Icons.skip_next
                            : acierto
                                ? Icons.check_circle
                                : Icons.cancel,
                        color: color,
                        size: 20),
                    const SizedBox(width: 6),
                    Text(
                      !e.soportado
                          ? 'Saltado'
                          : acierto
                              ? '¡Correcto!'
                              : 'No exactamente',
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
                ),
                if (e.explicacion.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(e.explicacion),
                ],
                const SizedBox(height: 12),
                BotonRebote(
                  onTap: () => widget.onTerminado(acierto),
                  child: FilledButton(
                    onPressed: () => widget.onTerminado(acierto),
                    style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48)),
                    child: Text(widget.esUltimo
                        ? widget.etiquetaFinal
                        : 'CONTINUAR'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
