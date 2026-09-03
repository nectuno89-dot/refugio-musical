// ===========================================================================
//  musica.dart — datos y utilidades musicales (sin interfaz).
// ===========================================================================

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Las 12 notas de la octava. Índice 0 = DO, 1 = DO#, ... 11 = SI.
const List<String> nombresNotas = [
  'DO', 'DO#', 'RE', 'RE#', 'MI', 'FA', 'FA#', 'SOL', 'SOL#', 'LA', 'LA#', 'SI',
];

/// La tecla DO del teclado suena como el DO central del piano (nota MIDI 60).
const int midiDeDo = 60;

/// Para cada una de las 12 notas: a qué LETRA corresponde (0=DO ... 6=SI)
/// y si lleva sostenido. Se usa para colocarlas en el pentagrama.
const List<int> letraDeNota = [0, 0, 1, 1, 2, 3, 3, 4, 4, 5, 5, 6];
const List<bool> tieneSostenido = [
  false, true, false, true, false, false, true, false, true, false, true, false,
];

/// Una escala: nombre + saltos en semitonos entre sus grados (suman 12).
class Escala {
  final String id;
  final String nombre;
  final List<int> pasos; // "pasosSemitonos" en el JSON
  final List<String> grados;
  final String formula; // "formulaTexto"
  final String caracter;

  const Escala({
    required this.id,
    required this.nombre,
    required this.pasos,
    required this.grados,
    required this.formula,
    required this.caracter,
  });

  factory Escala.fromJson(Map<String, dynamic> j) {
    return Escala(
      id: j['id'] as String,
      nombre: j['nombre'] as String,
      pasos: (j['pasosSemitonos'] as List).map((x) => x as int).toList(),
      grados:
          (j['grados'] as List?)?.map((x) => x as String).toList() ?? const [],
      formula: j['formulaTexto'] as String? ?? '',
      caracter: j['caracter'] as String? ?? '',
    );
  }
}

/// Lee assets/content/escalas.json y devuelve todas las escalas.
Future<List<Escala>> cargarEscalas() async {
  final texto = await rootBundle.loadString('assets/content/escalas.json');
  final data = jsonDecode(texto) as Map<String, dynamic>;
  final lista = data['escalas'] as List<dynamic>;
  return lista.map((e) => Escala.fromJson(e as Map<String, dynamic>)).toList();
}

/// Conjunto de notas (índices 0..11) que forman la escala.
Set<int> notasDeEscala(int tonica, List<int> pasos) {
  final resultado = <int>{tonica};
  int actual = tonica;
  for (final salto in pasos) {
    actual = (actual + salto) % 12;
    resultado.add(actual);
  }
  return resultado;
}

/// Notas MIDI de la escala, ascendente, incluida la octava final.
List<int> midisDeEscala(int tonica, List<int> pasos) {
  final resultado = <int>[midiDeDo + tonica];
  int actual = midiDeDo + tonica;
  for (final salto in pasos) {
    actual += salto;
    resultado.add(actual);
  }
  return resultado;
}

/// Ordena las notas de una escala empezando por la tónica (para listarlas).
List<int> ordenarDesdeTonica(Set<int> notas, int tonica) {
  final lista = notas.toList()..sort();
  return [
    ...lista.where((n) => n >= tonica),
    ...lista.where((n) => n < tonica),
  ];
}
