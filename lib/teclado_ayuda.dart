// ===========================================================================
//  teclado_ayuda.dart — teclado de piano de apoyo, desplegable, para usar
//  mientras se resuelve un ejercicio o lección. Solo suena; no afecta a la
//  respuesta.
// ===========================================================================

import 'package:flutter/material.dart';

import 'motor_audio.dart';
import 'retro.dart';
import 'tema.dart';

const _nombres = [
  'DO', 'DO#', 'RE', 'RE#', 'MI', 'FA', 'FA#', 'SOL', 'SOL#', 'LA', 'LA#', 'SI',
];

class TecladoAyuda extends StatefulWidget {
  final MotorAudio audio;
  final Color acento;
  final int midiInicio; // MIDI de la tecla más grave
  final int octavas;

  const TecladoAyuda({
    super.key,
    required this.audio,
    required this.acento,
    this.midiInicio = 48, // DO3
    this.octavas = 2,
  });

  @override
  State<TecladoAyuda> createState() => _TecladoAyudaState();
}

class _TecladoAyudaState extends State<TecladoAyuda> {
  final Set<int> _presionadas = {};

  void _pulsar(int midi) {
    Retro.tecla();
    widget.audio.pulsar(midi);
    setState(() => _presionadas.add(midi));
  }

  void _soltar(int midi) {
    widget.audio.soltar(midi);
    if (mounted) setState(() => _presionadas.remove(midi));
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.octavas * 12 + 1;
    return Container(
      height: 150,
      width: double.infinity,
      color: context.pal.superficieAlt,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            for (int i = 0; i < total; i++) _tecla(widget.midiInicio + i),
          ],
        ),
      ),
    );
  }

  Widget _tecla(int midi) {
    final pc = midi % 12;
    final negra = _nombres[pc].contains('#');
    final pressed = _presionadas.contains(midi);
    return GestureDetector(
      onTapDown: (_) => _pulsar(midi),
      onTapUp: (_) => _soltar(midi),
      onTapCancel: () => _soltar(midi),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: negra ? 26 : 38,
        height: negra ? 88 : 130,
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        decoration: BoxDecoration(
          color: pressed
              ? widget.acento
              : (negra ? const Color(0xFF1E1E1E) : Colors.white),
          border: Border.all(color: Colors.black26),
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(5)),
        ),
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          _nombres[pc],
          style: TextStyle(
            fontSize: 8,
            color: pressed
                ? Colors.white
                : (negra ? Colors.white54 : Colors.black45),
          ),
        ),
      ),
    );
  }
}
