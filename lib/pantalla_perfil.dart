// ===========================================================================
//  pantalla_perfil.dart — la pestaña "Perfil": tu racha, tu nivel, la
//  actividad de la semana, los logros y unos cuantos contadores.
//  Solo lee de [Gamificacion]; no cambia nada.
// ===========================================================================

import 'package:flutter/material.dart';

import 'animaciones.dart';
import 'gamificacion.dart';
import 'pantalla_ajustes.dart';
import 'tema.dart';

class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final abajo = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil'), centerTitle: true),
      body: ValueListenableBuilder<int>(
        valueListenable: Gamificacion.cambios,
        builder: (context, _, _) {
          return ListView(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + abajo),
            children: [
              const _TarjetaRacha(),
              const SizedBox(height: 14),
              const _TarjetaNivel(),
              const SizedBox(height: 14),
              const _TarjetaSemana(),
              const SizedBox(height: 14),
              _tituloSeccion(context, 'Logros'),
              const SizedBox(height: 8),
              const _RejillaLogros(),
              const SizedBox(height: 18),
              _tituloSeccion(context, 'En números'),
              const SizedBox(height: 8),
              const _Contadores(),
              const SizedBox(height: 18),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Ajustes'),
                  subtitle: const Text('Tema, sonido, tutoriales'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PantallaAjustes()),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _tituloSeccion(BuildContext context, String t) => Text(
        t.toUpperCase(),
        style: TextStyle(
          color: context.pal.acento,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      );
}

// ---------------------------------------------------------------------------
//  Racha
// ---------------------------------------------------------------------------
class _TarjetaRacha extends StatelessWidget {
  const _TarjetaRacha();

  @override
  Widget build(BuildContext context) {
    final racha = Gamificacion.racha;
    final activa = racha > 0;
    // Últimos 7 días (índice 6 = hoy), con su etiqueta de día real.
    final dias = Gamificacion.ultimos7();
    const nombresDia = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.pal.borde),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: activa
              ? [
                  context.pal.aviso.withValues(alpha: 0.22),
                  context.pal.superficie,
                ]
              : [context.pal.superficie, context.pal.superficie],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Latido(
                max: activa ? 1.12 : 1.0,
                periodo: const Duration(milliseconds: 1800),
                child: Icon(Icons.local_fire_department,
                    size: 46,
                    color: activa
                        ? context.pal.aviso
                        : context.pal.textoTenue),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$racha',
                      style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          color: context.pal.texto)),
                  Text(racha == 1 ? 'día de racha' : 'días de racha',
                      style: TextStyle(color: context.pal.textoTenue)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Mejor',
                      style: TextStyle(
                          fontSize: 11, color: context.pal.textoTenue)),
                  Text('${Gamificacion.mejorRacha}',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: context.pal.texto)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var k = 0; k < 7; k++)
                Column(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dias[k].xp > 0
                            ? context.pal.aviso
                            : context.pal.superficieAlt,
                        border: Border.all(
                          color: k == 6
                              ? context.pal.acento
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: dias[k].xp > 0
                          ? const Icon(Icons.check,
                              size: 15, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(nombresDia[dias[k].dia.weekday - 1],
                        style: TextStyle(
                            fontSize: 10, color: context.pal.textoTenue)),
                  ],
                ),
            ],
          ),
          if (!activa) ...[
            const SizedBox(height: 12),
            Text(
              'Haz algo hoy —un ejercicio, una lección— y tu racha vuelve a arrancar.',
              style: TextStyle(fontSize: 12, color: context.pal.textoTenue),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Nivel + XP
// ---------------------------------------------------------------------------
class _TarjetaNivel extends StatelessWidget {
  const _TarjetaNivel();

  @override
  Widget build(BuildContext context) {
    final techo = Gamificacion.xpTechoNivel;
    final base = Gamificacion.xpBaseNivel;
    final xp = Gamificacion.xp;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.pal.superficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.pal.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.pal.acento.withValues(alpha: 0.18),
                ),
                child: Text('${Gamificacion.nivelIndice + 1}',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: context.pal.acento)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Gamificacion.nivelNombre,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: context.pal.texto)),
                    Text('$xp XP en total',
                        style:
                            TextStyle(color: context.pal.textoTenue, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: Gamificacion.progresoNivel,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$base',
                  style:
                      TextStyle(fontSize: 11, color: context.pal.textoTenue)),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    techo == null
                        ? 'Nivel máximo alcanzado'
                        : '${techo - xp} XP para ${Gamificacion.siguienteNivelNombre}',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: context.pal.acento),
                  ),
                ),
              ),
              Text(techo == null ? '' : '$techo',
                  style:
                      TextStyle(fontSize: 11, color: context.pal.textoTenue)),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Actividad de la semana (barras de XP por día)
