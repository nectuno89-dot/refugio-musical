// ===========================================================================
//  progreso.dart — guarda qué ejercicios están completados.
//  Usa shared_preferences: los datos quedan en el dispositivo y sobreviven
//  al cerrar la app.
// ===========================================================================

import 'package:shared_preferences/shared_preferences.dart';

class Progreso {
  static const _clave = 'ejercicios_completados';

  static Future<Set<String>> cargar() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList(_clave) ?? const <String>[]).toSet();
  }

  static Future<void> marcarCompletado(String id) async {
    final p = await SharedPreferences.getInstance();
    final s = (p.getStringList(_clave) ?? const <String>[]).toSet()..add(id);
    await p.setStringList(_clave, s.toList());
  }

  /// Borra el progreso solo de los ids indicados (p. ej. los de una materia).
  /// Deja intacto el progreso de las demás.
  static Future<void> reiniciar(Iterable<String> ids) async {
    final p = await SharedPreferences.getInstance();
    final actuales = (p.getStringList(_clave) ?? const <String>[]).toSet();
    actuales.removeAll(ids);
    await p.setStringList(_clave, actuales.toList());
  }
}
