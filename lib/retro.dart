// ===========================================================================
//  retro.dart — micro-feedback al tocar: una vibración mínima + un sonido
//  muy breve. Se usa en botones (BotonRebote) y en las teclas del piano.
//  El usuario puede desactivar la vibración y/o el sonido desde Ajustes.
// ===========================================================================

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Retro {
  static bool haptica = true;
  static bool sonido = true;
  static bool _prefsCargadas = false;

  // Pequeña reserva de reproductores para el 'tic' (permite toques rápidos).
  static final List<AudioPlayer> _pool = List.generate(
    4,
    (_) => AudioPlayer()..setReleaseMode(ReleaseMode.stop),
  );
  static int _idx = 0;

  /// Carga las preferencias guardadas. Llamar una vez al arrancar.
  static Future<void> cargar() async {
    if (_prefsCargadas) return;
    _prefsCargadas = true;
    final p = await SharedPreferences.getInstance();
    haptica = p.getBool('retro_haptica') ?? true;
    sonido = p.getBool('retro_sonido') ?? true;
  }

  static Future<void> setHaptica(bool v) async {
    haptica = v;
    (await SharedPreferences.getInstance()).setBool('retro_haptica', v);
  }

  static Future<void> setSonido(bool v) async {
    sonido = v;
    (await SharedPreferences.getInstance()).setBool('retro_sonido', v);
  }

  /// Toque de botón / chip / celda: vibración de selección + 'tic' suave.
  static void toque() {
    if (haptica) HapticFeedback.selectionClick();
    if (sonido) _tic(0.28);
  }

  /// Tecla del piano: solo vibración (el sonido de la nota ya es el "sonido").
  static void tecla() {
    if (haptica) HapticFeedback.lightImpact();
  }

  static void _tic(double vol) {
    final p = _pool[_idx];
    _idx = (_idx + 1) % _pool.length;
    // sin await: el toque no debe esperar al audio
    p.stop();
    p.setVolume(vol);
    p.play(AssetSource('audio/tap.wav'));
  }
}
