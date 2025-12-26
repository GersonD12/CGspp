import 'package:flutter/material.dart';

/// Extensión del tema con colores personalizados adicionales
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  // Colores personalizados
  final Color barColor;
  final Color buttonColor;
  final Color shadowColor;
  final Color barBorder;
  
  // Colores específicos del formulario
  final Color formPrimary;
  final Color formProgressBackground;
  final Color formButtonDisabled;
  final Color formChipBackground;

  const AppThemeExtension({
    required this.barColor,
    required this.buttonColor,
    required this.shadowColor,
    required this.barBorder,
    required this.formPrimary,
    required this.formProgressBackground,
    required this.formButtonDisabled,
    required this.formChipBackground,
  });

  @override
  AppThemeExtension copyWith({
    Color? barColor,
    Color? buttonColor,
    Color? shadowColor,
    Color? barBorder,
    Color? formPrimary,
    Color? formProgressBackground,
    Color? formButtonDisabled,
    Color? formChipBackground,
  }) {
    return AppThemeExtension(
      barColor: barColor ?? this.barColor,
      buttonColor: buttonColor ?? this.buttonColor,
      shadowColor: shadowColor ?? this.shadowColor,
      barBorder: barBorder ?? this.barBorder,
      formPrimary: formPrimary ?? this.formPrimary,
      formProgressBackground: formProgressBackground ?? this.formProgressBackground,
      formButtonDisabled: formButtonDisabled ?? this.formButtonDisabled,
      formChipBackground: formChipBackground ?? this.formChipBackground,
    );
  }

  @override
  AppThemeExtension lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      barColor: Color.lerp(barColor, other.barColor, t)!,
      buttonColor: Color.lerp(buttonColor, other.buttonColor, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      barBorder: Color.lerp(barBorder, other.barBorder, t)!,
      formPrimary: Color.lerp(formPrimary, other.formPrimary, t)!,
      formProgressBackground: Color.lerp(formProgressBackground, other.formProgressBackground, t)!,
      formButtonDisabled: Color.lerp(formButtonDisabled, other.formButtonDisabled, t)!,
      formChipBackground: Color.lerp(formChipBackground, other.formChipBackground, t)!,
    );
  }
}
