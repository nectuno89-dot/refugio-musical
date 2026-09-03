// ===========================================================================
//  pantalla_ajustes.dart — preferencias de la app: vibración/sonido de toque
//  y control de los mini-tutoriales.
// ===========================================================================

import 'package:flutter/material.dart';

import 'onboarding.dart';
import 'retro.dart';
import 'tema.dart';
import 'tutorial.dart';

class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  @override
  Widget build(BuildContext context) {
    final abajo = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(4, 8, 4, 24 + abajo),
        children: [
          _titulo('Apariencia'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('Sistema'),
                    icon: Icon(Icons.brightness_auto, size: 18)),
                ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Claro'),
                    icon: Icon(Icons.light_mode, size: 18)),
                ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Oscuro'),
                    icon: Icon(Icons.dark_mode, size: 18)),
              ],
              selected: {modoTema.value},
              showSelectedIcon: false,
              onSelectionChanged: (s) {
                guardarModoTema(s.first);
                setState(() {});
              },
            ),
          ),
          const Divider(height: 28),
          _titulo('Vibración y sonido'),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('Vibración al tocar'),
            subtitle:
                const Text('Un impulso muy corto en botones y en el teclado'),
            value: Retro.haptica,
            onChanged: (v) {
              Retro.setHaptica(v);
              setState(() {});
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.touch_app),
            title: const Text('Sonido de toque'),
            subtitle: const Text('Un «tic» breve al pulsar un botón'),
            value: Retro.sonido,
            onChanged: (v) {
              Retro.setSonido(v);
              Retro.toque(); // muestra cómo suena
              setState(() {});
            },
          ),
          const Divider(height: 28),
          _titulo('Tutoriales'),
          SwitchListTile(
            secondary: const Icon(Icons.school_outlined),
            title: const Text('Mostrar tutoriales'),
            subtitle: const Text(
                'Guías breves la primera vez que abres cada pantalla'),
            value: Onboarding.habilitado,
            onChanged: (v) {
              Onboarding.setHabilitado(v);
              setState(() {});
            },
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text('Volver a ver todos los tutoriales'),
            subtitle: const Text(
                'Se mostrarán de nuevo al entrar en cada pantalla'),
            onTap: () async {
              await Onboarding.reiniciar();
              if (!context.mounted) return;
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tutoriales reactivados')),
              );
            },
          ),
          const SizedBox(height: 4),
          _titulo('Ver un tutorial ahora'),
          _verAhora('Inicio', Icons.home_outlined, tutInicio),
          _verAhora('Lecciones', Icons.auto_stories, tutLecciones),
          _verAhora('Ejercicios', Icons.check_circle_outline, tutEjercicio),
          _verAhora('Componer', Icons.edit_note, tutComponer),
          _verAhora('Explorar escalas', Icons.travel_explore, tutEscalas),
          _verAhora('Wiki', Icons.menu_book, tutWiki),
          const Divider(height: 28),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Refugio Musical · versión beta\nH&M',
              style: TextStyle(color: context.pal.textoTenue, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _titulo(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        child: Text(t.toUpperCase(),
            style: TextStyle(
                color: context.pal.acento,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5)),
      );

  Widget _verAhora(String nombre, IconData icono, List<PasoTutorial> pasos) =>
      ListTile(
        leading: Icon(icono),
        title: Text(nombre),
        trailing: Icon(Icons.play_circle_outline, color: context.pal.textoTenue),
        onTap: () => reproducirTutorial(context, pasos),
      );
}
