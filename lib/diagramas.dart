// ===========================================================================
//  diagramas.dart — diagramas didácticos dibujados "a mano" y animados.
//  · _Boceto: primitivas de dibujo con leve temblor (aspecto de trazo a mano)
//    y con soporte de "trazado progresivo" (prog 0..1).
//  · DiagramaAnimado(nombre): widget que anima el dibujo al aparecer y tiene
//    un botón para volver a verlo.
//  · diagramas: registro nombre -> función de dibujo.
// ===========================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'retro.dart';
import 'tema.dart';

typedef _DibujarDiagrama = void Function(
    Canvas canvas, Size size, double t, _Boceto b);

// ---------------------------------------------------------------------------
//  Widget
// ---------------------------------------------------------------------------
class DiagramaAnimado extends StatefulWidget {
  final String nombre;
  final double alto;
  final String? pie;

  const DiagramaAnimado(this.nombre, {super.key, this.alto = 190, this.pie});

  @override
  State<DiagramaAnimado> createState() => _DiagramaAnimadoState();
}

class _DiagramaAnimadoState extends State<DiagramaAnimado>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..forward();
  late final Animation<double> _t =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _replay() {
    Retro.toque();
    _c.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final fn = _diagramas[widget.nombre];
    final pal = context.pal;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
      decoration: BoxDecoration(
        color: pal.superficieAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pal.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              SizedBox(
                height: widget.alto,
                child: fn == null
                    ? Center(
                        child: Text('(diagrama pendiente)',
                            style: TextStyle(
                                color: pal.textoTenue, fontSize: 12)))
                    : AnimatedBuilder(
                        animation: _t,
                        builder: (_, _) => CustomPaint(
                          size: Size.infinite,
                          painter: _PintorDiagrama(
                              widget.nombre, fn, _t.value, pal.tinta),
                        ),
                      ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  iconSize: 17,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.replay, color: pal.textoTenue),
                  tooltip: 'Ver de nuevo',
                  onPressed: _replay,
                ),
              ),
            ],
          ),
          if (widget.pie != null && widget.pie!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
              child: Text(widget.pie!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11.5, color: pal.textoTenue, height: 1.3)),
            ),
        ],
      ),
    );
  }
}

class _PintorDiagrama extends CustomPainter {
  final String nombre;
  final _DibujarDiagrama fn;
  final double t;
  final Color tinta;
  _PintorDiagrama(this.nombre, this.fn, this.t, this.tinta);

  @override
  void paint(Canvas canvas, Size size) {
    final b = _Boceto(canvas, nombre.hashCode & 0x7fffffff, tinta);
    fn(canvas, size, t, b);
  }

  @override
  bool shouldRepaint(covariant _PintorDiagrama old) =>
      old.t != t || old.nombre != nombre || old.tinta != tinta;
}

// ---------------------------------------------------------------------------
//  Primitivas de dibujo "a mano"
// ---------------------------------------------------------------------------
class _Boceto {
  final Canvas c;
  final int _semilla;
  final Color tinta; // color de trazo por defecto (según el tema)
  late math.Random _r;

  _Boceto(this.c, this._semilla, this.tinta) {
    _r = math.Random(_semilla);
  }

  /// Reinicia el generador: así el temblor es idéntico en cada fotograma
  /// (solo cambia 'prog'). Llamar al principio de cada función de dibujo.
  void reiniciar() => _r = math.Random(_semilla);

  double _j([double amp = 1.2]) => (_r.nextDouble() * 2 - 1) * amp;

  Path _recorta(Path p, double prog) {
    if (prog >= 1) return p;
    if (prog <= 0) return Path();
    final out = Path();
    for (final m in p.computeMetrics()) {
      out.addPath(m.extractPath(0, m.length * prog.clamp(0.0, 1.0)),
          Offset.zero);
    }
    return out;
  }

