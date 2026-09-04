// Pruebas de Gamificacion: racha, niveles y logros son la lógica más
// delicada de la app (fechas, umbrales) y la más fácil de romper sin darse
// cuenta. Como todo el estado es estático, cada test empieza reiniciándolo
// a mano en `setUp`.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:clave/gamificacion.dart';

String _fecha(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Gamificacion.xp = 0;
    Gamificacion.racha = 0;
    Gamificacion.mejorRacha = 0;
    Gamificacion.ultimaFecha = null;
    Gamificacion.ejerciciosAcertados = 0;
    Gamificacion.leccionesCompletadas = 0;
    Gamificacion.escalasVistas = {};
    Gamificacion.articulosLeidos = {};
    Gamificacion.modulosLeidos = {};
    Gamificacion.logros = {};
    Gamificacion.xpPorDia = {};
  });

  group('Niveles', () {
    test('0 XP es Aprendiz, con techo en 100', () {
      Gamificacion.xp = 0;
      expect(Gamificacion.nivelNombre, 'Aprendiz');
      expect(Gamificacion.nivelIndice, 0);
      expect(Gamificacion.xpTechoNivel, 100);
    });

    test('justo en el umbral ya cuenta para el nivel siguiente', () {
      Gamificacion.xp = 100;
      expect(Gamificacion.nivelNombre, 'Iniciado');
    });

    test('un punto por debajo del umbral, todavía el nivel anterior', () {
      Gamificacion.xp = 99;
      expect(Gamificacion.nivelNombre, 'Aprendiz');
    });

    test('el nivel máximo no tiene techo y el progreso es 100%', () {
      Gamificacion.xp = 999999;
      expect(Gamificacion.nivelNombre, 'Maestro');
      expect(Gamificacion.xpTechoNivel, isNull);
      expect(Gamificacion.progresoNivel, 1.0);
    });

    test('progresoNivel a mitad de camino entre dos niveles', () {
      // Estudiante empieza en 500, Músico en 900 (rango de 400).
      Gamificacion.xp = 700;
      expect(Gamificacion.nivelNombre, 'Estudiante');
      expect(Gamificacion.progresoNivel, closeTo(0.5, 0.001));
    });
  });

  group('Racha', () {
    test('la primera actividad de la app arranca la racha en 1', () async {
      await Gamificacion.ejercicioAcertado();
      expect(Gamificacion.racha, 1);
      expect(Gamificacion.mejorRacha, 1);
    });

    test('una segunda actividad el mismo día no duplica la racha', () async {
      await Gamificacion.ejercicioAcertado();
      final xpTrasLaPrimera = Gamificacion.xp;
      await Gamificacion.ejercicioAcertado();
      expect(Gamificacion.racha, 1);
      expect(Gamificacion.xp, xpTrasLaPrimera + 10); // el XP sí se acumula
    });

    test('actividad ayer + hoy incrementa la racha en uno', () async {
      final ayer = DateTime.now().subtract(const Duration(days: 1));
      Gamificacion.ultimaFecha = _fecha(ayer);
      Gamificacion.racha = 3;
      Gamificacion.mejorRacha = 3;
      await Gamificacion.ejercicioAcertado();
      expect(Gamificacion.racha, 4);
      expect(Gamificacion.mejorRacha, 4);
    });

    test('saltarse un día entero rompe la racha (vuelve a 1)', () async {
      final anteayer = DateTime.now().subtract(const Duration(days: 2));
      Gamificacion.ultimaFecha = _fecha(anteayer);
      Gamificacion.racha = 10;
      Gamificacion.mejorRacha = 10;
      await Gamificacion.ejercicioAcertado();
      expect(Gamificacion.racha, 1);
      expect(Gamificacion.mejorRacha, 10); // el récord no baja nunca
    });
  });

  group('Logros', () {
    test('terminar la primera lección desbloquea "primera-leccion"', () async {
      final nuevos = await Gamificacion.leccionCompletada();
      expect(nuevos.map((l) => l.id), contains('primera-leccion'));
    });

    test('un logro ya conseguido no se vuelve a avisar', () async {
      await Gamificacion.leccionCompletada();
      final segunda = await Gamificacion.leccionCompletada();
      expect(segunda, isEmpty);
    });

    test('"escalas-20" se desbloquea justo en la escala número 20', () async {
      for (var i = 1; i < 20; i++) {
        final nuevos = await Gamificacion.escalaExplorada('escala-$i');
        expect(nuevos, isEmpty, reason: 'no debe desbloquearse antes de la 20');
      }
      final ultimos = await Gamificacion.escalaExplorada('escala-20');
      expect(ultimos.map((l) => l.id), contains('escalas-20'));
    });

    test('explorar la misma escala dos veces cuenta como una sola', () async {
      await Gamificacion.escalaExplorada('DO mayor');
      await Gamificacion.escalaExplorada('DO mayor');
      expect(Gamificacion.escalasVistas.length, 1);
    });
  });

  group('ultimos7 (para el gráfico de Perfil)', () {
    test('sin actividad, los 7 días salen en 0', () {
      final dias = Gamificacion.ultimos7();
      expect(dias.length, 7);
      expect(dias.every((d) => d.xp == 0), isTrue);
    });

    test('el XP de hoy aparece en el último elemento', () async {
      await Gamificacion.ejercicioAcertado(); // suma 10 XP a hoy
      final dias = Gamificacion.ultimos7();
      expect(dias.last.xp, 10);
    });
  });
}
