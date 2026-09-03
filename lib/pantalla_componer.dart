// ===========================================================================
//  pantalla_componer.dart — la sección "Componer": un curso didáctico de
//  composición (motivo, frase, formas, armonía, melodía…), con diagramas
//  animados y ejemplos que suenan.
// ===========================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'animaciones.dart';
import 'bloques_didacticos.dart';
import 'gamificacion.dart';
import 'progreso.dart';
import 'tema.dart';
import 'tutorial.dart';

// ---------------------------------------------------------------------------
//  Modelo
// ---------------------------------------------------------------------------
class Modulo {
  final String id;
  final String parte;
  final String titulo;
  final String resumen;
  final List<Map<String, dynamic>> bloques;
  final List<String> verTambien;

  Modulo({
    required this.id,
    required this.parte,
    required this.titulo,
    required this.resumen,
    required this.bloques,
    required this.verTambien,
  });

  factory Modulo.fromJson(Map<String, dynamic> j) => Modulo(
        id: j['id'] as String,
        parte: j['parte'] as String? ?? '',
        titulo: j['titulo'] as String? ?? '',
        resumen: j['resumen'] as String? ?? '',
        bloques: [
          for (final b in (j['bloques'] as List? ?? const []))
            (b as Map<String, dynamic>),
        ],
        verTambien: [
          for (final v in (j['verTambien'] as List? ?? const [])) v as String,
        ],
      );

  String get claveProgreso => 'comp-$id';
}

Future<List<Modulo>> cargarComposicion() async {
  final texto = await rootBundle.loadString('assets/content/composicion.json');
  final data = jsonDecode(texto) as Map<String, dynamic>;
  return [
    for (final m in (data['modulos'] as List))
      Modulo.fromJson(m as Map<String, dynamic>),
  ];
}

// ---------------------------------------------------------------------------
//  Lista de módulos
// ---------------------------------------------------------------------------
class PantallaComponer extends StatefulWidget {
  const PantallaComponer({super.key});

  @override
  State<PantallaComponer> createState() => _PantallaComponerState();
}

class _PantallaComponerState extends State<PantallaComponer> {
  List<Modulo> modulos = [];
  Set<String> leidos = {};
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) mostrarTutorial(context, 'componer', tutComponer);
    });
  }

  Future<void> _cargar() async {
    final m = await cargarComposicion();
    final p = await Progreso.cargar();
    setState(() {
      modulos = m;
      leidos = p;
      cargando = false;
    });
  }

  Future<void> _abrir(Modulo m, int numero) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => PantallaModulo(modulo: m, numero: numero)),
    );
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final abajo = MediaQuery.paddingOf(context).bottom;
    // Partes en el orden en que aparecen.
    final partes = <String>[];
    for (final m in modulos) {
      if (!partes.contains(m.parte)) partes.add(m.parte);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Componer'), centerTitle: true),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(14, 14, 14, 28 + abajo),
              children: [
                Text(
                  'Un curso para aprender a componer: del motivo a la forma, '
                  'con diagramas y ejemplos que suenan.',
                  style: TextStyle(color: context.pal.textoTenue, height: 1.4),
                ),
                const SizedBox(height: 16),
                for (final parte in partes) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 10, 2, 8),
                    child: Text(parte.toUpperCase(),
                        style: TextStyle(
                            color: context.pal.acento,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5)),
                  ),
                  for (final m in modulos.where((x) => x.parte == parte))
                    EntradaAnimada(
                      retardo: Duration(
                          milliseconds: 40 + modulos.indexOf(m) * 40),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TarjetaModulo(
                          numero: modulos.indexOf(m) + 1,
                          modulo: m,
                          leido: leidos.contains(m.claveProgreso),
                          onTap: () =>
                              _abrir(m, modulos.indexOf(m) + 1),
                        ),
                      ),
                    ),
                ],
              ],
            ),
    );
  }
}

class _TarjetaModulo extends StatelessWidget {
  final int numero;
  final Modulo modulo;
  final bool leido;
  final VoidCallback onTap;

  const _TarjetaModulo({
    required this.numero,
    required this.modulo,
    required this.leido,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BotonRebote(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.pal.superficie,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.pal.borde),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: leido
                    ? context.pal.exito
                    : const Color(0xFFF472B6).withValues(alpha: 0.9),
              ),
              child: leido
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : Text('$numero',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(modulo.titulo,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: context.pal.texto)),
                  const SizedBox(height: 4),
                  Text(modulo.resumen,
                      style: TextStyle(
                          fontSize: 12.5, color: context.pal.textoTenue, height: 1.35)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward, size: 16, color: context.pal.textoTenue),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Lectura de un módulo
// ---------------------------------------------------------------------------
class PantallaModulo extends StatefulWidget {
  final Modulo modulo;
  final int numero;
  const PantallaModulo({super.key, required this.modulo, required this.numero});

  @override
  State<PantallaModulo> createState() => _PantallaModuloState();
}

class _PantallaModuloState extends State<PantallaModulo> {
  @override
  void initState() {
    super.initState();
    Progreso.marcarCompletado(widget.modulo.claveProgreso);
    Gamificacion.moduloLeido(widget.modulo.claveProgreso);
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.modulo;
    final abajo = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      appBar: AppBar(title: Text('${widget.numero}. ${m.titulo}')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + abajo),
        children: [
          Text(m.resumen,
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: context.pal.textoTenue,
                  height: 1.4)),
          const SizedBox(height: 14),
          VisorBloques(bloques: m.bloques),
        ],
      ),
    );
  }
}
