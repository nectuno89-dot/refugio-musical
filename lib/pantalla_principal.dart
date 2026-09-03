// ===========================================================================
//  pantalla_principal.dart — el esqueleto de la app: barra inferior de 5
//  pestañas (Aprender · Componer · Explorar · Wiki · Perfil).
//
//  Cada pestaña conserva su estado (IndexedStack) pero solo se construye la
//  primera vez que se visita, para que los mini-tutoriales de cada pantalla
//  no salten todos a la vez al arrancar.
// ===========================================================================

import 'package:flutter/material.dart';

import 'pantalla_aprender.dart';
import 'pantalla_componer.dart';
import 'pantalla_escalas.dart';
import 'pantalla_perfil.dart';
import 'pantalla_wiki.dart';
import 'retro.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _i = 0;
  final _visitadas = <int>{0};

  void _ir(int destino) {
    if (destino == _i) return;
    Retro.toque();
    setState(() {
      _i = destino;
      _visitadas.add(destino);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pestanas = <Widget>[
      PantallaAprender(onVerPerfil: () => _ir(4)),
      const PantallaComponer(),
      const PantallaEscalas(),
      const PantallaWiki(),
      const PantallaPerfil(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _i,
        children: [
          for (var k = 0; k < pestanas.length; k++)
            _visitadas.contains(k)
                ? pestanas[k]
                : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: _ir,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Aprender',
          ),
          NavigationDestination(
            icon: Icon(Icons.gesture_outlined),
            selectedIcon: Icon(Icons.gesture),
            label: 'Componer',
          ),
          NavigationDestination(
            icon: Icon(Icons.travel_explore_outlined),
            selectedIcon: Icon(Icons.travel_explore),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Wiki',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
