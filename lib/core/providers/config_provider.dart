import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:calet/core/theme/app_colors.dart';
import 'package:calet/core/theme/app_theme_extension.dart';

class AppConfig {
  final Brightness brightness;
  final ThemeData theme;

  AppConfig({required this.brightness, required this.theme});

  /// Copia la configuración actual con cambios específicos
  AppConfig copyWith({Brightness? brightness, ThemeData? theme}) {
    return AppConfig(
      brightness: brightness ?? this.brightness,
      theme: theme ?? this.theme,
    );
  }
}

/// Provider de configuración de la aplicación
class ConfigNotifier extends StateNotifier<AppConfig> {
  ConfigNotifier() : super(_lightConfig);

  static final AppConfig _lightConfig = AppConfig(
    brightness: Brightness.light,
    theme: _buildLightTheme(),
  );

  static final AppConfig _darkConfig = AppConfig(
    brightness: Brightness.dark,
    theme: _buildDarkTheme(),
  );

  /// Construir tema claro
  static ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.lightBackground,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightAppBar,
        foregroundColor: AppColors.lightText,
        elevation: 0,
      ),

      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightButton,
          foregroundColor: AppColors.lightText,
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightButton,
        foregroundColor: AppColors.lightText,
      ),

      // Texto
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.lightText),
        bodyMedium: TextStyle(color: AppColors.lightText),
        bodySmall: TextStyle(color: AppColors.lightText),
        displayLarge: TextStyle(color: AppColors.lightText),
        displayMedium: TextStyle(color: AppColors.lightText),
        displaySmall: TextStyle(color: AppColors.lightText),
        headlineLarge: TextStyle(color: AppColors.lightText),
        headlineMedium: TextStyle(color: AppColors.lightText),
        headlineSmall: TextStyle(color: AppColors.lightText),
        titleLarge: TextStyle(color: AppColors.lightText),
        titleMedium: TextStyle(color: AppColors.lightText),
        titleSmall: TextStyle(color: AppColors.lightText),
        labelLarge: TextStyle(color: AppColors.lightText),
        labelMedium: TextStyle(color: AppColors.lightText),
        labelSmall: TextStyle(color: AppColors.lightText),
      ),

      // ColorScheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightButton,
        onPrimary: AppColors.lightText,
        secondary: AppColors.lightButton,
        onSecondary: AppColors.lightText,
        surface: AppColors.lightBackground,
        onSurface: AppColors.lightText,
        surfaceContainerHighest: AppColors.cardColorLight, // Para cards
        outline:
            AppColors.unselectedItemColorLight, // Para items no seleccionados
      ),

      // IconTheme
      iconTheme: const IconThemeData(color: AppColors.lightText),

      // Extensión de colores personalizados
      //añadir los nuevos colores personalizados
      extensions: <ThemeExtension<dynamic>>[
        const AppThemeExtension(
          //aqui
          barColor: AppColors.barColorLight,
          buttonColor: AppColors.buttonColorLight,
          //luego ir a la linea 170
          shadowColor: AppColors.shadowColorLight,
          barBorder: AppColors.barBorderLight,
        ),
      ],
    );
  }

  /// Construir tema oscuro
  static ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.darkBackground,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkAppBar,
        foregroundColor: AppColors.darkText,
        elevation: 0,
      ),

      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkButton,
          foregroundColor: AppColors.darkText,
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkButton,
        foregroundColor: AppColors.darkText,
      ),

      // Texto
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.darkText),
        bodyMedium: TextStyle(color: AppColors.darkText),
        bodySmall: TextStyle(color: AppColors.darkText),
        displayLarge: TextStyle(color: AppColors.darkText),
        displayMedium: TextStyle(color: AppColors.darkText),
        displaySmall: TextStyle(color: AppColors.darkText),
        headlineLarge: TextStyle(color: AppColors.darkText),
        headlineMedium: TextStyle(color: AppColors.darkText),
        headlineSmall: TextStyle(color: AppColors.darkText),
        titleLarge: TextStyle(color: AppColors.darkText),
        titleMedium: TextStyle(color: AppColors.darkText),
        titleSmall: TextStyle(color: AppColors.darkText),
        labelLarge: TextStyle(color: AppColors.darkText),
        labelMedium: TextStyle(color: AppColors.darkText),
        labelSmall: TextStyle(color: AppColors.darkText),
      ),

      // ColorScheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkButton,
        onPrimary: AppColors.darkText,
        secondary: AppColors.darkButton,
        onSecondary: AppColors.darkText,
        surface: AppColors.darkBackground,
        onSurface: AppColors.darkText,
        surfaceContainerHighest: AppColors.cardColorDark, // 👈 Versión DARK
        outline: AppColors.unselectedItemColorDark, // 👈 Versión DARK
      ),

      // IconTheme
      iconTheme: const IconThemeData(color: AppColors.darkText),

      // Extensión de colores personalizados
      //añadir tambien aqui
      extensions: <ThemeExtension<dynamic>>[
        const AppThemeExtension(
          barColor: AppColors.barColorDark,
          buttonColor: AppColors.buttonColorDark,
          shadowColor: AppColors.shadowColorDark,
          barBorder: AppColors.barBorderDark,
        ),
      ],
    );
  }

  /// Cambiar entre tema claro y oscuro
  void toggleTheme() {
    if (state.brightness == Brightness.light) {
      state = _darkConfig;
    } else {
      state = _lightConfig;
    }
  }

  /// Establecer tema específico
  void setTheme(Brightness brightness) {
    if (brightness == Brightness.light) {
      state = _lightConfig;
    } else {
      state = _darkConfig;
    }
  }
}

/// Provider de configuración de la aplicación
final configProvider = StateNotifierProvider<ConfigNotifier, AppConfig>((ref) {
  return ConfigNotifier();
});
