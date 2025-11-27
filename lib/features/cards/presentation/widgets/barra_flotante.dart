import 'package:flutter/material.dart';
import 'dart:ui'; // Importar para usar ImageFilter

class BarraFlotante extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color borderColor;
  final bool isFullyRound; // ¿Totalmente redondo (tipo píldora)?
  final double radius; // Si no es totalmente redondo, ¿cuánto radio?
  final VoidCallback? onTap; // Función al presionar
  final TextStyle? textStyle; // Opcional: para cambiar color/tamaño de letra
  final double trasparency;

  final Widget? child; // Nuevo parámetro opcional

  const BarraFlotante({
    Key? key,
    this.text = '', // Ahora es opcional si se pasa child
    this.child,
    this.backgroundColor = Colors.blue, // Color por defecto
    this.borderColor = Colors.transparent, // Sin borde por defecto
    this.isFullyRound = true, // Por defecto es tipo píldora
    this.radius = 10.0, // Radio por defecto si no es píldora
    this.onTap,
    this.textStyle,
    this.trasparency = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lógica: Si es totalmente redondo, usamos un radio muy alto (999),
    // si no, usamos el valor de 'radius'.
    final double effectiveRadius = isFullyRound ? 999.0 : radius;

    Widget content =
        child ??
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style:
                textStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
          ),
        );

    Widget container = Container(
      decoration: BoxDecoration(
        // Fondo semi-transparente
        color: backgroundColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(effectiveRadius),
        // Borde sutil
        border: Border.all(color: borderColor, width: 2.0),
        // Sombra sólida desplazada
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.2),
            blurRadius: 2,
            spreadRadius: 0,
            offset: const Offset(3, 4), // Ajustado a 3,3 como en home
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius),
        // Efecto de lente sutil
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: trasparency, sigmaY: trasparency),
          child: content,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        elevation: 0,
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(effectiveRadius),
          child: container,
        ),
      );
    } else {
      return container;
    }
  }
}
