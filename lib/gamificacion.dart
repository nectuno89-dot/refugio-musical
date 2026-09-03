// ===========================================================================
//  gamificacion.dart — racha, XP, niveles y logros.
//  Todo se guarda en el dispositivo con shared_preferences y sobrevive al
//  cerrar la app. No hay servidor: es tu progreso, para ti.
//
//  · La RACHA cuenta días seguidos con algo de actividad de aprendizaje
//    (acertar un ejercicio, terminar una lección, leer un módulo…). Si te
//    saltas un día entero, vuelve a cero.
//  · El XP sube con cada logro pequeño y te va subiendo de NIVEL.
//  · Los LOGROS son metas concretas que se desbloquean una vez.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Una meta desbloqueable. El texto es ameno; la condición se comprueba en
/// [Gamificacion._revisarLogros].
class Logro {
  final String id;
  final String nombre;
  final String desc;
  final IconData icono;
  const Logro(this.id, this.nombre, this.desc, this.icono);
}

class Gamificacion {
  // ---- Estado en memoria (espejo de lo guardado) ----
  static int xp = 0;
  static int racha = 0;
  static int mejorRacha = 0;
  static String? ultimaFecha; // 'aaaa-mm-dd' del último día con actividad
  static int ejerciciosAcertados = 0;
  static int leccionesCompletadas = 0;
  static Set<String> escalasVistas = <String>{};
  static Set<String> articulosLeidos = <String>{};
  static Set<String> modulosLeidos = <String>{};
  static Set<String> logros = <String>{};
  static Map<String, int> xpPorDia = <String, int>{};

  static bool _cargado = false;

  /// Se incrementa en cada cambio para que Perfil y la tira de racha se
  /// redibujen sin acoplarse a esta clase.
  static final ValueNotifier<int> cambios = ValueNotifier<int>(0);

  // ---- Niveles: (xp mínimo, nombre) en orden ascendente ----
  static const List<(int, String)> niveles = [
    (0, 'Aprendiz'),
    (100, 'Iniciado'),
    (250, 'Aficionado'),
    (500, 'Estudiante'),
    (900, 'Músico'),
    (1500, 'Intérprete'),
    (2400, 'Compositor'),
    (3600, 'Maestro'),
  ];

  // ---- Catálogo de logros ----
  static const List<Logro> catalogoLogros = [
    Logro('primera-leccion', 'Primer paso', 'Termina tu primera lección',
        Icons.school),
    Logro('racha-7', 'Constancia', 'Siete días seguidos sin fallar',
        Icons.local_fire_department),
    Logro('ejercicios-50', 'Rodaje', 'Acierta 50 ejercicios',
        Icons.fitness_center),
    Logro('escalas-20', 'Explorador', 'Escucha 20 escalas distintas',
        Icons.travel_explore),
    Logro('wiki-60', 'Ratón de biblioteca', 'Lee 60 artículos de la wiki',
        Icons.menu_book),
    Logro('compositor-17', 'Caja de herramientas',
        'Recorre los 17 módulos de Componer', Icons.edit_note),
  ];

  // =========================================================================
  //  Carga / guardado
  // =========================================================================
  static Future<void> cargar() async {
    if (_cargado) return;
    _cargado = true;
    final p = await SharedPreferences.getInstance();
    xp = p.getInt('g_xp') ?? 0;
    racha = p.getInt('g_racha') ?? 0;
    mejorRacha = p.getInt('g_mejor') ?? 0;
    ultimaFecha = p.getString('g_ultima');
    ejerciciosAcertados = p.getInt('g_ej') ?? 0;
    leccionesCompletadas = p.getInt('g_lec') ?? 0;
    escalasVistas = (p.getStringList('g_escalas') ?? const []).toSet();
    articulosLeidos = (p.getStringList('g_articulos') ?? const []).toSet();
    modulosLeidos = (p.getStringList('g_modulos') ?? const []).toSet();
    logros = (p.getStringList('g_logros') ?? const []).toSet();
    xpPorDia = _leerDias(p.getStringList('g_dias') ?? const []);

    // Si el último día con actividad no es hoy ni ayer, la racha está rota.
    if (ultimaFecha != _hoy && ultimaFecha != _ayer) racha = 0;
  }

