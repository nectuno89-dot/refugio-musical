// ===========================================================================
//  pantalla_aprender.dart — la pestaña "Aprender": el punto de partida.
//  Arriba, una tira compacta con tu racha y tu nivel (toca para ver el
//  Perfil). Debajo, las tres vías de estudio: Lecciones (empieza aquí),
//  Solfeo y Ejercicios de escalas.
// ===========================================================================

import 'package:flutter/material.dart';

import 'animaciones.dart';
import 'gamificacion.dart';
import 'pantalla_ajustes.dart';
import 'pantalla_ejercicios.dart';
import 'pantalla_leccion.dart';
import 'tema.dart';
import 'tutorial.dart';

class PantallaAprender extends StatefulWidget {
  /// Salta a la pestaña de Perfil (la gestiona [PantallaPrincipal]).
  final VoidCallback onVerPerfil;

  const PantallaAprender({super.key, required this.onVerPerfil});

  @override
  State<PantallaAprender> createState() => _PantallaAprenderState();
}

class _PantallaAprenderState extends State<PantallaAprender> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) mostrarTutorial(context, 'inicio', tutInicio);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vias = <_Via>[
      _Via(Icons.school, context.pal.exito, 'Lecciones',
          'Aprende paso a paso, con explicación y ejemplos que suenan. El mejor sitio para empezar.',
          () => const PantallaListaLecciones(),
          destacada: true),
      _Via(Icons.music_note, const Color(0xFF38BDF8), 'Solfeo',
          'Leer notas, ritmo, compás y alteraciones. 95 ejercicios con la teoría a la mano.',
          () => const PantallaEjercicios(materia: materiaSolfeo)),
      _Via(Icons.fitness_center, const Color(0xFFA78BFA),
          'Ejercicios de escalas',
          '184 ejercicios por niveles: armaduras, grados, modos e improvisación.',
          () => const PantallaEjercicios(materia: materiaEscalas)),
    ];

    final abajo = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 24 + abajo),
          children: [
            // ---- Cabecera ----
            EntradaAnimada(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset('assets/brand/icon_rounded_512.png',
                        width: 44, height: 44, filterQuality: FilterQuality.medium),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Refugio Musical',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        Text('¿Seguimos aprendiendo?',
                            style: TextStyle(color: context.pal.textoTenue)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Ajustes',
                    icon: Icon(Icons.settings_outlined,
                        color: context.pal.textoTenue),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PantallaAjustes()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ---- Tira de racha + nivel ----
            EntradaAnimada(
              retardo: const Duration(milliseconds: 60),
              child: _TiraProgreso(onTap: widget.onVerPerfil),
            ),
            const SizedBox(height: 18),
            // ---- Vías de estudio ----
            for (var i = 0; i < vias.length; i++)
              EntradaAnimada(
                retardo: Duration(milliseconds: 120 + i * 70),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _TarjetaVia(via: vias[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Tira compacta: racha a la izquierda, nivel + barra de XP a la derecha.
// ---------------------------------------------------------------------------
class _TiraProgreso extends StatelessWidget {
  final VoidCallback onTap;
  const _TiraProgreso({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: Gamificacion.cambios,
      builder: (context, _, _) {
        final techo = Gamificacion.xpTechoNivel;
        final falta = techo == null ? 0 : techo - Gamificacion.xp;
        return BotonRebote(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            decoration: BoxDecoration(
              color: context.pal.superficie,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.pal.borde),
            ),
            child: Row(
              children: [
                // Racha
                Icon(Icons.local_fire_department,
                    color: Gamificacion.racha > 0
                        ? context.pal.aviso
                        : context.pal.textoTenue,
                    size: 26),
                const SizedBox(width: 4),
                Text('${Gamificacion.racha}',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: context.pal.texto)),
                const SizedBox(width: 14),
                Container(width: 1, height: 34, color: context.pal.borde),
                const SizedBox(width: 14),
                // Nivel + barra
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nivel ${Gamificacion.nivelIndice + 1} · ${Gamificacion.nivelNombre}',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: context.pal.texto),
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: Gamificacion.progresoNivel,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        techo == null
                            ? '${Gamificacion.xp} XP · nivel máximo'
                            : '$falta XP para ${Gamificacion.siguienteNivelNombre}',
                        style: TextStyle(
                            fontSize: 11, color: context.pal.textoTenue),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: context.pal.textoTenue),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
//  Vías de estudio (tarjetas grandes con círculo).
// ---------------------------------------------------------------------------
class _Via {
  final IconData icono;
  final Color color;
  final String titulo;
  final String descripcion;
  final Widget Function() destino;
  final bool destacada;
  _Via(this.icono, this.color, this.titulo, this.descripcion, this.destino,
      {this.destacada = false});
}

class _TarjetaVia extends StatelessWidget {
  final _Via via;
  const _TarjetaVia({required this.via});

  @override
  Widget build(BuildContext context) {
    return BotonRebote(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => via.destino()),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Latido(
            max: 1.05,
            periodo: const Duration(milliseconds: 2600),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    via.color,
                    Color.lerp(via.color, Colors.black, 0.35)!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: via.color.withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(via.icono, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.pal.superficie,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      via.destacada ? context.pal.exito : context.pal.borde,
                  width: via.destacada ? 1.4 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(via.titulo,
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: context.pal.texto)),
                      ),
                      Icon(Icons.arrow_forward,
                          size: 16, color: context.pal.textoTenue),
                    ],
                  ),
                  if (via.destacada) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.pal.exito.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('EMPIEZA AQUÍ',
                          style: TextStyle(
                              color: context.pal.exito,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5)),
                    ),
                  ],
                  const SizedBox(height: 5),
                  Text(via.descripcion,
                      style: TextStyle(
                          fontSize: 12.5,
                          color: context.pal.textoTenue,
                          height: 1.35)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
