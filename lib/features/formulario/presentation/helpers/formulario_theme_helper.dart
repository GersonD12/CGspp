import 'package:calet/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

/// Helper para obtener colores del tema del formulario
class FormularioThemeHelper {
  /// Obtiene la extensión del tema
  static AppThemeExtension getThemeExtension(BuildContext context) {
    return Theme.of(context).extension<AppThemeExtension>() ??
        const AppThemeExtension(
          barColor: Colors.transparent,
          buttonColor: Colors.transparent,
          shadowColor: Colors.transparent,
          barBorder: Colors.transparent,
          formPrimary: Colors.blue,
          formProgressBackground: Colors.grey,
          formButtonDisabled: Colors.grey,
          formChipBackground: Colors.grey,
        );
  }

  /// Color principal del formulario
  static Color getFormPrimary(BuildContext context) {
    return getThemeExtension(context).formPrimary;
  }

  /// Color de fondo de la barra de progreso
  static Color getFormProgressBackground(BuildContext context) {
    return getThemeExtension(context).formProgressBackground;
  }

  /// Color de botón deshabilitado
  static Color getFormButtonDisabled(BuildContext context) {
    return getThemeExtension(context).formButtonDisabled;
  }

  /// Color de fondo de chip no seleccionado
  static Color getFormChipBackground(BuildContext context) {
    return getThemeExtension(context).formChipBackground;
  }

  /// Color de texto según el tema
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Color de fondo del scaffold
  static Color getScaffoldBackground(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }
}