  void linea(Offset a, Offset b,
      {double prog = 1, Color? color, double grosor = 2.4}) {
    if (prog <= 0) return;
    final mid = Offset.lerp(a, b, 0.5)! + Offset(_j(), _j());
    final path = Path()
      ..moveTo(a.dx + _j(0.6), a.dy + _j(0.6))
      ..quadraticBezierTo(
          mid.dx, mid.dy, b.dx + _j(0.6), b.dy + _j(0.6));
    c.drawPath(
      _recorta(path, prog),
      Paint()
        ..color = (color ?? tinta)
        ..strokeWidth = grosor
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  void flecha(Offset a, Offset b,
      {double prog = 1, Color? color, double grosor = 2.4}) {
    linea(a, b, prog: prog, color: color, grosor: grosor);
    if (prog < 0.82) return;
    final dir = b - a;
    final ang = math.atan2(dir.dy, dir.dx);
    const l = 9.0;
    final p = Paint()
      ..color = (color ?? tinta)
      ..strokeWidth = grosor
      ..strokeCap = StrokeCap.round;
    c.drawLine(b, b + Offset(math.cos(ang + 2.5) * l, math.sin(ang + 2.5) * l),
        p);
    c.drawLine(b, b + Offset(math.cos(ang - 2.5) * l, math.sin(ang - 2.5) * l),
        p);
  }

  /// Arco entre dos puntos (para frases: pregunta / respuesta).
  void arco(Offset a, Offset b, double altura,
      {double prog = 1, Color? color, double grosor = 2.4}) {
    if (prog <= 0) return;
    final ctrl = Offset((a.dx + b.dx) / 2 + _j(), a.dy - altura + _j());
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, b.dx, b.dy);
    c.drawPath(
      _recorta(path, prog),
      Paint()
        ..color = (color ?? tinta)
        ..strokeWidth = grosor
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  void caja(Rect r,
      {double prog = 1,
      Color? borde,
      Color? relleno,
      double radio = 8,
      double grosor = 2.2}) {
    final rr = RRect.fromRectAndRadius(r, Radius.circular(radio));
    if (relleno != null) {
      c.drawRRect(
        rr,
        Paint()
          ..color = relleno.withValues(alpha: relleno.a * prog.clamp(0.0, 1.0)),
      );
    }
    final path = Path()..addRRect(rr);
    c.drawPath(
      _recorta(path, prog),
      Paint()
        ..color = (borde ?? tinta)
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosor
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void circulo(Offset centro, double rad,
      {double prog = 1,
      Color? borde,
      Color? relleno,
      double grosor = 2.4}) {
    if (relleno != null) {
      c.drawCircle(
        centro,
        rad,
        Paint()
          ..color = relleno.withValues(alpha: relleno.a * prog.clamp(0.0, 1.0)),
      );
    }
    final path = Path()
      ..addOval(Rect.fromCircle(center: centro, radius: rad));
    c.drawPath(
      _recorta(path, prog),
      Paint()
        ..color = (borde ?? tinta)
        ..style = PaintingStyle.stroke
        ..strokeWidth = grosor,
    );
  }

  void punto(Offset o, {double r = 3, Color? color, double prog = 1}) {
    if (prog <= 0.05) return;
    c.drawCircle(o, r * prog.clamp(0.0, 1.0),
        Paint()..color = (color ?? tinta));
  }

  void texto(String s, Offset at,
      {double size = 12,
      Color? color,
      FontWeight peso = FontWeight.w600,
      TextAlign align = TextAlign.center,
      double prog = 1,
      double maxW = 220}) {
    if (prog <= 0.03) return;
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontSize: size,
          height: 1.2,
          fontWeight: peso,
          color: (color ?? tinta).withValues(alpha: (color ?? tinta).a * prog.clamp(0.0, 1.0)),
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
      maxLines: 3,
    )..layout(maxWidth: maxW);
    final dx = align == TextAlign.center
        ? at.dx - tp.width / 2
        : align == TextAlign.right
            ? at.dx - tp.width
            : at.dx;
    tp.paint(c, Offset(dx, at.dy - tp.height / 2));
  }
}

/// Mapea t en [a,b] a [0,1] (para encadenar apariciones).
double _et(double t, double a, double b) =>
    ((t - a) / (b - a)).clamp(0.0, 1.0);

// ---------------------------------------------------------------------------
//  Registro de diagramas
// ---------------------------------------------------------------------------
final Map<String, _DibujarDiagrama> _diagramas = {
  'jerarquia_frase': _jerarquiaFrase,
  'formas_pequenas': _formasPequenas,
  'forma_sonata': _formaSonata,
  'funciones_tonales': _funcionesTonales,
  'circulo_quintas': _circuloQuintas,
  'contorno_melodico': _contornoMelodico,
  'modos_brillo': _modosBrillo,
  'antecedente_consecuente': _antecedenteConsecuente,
  'serie_armonicos': _serieArmonicos,
  'cadencias': _cadencias,
  // --- escalas (Lecciones) ---
  'teclado_octava': _tecladoOctava,
  'escalera_mayor': _escaleraMayor,
  'grados_nombres': _gradosNombres,
  'orden_alteraciones': _ordenAlteraciones,
  'relativas': _relativas,
  'pentatonica': _pentatonica,
  'modos_siete': _modosSiete,
  'menor_armonica': _menorArmonica,
  'escala_disminuida': _escalaDisminuida,
  'tonos_enteros': _tonosEnteros,
};

// ---- 1. Jerarquía: motivo -> frase -> período -> sección ------------------
void _jerarquiaFrase(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  final w = s.width, m = 14.0;
  final ancho = w - 2 * m;
  final filas = [
    (0.62, 'sección', 1, kAviso),
    (0.42, 'período', 1, kExito),
    (0.24, 'frase', 2, kAcento),
    (0.06, 'motivo', 4, const Color(0xFF38BDF8)),
  ];
  for (var i = 0; i < filas.length; i++) {
    final (yf, etiqueta, n, color) = filas[i];
    final y = s.height * (0.14 + i * 0.24);
    final prog = _et(t, i * 0.16, i * 0.16 + 0.5);
    final cellW = ancho / n;
    for (var k = 0; k < n; k++) {
      final r = Rect.fromLTWH(m + k * cellW + 3, y, cellW - 6, s.height * 0.14);
      b.caja(r,
          prog: prog,
          relleno: color.withValues(alpha: 0.16),
          borde: color,
          radio: 7);
      b.texto(n == 1 ? etiqueta : '$etiqueta ${k + 1}',
          Offset(r.center.dx, r.center.dy),
          size: n >= 4 ? 10 : 11.5, color: kTexto, prog: _et(t, i * 0.16 + 0.2, i * 0.16 + 0.6));
    }
  }
  b.texto('cada nivel agrupa varios del anterior',
      Offset(w / 2, s.height - 8),
      size: 10.5, color: kTextoTenue, prog: _et(t, 0.75, 1));
}

// ---- 2. Formas pequeñas --------------------------------------------------
void _formasPequenas(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  final m = 12.0;
  final ancho = s.width - 2 * m - 70; // deja hueco a la izquierda para el nombre
  final filas = [
    ('Binaria', ['A', 'B'], [kAcento, kAviso]),
    ('Ternaria', ['A', 'B', 'A'], [kAcento, kAviso, kAcento]),
    ('Rondó', ['A', 'B', 'A', 'C', 'A'],
        [kAcento, kAviso, kAcento, kExito, kAcento]),
    ('Tema y var.', ['T', 'V1', 'V2', 'V3'],
        [kExito, kExito, kExito, kExito]),
  ];
  final h = (s.height - 16) / filas.length;
  for (var i = 0; i < filas.length; i++) {
    final (nombre, bloques, colores) = filas[i];
    final y = 6 + i * h;
    final prog = _et(t, i * 0.18, i * 0.18 + 0.55);
    b.texto(nombre, Offset(m, y + h / 2 - 2),
        size: 10.5, color: kTextoTenue, align: TextAlign.left, prog: prog, maxW: 64);
    final bw = ancho / bloques.length;
    for (var k = 0; k < bloques.length; k++) {
      final r = Rect.fromLTWH(
          m + 66 + k * bw + 2, y + 4, bw - 4, h - 14);
      final p2 = _et(t, i * 0.18 + k * 0.05, i * 0.18 + k * 0.05 + 0.45);
      b.caja(r,
          prog: p2,
          relleno: colores[k].withValues(alpha: 0.2),
          borde: colores[k],
          radio: 6);
      b.texto(bloques[k], r.center,
          size: 10.5, color: kTexto, prog: _et(t, i * 0.18 + k * 0.05 + 0.15, i * 0.18 + k * 0.05 + 0.5));
    }
  }
}

// ---- 3. Forma sonata --------------------------------------------------
void _formaSonata(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  final m = 12.0;
  final ancho = s.width - 2 * m;
  final y = s.height * 0.18;
  final h = s.height * 0.30;
  final partes = [
    (0.40, 'EXPOSICIÓN', kAcento, ['Tema 1 · I', 'puente', 'Tema 2 · V']),
    (0.26, 'DESARROLLO', kAviso, ['se combinan y', 'modulan los temas']),
    (0.34, 'REEXPOSICIÓN', kExito, ['Tema 1 · I', 'Tema 2 · I']),
  ];
  var x = m;
  for (var i = 0; i < partes.length; i++) {
    final (frac, nombre, color, subs) = partes[i];
    final bw = ancho * frac;
    final prog = _et(t, i * 0.2, i * 0.2 + 0.55);
    final r = Rect.fromLTWH(x + 3, y, bw - 6, h);
    b.caja(r,
        prog: prog,
        relleno: color.withValues(alpha: 0.16),
        borde: color,
        radio: 8);
    b.texto(nombre, Offset(r.center.dx, y - 12),
        size: 10.5, color: color, prog: _et(t, i * 0.2 + 0.15, i * 0.2 + 0.5));
    for (var k = 0; k < subs.length; k++) {
      b.texto(subs[k], Offset(r.center.dx, y + h + 12 + k * 13),
          size: 9.5,
          color: kTextoTenue,
          prog: _et(t, 0.55 + i * 0.12 + k * 0.04, 0.9 + i * 0.05),
          maxW: bw + 20);
    }
    x += bw;
  }
  final pf = _et(t, 0.8, 1);
  b.flecha(Offset(m + 20, y + h + 52), Offset(s.width - m - 20, y + h + 52),
      prog: pf, color: kTextoTenue, grosor: 1.8);
  b.texto('sale de la tónica…  viaja…  y vuelve a la tónica',
      Offset(s.width / 2, y + h + 64),
      size: 9.5, color: kTextoTenue, prog: pf);
}

// ---- 4. Funciones tonales -------------------------------------------------
void _funcionesTonales(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  final m = 12.0;
  final w = (s.width - 2 * m - 24) / 3;
  final y = s.height * 0.30;
  final h = s.height * 0.34;
  final zonas = [
    ('TÓNICA', 'reposo\nI · vi · iii', kExito),
    ('SUBDOMINANTE', 'aleja\nIV · ii', kAviso),
    ('DOMINANTE', 'tensión\nV · vii°', kError),
  ];
  final centros = <Offset>[];
  for (var i = 0; i < 3; i++) {
    final (nombre, cuerpo, color) = zonas[i];
    final x = m + i * (w + 12);
    final r = Rect.fromLTWH(x, y, w, h);
    final prog = _et(t, i * 0.14, i * 0.14 + 0.5);
    b.caja(r,
        prog: prog,
        relleno: color.withValues(alpha: 0.15),
        borde: color,
        radio: 10);
    b.texto(nombre, Offset(r.center.dx, y + 14),
        size: 10, color: color, prog: _et(t, i * 0.14 + 0.15, i * 0.14 + 0.5));
    b.texto(cuerpo, Offset(r.center.dx, r.center.dy + 8),
        size: 10, color: kTexto, prog: _et(t, i * 0.14 + 0.2, i * 0.14 + 0.55));
    centros.add(Offset(r.center.dx, y - 6));
  }
  // flechas de "empuje": S -> D -> T
  b.flecha(centros[1], centros[2] + const Offset(-4, 0),
      prog: _et(t, 0.55, 0.8), color: kTextoTenue, grosor: 1.8);
  b.flecha(centros[2], centros[0] + const Offset(4, 0),
      prog: _et(t, 0.75, 1), color: kError, grosor: 2.4);
  b.texto('resuelve', Offset(s.width / 2, y - 20),
      size: 9.5, color: kError, prog: _et(t, 0.85, 1));
}

// ---- 5. Círculo de quintas ---------------------------------------------
const _cq = [
  ['DO', 'Am'],
  ['SOL', 'Em'],
  ['RE', 'Bm'],
  ['LA', 'F#m'],
  ['MI', 'C#m'],
  ['SI', 'G#m'],
  ['F#', 'D#m'],
  ['REb', 'Bbm'],
  ['LAb', 'Fm'],
  ['MIb', 'Cm'],
  ['SIb', 'Gm'],
  ['FA', 'Dm'],
];
void _circuloQuintas(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  final cx = s.width / 2, cy = s.height / 2 + 2;
  final rExt = math.min(s.width, s.height) / 2 - 16;
  b.circulo(Offset(cx, cy), rExt, prog: _et(t, 0, 0.4), borde: kBorde, grosor: 1.6);
  for (var i = 0; i < 12; i++) {
    final ang = -math.pi / 2 + i * (math.pi * 2 / 12);
    final prog = _et(t, 0.25 + i * 0.045, 0.55 + i * 0.045);
    final pM = Offset(cx + math.cos(ang) * rExt, cy + math.sin(ang) * rExt);
    final pm = Offset(cx + math.cos(ang) * (rExt - 34),
        cy + math.sin(ang) * (rExt - 34));
    b.punto(pM, r: 3.5, color: kAcento, prog: prog);
    b.texto(_cq[i][0], pM.translate(0, math.sin(ang) < -0.2 ? -9 : 9),
        size: 11, color: kTexto, peso: FontWeight.w800, prog: prog);
    b.texto(_cq[i][1], pm, size: 8.5, color: kTextoTenue, prog: prog);
  }
  b.texto('vecinas = 1\nalteración', Offset(cx, cy),
      size: 9, color: kTextoTenue, prog: _et(t, 0.7, 1));
}

// ---- 6. Contorno melódico --------------------------------------------
void _contornoMelodico(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  final celdas = [
    ('Arco', (double x) => 1 - math.sin(x * math.pi)),
    ('Onda', (double x) => 0.5 - 0.42 * math.sin(x * math.pi * 2)),
    ('Escalera', (double x) => 1 - (x * 5).floorToDouble() / 5),
    ('Zigzag', (double x) => x.isNaN ? 0.5 : (0.5 + 0.4 * ((x * 6).floor().isEven ? 1 : -1))),
  ];
  final cw = s.width / 2, ch = (s.height - 6) / 2;
  for (var i = 0; i < 4; i++) {
    final col = i % 2, row = i ~/ 2;
    final ox = col * cw + 10, oy = row * ch + 4;
    final iw = cw - 24, ih = ch - 26;
    final prog = _et(t, i * 0.16, i * 0.16 + 0.6);
    final (nombre, f) = celdas[i];
    // baseline
    b.linea(Offset(ox, oy + ih), Offset(ox + iw, oy + ih),
        prog: _et(t, i * 0.16, i * 0.16 + 0.3), color: kBorde, grosor: 1.4);
    Offset? prev;
    for (var k = 0; k <= 12; k++) {
      final xx = k / 12;
      final o = Offset(ox + xx * iw, oy + (f(xx).clamp(0.0, 1.0)) * ih);
      final pk = _et(t, i * 0.16 + xx * 0.4, i * 0.16 + xx * 0.4 + 0.35);
      if (prev != null && pk > 0) {
        b.linea(prev, o, prog: 1, color: kAcento, grosor: 2.2);
      }
      if (k % 3 == 0) b.punto(o, r: 2.6, color: kAviso, prog: pk);
      prev = pk > 0.2 ? o : prev;
    }
    b.texto(nombre, Offset(ox + iw / 2, oy + ih + 12),
        size: 10, color: kTextoTenue, prog: prog);
  }
}

// ---- 7. Modos por brillo -------------------------------------------------
const _modos = [
  ['Lidio', '4ª aumentada'],
  ['Jónico', '(= mayor)'],
  ['Mixolidio', '7ª menor'],
  ['Dórico', '6ª mayor'],
  ['Eólico', '(= menor)'],
  ['Frigio', '2ª menor'],
  ['Locrio', '5ª disminuida'],
];
void _modosBrillo(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  final m = 12.0;
  final h = (s.height - 10) / _modos.length;
  final maxW = s.width - 2 * m - 128;
  for (var i = 0; i < _modos.length; i++) {
    final y = 5 + i * h;
    final prog = _et(t, i * 0.11, i * 0.11 + 0.5);
    final largo = maxW * (1 - i / (_modos.length - 0.4));
    final color = Color.lerp(kAviso, kAcento, i / (_modos.length - 1))!;
    final r = Rect.fromLTWH(m, y + 3, largo.clamp(24, maxW), h - 10);
    b.caja(Rect.fromLTWH(r.left, r.top, r.width * prog, r.height),
        prog: 1, relleno: color.withValues(alpha: 0.28), borde: color, radio: 5);
    b.texto('${_modos[i][0]} · ${_modos[i][1]}',
        Offset(m + maxW + 8, r.center.dy),
        size: 10, color: kTexto, align: TextAlign.left, prog: prog, maxW: 124);
  }
  b.texto('↑ más brillante        ↓ más oscuro', Offset(s.width / 2, s.height - 4),
      size: 8.5, color: kTextoTenue, prog: _et(t, 0.8, 1));
}

// ---- 8. Antecedente / consecuente -------------------------------------
void _antecedenteConsecuente(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  final m = 20.0;
  final base = s.height * 0.62;
  final mid = s.width / 2;
  b.linea(Offset(m, base), Offset(s.width - m, base),
      prog: _et(t, 0, 0.25), color: kBorde, grosor: 1.4);
  // antecedente
  b.arco(Offset(m + 6, base), Offset(mid - 6, base), s.height * 0.34,
      prog: _et(t, 0.15, 0.6), color: kAcento);
  b.texto(',', Offset(mid - 2, base - 6),
      size: 26, color: kAviso, peso: FontWeight.w900, prog: _et(t, 0.55, 0.7));
  b.texto('antecedente\n(pregunta — queda abierta)',
      Offset((m + mid) / 2, base + 20),
      size: 9.5, color: kTextoTenue, prog: _et(t, 0.35, 0.7));
  // consecuente
  b.arco(Offset(mid + 6, base), Offset(s.width - m - 6, base), s.height * 0.34,
      prog: _et(t, 0.55, 1), color: kExito);
  b.texto('.', Offset(s.width - m - 4, base - 2),
      size: 26, color: kExito, peso: FontWeight.w900, prog: _et(t, 0.92, 1));
  b.texto('consecuente\n(respuesta — cierra)',
      Offset((mid + s.width - m) / 2, base + 20),
      size: 9.5, color: kTextoTenue, prog: _et(t, 0.75, 1));
}

// ---- 9. Serie de armónicos --------------------------------------------
const _arm = [
  ['1', 'DO', ''],
  ['2', 'DO', 'octava'],
  ['3', 'SOL', 'quinta'],
  ['4', 'DO', ''],
  ['5', 'MI', '3ª mayor'],
  ['6', 'SOL', ''],
  ['7', 'SIb', '−31 cents'],
  ['8', 'DO', ''],
];
void _serieArmonicos(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  final m = 14.0;
  final h = (s.height - 10) / _arm.length;
  final maxW = s.width - 2 * m - 96;
  for (var i = 0; i < _arm.length; i++) {
    final idx = _arm.length - 1 - i; // dibuja de abajo (fundamental) arriba
    final y = 5 + i * h;
    final prog = _et(t, idx * 0.1, idx * 0.1 + 0.5);
    final largo = maxW / (idx + 1) + 26;
    final color = idx == 0 ? kAcento : kTextoTenue;
    b.linea(Offset(m, y + h / 2), Offset(m + largo * prog, y + h / 2),
        prog: 1, color: color, grosor: idx == 0 ? 3.4 : 2.2);
    b.punto(Offset(m + largo * prog, y + h / 2), r: 3, color: color, prog: prog);
    b.texto(
        '${_arm[idx][0]}·${_arm[idx][1]}${_arm[idx][2].isEmpty ? '' : '  ${_arm[idx][2]}'}',
        Offset(m + maxW + 6, y + h / 2),
        size: 9.5, color: kTexto, align: TextAlign.left, prog: prog, maxW: 92);
  }
  b.texto('la naturaleza "regala" octava, quinta y 3ª mayor',
      Offset(s.width / 2, s.height - 3),
      size: 8.5, color: kTextoTenue, prog: _et(t, 0.85, 1));
}

// ---- 10. Cadencias --------------------------------------------------
void _cadencias(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  final filas = [
    ('Auténtica', 'V', 'I', 'el final más rotundo', kExito),
    ('Plagal', 'IV', 'I', 'la cadencia "amén"', kAcento),
    ('Rota', 'V', 'vi', 'promete tónica y sorprende', kAviso),
  ];
  final h = (s.height - 8) / filas.length;
  final m = 12.0;
  for (var i = 0; i < filas.length; i++) {
    final (nombre, a, d, nota, color) = filas[i];
    final y = 4 + i * h;
    final prog = _et(t, i * 0.2, i * 0.2 + 0.55);
    b.texto(nombre, Offset(m, y + h / 2),
        size: 10.5, color: color, align: TextAlign.left, peso: FontWeight.w800,
        prog: prog, maxW: 76);
    final r1 = Rect.fromLTWH(m + 80, y + 6, 40, h - 18);
    final r2 = Rect.fromLTWH(m + 156, y + 6, 40, h - 18);
    b.caja(r1, prog: prog, borde: kTextoTenue, radio: 6);
    b.texto(a, r1.center, size: 12, color: kTexto, prog: _et(t, i * 0.2 + 0.15, i * 0.2 + 0.5));
    b.flecha(Offset(r1.right + 4, r1.center.dy),
        Offset(r2.left - 4, r2.center.dy),
        prog: _et(t, i * 0.2 + 0.3, i * 0.2 + 0.6), color: color);
    b.caja(r2,
        prog: prog,
        borde: color,
        relleno: color.withValues(alpha: 0.14),
        radio: 6);
    b.texto(d, r2.center, size: 12, color: kTexto, prog: _et(t, i * 0.2 + 0.35, i * 0.2 + 0.65));
    b.texto(nota, Offset(r2.right + 12, r2.center.dy),
        size: 9, color: kTextoTenue, align: TextAlign.left,
        prog: _et(t, i * 0.2 + 0.4, i * 0.2 + 0.75), maxW: s.width - r2.right - 18);
  }
}

// ===========================================================================
//  Diagramas de ESCALAS (para la sección Lecciones)
// ===========================================================================

const _cian = Color(0xFF38BDF8);

// ---- Octava del teclado: dónde están los semitonos naturales -------------
void _tecladoOctava(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  const blancas = ['DO', 'RE', 'MI', 'FA', 'SOL', 'LA', 'SI', 'DO'];
  final m = 14.0;
  final w = (s.width - 2 * m) / blancas.length;
  final top = s.height * 0.16;
  final h = s.height * 0.62;
  for (var i = 0; i < blancas.length; i++) {
    final r = Rect.fromLTWH(m + i * w, top, w - 3, h);
    final prog = _et(t, i * 0.06, i * 0.06 + 0.4);
    b.caja(r,
        prog: prog,
        borde: kBorde,
        relleno: kTextoTenue.withValues(alpha: 0.06),
        radio: 4);
    b.texto(blancas[i], Offset(r.center.dx, top + h - 12),
        size: 9.5,
        color: kTextoTenue,
        prog: _et(t, i * 0.06 + 0.2, i * 0.06 + 0.5));
  }
  const negras = [0, 1, 3, 4, 5];
  for (final k in negras) {
    final r = Rect.fromLTWH(m + (k + 1) * w - w * 0.32, top, w * 0.6, h * 0.62);
    b.caja(r,
        prog: _et(t, 0.35, 0.7),
        borde: kTexto,
        relleno: kTexto.withValues(alpha: 0.85),
        radio: 3);
  }
  for (final k in [2, 6]) {
    final x = m + (k + 1) * w - 1.5;
    b.linea(Offset(x, top - 6), Offset(x, top + h + 6),
        prog: _et(t, 0.6, 0.9), color: kError, grosor: 2.6);
  }
  b.texto('MI-FA y SI-DO: solo un semitono (sin tecla negra en medio)',
      Offset(s.width / 2, s.height - 8),
      size: 9.5, color: kError, prog: _et(t, 0.8, 1), maxW: s.width - 12);
}

// ---- Escalera de la escala mayor: T-T-ST-T-T-T-ST -----------------------
void _escaleraMayor(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  const pasos = ['T', 'T', 'ST', 'T', 'T', 'T', 'ST'];
  final m = 16.0;
  final baseY = s.height - 20;
  final totalUnid = pasos.fold<double>(0, (a, p) => a + (p == 'T' ? 2 : 1));
  final ux = (s.width - 2 * m) / totalUnid;
  final uy = (s.height - 44) / 7;
  var x = m, y = baseY;
  b.punto(Offset(x, y), r: 3.5, color: kAcento, prog: _et(t, 0, 0.2));
  b.texto('1', Offset(x, y + 12),
      size: 9, color: kTextoTenue, prog: _et(t, 0, 0.3));
  for (var i = 0; i < pasos.length; i++) {
    final dx = ux * (pasos[i] == 'T' ? 2 : 1);
    final prog = _et(t, 0.1 + i * 0.11, 0.1 + i * 0.11 + 0.4);
    final esST = pasos[i] == 'ST';
    b.linea(Offset(x, y), Offset(x + dx, y),
        prog: prog, color: kBorde, grosor: 1.6);
    b.linea(Offset(x + dx, y), Offset(x + dx, y - uy),
        prog: prog, color: esST ? kError : kAcento, grosor: esST ? 3 : 2.4);
    b.texto(pasos[i], Offset(x + dx / 2, y - 9),
        size: 9.5, color: esST ? kError : kTextoTenue, prog: prog);
    x += dx;
    y -= uy;
    b.punto(Offset(x, y), r: 3.5, color: kAcento, prog: prog);
    b.texto('${i + 2}', Offset(x, y - 11),
        size: 9, color: kTextoTenue, prog: prog);
  }
  b.texto('los semitonos caen entre 3-4 y 7-8', Offset(s.width / 2, 12),
      size: 9.5, color: kError, prog: _et(t, 0.85, 1));
}

// ---- Nombres y funciones de los 7 grados --------------------------------
void _gradosNombres(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  const g = [
    ['I', 'tonica'],
    ['II', 'supertonica'],
    ['III', 'mediante'],
    ['IV', 'subdominante'],
    ['V', 'dominante'],
    ['VI', 'superdominante'],
    ['VII', 'sensible'],
  ];
  final m = 10.0;
  final w = (s.width - 2 * m) / g.length;
  final y = s.height * 0.28;
  final h = s.height * 0.34;
  for (var i = 0; i < g.length; i++) {
    final r = Rect.fromLTWH(m + i * w + 2, y, w - 4, h);
    final prog = _et(t, i * 0.09, i * 0.09 + 0.45);
    final fuerte = i == 0 || i == 3 || i == 4;
    final col = i == 0
        ? kExito
        : (i == 4 ? kError : (i == 3 ? kAviso : kTextoTenue));
    b.caja(r,
        prog: prog,
        borde: col,
        relleno: fuerte ? col.withValues(alpha: 0.16) : null,
        radio: 6);
    b.texto(g[i][0], Offset(r.center.dx, y + 13),
        size: 12, color: kTexto, peso: FontWeight.w900, prog: prog);
    b.texto(g[i][1], Offset(r.center.dx, y + h + 12),
        size: 8.5,
        color: kTextoTenue,
        prog: _et(t, i * 0.09 + 0.2, i * 0.09 + 0.6),
        maxW: w + 8);
  }
  b.texto('I reposa - V tensiona - IV es el puente',
      Offset(s.width / 2, s.height - 6),
      size: 9.5, color: kTextoTenue, prog: _et(t, 0.85, 1));
}

// ---- Orden de sostenidos (y bemoles al reves) --------------------------
void _ordenAlteraciones(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  const orden = ['FA', 'DO', 'SOL', 'RE', 'LA', 'MI', 'SI'];
  final m = 16.0;
  final w = (s.width - 2 * m) / orden.length;
  final y0 = s.height * 0.22, y1 = s.height * 0.66;
  Offset? prev;
  for (var i = 0; i < orden.length; i++) {
    final cx = m + i * w + w / 2;
    final cy = y0 + (y1 - y0) * (i / (orden.length - 1));
    final prog = _et(t, i * 0.1, i * 0.1 + 0.45);
    if (prev != null) {
      b.linea(prev, Offset(cx, cy), prog: prog, color: kBorde, grosor: 1.4);
    }
    b.circulo(Offset(cx, cy), 12,
        prog: prog,
        borde: kAcento,
        relleno: kAcento.withValues(alpha: 0.14));
    b.texto('${orden[i]}#', Offset(cx, cy), size: 9.5, color: kTexto, prog: prog);
    b.texto('${i + 1}', Offset(cx, cy + 22),
        size: 8,
        color: kTextoTenue,
        prog: _et(t, i * 0.1 + 0.2, i * 0.1 + 0.6));
    prev = Offset(cx, cy);
  }
  b.texto('sostenidos: FA DO SOL RE LA MI SI   .   bemoles: el mismo orden al reves',
      Offset(s.width / 2, s.height - 8),
      size: 9, color: kTextoTenue, prog: _et(t, 0.8, 1), maxW: s.width - 8);
}

// ---- Relativas: misma armadura, distinto punto de partida -------------
void _relativas(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  const notas = [
    'DO', 'RE', 'MI', 'FA', 'SOL', 'LA', 'SI', 'DO', 'RE', 'MI', 'FA', 'SOL', 'LA'
  ];
  final m = 10.0;
  final w = (s.width - 2 * m) / notas.length;
  final y = s.height * 0.42;
  final h = s.height * 0.2;
  for (var i = 0; i < notas.length; i++) {
    final r = Rect.fromLTWH(m + i * w + 1, y, w - 2, h);
    final prog = _et(t, i * 0.05, i * 0.05 + 0.4);
    final enMayor = i <= 7;
    final enMenor = i >= 5;
    b.caja(r,
        prog: prog,
        borde: kBorde,
        relleno: (enMayor && enMenor)
            ? kExito.withValues(alpha: 0.18)
            : (enMayor
                ? kAcento.withValues(alpha: 0.12)
                : kAviso.withValues(alpha: 0.12)),
        radio: 4);
    b.texto(notas[i], r.center, size: 8.5, color: kTexto, prog: prog);
  }
  b.arco(Offset(m + 0.4 * w, y - 4), Offset(m + 7.6 * w, y - 4), 22,
      prog: _et(t, 0.5, 0.8), color: kAcento);
  b.texto('DO mayor  (1 - 8)', Offset(m + 4 * w, y - 30),
      size: 9.5, color: kAcento, prog: _et(t, 0.6, 0.85));
  b.arco(Offset(m + 5.4 * w, y + h + 4), Offset(m + 12.6 * w, y + h + 4), -22,
      prog: _et(t, 0.7, 1), color: kAviso);
  b.texto('LA menor  (empieza en el 6 grado)', Offset(m + 9 * w, y + h + 30),
      size: 9.5, color: kAviso, prog: _et(t, 0.8, 1), maxW: s.width);
}

// ---- Pentatonica: la mayor sin la 4a ni la 7a -------------------------
void _pentatonica(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  const notas = ['DO', 'RE', 'MI', 'FA', 'SOL', 'LA', 'SI'];
  final m = 18.0;
  final w = (s.width - 2 * m) / notas.length;
  final y = s.height * 0.34;
  final h = s.height * 0.3;
  for (var i = 0; i < notas.length; i++) {
    final r = Rect.fromLTWH(m + i * w + 3, y, w - 6, h);
    final prog = _et(t, i * 0.08, i * 0.08 + 0.45);
    final fuera = i == 3 || i == 6;
    b.caja(r,
        prog: prog,
        borde: fuera ? kError : kExito,
        relleno: fuera ? null : kExito.withValues(alpha: 0.16),
        radio: 6);
    b.texto(notas[i], Offset(r.center.dx, r.center.dy - 4),
        size: 10.5, color: kTexto, prog: prog);
    b.texto('${i + 1}', Offset(r.center.dx, y + h + 10),
        size: 8.5, color: kTextoTenue, prog: prog);
    if (fuera) {
      b.linea(Offset(r.left + 3, r.top + 3), Offset(r.right - 3, r.bottom - 3),
          prog: _et(t, i * 0.08 + 0.25, i * 0.08 + 0.6),
          color: kError,
          grosor: 2.6);
    }
  }
  b.texto('quita la 4a y la 7a  ->  5 notas que casi siempre pegan',
      Offset(s.width / 2, s.height - 6),
      size: 9.5, color: kExito, prog: _et(t, 0.85, 1), maxW: s.width - 8);
}

// ---- Los 7 modos: una escala, siete puntos de partida ----------------
void _modosSiete(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  const notas = ['DO', 'RE', 'MI', 'FA', 'SOL', 'LA', 'SI'];
  const modos = [
    'jonico', 'dorico', 'frigio', 'lidio', 'mixolidio', 'eolico', 'locrio'
  ];
  final m = 12.0;
  final w = (s.width - 2 * m) / notas.length;
  final y = s.height * 0.2;
  for (var i = 0; i < notas.length; i++) {
    final cx = m + i * w + w / 2;
    final prog = _et(t, i * 0.05, i * 0.05 + 0.35);
    b.circulo(Offset(cx, y), 11,
        prog: prog, borde: kBorde, relleno: kAcento.withValues(alpha: 0.1));
    b.texto(notas[i], Offset(cx, y), size: 8.5, color: kTexto, prog: prog);
  }
  for (var i = 0; i < modos.length; i++) {
    final cx = m + i * w + w / 2;
    final yy = y + 24 + i * ((s.height - y - 34) / modos.length);
    final prog = _et(t, 0.25 + i * 0.09, 0.25 + i * 0.09 + 0.45);
    b.flecha(Offset(cx, y + 13), Offset(cx, yy - 4),
        prog: prog, color: kAcento, grosor: 1.6);
    b.texto('${i + 1}. ${notas[i]} -> ${modos[i]}', Offset(cx + 8, yy),
        size: 9,
        color: kTexto,
        align: TextAlign.left,
        prog: prog,
        maxW: s.width - cx);
  }
}

// ---- Menor armonica: el salto de 2a aumentada -----------------------
void _menorArmonica(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  const notas = ['LA', 'SI', 'DO', 'RE', 'MI', 'FA', 'SOL#', 'LA'];
  final m = 16.0;
  final w = (s.width - 2 * m) / notas.length;
  final y = s.height * 0.4;
  final h = s.height * 0.24;
  for (var i = 0; i < notas.length; i++) {
    final r = Rect.fromLTWH(m + i * w + 2, y, w - 4, h);
    final prog = _et(t, i * 0.08, i * 0.08 + 0.45);
    final sube = i == 6;
    b.caja(r,
        prog: prog,
        borde: sube ? kAviso : kBorde,
        relleno: sube
            ? kAviso.withValues(alpha: 0.2)
            : kTextoTenue.withValues(alpha: 0.06),
        radio: 5);
    b.texto(notas[i], r.center, size: 9, color: kTexto, prog: prog);
  }
  final xa = m + 5 * w + w / 2, xb = m + 6 * w + w / 2;
  b.arco(Offset(xa, y - 4), Offset(xb, y - 4), 26,
      prog: _et(t, 0.6, 0.9), color: kError);
  b.texto('2a aumentada (3 semitonos)', Offset((xa + xb) / 2, y - 34),
      size: 9.5, color: kError, prog: _et(t, 0.7, 0.95), maxW: s.width);
  b.texto('subir el 7 grado crea la sensible -> cadencia fuerte hacia el i',
      Offset(s.width / 2, y + h + 16),
      size: 9, color: kTextoTenue, prog: _et(t, 0.8, 1), maxW: s.width - 6);
}

// ---- Escala disminuida: T-ST-T-ST... simetrica -----------------------
void _escalaDisminuida(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  const pasos = ['T', 'ST', 'T', 'ST', 'T', 'ST', 'T', 'ST'];
  final m = 16.0;
  final w = (s.width - 2 * m) / (pasos.length + 1);
  final y = s.height * 0.5;
  for (var i = 0; i <= pasos.length; i++) {
    final cx = m + i * w + w / 2;
    final prog = _et(t, i * 0.08, i * 0.08 + 0.4);
    b.punto(Offset(cx, y), r: 4, color: kAcento, prog: prog);
    if (i < pasos.length) {
      final esST = pasos[i] == 'ST';
      b.texto(pasos[i], Offset(cx + w / 2, y - 14),
          size: 9.5,
          color: esST ? _cian : kAviso,
          prog: _et(t, i * 0.08 + 0.15, i * 0.08 + 0.5));
      b.linea(Offset(cx + 4, y), Offset(cx + w - 4, y),
          prog: prog, color: esST ? _cian : kAviso, grosor: esST ? 2 : 2.8);
    }
  }
  b.texto('8 notas . el patron se repite cada 3 semitonos -> es simetrica',
      Offset(s.width / 2, y + 26),
      size: 9.5, color: kTextoTenue, prog: _et(t, 0.85, 1), maxW: s.width - 8);
}

// ---- Tonos enteros: solo tonos, flota ---------------------------
void _tonosEnteros(Canvas c, Size s, double t, _Boceto b) {
  b.reiniciar();
  const notas = ['DO', 'RE', 'MI', 'FA#', 'SOL#', 'LA#', 'DO'];
  final m = 16.0;
  final w = (s.width - 2 * m) / notas.length;
  final y = s.height * 0.46;
  for (var i = 0; i < notas.length; i++) {
    final cx = m + i * w + w / 2;
    final prog = _et(t, i * 0.1, i * 0.1 + 0.45);
    b.circulo(Offset(cx, y), 13,
        prog: prog, borde: kAcento, relleno: kAcento.withValues(alpha: 0.12));
    b.texto(notas[i], Offset(cx, y), size: 8.5, color: kTexto, prog: prog);
    if (i < notas.length - 1) {
      b.texto('T', Offset(cx + w / 2, y - 20),
          size: 10,
          color: kAviso,
          prog: _et(t, i * 0.1 + 0.2, i * 0.1 + 0.55));
    }
  }
  b.texto('todos los pasos iguales . sin semitonos ni tritono -> no hay donde caer',
      Offset(s.width / 2, y + 28),
      size: 9, color: kTextoTenue, prog: _et(t, 0.85, 1), maxW: s.width - 8);
}
