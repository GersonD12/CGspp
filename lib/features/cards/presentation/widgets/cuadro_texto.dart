import 'package:flutter/material.dart';

/// Un widget que muestra texto dentro de un cuadro con bordes y scroll.
class TextBox extends StatelessWidget {
  final Color backgroundColor;
  final TextEditingController controller;
  final Color textColor;
  final double borderWidth;
  final Color borderColor;
  final double borderRadius;
  final String? hintText;
  final int? maxLines;

  const TextBox({
    super.key,
    this.backgroundColor = Colors.transparent,
    required this.controller,
    this.hintText,
    this.textColor = Colors.black,
    this.borderWidth = 1.0,
    this.borderColor = Colors.grey,
    this.borderRadius = 12.0,
    this.maxLines = 5, // Un valor razonable por defecto.
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),

      child: TextField(
        controller: controller,
        readOnly: false, // Permitimos la edición
        maxLines: maxLines,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
          border: InputBorder.none, // Sin bordes internos
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
