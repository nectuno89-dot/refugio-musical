// Prueba mínima: la app se construye sin errores.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clave/main.dart';

void main() {
  testWidgets('La app arranca', (WidgetTester tester) async {
    await tester.pumpWidget(const ClaveApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
