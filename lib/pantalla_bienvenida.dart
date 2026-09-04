// ===========================================================================
//  pantalla_bienvenida.dart — pantalla inicial / de carga.
//  Muestra un mensaje ameno mientras la app "respira" antes de entrar.
// ===========================================================================

import 'package:flutter/material.dart';

import 'musica.dart';
import 'pantalla_principal.dart';

// ---------------------------------------------------------------------------
//  Constantes del splash. El splash es una pantalla de marca fija (no usa
//  context.pal porque no cambia con el tema claro/oscuro), así que sus
//  colores y medidas viven aquí, con nombre, en vez de sueltas en el build().
// ---------------------------------------------------------------------------
const _colorFondoArriba = Color(0xFF3B3E53);
const _colorFondoMedio = Color(0xFF6C6F86);
const _colorFondoAbajo = Color(0xFF83869A);
const _colorTitulo = Color(0xFFF1F4FA);
const _colorSubtitulo = Color(0xCCEFF3FA);
const _colorSpinner = Color(0xFFB9AEEC);

const _anchoLogo = 200.0;
const _tamanoSpinner = 26.0;
const _grosorSpinner = 2.4;

const _espacioLogoTitulo = 26.0;
const _espacioTituloSubtitulo = 10.0;
const _espacioSubtituloSpinner = 40.0;

const _duracionAparicion = Duration(milliseconds: 900);
const _duracionMinimaEnPantalla = Duration(milliseconds: 2200);
const _duracionTransicionSalida = Duration(milliseconds: 500);

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
      Future<void>.delayed(_duracionMinimaEnPantalla),
    ]);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: _duracionTransicionSalida,
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
            colors: [_colorFondoArriba, _colorFondoMedio, _colorFondoAbajo],
            stops: [0.0, 0.72, 1.0],
          ),
        ),
        child: Center(
          child: AnimatedOpacity(
            opacity: _opacidad,
            duration: _duracionAparicion,
            curve: Curves.easeOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/brand/mark_white.png',
                    width: _anchoLogo, filterQuality: FilterQuality.medium),
                const SizedBox(height: _espacioLogoTitulo),
                const Text(
                  'Refugio Musical',
                  style: TextStyle(
                    color: _colorTitulo,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: _espacioTituloSubtitulo),
                const Text(
                  'Bienvenido a tu refugio musical',
                  style: TextStyle(color: _colorSubtitulo, fontSize: 15),
                ),
                const SizedBox(height: _espacioSubtituloSpinner),
                const SizedBox(
                  width: _tamanoSpinner,
                  height: _tamanoSpinner,
                  child: CircularProgressIndicator(
                    strokeWidth: _grosorSpinner,
                    valueColor: AlwaysStoppedAnimation(_colorSpinner),
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
