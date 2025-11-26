import 'package:flutter/material.dart';
import 'package:calet/core/theme/app_theme_extension.dart';

/// Extension helper para acceder fácilmente a los colores personalizados del tema
extension ThemeHelper on BuildContext {
  /// Obtiene los colores personalizados del tema
  ///
  /// Uso: context.appColors.barColor
  AppThemeExtension get appColors =>
      Theme.of(this).extension<AppThemeExtension>()!;
}
