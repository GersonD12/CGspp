import 'package:flutter/material.dart';

class BotonSiguiente extends StatelessWidget {
  final VoidCallback? onPressed; // Ahora puede ser nulo
  final String
  texto; // Propiedad para el texto, la variable en donde se va a guardar el texto
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double? height;
  final double? fontSize;
  final double? elevation;

  const BotonSiguiente({
    super.key,
    this.onPressed, // Ya no es requerido
    this.texto = 'Siguiente', // Valor por defecto o inicial
    this.color,
    this.textColor,
    this.icon,
    this.width,
    this.height,
    this.fontSize = 16.0,
    this.elevation = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: texto.isEmpty || texto.trim().isEmpty
          ? FloatingActionButton(
              onPressed: onPressed,
              backgroundColor: color,
              elevation: elevation,
              child: Icon(icon, color: textColor),
            )
          : FloatingActionButton.extended(
              onPressed: onPressed,
              // Usamos la propiedad 'texto' en lugar del texto fijo
              label: Text(
                texto,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              icon: Icon(icon, color: textColor),
              backgroundColor: color,
              elevation: elevation,
            ),
    );
  }
}
