// Pruebas de los "fromJson" y de las funciones puras de música. Son la
// mejor documentación de cómo debe verse el contenido en assets/content/*.json
// y atrapan errores de parseo antes de que lleguen a la app.

import 'package:flutter_test/flutter_test.dart';

import 'package:clave/ejercicio.dart';
import 'package:clave/musica.dart';
import 'package:clave/pantalla_componer.dart';
import 'package:clave/pantalla_leccion.dart';

void main() {
  group('Ejercicio.fromJson', () {
    test('opcion_multiple: "correcta" es un índice entero', () {
      final e = Ejercicio.fromJson({
        'id': 'ej-1',
        'nivel': 2,
        'tipo': 'opcion_multiple',
        'enunciado': '¿Cuántos sostenidos tiene RE mayor?',
        'opciones': ['1', '2', '3'],
        'correcta': 1,
        'explicacion': 'RE mayor lleva FA# y DO#.',
      });
      expect(e.correcta, 1);
      expect(e.correctaVF, isNull);
      expect(e.soportado, isTrue);
    });

    test('verdadero_falso: "correcta" es un booleano, no un índice', () {
      final e = Ejercicio.fromJson({
        'id': 'ej-2',
        'tipo': 'verdadero_falso',
        'enunciado': 'DO mayor y LA menor son relativas.',
        'correcta': true,
      });
      expect(e.correctaVF, isTrue);
      expect(e.correcta, -1); // no es opcion_multiple: sin índice válido
    });

    test('valores opcionales ausentes usan defaults seguros', () {
      final e = Ejercicio.fromJson({'id': 'ej-3', 'tipo': 'completar'});
      expect(e.nivel, 1);
      expect(e.enunciado, '');
      expect(e.opciones, isEmpty);
      expect(e.respuestas, isEmpty);
      expect(e.midi, isNull);
      expect(e.pista, '');
    });

    test('soportado es falso para un tipo no reconocido', () {
      final e = Ejercicio.fromJson({'id': 'ej-4', 'tipo': 'algo_nuevo'});
      expect(e.soportado, isFalse);
    });
  });

  group('Escala.fromJson', () {
    test('parsea los campos con sus nombres reales en el JSON', () {
      final esc = Escala.fromJson({
        'id': 'mayor',
        'nombre': 'Escala mayor',
        'pasosSemitonos': [2, 2, 1, 2, 2, 2, 1],
        'grados': ['1', '2', '3', '4', '5', '6', '7'],
        'formulaTexto': 'T-T-ST-T-T-T-ST',
        'caracter': 'Alegre y resuelto.',
      });
      expect(esc.pasos, [2, 2, 1, 2, 2, 2, 1]);
      expect(esc.formula, 'T-T-ST-T-T-T-ST');
    });

    test('grados/formula/caracter son opcionales', () {
      final esc = Escala.fromJson({
        'id': 'x',
        'nombre': 'X',
        'pasosSemitonos': [2, 2, 1, 2, 2, 2, 1],
      });
      expect(esc.grados, isEmpty);
      expect(esc.formula, '');
      expect(esc.caracter, '');
    });
  });

  group('Funciones puras de música', () {
    test('midisDeEscala: DO mayor desde DO (tónica 0)', () {
      final midis = midisDeEscala(0, [2, 2, 1, 2, 2, 2, 1]);
      expect(midis, [60, 62, 64, 65, 67, 69, 71, 72]);
    });

    test('midisDeEscala: la escala siempre cierra en la octava', () {
      final midis = midisDeEscala(4, [2, 2, 1, 2, 2, 2, 1]); // desde MI
      expect(midis.first + 12, midis.last);
    });

    test('notasDeEscala: DO mayor tiene 7 clases de nota distintas', () {
      final notas = notasDeEscala(0, [2, 2, 1, 2, 2, 2, 1]);
      expect(notas, {0, 2, 4, 5, 7, 9, 11});
    });

    test('ordenarDesdeTonica: reordena empezando por la tónica', () {
      final notas = notasDeEscala(7, [2, 2, 1, 2, 2, 2, 1]); // SOL mayor
      final orden = ordenarDesdeTonica(notas, 7);
      expect(orden.first, 7); // empieza en SOL
      expect(orden.length, notas.length);
    });
  });

  group('Leccion.fromJson', () {
    test('acepta bloques de texto viejos (String suelto) y nuevos (Map)', () {
      final l = Leccion.fromJson({
        'id': 'lec-1-1',
        'nivel': 1,
        'titulo': 'Prueba',
        'objetivo': 'Probar el parseo.',
        'intro': [
          'Un párrafo suelto (formato antiguo).',
          {'tipo': 'clave', 'titulo': 'Ojo', 'texto': 'Un recuadro.'},
        ],
        'ejercicios': [
          {'id': 'ej-1', 'tipo': 'verdadero_falso', 'correcta': true},
        ],
      });
      expect(l.intro[0]['tipo'], 'texto');
      expect(l.intro[0]['texto'], 'Un párrafo suelto (formato antiguo).');
      expect(l.intro[1]['tipo'], 'clave');
      expect(l.ejercicios, hasLength(1));
    });
  });

  group('Modulo.fromJson', () {
    test('claveProgreso antepone "comp-" al id', () {
      final m = Modulo.fromJson({
        'id': '03-frase',
        'parte': 'La idea y su desarrollo',
        'titulo': 'Frase y período',
        'resumen': 'La música respira en frases.',
        'bloques': [
          {'tipo': 'texto', 'texto': 'Hola'},
        ],
      });
      expect(m.claveProgreso, 'comp-03-frase');
      expect(m.bloques, hasLength(1));
      expect(m.verTambien, isEmpty);
    });
  });
}
