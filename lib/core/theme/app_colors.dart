import 'package:flutter/material.dart';

/// Colores personalizados de la aplicación para tema claro y oscuro
class AppColors {
  // Tema Claro - Light Theme
  static const Color lightBackground = Color.fromARGB(255, 248, 226, 185);
  static const Color lightAppBar = Color.fromARGB(255, 248, 226, 185);
  static const Color lightButton = Color.fromARGB(255, 24, 24, 24);
  static const Color lightText = Color.fromARGB(255, 108, 114, 90);
  static const Color unselectedItemColorLight = Color.fromARGB(255, 0, 0, 0);
  static const Color cardColorLight = Color.fromARGB(255, 255, 255, 255);
  static const Color barColorLight = Color.fromARGB(
    200,
    255,
    255,
    255,
  ); // Blanco con transparencia
  static const Color buttonColorLight = Color.fromARGB(
    224,
    255,
    255,
    255,
  ); // Gris con transparencia
  //aca se pueden añadir mas colores personalizados, primero aca el tema blanco
  static const Color shadowColorLight = Color.fromARGB(40, 124, 124, 124);
  static const Color barBorderLight = Color.fromARGB(
    255,
    89,
    94,
    74,
  ); // Gris con transparencia

  // Tema Oscuro - Dark Theme
  static const Color darkBackground = Color.fromRGBO(31, 30, 27, 1);
  static const Color darkAppBar = Color.fromRGBO(31, 30, 27, 1);
  static const Color darkButton = Color.fromRGBO(139, 111, 71, 1);
  static const Color darkText = Color.fromRGBO(214, 194, 165, 1);
  static const Color unselectedItemColorDark = Color.fromARGB(
    255,
    255,
    255,
    255,
  );
  static const Color cardColorDark = Color.fromARGB(255, 248, 226, 185);
  static const Color barColorDark = Color.fromARGB(
    200,
    50,
    50,
    50,
  ); // Gris con transparencia
  static const Color buttonColorDark = Color.fromRGBO(139, 111, 71, 1);
  //aca se pueden añadir mas colores personalizados, aca el tema oscuro y luego en config_provaider
  static const Color shadowColorDark = Color.fromARGB(101, 194, 194, 194);
  static const Color barBorderDark = Color.fromARGB(
    57,
    168,
    106,
    0,
  ); // Gris con transparencia
}
