// ===========================================================================
//  onboarding.dart — controla qué mini-tutoriales ha visto ya el usuario.
//  · Cada pantalla clave tiene una "clave" y su tutorial se muestra una sola
//    vez (la primera).
//  · Se pueden desactivar por completo desde Ajustes, o reiniciar para
//    volver a verlos.
// ===========================================================================

import 'package:shared_preferences/shared_preferences.dart';

class Onboarding {
  static bool habilitado = true;
  static Set<String> _vistos = <String>{};
  static bool _cargado = false;

  static Future<void> cargar() async {
    if (_cargado) return;
    _cargado = true;
    final p = await SharedPreferences.getInstance();
    habilitado = p.getBool('onb_habilitado') ?? true;
    _vistos = (p.getStringList('onb_vistos') ?? const <String>[]).toSet();
  }

  /// ¿Toca mostrar el tutorial de esta pantalla?
  static bool pendiente(String clave) =>
      habilitado && !_vistos.contains(clave);

  static Future<void> marcarVisto(String clave) async {
    _vistos.add(clave);
    final p = await SharedPreferences.getInstance();
    await p.setStringList('onb_vistos', _vistos.toList());
  }

  static Future<void> setHabilitado(bool v) async {
    habilitado = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool('onb_habilitado', v);
  }

  /// Vuelve a activar y a marcar como "no vistos" todos los tutoriales.
  static Future<void> reiniciar() async {
    _vistos.clear();
    habilitado = true;
    final p = await SharedPreferences.getInstance();
    await p.setStringList('onb_vistos', const <String>[]);
    await p.setBool('onb_habilitado', true);
  }
}
