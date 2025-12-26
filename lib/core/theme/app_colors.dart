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
  
  // Colores específicos del formulario - Light Theme
  static const Color formPrimaryLight = Color.fromARGB(255, 76, 94, 175); // Azul principal
  static const Color formProgressBackgroundLight = Color.fromARGB(255, 226, 219, 204); // Fondo barra progreso
  static const Color formButtonDisabledLight = Color.fromARGB(255, 235, 213, 172); // Botón deshabilitado
  static const Color formChipBackgroundLight = Color.fromARGB(255, 238, 238, 238); // Fondo chip no seleccionado
  
  // Color de error - Light Theme
  static const Color errorLight = Color(0xFFD32F2F); // Rojo oscuro para modo claro
  static const Color onErrorLight = Color(0xFFFFFFFF); // Blanco para texto sobre error

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
  static const Color shadowColorDark = Color.fromARGB(55, 194, 194, 194);
  static const Color barBorderDark = Color.fromRGBO(139, 111, 71, 1);
  
  // Colores específicos del formulario - Dark Theme
  static const Color formPrimaryDark = Color.fromARGB(255, 139, 157, 195); // Azul principal más claro para dark
  static const Color formProgressBackgroundDark = Color.fromARGB(255, 50, 50, 50); // Fondo barra progreso oscuro
  static const Color formButtonDisabledDark = Color.fromARGB(255, 80, 70, 60); // Botón deshabilitado oscuro
  static const Color formChipBackgroundDark = Color.fromARGB(255, 60, 60, 60); // Fondo chip no seleccionado oscuro
  
  // Color de error - Dark Theme
  static const Color errorDark = Color.fromARGB(255, 255, 37, 34); // Rojo claro/brillante para modo oscuro
  static const Color onErrorDark = Color(0xFFFFFFFF); // Blanco para texto sobre error
}
