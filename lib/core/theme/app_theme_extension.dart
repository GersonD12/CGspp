import 'package:flutter/material.dart';

/// Extensión del tema con colores personalizados adicionales
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  // Colores personalizados
  final Color barColor;
  final Color buttonColor;
  final Color shadowColor;
  final Color barBorder;
  final Color barIconprecionado;
  final Color barIconSuelto;

  const AppThemeExtension({
    required this.barColor,
    required this.buttonColor,
    required this.shadowColor,
    required this.barBorder,
    required this.barIconprecionado,
    required this.barIconSuelto,
  });

  @override
  AppThemeExtension copyWith({
    Color? barColor,
    Color? buttonColor,
    Color? shadowColor,
    Color? barBorder,
    Color? barIconprecionado,
    Color? barIconSuelto,
  }) {
    return AppThemeExtension(
      barColor: barColor ?? this.barColor,
      buttonColor: buttonColor ?? this.buttonColor,
      shadowColor: shadowColor ?? this.shadowColor,
      barBorder: barBorder ?? this.barBorder,
      barIconprecionado: barIconprecionado ?? this.barIconprecionado,
      barIconSuelto: barIconSuelto ?? this.barIconSuelto,
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
      barIconprecionado: Color.lerp(
        barIconprecionado,
        other.barIconprecionado,
        t,
      )!,
      barIconSuelto: Color.lerp(barIconSuelto, other.barIconSuelto, t)!,
    );
  }
}
