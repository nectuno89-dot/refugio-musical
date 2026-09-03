// ===========================================================================
//  ruta_pasos.dart — "ruta" visual estilo Duolingo: una fila serpenteante de
//  nodos circulares (escalones). Cada nodo es un ejercicio o una lección.
// ===========================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'animaciones.dart';
import 'tema.dart';

enum EstadoPaso { completado, actual, disponible }

class Paso {
  final EstadoPaso estado;
  final int? numero; // etiqueta numérica (1, 2, 3…)
  final IconData? icono; // o un icono, para nodos especiales
  final VoidCallback onTap;

  const Paso({
    required this.estado,
    this.numero,
    this.icono,
    required this.onTap,
  });
}

class RutaPasos extends StatelessWidget {
  final List<Paso> pasos;
  final Color acento;

  const RutaPasos({super.key, required this.pasos, required this.acento});

  double _zig(int i) => 60.0 * math.sin(i * 0.8);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
      child: Column(
        children: [
          for (var i = 0; i < pasos.length; i++)
            Transform.translate(
              offset: Offset(_zig(i), 0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: BotonRebote(
                  onTap: pasos[i].onTap,
                  escala: 0.9,
                  child: pasos[i].estado == EstadoPaso.actual
                      ? Latido(child: _Nodo(paso: pasos[i], acento: acento))
                      : _Nodo(paso: pasos[i], acento: acento),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Nodo extends StatelessWidget {
  final Paso paso;
  final Color acento;

  const _Nodo({required this.paso, required this.acento});

  static Color _oscurecer(Color c, [double f = 0.72]) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness * f).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final done = paso.estado == EstadoPaso.completado;
    final actual = paso.estado == EstadoPaso.actual;

    final Color base = done
        ? context.pal.exito
        : actual
            ? acento
            : context.pal.superficieAlt;
    final Color sombra = done
        ? _oscurecer(context.pal.exito)
        : actual
            ? _oscurecer(acento)
            : _oscurecer(context.pal.superficieAlt, 0.86);
    final double size = actual ? 66 : 56;

    Widget contenido;
    if (paso.icono != null) {
      contenido = Icon(paso.icono,
          color: actual || done ? Colors.white : context.pal.textoTenue, size: 24);
    } else if (done) {
      contenido = const Icon(Icons.check, color: Colors.white, size: 28);
    } else {
      contenido = Text(
        '${paso.numero ?? ""}',
        style: TextStyle(
          color: actual ? Colors.white : context.pal.textoTenue,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      );
    }

    return SizedBox(
        width: size + 10,
        height: size + 12,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 7,
              child: Container(
                width: size,
                height: size,
                decoration:
                    BoxDecoration(color: sombra, shape: BoxShape.circle),
              ),
            ),
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(color: base, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: contenido,
            ),
            if (actual)
              Positioned(
                top: -14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: acento,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('EMPIEZA',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
    );
  }
}
