import 'package:flutter/material.dart';

class BotonSiguiente extends StatelessWidget {
  final VoidCallback onPressed;
  final String
  texto; // Propiedad para el texto, la variable en donde se va a guardar el texto
  final Color? color;
  final Color? textColor;

  const BotonSiguiente({
    super.key,
    required this.onPressed,
    this.texto = 'Siguiente', // Valor por defecto o inicial
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      // Usamos la propiedad 'texto' en lugar del texto fijo
      label: Text(
        texto,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      icon: const Icon(Icons.arrow_forward, color: Colors.black),
      backgroundColor: color,
    );
  }
}
