import 'package:flutter/material.dart';

class AppColors {
  // =========================================================
  // Fondos principales
  // =========================================================

  static const Color background = Color(0xFF0C0F14);
  static const Color backgroundSoft = Color(0xFF121821);

  // =========================================================
  // Paneles / tarjetas
  // =========================================================

  static const Color panel = Color(0xFF171D27);
  static const Color panelAlt = Color(0xFF1E2633);
  static const Color panelLight = Color(0xFF212B3A);

  // =========================================================
  // Colores principales NEXPLAY
  // =========================================================

  static const Color primary = Color(0xFFFF6B57);
  static const Color primaryDark = Color(0xFFDA4F3B);
  static const Color primarySoft = Color(0xFFFFA07A);

  // =========================================================
  // Dorado / amarillo gamer
  // =========================================================

  static const Color secondary = Color(0xFFF7C948);
  static const Color secondarySoft = Color(0xFFFFE29A);

  // =========================================================
  // Acentos
  // =========================================================

  static const Color accent = Color(0xFFF59E6B);

  // =========================================================
  // Textos
  // =========================================================

  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFFB8C0CC);

  // =========================================================
  // Bordes
  // =========================================================

  static const Color border = Color(0xFF2A3340);
  static const Color borderSoft = Color(0xFF3B4659);

  // =========================================================
  // Estados
  // =========================================================

  static const Color success = Color(0xFF3AD29F);
  static const Color error = Color(0xFFFF5D73);
  static const Color neutral = Color(0xFF8A94A6);

  static const Color white = Color(0xFFFFFFFF);

  // =========================================================
  // Compatibilidad con módulos de Joselin
  // =========================================================
  //
  // Estos nombres son utilizados por Login y Catálogo.
  // Apuntan a nuestra paleta NEXPLAY para mantener una sola
  // identidad visual en toda la aplicación.
  // =========================================================

  static const Color surface = panel;

  static const Color surfaceCard = panelAlt;

  static const Color textWhite = textPrimary;

  static const Color textGray = textSecondary;
}