// ---------------------------------------------------------------------------
class _TarjetaSemana extends StatelessWidget {
  const _TarjetaSemana();

  @override
  Widget build(BuildContext context) {
    final dias = Gamificacion.ultimos7();
    final maxXp = dias.fold<int>(1, (m, d) => d.xp > m ? d.xp : m);
    const nombresDia = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: context.pal.superficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.pal.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Esta semana',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: context.pal.texto)),
          const SizedBox(height: 14),
          SizedBox(
            height: 112,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final d in dias)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(d.xp > 0 ? '${d.xp}' : '',
                            style: TextStyle(
                                fontSize: 9, color: context.pal.textoTenue)),
                        const SizedBox(height: 2),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          tween: Tween(
                              begin: 0, end: (d.xp / maxXp).clamp(0.0, 1.0)),
                          builder: (context, v, _) => Container(
                            width: 16,
                            height: 8 + v * 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: d.xp > 0
                                  ? context.pal.acento
                                  : context.pal.superficieAlt,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(nombresDia[d.dia.weekday - 1],
                            style: TextStyle(
                                fontSize: 10,
                                color: context.pal.textoTenue)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Logros
// ---------------------------------------------------------------------------
class _RejillaLogros extends StatelessWidget {
  const _RejillaLogros();

  @override
  Widget build(BuildContext context) {
    return GridView.extent(
      maxCrossAxisExtent: 130,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.86,
      children: [
        for (final l in Gamificacion.catalogoLogros)
          _CeldaLogro(logro: l, conseguido: Gamificacion.logros.contains(l.id)),
      ],
    );
  }
}

class _CeldaLogro extends StatelessWidget {
  final Logro logro;
  final bool conseguido;
  const _CeldaLogro({required this.logro, required this.conseguido});

  @override
  Widget build(BuildContext context) {
    final color = conseguido ? context.pal.acento : context.pal.textoTenue;
    return GestureDetector(
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          icon: Icon(logro.icono, color: color, size: 34),
          title: Text(logro.nombre, textAlign: TextAlign.center),
          content: Text(
            conseguido ? '${logro.desc}.\n\n¡Conseguido!' : '${logro.desc}.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
      child: Opacity(
        opacity: conseguido ? 1 : 0.55,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.pal.superficie,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: conseguido ? context.pal.acento : context.pal.borde,
              width: conseguido ? 1.4 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(logro.icono, size: 30, color: color),
                  if (!conseguido)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Icon(Icons.lock,
                          size: 13, color: context.pal.textoTenue),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                logro.nombre,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: context.pal.texto),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Contadores
// ---------------------------------------------------------------------------
class _Contadores extends StatelessWidget {
  const _Contadores();

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[
      (Icons.school, '${Gamificacion.leccionesCompletadas}', 'Lecciones'),
      (Icons.fitness_center, '${Gamificacion.ejerciciosAcertados}', 'Aciertos'),
      (Icons.travel_explore, '${Gamificacion.escalasVistas.length}', 'Escalas'),
    ];
    return Row(
      children: [
        for (var k = 0; k < items.length; k++) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: context.pal.superficie,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.pal.borde),
              ),
              child: Column(
                children: [
                  Icon(items[k].$1, color: context.pal.acento, size: 22),
                  const SizedBox(height: 6),
                  Text(items[k].$2,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: context.pal.texto)),
                  Text(items[k].$3,
                      style: TextStyle(
                          fontSize: 11, color: context.pal.textoTenue)),
                ],
              ),
            ),
          ),
          if (k < items.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}
