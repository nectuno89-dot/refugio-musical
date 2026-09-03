// ===========================================================================
//  Clave — punto de entrada. Solo monta la app y abre la pantalla inicial.
// ===========================================================================

import 'package:flutter/material.dart';

import 'gamificacion.dart';
import 'onboarding.dart';
import 'pantalla_bienvenida.dart';
import 'retro.dart';
import 'tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Retro.cargar();
  await Onboarding.cargar();
  await Gamificacion.cargar();
  await cargarModoTema();
  runApp(const ClaveApp());
}

class ClaveApp extends StatelessWidget {
  const ClaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: modoTema,
      builder: (context, modo, _) => MaterialApp(
        title: 'Refugio Musical',
        debugShowCheckedModeBanner: false,
        theme: temaClaro(),
        darkTheme: temaOscuro(),
        themeMode: modo,
        home: const PantallaBienvenida(),
        builder: (context, child) => Stack(
          children: [
            ?child,
            // Marca de agua discreta, abajo a la derecha, en toda la app.
            Positioned(
              right: 10,
              bottom: 4,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.16,
                  child: Text(
                    'H&M',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: context.pal.texto,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
