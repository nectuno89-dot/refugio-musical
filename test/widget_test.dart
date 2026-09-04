// Prueba mínima: la app se construye sin errores.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:clave/main.dart';

void main() {
  testWidgets('La app arranca', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ClaveApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    // El splash espera ~2.2s antes de navegar; dejamos correr ese temporizador
    // para no terminar el test con un Timer pendiente.
    await tester.pump(const Duration(seconds: 6));
    // La pantalla de Aprender, recién construida, arranca sus propias
    // animaciones de entrada escalonadas (EntradaAnimada); un segundo pump
    // corto las deja terminar también a ellas.
    await tester.pump(const Duration(milliseconds: 500));
  });
}
