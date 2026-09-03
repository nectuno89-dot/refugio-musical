// ===========================================================================
//  tema.dart — temas claro y oscuro + paleta de tokens de la app.
//
//  Los colores se leen con `context.pal` (una AppPalette registrada como
//  ThemeExtension), así que cambian solos al alternar el tema.
//  Los `k*` de abajo se conservan como valores del tema OSCURO por
//  compatibilidad con código que aún no usa `context.pal`.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Tokens del tema oscuro (compatibilidad) -------------------------------
const kFondo = Color(0xFF0E0E15);
const kSuperficie = Color(0xFF1A1A25);
const kSuperficieAlt = Color(0xFF23232F);
const kBorde = Color(0xFF2E2E3D);
const kAcento = Color(0xFF7C83FF);
const kExito = Color(0xFF34D399);
const kError = Color(0xFFF87171);
const kAviso = Color(0xFFFBBF24);
const kTexto = Color(0xFFECECF2);
const kTextoTenue = Color(0xFF9A9AAB);

// --- Paleta como ThemeExtension ------------------------------------------
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color fondo;
  final Color superficie;
  final Color superficieAlt;
  final Color borde;
  final Color acento;
  final Color exito;
  final Color aviso;
  final Color error;
  final Color texto;
  final Color textoTenue;
  final Color componer; // rosa de la sección Componer
  final Color tinta; // trazo de pentagrama y diagramas
  final Brightness brillo;

  const AppPalette({
    required this.fondo,
    required this.superficie,
    required this.superficieAlt,
    required this.borde,
    required this.acento,
    required this.exito,
    required this.aviso,
    required this.error,
    required this.texto,
    required this.textoTenue,
    required this.componer,
    required this.tinta,
    required this.brillo,
  });

  bool get esOscuro => brillo == Brightness.dark;

  @override
  AppPalette copyWith({
    Color? fondo,
    Color? superficie,
    Color? superficieAlt,
    Color? borde,
    Color? acento,
    Color? exito,
    Color? aviso,
    Color? error,
    Color? texto,
    Color? textoTenue,
    Color? componer,
    Color? tinta,
    Brightness? brillo,
  }) =>
      AppPalette(
        fondo: fondo ?? this.fondo,
        superficie: superficie ?? this.superficie,
        superficieAlt: superficieAlt ?? this.superficieAlt,
        borde: borde ?? this.borde,
        acento: acento ?? this.acento,
        exito: exito ?? this.exito,
        aviso: aviso ?? this.aviso,
        error: error ?? this.error,
        texto: texto ?? this.texto,
        textoTenue: textoTenue ?? this.textoTenue,
        componer: componer ?? this.componer,
        tinta: tinta ?? this.tinta,
        brillo: brillo ?? this.brillo,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      fondo: Color.lerp(fondo, other.fondo, t)!,
      superficie: Color.lerp(superficie, other.superficie, t)!,
      superficieAlt: Color.lerp(superficieAlt, other.superficieAlt, t)!,
      borde: Color.lerp(borde, other.borde, t)!,
      acento: Color.lerp(acento, other.acento, t)!,
      exito: Color.lerp(exito, other.exito, t)!,
      aviso: Color.lerp(aviso, other.aviso, t)!,
      error: Color.lerp(error, other.error, t)!,
      texto: Color.lerp(texto, other.texto, t)!,
      textoTenue: Color.lerp(textoTenue, other.textoTenue, t)!,
      componer: Color.lerp(componer, other.componer, t)!,
      tinta: Color.lerp(tinta, other.tinta, t)!,
      brillo: t < 0.5 ? brillo : other.brillo,
    );
  }
}

const paletaOscura = AppPalette(
  fondo: Color(0xFF0E0E15),
  superficie: Color(0xFF1A1A25),
  superficieAlt: Color(0xFF23232F),
  borde: Color(0xFF2E2E3D),
  acento: Color(0xFF7C83FF),
  exito: Color(0xFF34D399),
  aviso: Color(0xFFFBBF24),
  error: Color(0xFFF87171),
  texto: Color(0xFFECECF2),
  textoTenue: Color(0xFF9A9AAB),
  componer: Color(0xFFF472B6),
  tinta: Color(0xE6ECECF2),
  brillo: Brightness.dark,
);

const paletaClara = AppPalette(
  fondo: Color(0xFFF6F5FB),
  superficie: Color(0xFFFFFFFF),
  superficieAlt: Color(0xFFEFEDF7),
  borde: Color(0xFFE4E1EE),
  acento: Color(0xFF5B54E0),
  exito: Color(0xFF0E9E6E),
  aviso: Color(0xFFB5791C),
  error: Color(0xFFD9534F),
  texto: Color(0xFF191922),
  textoTenue: Color(0xFF6A6A79),
  componer: Color(0xFFD4479A),
  tinta: Color(0xE6191922),
  brillo: Brightness.light,
);

extension PalContext on BuildContext {
  AppPalette get pal =>
      Theme.of(this).extension<AppPalette>() ?? paletaOscura;
}

// --- Preferencia de tema (Sistema / Claro / Oscuro) ---------------------
final ValueNotifier<ThemeMode> modoTema = ValueNotifier(ThemeMode.dark);

Future<void> cargarModoTema() async {
  final p = await SharedPreferences.getInstance();
  final v = p.getString('modo_tema');
  modoTema.value = v == 'claro'
      ? ThemeMode.light
      : v == 'sistema'
          ? ThemeMode.system
          : ThemeMode.dark;
}

Future<void> guardarModoTema(ThemeMode m) async {
  modoTema.value = m;
  final p = await SharedPreferences.getInstance();
  await p.setString(
      'modo_tema',
      m == ThemeMode.light
          ? 'claro'
          : m == ThemeMode.system
              ? 'sistema'
              : 'oscuro');
}

// --- ThemeData ---------------------------------------------------------
ThemeData _tema(AppPalette pal) {
  final scheme = ColorScheme.fromSeed(
    seedColor: pal.acento,
    brightness: pal.brillo,
  ).copyWith(
    surface: pal.superficie,
    primary: pal.acento,
    onSurface: pal.texto,
    onSurfaceVariant: pal.textoTenue,
    outline: pal.borde,
    outlineVariant: pal.borde,
    error: pal.error,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: pal.brillo,
    colorScheme: scheme,
    scaffoldBackgroundColor: pal.fondo,
    fontFamily: 'Roboto',
    extensions: [pal],
    cardTheme: CardThemeData(
      color: pal.superficie,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: pal.borde),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: pal.fondo,
      foregroundColor: pal.texto,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
    ),
    dividerColor: pal.borde,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: pal.acento,
        foregroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle:
            const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: pal.acento,
        side: BorderSide(color: pal.borde),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: pal.acento),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: pal.superficieAlt,
      contentTextStyle: TextStyle(color: pal.texto),
    ),
    listTileTheme: ListTileThemeData(iconColor: pal.textoTenue),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: pal.acento,
      linearTrackColor: pal.superficieAlt,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: pal.superficie,
      indicatorColor: pal.acento.withValues(alpha: 0.18),
      elevation: 0,
      height: 64,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? pal.acento
              : pal.textoTenue,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: s.contains(WidgetState.selected)
              ? pal.acento
              : pal.textoTenue,
        ),
      ),
    ),
  );
}

ThemeData temaOscuro() => _tema(paletaOscura);
ThemeData temaClaro() => _tema(paletaClara);
