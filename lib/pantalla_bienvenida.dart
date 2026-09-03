// ===========================================================================
//  pantalla_bienvenida.dart — pantalla inicial / de carga.
//  Muestra un mensaje ameno mientras la app "respira" antes de entrar.
// ===========================================================================

import 'package:flutter/material.dart';

import 'musica.dart';
import 'pantalla_principal.dart';

class PantallaBienvenida extends StatefulWidget {
  const PantallaBienvenida({super.key});

  @override
  State<PantallaBienvenida> createState() => _PantallaBienvenidaState();
}

class _PantallaBienvenidaState extends State<PantallaBienvenida> {
  double _opacidad = 0; // para el efecto de aparición suave

  @override
  void initState() {
    super.initState();
    // Aparecer con suavidad justo después del primer fotograma.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _opacidad = 1);
    });
    _entrar();
  }

  Future<void> _entrar() async {
    // Espera lo que tarde en cargar el contenido, con un mínimo de 2 s para
    // que el mensaje se pueda leer.
    await Future.wait([
      cargarEscalas(), // precarga: así la siguiente pantalla ya la tiene lista
      Future<void>.delayed(const Duration(milliseconds: 2200)),
    ]);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, anim, _) => const PantallaPrincipal(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3B3E53), Color(0xFF6C6F86), Color(0xFF83869A)],
            stops: [0.0, 0.72, 1.0],
          ),
        ),
        child: Center(
          child: AnimatedOpacity(
            opacity: _opacidad,
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/brand/mark_white.png',
                    width: 200, filterQuality: FilterQuality.medium),
                const SizedBox(height: 26),
                const Text(
                  'Refugio Musical',
                  style: TextStyle(
                    color: Color(0xFFF1F4FA),
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Bienvenido a tu refugio musical',
                  style: TextStyle(color: Color(0xCCEFF3FA), fontSize: 15),
                ),
                const SizedBox(height: 40),
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(Color(0xFFB9AEEC)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
