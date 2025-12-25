import 'package:flutter/material.dart';

class Boton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String texto;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final double? width; //  anchura
  final double? height; //altura
  final double? fontSize;
  final double? elevation;
  final int borderRadius;
  final bool circular;
  final Color? shadowColor;

  const Boton({
    super.key,
    this.onPressed,
    this.texto = 'Siguiente',
    this.color,
    this.textColor,
    this.icon,
    this.width = 150,
    this.height = 50,
    this.fontSize = 16.0,
    this.elevation = 2.0,
    this.borderRadius = 25,
    this.circular = false,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    // Configurar sombra personalizada; si no se provee shadowColor, usar un gris tenue por defecto
    final List<BoxShadow> customShadow = [
      BoxShadow(
        color: shadowColor ?? Colors.black45,
        blurRadius: 0,
        spreadRadius: 0,
        offset: Offset(width! * 0.01, height! * 0.08),
      ),
    ];

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow: customShadow,
        borderRadius: circular
            ? BorderRadius.circular(100)
            : BorderRadius.circular(borderRadius.toDouble()),
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: texto.isEmpty || texto.trim().isEmpty
            ? FloatingActionButton(
                onPressed: onPressed,
                backgroundColor: color,
                elevation: shadowColor != null
                    ? 0
                    : elevation, // Sin elevation si hay sombra custom
                heroTag: null,
                child: Icon(icon, color: textColor),
              )
            : FloatingActionButton.extended(
                onPressed: onPressed,
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
                elevation: shadowColor != null
                    ? 0
                    : elevation, // Sin elevation si hay sombra custom
                // Aplicar borderRadius personalizado o circular
                shape: circular
                    ? const StadiumBorder()
                    : RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          borderRadius.toDouble(),
                        ),
                      ),
                heroTag: null,
              ),
      ),
    );
  }
}