  static Future<void> _guardar() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('g_xp', xp);
    await p.setInt('g_racha', racha);
    await p.setInt('g_mejor', mejorRacha);
    if (ultimaFecha != null) await p.setString('g_ultima', ultimaFecha!);
    await p.setInt('g_ej', ejerciciosAcertados);
    await p.setInt('g_lec', leccionesCompletadas);
    await p.setStringList('g_escalas', escalasVistas.toList());
    await p.setStringList('g_articulos', articulosLeidos.toList());
    await p.setStringList('g_modulos', modulosLeidos.toList());
    await p.setStringList('g_logros', logros.toList());
    await p.setStringList('g_dias', _escribirDias(xpPorDia));
    cambios.value++;
  }

  // =========================================================================
  //  Eventos (los llaman las pantallas). Devuelven los logros recién
  //  conseguidos por si se quiere avisar al usuario.
  // =========================================================================
  static Future<List<Logro>> ejercicioAcertado() {
    ejerciciosAcertados++;
    _tocarDia();
    _sumarXp(10);
    return _cerrar();
  }

  static Future<List<Logro>> leccionCompletada() {
    leccionesCompletadas++;
    _tocarDia();
    _sumarXp(40);
    return _cerrar();
  }

  static Future<List<Logro>> moduloLeido(String id) {
    final nuevo = modulosLeidos.add(id);
    _tocarDia();
    if (nuevo) _sumarXp(15);
    return _cerrar();
  }

  static Future<List<Logro>> escalaExplorada(String nombre) {
    final nuevo = escalasVistas.add(nombre);
    _tocarDia();
    if (nuevo) _sumarXp(4);
    return _cerrar();
  }

  static Future<List<Logro>> articuloLeido(String id) {
    final nuevo = articulosLeidos.add(id);
    if (nuevo) {
      _tocarDia();
      _sumarXp(3);
    }
    return _cerrar();
  }

  // =========================================================================
  //  Lógica interna
  // =========================================================================
  static final List<Logro> _nuevos = [];

  static void _sumarXp(int n) {
    xp += n;
    xpPorDia[_hoy] = (xpPorDia[_hoy] ?? 0) + n;
  }

  /// Marca que hoy hubo actividad y actualiza la racha.
  static void _tocarDia() {
    if (ultimaFecha == _hoy) return; // ya contaba hoy
    if (ultimaFecha == _ayer) {
      racha++;
    } else {
      racha = 1; // empieza de nuevo (hoy es el día 1)
    }
    ultimaFecha = _hoy;
    if (racha > mejorRacha) mejorRacha = racha;
  }

  static void _revisarLogros() {
    void ganar(String id) {
      if (logros.add(id)) {
        _nuevos.add(catalogoLogros.firstWhere((l) => l.id == id));
      }
    }

    if (leccionesCompletadas >= 1) ganar('primera-leccion');
    if (mejorRacha >= 7) ganar('racha-7');
    if (ejerciciosAcertados >= 50) ganar('ejercicios-50');
    if (escalasVistas.length >= 20) ganar('escalas-20');
    if (articulosLeidos.length >= 60) ganar('wiki-60');
    if (modulosLeidos.length >= 17) ganar('compositor-17');
  }

  static Future<List<Logro>> _cerrar() async {
    _nuevos.clear();
    _revisarLogros();
    final resultado = List<Logro>.from(_nuevos);
    await _guardar();
    return resultado;
  }

  // =========================================================================
  //  Consultas para la pantalla de Perfil
  // =========================================================================
  static int get nivelIndice {
    var idx = 0;
    for (var i = 0; i < niveles.length; i++) {
      if (xp >= niveles[i].$1) idx = i;
    }
    return idx;
  }

  static String get nivelNombre => niveles[nivelIndice].$2;

  /// XP con el que empezó el nivel actual.
  static int get xpBaseNivel => niveles[nivelIndice].$1;

  /// XP necesario para el siguiente nivel, o `null` si ya es el máximo.
  static int? get xpTechoNivel =>
      nivelIndice + 1 < niveles.length ? niveles[nivelIndice + 1].$1 : null;

  /// Nombre del siguiente nivel, o `null` si ya es el máximo.
  static String? get siguienteNivelNombre =>
      nivelIndice + 1 < niveles.length ? niveles[nivelIndice + 1].$2 : null;

  /// Progreso (0..1) dentro del nivel actual.
  static double get progresoNivel {
    final techo = xpTechoNivel;
    if (techo == null) return 1;
    final rango = techo - xpBaseNivel;
    if (rango <= 0) return 1;
    return ((xp - xpBaseNivel) / rango).clamp(0.0, 1.0);
  }

  /// Los últimos 7 días (de más antiguo a hoy) con su XP.
  static List<({DateTime dia, int xp})> ultimos7() {
    final hoy = DateTime.now();
    final base = DateTime(hoy.year, hoy.month, hoy.day);
    return [
      for (var k = 6; k >= 0; k--)
        (
          dia: base.subtract(Duration(days: k)),
          xp: xpPorDia[_fecha(base.subtract(Duration(days: k)))] ?? 0,
        ),
    ];
  }

  // ---- utilidades de fecha ----
  static String _fecha(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String get _hoy => _fecha(DateTime.now());
  static String get _ayer =>
      _fecha(DateTime.now().subtract(const Duration(days: 1)));

  static Map<String, int> _leerDias(List<String> lista) {
    final m = <String, int>{};
    for (final e in lista) {
      final i = e.indexOf('=');
      if (i > 0) {
        final v = int.tryParse(e.substring(i + 1));
        if (v != null) m[e.substring(0, i)] = v;
      }
    }
    return m;
  }

  static List<String> _escribirDias(Map<String, int> m) {
    final claves = m.keys.toList()..sort();
    // Nos quedamos con los últimos 21 días para no crecer sin límite.
    final recorte = claves.length > 21 ? claves.sublist(claves.length - 21) : claves;
    return [for (final k in recorte) '$k=${m[k]}'];
  }
}

/// Muestra un aviso breve por cada logro recién conseguido.
void avisarLogros(BuildContext context, List<Logro> nuevos) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  for (final l in nuevos) {
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(l.icono, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Logro desbloqueado: ${l.nombre}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
