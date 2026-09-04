// ===========================================================================
//  bloques_didacticos.dart — motor de bloques de contenido reutilizable para
//  las secciones que "enseñan" (Lecciones y Componer).
//
//  Un bloque es un Map con 'tipo':
//    texto      -> {texto}            (prefijo "## " = subtítulo; admite **negrita**)
//    clave      -> {titulo, texto}    (recuadro de idea clave)
//    lista      -> {items:[...]}      (viñetas, admiten **negrita**)
//    tabla      -> {titulo?, filas:[[izq,der], ...]}
//    pasos      -> {titulo?, pasos:['T','T','ST', ...]}   (patrón tono/semitono)
//    diagrama   -> {nombre, alto?, pie?}                  (DiagramaAnimado)
//    escala     -> {tonicaIdx, pasos:[int], titulo?}      (pentagrama + escuchar)
//    nota       -> {midi, titulo?}                        (una nota + escuchar)
//    audio      -> {archivo, titulo?}                     (wav de assets/audio)
// ===========================================================================

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'animaciones.dart';
import 'diagramas.dart';
import 'motor_audio.dart';
import 'musica.dart';
import 'pentagrama.dart';
import 'tema.dart';

// ---------------------------------------------------------------------------
//  Texto con **negritas** simples.
// ---------------------------------------------------------------------------
class RicoTexto extends StatelessWidget {
  final String texto;
  final double size;
  const RicoTexto(this.texto, {super.key, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final re = RegExp(r'\*\*(.+?)\*\*');
    var i = 0;
    for (final match in re.allMatches(texto)) {
      if (match.start > i) {
        spans.add(TextSpan(text: texto.substring(i, match.start)));
      }
      spans.add(TextSpan(
          text: match.group(1),
          style: TextStyle(
              fontWeight: FontWeight.w700, color: context.pal.texto)));
      i = match.end;
    }
    if (i < texto.length) spans.add(TextSpan(text: texto.substring(i)));
    return Text.rich(
      TextSpan(children: spans),
      style: TextStyle(fontSize: size, height: 1.5, color: context.pal.texto),
    );
  }
}

// ---------------------------------------------------------------------------
//  Visor de una lista de bloques. Gestiona su propio audio.
// ---------------------------------------------------------------------------
class VisorBloques extends StatefulWidget {
  final List<Map<String, dynamic>> bloques;
  const VisorBloques({super.key, required this.bloques});

  @override
  State<VisorBloques> createState() => _VisorBloquesState();
}

class _VisorBloquesState extends State<VisorBloques> {
  MotorAudio? _audio;
  AudioPlayer? _wav;

  MotorAudio _motor() => _audio ??= (MotorAudio()..inicia());

  @override
  void dispose() {
    _audio?.libera();
    _wav?.dispose();
    super.dispose();
  }

  Future<void> _tocarSecuencia(List<int> midis) async {
    final a = _motor();
    for (final m in midis) {
      await a.pulsar(m);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await a.cortar(m);
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
  }

  Future<void> _tocarWav(String archivo) async {
    _wav ??= AudioPlayer();
    await _wav!.stop();
    await _wav!.play(AssetSource('audio/$archivo.wav'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final b in widget.bloques) _bloque(b)],
    );
  }

  Widget _bloque(Map<String, dynamic> b) {
    switch (b['tipo'] as String? ?? '') {
      case 'texto':
        return _bloqueTexto(b);
      case 'clave':
        return _bloqueClave(b);
      case 'lista':
        return _bloqueLista(b);
      case 'tabla':
        return _bloqueTabla(b);
      case 'pasos':
        return _bloquePasos(b);
      case 'diagrama':
        return _bloqueDiagrama(b);
      case 'audio':
        return _bloqueAudio(b);
      case 'escala':
        return _bloqueEscala(b);
      case 'nota':
        return _bloqueNota(b);
      default:
        return const SizedBox.shrink();
    }
  }

