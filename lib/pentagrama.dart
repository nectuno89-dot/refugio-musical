// ===========================================================================
//  pentagrama.dart — widgets musicales dibujados:
//  · Pentagrama: dibuja un pentagrama con las notas indicadas.
//  · Tecla: una tecla de piano.
// ===========================================================================

import 'package:flutter/material.dart';
import 'musica.dart';
import 'retro.dart';
import 'tema.dart';

// ---------------------------------------------------------------------------
//  Pentagrama
// ---------------------------------------------------------------------------
class Pentagrama extends StatelessWidget {
  final List<int> midis; // notas MIDI a mostrar, de izquierda a derecha
  final Color color;
  final Color? tinta; // color de líneas, clave y alteraciones (por defecto, del tema)

  const Pentagrama({
    super.key,
    required this.midis,
    required this.color,
    this.tinta,
  });

  @override
  Widget build(BuildContext context) {
    const double alto = 150;
    final double ancho = 70 + midis.length * 34 + 20;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: CustomPaint(
        size: Size(ancho, alto),
        painter: _PentagramaPainter(
            midis: midis, color: color, tinta: tinta ?? context.pal.tinta),
      ),
    );
  }
}

class _PentagramaPainter extends CustomPainter {
  final List<int> midis;
  final Color color;
  final Color tinta;

  _PentagramaPainter(
      {required this.midis, required this.color, required this.tinta});

  /// Convierte una nota MIDI en su "escalón" en el pentagrama:
  /// 0 = línea de abajo (MI4). Cada escalón = media distancia entre líneas.
  int _escalon(int midi) {
    final pc = midi % 12;
    final octava = (midi ~/ 12) - 1;
    final letra = letraDeNota[pc];
    final absoluto = octava * 7 + letra;
    return absoluto - (4 * 7 + 2); // referencia: MI4
  }

  @override
  void paint(Canvas canvas, Size size) {
    const double medio = 6; // media distancia entre líneas
    const double yBase = 95; // y de la línea de abajo (MI4)
    final lapiz = Paint()
      ..color = tinta
      ..strokeWidth = 1.2;

    double y(int escalon) => yBase - escalon * medio;

    for (final s in [0, 2, 4, 6, 8]) {
      canvas.drawLine(Offset(8, y(s)), Offset(size.width - 8, y(s)), lapiz);
    }

    final tpClave = TextPainter(
      text: TextSpan(
        text: '\u{1D11E}',
        style: TextStyle(fontSize: 58, color: tinta),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpClave.paint(canvas, Offset(10, y(8) - 12));

    double x = 74;
    final relleno = Paint()..color = color;
    for (final midi in midis) {
      final s = _escalon(midi);
      final cy = y(s);

      if (s < 0) {
        for (int l = -2; l >= s; l -= 2) {
          canvas.drawLine(Offset(x - 10, y(l)), Offset(x + 10, y(l)), lapiz);
        }
      } else if (s > 8) {
        for (int l = 10; l <= s; l += 2) {
          canvas.drawLine(Offset(x - 10, y(l)), Offset(x + 10, y(l)), lapiz);
        }
      }

      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, cy), width: 13, height: 10),
        relleno,
      );

      if (tieneSostenido[midi % 12]) {
        final tp = TextPainter(
          text: TextSpan(
            text: '♯', // ♯
            style: TextStyle(fontSize: 16, color: tinta),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - 22, cy - 10));
      }

      x += 34;
    }
  }

  @override
  bool shouldRepaint(covariant _PentagramaPainter old) =>
      old.midis.toString() != midis.toString() || old.color != color || old.tinta != tinta;
}

// ---------------------------------------------------------------------------
//  Tecla de piano
// ---------------------------------------------------------------------------
class Tecla extends StatelessWidget {
  final String nombre;
  final bool negra;
  final bool encendida;
  final bool esTonica;
  final Color acento;
  final VoidCallback onPress; // al pulsar
  final VoidCallback onRelease; // al soltar

  const Tecla({
    super.key,
    required this.nombre,
    required this.negra,
    required this.encendida,
    required this.esTonica,
    required this.acento,
    required this.onPress,
    required this.onRelease,
  });

  @override
  Widget build(BuildContext context) {
    final Color colorFondo = esTonica && encendida
        ? const Color(0xFF312E81)
        : encendida
            ? acento
            : (negra ? const Color(0xFF1E1E1E) : Colors.white);
    final Color colorTexto = encendida
        ? Colors.white
        : (negra ? Colors.white70 : Colors.black54);

    return GestureDetector(
      onTapDown: (_) {
        Retro.tecla();
        onPress();
      },
      onTapUp: (_) => onRelease(),
      onTapCancel: onRelease,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: negra ? 34 : 50,
        height: negra ? 150 : 230,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: colorFondo,
          border: Border.all(color: Colors.black26),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        ),
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(nombre, style: TextStyle(fontSize: 11, color: colorTexto)),
      ),
    );
  }
}
