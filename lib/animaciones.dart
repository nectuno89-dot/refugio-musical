// ===========================================================================
//  animaciones.dart — pequeñas animaciones reutilizables.
// ===========================================================================

import 'package:flutter/material.dart';

import 'retro.dart';

/// Envuelve un widget: se hunde un poco al pulsarlo (feedback táctil).
class BotonRebote extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double escala; // cuánto se encoge (0.94 = 6%)

  const BotonRebote({
    super.key,
    required this.child,
    this.onTap,
    this.escala = 0.94,
  });

  @override
  State<BotonRebote> createState() => _BotonReboteState();
}

class _BotonReboteState extends State<BotonRebote> {
  bool _abajo = false;

  void _set(bool v) {
    if (widget.onTap == null) return;
    if (v) Retro.toque(); // micro-feedback al iniciar el toque
    setState(() => _abajo = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _abajo ? widget.escala : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Aparición con desvanecido + leve deslizamiento hacia arriba. Con [retardo]
/// escalonado se consigue el efecto "cascada" de una lista.
class EntradaAnimada extends StatefulWidget {
  final Widget child;
  final Duration retardo;
  final double desde; // desplazamiento inicial en px

  const EntradaAnimada({
    super.key,
    required this.child,
    this.retardo = Duration.zero,
    this.desde = 16,
  });

  @override
  State<EntradaAnimada> createState() => _EntradaAnimadaState();
}

class _EntradaAnimadaState extends State<EntradaAnimada> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.retardo, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : Offset(0, widget.desde / 100),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 380),
        child: widget.child,
      ),
    );
  }
}

/// Latido suave e infinito (para el nodo "actual" de la ruta, iconos, etc.).
class Latido extends StatefulWidget {
  final Widget child;
  final double min;
  final double max;
  final Duration periodo;

  const Latido({
    super.key,
    required this.child,
    this.min = 1.0,
    this.max = 1.08,
    this.periodo = const Duration(milliseconds: 1100),
  });

  @override
  State<Latido> createState() => _LatidoState();
}

class _LatidoState extends State<Latido> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.periodo)..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: widget.min, end: widget.max).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      ),
      child: widget.child,
    );
  }
}
