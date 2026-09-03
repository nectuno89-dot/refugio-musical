// ===========================================================================
//  pantalla_wiki.dart — la wiki del Refugio Musical.
//  Índice por secciones + buscador + lectura de artículos con audio,
//  fuentes y "Ver también".
// ===========================================================================

import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

import 'diagramas.dart';
import 'ejercicio.dart' show sinAcentos;
import 'gamificacion.dart';
import 'tema.dart';
import 'tutorial.dart';

/// Abre una búsqueda web con el texto indicado (fallback cuando la wiki
/// no tiene el tema).
Future<void> buscarEnLaWeb(String consulta) async {
  final q = Uri.encodeComponent('$consulta música teoría');
  final uri = Uri.parse('https://www.google.com/search?q=$q');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class Fuente {
  final String titulo;
  final String url;
  const Fuente(this.titulo, this.url);
  factory Fuente.fromJson(Map<String, dynamic> j) =>
      Fuente(j['titulo'] as String? ?? j['url'] as String? ?? '',
          j['url'] as String? ?? '');
}

class Articulo {
  final String id;
  final String seccion;
  final String categoria;
  final String titulo;
  final String resumen;
  final List<String> cuerpo;
  final List<String> verTambien;
  final String? audio; // nombre de archivo en assets/audio (sin .wav)
  final String? imagen; // nombre de archivo en assets/img
  final List<Fuente> fuentes;

  Articulo({
    required this.id,
    required this.seccion,
    required this.categoria,
    required this.titulo,
    required this.resumen,
    required this.cuerpo,
    required this.verTambien,
    required this.audio,
    required this.imagen,
    required this.fuentes,
  });

  factory Articulo.fromJson(Map<String, dynamic> j) => Articulo(
        id: j['id'] as String,
        seccion: j['seccion'] as String,
        categoria: j['categoria'] as String? ?? '',
        titulo: j['titulo'] as String,
        resumen: j['resumen'] as String? ?? '',
        cuerpo:
            (j['cuerpo'] as List?)?.map((x) => x as String).toList() ?? const [],
        verTambien: (j['verTambien'] as List?)?.map((x) => x as String).toList() ??
            const [],
        audio: j['audio'] as String?,
        imagen: j['imagen'] as String?,
        fuentes: (j['fuentes'] as List?)
                ?.map((f) => Fuente.fromJson(f as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  String get textoBusqueda =>
      sinAcentos('$titulo $resumen ${cuerpo.join(" ")}');
}

const nombresSeccion = {
  'teoria': 'Teoría musical',
  'historia': 'Historia de la música',
  'compositores': 'Compositores y figuras',
  'instrumentos': 'Instrumentos',
  'produccion': 'Producción y tecnología',
  'teatro': 'Teatro',
  'danza': 'Danza',
  'teatro_musical': 'Teatro musical',
  'mitos': 'Teorías y rumores',
  'curiosidades': 'Curiosidades verificables',
};

Future<List<Articulo>> cargarWiki() async {
  final texto = await rootBundle.loadString('assets/content/wiki.json');
  final data = jsonDecode(texto) as Map<String, dynamic>;
  return (data['articulos'] as List)
      .map((a) => Articulo.fromJson(a as Map<String, dynamic>))
      .toList();
}

// ---------------------------------------------------------------------------
//  Pantalla principal
// ---------------------------------------------------------------------------
class PantallaWiki extends StatefulWidget {
  const PantallaWiki({super.key});

  @override
  State<PantallaWiki> createState() => _PantallaWikiState();
}

class _PantallaWikiState extends State<PantallaWiki> {
  List<Articulo> todos = [];
  bool cargando = true;
  String consulta = '';

  static const _orden = [
    'teoria', 'historia', 'compositores', 'instrumentos', 'produccion',
    'teatro', 'danza', 'teatro_musical', 'mitos', 'curiosidades',
  ];

  @override
  void initState() {
    super.initState();
    cargarWiki().then((a) {
      setState(() {
        todos = a;
        cargando = false;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) mostrarTutorial(context, 'wiki', tutWiki);
    });
  }

  void _abrir(Articulo a) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => PantallaArticulo(articulo: a, todos: todos)),
    );
  }

  // Búsqueda tolerante: divide en palabras y no exige coincidencia exacta.
  // Devuelve (coincidencias, relacionados).
  (List<Articulo>, List<Articulo>) _buscar(String consulta) {
    final tokens = sinAcentos(consulta.trim())
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return (const [], const []);

    int puntua(Articulo a) {
      final titulo = sinAcentos(a.titulo);
      var p = 0;
      for (final t in tokens) {
        if (titulo.contains(t)) p += 3;
        if (a.textoBusqueda.contains(t)) p += 1;
      }
      return p;
    }

    final exactas = todos
        .where((a) => tokens.every((t) => a.textoBusqueda.contains(t)))
        .toList()
      ..sort((x, y) => puntua(y).compareTo(puntua(x)));

    final relacionados = todos
        .where((a) =>
            !exactas.contains(a) &&
            tokens.any((t) => a.textoBusqueda.contains(t)))
        .toList()
      ..sort((x, y) => puntua(y).compareTo(puntua(x)));

    return (exactas, relacionados.take(12).toList());
  }

  @override
  Widget build(BuildContext context) {
    final buscando = consulta.trim().isNotEmpty;
    final (exactas, relacionados) = _buscar(consulta);
    final secciones = todos.map((a) => a.seccion).toSet().toList()
      ..sort((a, b) => _orden.indexOf(a).compareTo(_orden.indexOf(b)));

    return Scaffold(
      appBar: AppBar(title: const Text('Wiki'), centerTitle: true),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar en la wiki…',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: consulta.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => consulta = ''),
                            ),
                    ),
                    onChanged: (v) => setState(() => consulta = v),
                  ),
                ),
                Expanded(
                  child: buscando
                      ? _resultados(exactas, relacionados)
                      : ListView(
                          padding: EdgeInsets.only(
                              bottom: 16 +
                                  MediaQuery.paddingOf(context).bottom),
                          children: [
                            for (final s in secciones)
                              _CasillaSeccion(
                                seccion: s,
                                articulos:
                                    todos.where((a) => a.seccion == s).toList(),
                                onAbrir: _abrir,
                              ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Widget _fila(Articulo a) => ListTile(
        title: Text(a.titulo),
        subtitle: Text(
            '${nombresSeccion[a.seccion] ?? a.seccion} · ${a.resumen}',
            maxLines: 2, overflow: TextOverflow.ellipsis),
        onTap: () => _abrir(a),
      );

  Widget _resultados(List<Articulo> exactas, List<Articulo> relacionados) {
    final nada = exactas.isEmpty && relacionados.isEmpty;
    return ListView(
      padding:
          EdgeInsets.only(bottom: 16 + MediaQuery.paddingOf(context).bottom),
      children: [
        if (nada)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              'No hay ningún artículo en la wiki sobre «${consulta.trim()}». '
              'Puedes buscarlo en la web:',
              style: TextStyle(color: context.pal.textoTenue),
            ),
          ),
        for (final a in exactas) _fila(a),
        if (relacionados.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Relacionados',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (final a in relacionados) _fila(a),
        ],
        const Divider(height: 24),
        ListTile(
          leading: const Icon(Icons.open_in_new),
          title: Text('Buscar «${consulta.trim()}» en la web'),
          subtitle: const Text('Se abre el navegador'),
          onTap: () => buscarEnLaWeb(consulta.trim()),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _CasillaSeccion extends StatelessWidget {
  final String seccion;
  final List<Articulo> articulos;
  final void Function(Articulo) onAbrir;

  const _CasillaSeccion({
    required this.seccion,
    required this.articulos,
    required this.onAbrir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: seccion == 'teoria',
        leading: Icon(switch (seccion) {
          'mitos' => Icons.help_outline,
          'curiosidades' => Icons.lightbulb_outline,
          'compositores' => Icons.person_outline,
          'instrumentos' => Icons.piano,
          'produccion' => Icons.graphic_eq,
          'danza' => Icons.directions_run,
          _ => Icons.menu_book,
        }),
        title: Text(nombresSeccion[seccion] ?? seccion),
        subtitle: Text('${articulos.length} artículos'),
        children: [
          for (final a in articulos)
            ListTile(
              dense: true,
              title: Text(a.titulo),
              subtitle: Text(a.resumen,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onAbrir(a),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Lectura de un artículo
// ---------------------------------------------------------------------------
class PantallaArticulo extends StatefulWidget {
  final Articulo articulo;
  final List<Articulo> todos;

  const PantallaArticulo({
    super.key,
    required this.articulo,
    required this.todos,
  });

  @override
  State<PantallaArticulo> createState() => _PantallaArticuloState();
}

class _PantallaArticuloState extends State<PantallaArticulo> {
  final AudioPlayer _player = AudioPlayer();

  // Una clave por apartado (líneas "## ") para el índice navegable.
  late final Map<int, GlobalKey> _claves = {
    for (var i = 0; i < widget.articulo.cuerpo.length; i++)
      if (widget.articulo.cuerpo[i].startsWith('## ')) i: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    Gamificacion.articuloLeido(widget.articulo.id);
  }

  void _irA(int i) {
    final ctx = _claves[i]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          alignment: 0.05);
    }
  }

  /// "@@DIAGRAMA nombre | pie del diagrama" -> widget de diagrama animado.
  Widget _diagramaDeLinea(String linea) {
    final resto = linea.substring('@@DIAGRAMA '.length);
    final barra = resto.indexOf('|');
    final nombre = (barra >= 0 ? resto.substring(0, barra) : resto).trim();
    final pie = barra >= 0 ? resto.substring(barra + 1).trim() : null;
    return DiagramaAnimado(nombre, pie: pie, alto: 210);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _reproducir(String nombre) async {
    await _player.stop();
    await _player.play(AssetSource('audio/$nombre.wav'));
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.articulo;
    final relacionados = a.verTambien
        .expand((id) => widget.todos.where((x) => x.id == id))
        .toList();

    final indice = _claves.entries.toList();

    return Scaffold(
      appBar: AppBar(title: Text(nombresSeccion[a.seccion] ?? 'Wiki')),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, 20 + MediaQuery.paddingOf(context).bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Text(a.titulo, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(a.resumen,
              style: TextStyle(
                  fontStyle: FontStyle.italic, color: context.pal.textoTenue)),
          const SizedBox(height: 16),
          if (a.imagen != null && a.imagen!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/img/${a.imagen}',
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          if (a.audio != null && a.audio!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: OutlinedButton.icon(
                onPressed: () => _reproducir(a.audio!),
                icon: const Icon(Icons.volume_up),
                label: const Text('Escuchar ejemplo'),
              ),
            ),
          if (indice.length >= 3)
            Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: context.pal.superficieAlt,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.pal.borde),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('En este artículo',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  for (final e in indice)
                    InkWell(
                      onTap: () => _irA(e.key),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('•  ',
                                style: TextStyle(color: context.pal.acento)),
                            Expanded(
                              child: Text(
                                a.cuerpo[e.key].substring(3),
                                style: TextStyle(
                                    fontSize: 13,
                                    color: context.pal.acento,
                                    height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          for (var i = 0; i < a.cuerpo.length; i++)
            if (a.cuerpo[i].startsWith('## '))
              Padding(
                key: _claves[i],
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Text(a.cuerpo[i].substring(3),
                    style: Theme.of(context).textTheme.titleMedium),
              )
            else if (a.cuerpo[i].startsWith('@@DIAGRAMA '))
              _diagramaDeLinea(a.cuerpo[i])
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(a.cuerpo[i],
                    style: const TextStyle(height: 1.45)),
              ),
          if (relacionados.isNotEmpty) ...[
            const Divider(height: 32),
            const Text('Ver también',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in relacionados)
                  ActionChip(
                    label: Text(r.titulo),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PantallaArticulo(
                            articulo: r, todos: widget.todos),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (a.fuentes.isNotEmpty) ...[
            const Divider(height: 32),
            const Text('Fuentes',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            for (final f in a.fuentes)
              InkWell(
                onTap: f.url.isEmpty
                    ? null
                    : () => launchUrl(Uri.parse(f.url),
                        mode: LaunchMode.externalApplication),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    '· ${f.titulo}',
                    style: TextStyle(
                      fontSize: 12,
                      color: f.url.isEmpty
                          ? context.pal.textoTenue
                          : Theme.of(context).colorScheme.primary,
                      decoration: f.url.isEmpty
                          ? null
                          : TextDecoration.underline,
                    ),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
