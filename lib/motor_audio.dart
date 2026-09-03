// ===========================================================================
//  motor_audio.dart — reproduce sonidos de notas.
//  · pulsar/soltar: la nota SIEMPRE suena su decaída natural (~2,5 s). Solo
//    si mantienes la tecla pulsada más de _minMs, al soltar se aplica un
//    fundido de salida. Así un toque muy rápido igual suena de verdad.
//  · cortar: fuerza el fin de una nota (para reproducir escalas encadenadas).
//  · sonarMidi: disparo suelto que suena y decae solo (feedback).
// ===========================================================================

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

class _Nota {
  final AudioPlayer player;
  final DateTime inicio;
  Timer? timer;
  _Nota(this.player, this.inicio);
}

class MotorAudio {
  static const int _minMs = 850; // tiempo mínimo antes de que "soltar" corte
  static const int _muestraMs = 2600; // duración aprox. del wav

  final List<AudioPlayer> _oneShot = [];
  int _osIdx = 0;

  final List<AudioPlayer> _libres = [];
  final Map<int, _Nota> _sonando = {};
  final List<AudioPlayer> _todos = [];

  void inicia() {
    for (var i = 0; i < 6; i++) {
      final p = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      _oneShot.add(p);
      _todos.add(p);
    }
    for (var i = 0; i < 10; i++) {
      final p = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      _libres.add(p);
      _todos.add(p);
    }
  }

  // ---- Disparo suelto (feedback) --------------------------------------
  Future<void> sonarMidi(int midi) async {
    final p = _oneShot[_osIdx];
    _osIdx = (_osIdx + 1) % _oneShot.length;
    await p.stop();
    await p.setVolume(1.0);
    await p.play(AssetSource('notas/n$midi.wav'));
  }

  // ---- Tecla ----------------------------------------------------------
  Future<void> pulsar(int midi) async {
    final previa = _sonando.remove(midi);
    previa?.timer?.cancel();
    final AudioPlayer p = previa?.player ??
        (_libres.isNotEmpty
            ? _libres.removeLast()
            : _sonando.remove(_sonando.keys.first)!.player);

    final nota = _Nota(p, DateTime.now());
    _sonando[midi] = nota;
    await p.stop();
    await p.setVolume(1.0);
    await p.play(AssetSource('notas/n$midi.wav'));

    // Cuando el wav termina por sí solo, devuelve el reproductor a la reserva.
    nota.timer = Timer(const Duration(milliseconds: _muestraMs), () {
      if (identical(_sonando[midi], nota)) {
        _sonando.remove(midi);
        _libres.add(p);
      }
    });
  }

  /// El usuario suelta la tecla: si la mantuvo poco, se deja sonar (decaída
  /// natural); si la mantuvo un rato, se hace un fundido de salida.
  Future<void> soltar(int midi) async {
    final nota = _sonando[midi];
    if (nota == null) return;
    final trans = DateTime.now().difference(nota.inicio).inMilliseconds;
    if (trans < _minMs) return; // toque corto: que suene entero
    await _fundir(midi);
  }

  /// Fuerza el fin de la nota ya (reproducción de escalas encadenadas).
  Future<void> cortar(int midi) => _fundir(midi);

  Future<void> _fundir(int midi) async {
    final nota = _sonando.remove(midi);
    if (nota == null) return;
    nota.timer?.cancel();
    final p = nota.player;
    var v = 0.9;
    for (var i = 0; i < 12; i++) {
      v *= 0.6;
      await p.setVolume(v);
      await Future<void>.delayed(const Duration(milliseconds: 9));
    }
    await p.setVolume(0.0);
    _libres.add(p);
  }

  void libera() {
    for (final n in _sonando.values) {
      n.timer?.cancel();
    }
    for (final p in _todos) {
      p.dispose();
    }
  }
}
