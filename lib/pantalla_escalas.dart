// ===========================================================================
//  pantalla_escalas.dart — explorador de escalas:
//  eliges tónica + escala; se muestra en pentagrama y teclado, y suena.
// ===========================================================================

import 'package:flutter/material.dart';

import 'gamificacion.dart';
import 'motor_audio.dart';
import 'musica.dart';
import 'pentagrama.dart';
import 'tema.dart';
import 'tutorial.dart';

class PantallaEscalas extends StatefulWidget {
  const PantallaEscalas({super.key});

  @override
  State<PantallaEscalas> createState() => _PantallaEscalasState();
}

class _PantallaEscalasState extends State<PantallaEscalas> {
  int tonica = 0;
  Escala? escala;
  List<Escala> escalas = [];
  bool cargando = true;
  bool sonando = false;

  final MotorAudio audio = MotorAudio();

  @override
  void initState() {
    super.initState();
    audio.inicia();
    _iniciar();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) mostrarTutorial(context, 'escalas', tutEscalas);
    });
  }

  Future<void> _iniciar() async {
    final lista = await cargarEscalas();
    setState(() {
      escalas = lista;
      escala = lista.first;
      cargando = false;
    });
  }

  @override
  void dispose() {
    audio.libera();
    super.dispose();
  }

  Future<void> _reproducirEscala() async {
    if (sonando || escala == null) return;
    Gamificacion.escalaExplorada('${nombresNotas[tonica]} ${escala!.nombre}');
    setState(() => sonando = true);
    for (final midi in midisDeEscala(tonica, escala!.pasos)) {
      await audio.pulsar(midi);
      await Future.delayed(const Duration(milliseconds: 300));
      await audio.cortar(midi); // recorta la nota antes de la siguiente
      await Future.delayed(const Duration(milliseconds: 40));
    }
    if (mounted) setState(() => sonando = false);
  }

  @override
  Widget build(BuildContext context) {
    if (cargando || escala == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final acento = Theme.of(context).colorScheme.primary;
    final e = escala!;
    final notas = notasDeEscala(tonica, e.pasos);
    final midis = midisDeEscala(tonica, e.pasos);
    final listadoNotas =
        ordenarDesdeTonica(notas, tonica).map((i) => nombresNotas[i]).join('   ');

    return Scaffold(
      appBar: AppBar(
        title: Text('Explorar escalas (${escalas.length})'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
            bottom: 16 + MediaQuery.paddingOf(context).bottom),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Tónica: '),
                    DropdownButton<int>(
                      value: tonica,
                      onChanged: (v) => setState(() => tonica = v!),
                      items: [
                        for (int i = 0; i < 12; i++)
                          DropdownMenuItem(
                              value: i, child: Text(nombresNotas[i])),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Escala: '),
                    DropdownButton<Escala>(
                      value: e,
                      onChanged: (v) => setState(() => escala = v!),
                      items: [
                        for (final x in escalas)
                          DropdownMenuItem(value: x, child: Text(x.nombre)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${nombresNotas[tonica]} · ${e.nombre}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 2),
            Text(listadoNotas, style: TextStyle(color: context.pal.textoTenue)),
            if (e.formula.isNotEmpty)
              Text(e.formula,
                  style: TextStyle(color: context.pal.textoTenue, fontSize: 12)),
            const SizedBox(height: 12),
            Pentagrama(midis: midis, color: acento),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: sonando ? null : _reproducirEscala,
              icon: const Icon(Icons.play_arrow),
              label: Text(sonando ? 'Sonando…' : 'Reproducir escala'),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 12; i++)
                    Tecla(
                      nombre: nombresNotas[i],
                      negra: nombresNotas[i].contains('#'),
                      encendida: notas.contains(i),
                      esTonica: i == tonica,
                      acento: acento,
                      onPress: () => audio.pulsar(midiDeDo + i),
                      onRelease: () => audio.soltar(midiDeDo + i),
                    ),
                ],
              ),
            ),
            if (e.caracter.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
                child: Text(e.caracter,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.pal.textoTenue, fontSize: 13)),
              ),
          ],
        ),
      ),
    );
  }
}