  /// 'texto' -> {texto}. Un prefijo "## " lo convierte en subtítulo de sección.
  Widget _bloqueTexto(Map<String, dynamic> b) {
    final s = b['texto'] as String? ?? '';
    if (s.startsWith('## ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 4),
        child: Text(s.substring(3),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RicoTexto(s),
    );
  }

  /// 'clave' -> {titulo, texto}. Recuadro destacado para una idea clave.
  Widget _bloqueClave(Map<String, dynamic> b) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.pal.aviso.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.pal.aviso.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, size: 16, color: context.pal.aviso),
              const SizedBox(width: 6),
              Expanded(
                child: Text(b['titulo'] as String? ?? '',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: context.pal.aviso)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          RicoTexto(b['texto'] as String? ?? '', size: 13),
        ],
      ),
    );
  }

  /// 'lista' -> {items:[...]}. Viñetas, cada ítem admite **negrita**.
  Widget _bloqueLista(Map<String, dynamic> b) {
    final items =
        (b['items'] as List? ?? const []).map((x) => x as String).toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final it in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: TextStyle(color: context.pal.acento)),
                  Expanded(child: RicoTexto(it, size: 13.5)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 'tabla' -> {titulo?, filas:[[izq,der], ...]}.
  Widget _bloqueTabla(Map<String, dynamic> b) {
    final filas = (b['filas'] as List? ?? const [])
        .map((r) => (r as List).map((x) => '$x').toList())
        .toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: context.pal.borde),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if ((b['titulo'] as String? ?? '').isNotEmpty)
            Container(
              width: double.infinity,
              color: context.pal.superficieAlt,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(b['titulo'] as String,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          for (var i = 0; i < filas.length; i++) _filaTabla(filas[i], i),
        ],
      ),
    );
  }

  Widget _filaTabla(List<String> fila, int i) {
    return Container(
      decoration: BoxDecoration(
        color: i.isEven
            ? Colors.transparent
            : context.pal.superficieAlt.withValues(alpha: 0.5),
        border:
            i == 0 ? null : Border(top: BorderSide(color: context.pal.borde)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: RicoTexto(fila.isNotEmpty ? fila[0] : '', size: 12.5),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: RicoTexto(fila.length > 1 ? fila[1] : '', size: 12.5),
          ),
        ],
      ),
    );
  }

  /// 'pasos' -> {titulo?, pasos:['T','T','ST', ...]}. Patrón tono/semitono.
  Widget _bloquePasos(Map<String, dynamic> b) {
    final pasos =
        (b['pasos'] as List? ?? const []).map((x) => '$x').toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.pal.superficieAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((b['titulo'] as String? ?? '').isNotEmpty) ...[
            Text(b['titulo'] as String,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 12.5)),
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (var i = 0; i < pasos.length; i++) ...[
                if (i > 0)
                  Icon(Icons.arrow_forward,
                      size: 13, color: context.pal.textoTenue),
                _chipPaso(pasos[i]),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text('T = tono · ST = semitono',
              style: TextStyle(fontSize: 10.5, color: context.pal.textoTenue)),
        ],
      ),
    );
  }

  Widget _chipPaso(String paso) {
    final esSemitono = paso.toUpperCase().startsWith('ST') || paso == '½';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: context.pal.acento.withValues(alpha: esSemitono ? 0.22 : 0.08),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: context.pal.acento.withValues(alpha: 0.4)),
      ),
      child: Text(paso,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.pal.texto)),
    );
  }

  /// 'diagrama' -> {nombre, alto?, pie?}.
  Widget _bloqueDiagrama(Map<String, dynamic> b) {
    return DiagramaAnimado(
      b['nombre'] as String? ?? '',
      alto: (b['alto'] as num?)?.toDouble() ?? 200,
      pie: b['pie'] as String?,
    );
  }

  /// 'audio' -> {archivo, titulo?}. Un wav de assets/audio.
  Widget _bloqueAudio(Map<String, dynamic> b) {
    return _tarjeta(
      titulo: b['titulo'] as String? ?? 'Escucha este ejemplo',
      hijo: null,
      onPlay: () => _tocarWav(b['archivo'] as String? ?? ''),
    );
  }

  /// 'escala' -> {tonicaIdx, pasos:[int], titulo?}. Pentagrama + escuchar.
  Widget _bloqueEscala(Map<String, dynamic> b) {
    final acento = Theme.of(context).colorScheme.primary;
    final idx = (b['tonicaIdx'] as num?)?.toInt() ?? 0;
    final pasos = (b['pasos'] as List? ?? const [])
        .map((x) => (x as num).toInt())
        .toList();
    final midis = midisDeEscala(idx, pasos);
    return _tarjeta(
      titulo: b['titulo'] as String? ?? b['nota'] as String? ?? 'Ejemplo',
      hijo: Pentagrama(midis: midis, color: acento),
      onPlay: () => _tocarSecuencia(midis),
    );
  }

  /// 'nota' -> {midi, titulo?}. Una nota + escuchar.
  Widget _bloqueNota(Map<String, dynamic> b) {
    final acento = Theme.of(context).colorScheme.primary;
    final midi = (b['midi'] as num?)?.toInt() ?? 60;
    return _tarjeta(
      titulo: b['titulo'] as String? ?? b['nota'] as String? ?? 'Ejemplo',
      hijo: Pentagrama(midis: [midi], color: acento),
      onPlay: () => _tocarSecuencia([midi]),
    );
  }

  Widget _tarjeta({
    required String titulo,
    required Widget? hijo,
    required VoidCallback onPlay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.pal.superficieAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.graphic_eq, size: 16, color: context.pal.textoTenue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(titulo,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          if (hijo != null) ...[const SizedBox(height: 8), hijo],
          const SizedBox(height: 8),
          BotonRebote(
            onTap: onPlay,
            child: OutlinedButton.icon(
              onPressed: onPlay,
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Escuchar'),
            ),
          ),
        ],
      ),
    );
  }
}
