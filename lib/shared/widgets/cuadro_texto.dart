import 'package:flutter/material.dart';
import 'package:calet/core/theme/app_theme_extension.dart';

/// Un widget que muestra texto dentro de un cuadro con bordes y scroll.
class TextBox extends StatelessWidget {
  final TextEditingController controller;
  final double borderWidth;
  final double borderRadius;
  final String? hintText;
  final int? maxLines;
  final ValueChanged<String>? onSubmitted;

  const TextBox({
    super.key,
    required this.controller,
    this.hintText,
    this.borderWidth = 1.0,
    this.borderRadius = 12.0,
    this.maxLines = 5, // Un valor razonable por defecto.
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).extension<AppThemeExtension>()!.barColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Theme.of(
            context,
          ).extension<AppThemeExtension>()!.barBorder.withOpacity(0.2),
          width: borderWidth,
        ),
      ),

      child: TextField(
        controller: controller,
        readOnly: false, // Permitimos la edición
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none, // Sin bordes internos
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}
