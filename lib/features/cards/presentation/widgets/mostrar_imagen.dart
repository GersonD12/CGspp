import 'package:flutter/material.dart';

class MostrarImagen extends StatelessWidget {
  // 1. Parámetros disponibles
  final Color squareColor; // Color del cuadrado
  final double squareHeight; // Altura del cuadrado
  final double squareWidth; // Anchura del cuadrado
  final IconData icon;
  final String linkImage;
  final Color shadowColor; //color de sombra
  final double borderRadius;
  final Color textColor;
  final double textSize;
  final VoidCallback onTapAction;
  final Color borderColor;
  const MostrarImagen({
    Key? key,
    this.squareColor = Colors.white,
    this.squareHeight = 100,
    this.squareWidth = 100,
    this.icon = Icons.image,
    this.linkImage = '',
    this.borderRadius = 30.0,
    this.shadowColor = Colors.black26,
    this.textColor = Colors.black,
    this.textSize = 16.0,
    required this.onTapAction,
    this.borderColor = Colors.black, // El callback de la acción
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
          border: Border.all(color: borderColor, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 0.0,
              offset: const Offset(5, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            linkImage.isNotEmpty
                ? Image.network(linkImage)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: textSize * 5, color: textColor),
                      Text(
                        'No hay imagen',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: squareHeight * 0.08,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
