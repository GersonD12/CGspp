import 'package:flutter/material.dart';

class Cards extends StatelessWidget {
  // 1. Parámetros disponibles
  final Color squareColor; // Color del cuadrado
  final double squareHeight; // Altura del cuadrado
  final double squareWidth; // Anchura del cuadrado
  final String text; // Texto dentro del cuadrado
  final Color shadowColor; //color de sombra
  final double borderRadius;
  final Color textColor;
  final double textSize;
  final VoidCallback onTapAction;
  const Cards({
    Key? key,
    required this.squareColor,
    required this.squareHeight,
    required this.squareWidth,
    required this.text,
    this.borderRadius = 5.0,
    this.shadowColor = Colors.black26,
    this.textColor = Colors.white,
    this.textSize = 16.0,
    required this.onTapAction, // El callback de la acción
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 2. Usamos InkWell se usa para detectar toques y mostrar efectos visuales
    return InkWell(
      onTap: onTapAction, // 3. Acción al tocar el cuadrado
      child: Container(
        margin: const EdgeInsets.all(8.0),
        height: squareHeight, // 4. Altura
        width: squareWidth, // 5. Anchura
        decoration: BoxDecoration(
          color: squareColor, // 6. Color
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 5.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text, // 7. Texto parametrizado
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: textSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
