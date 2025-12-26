import 'package:flutter/material.dart';
import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/formulario/presentation/helpers/formulario_theme_helper.dart';

/// Widget que muestra el header de una pregunta (emoji + texto)
class PreguntaHeaderWidget extends StatelessWidget {
  final PreguntaDTO pregunta;
  final Widget? actionButton;

  const PreguntaHeaderWidget({
    super.key,
    required this.pregunta,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    final formTheme = FormularioThemeHelper.getThemeExtension(context);
    final textColor = FormularioThemeHelper.getTextColor(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Emoji en un contenedor circular
        if (pregunta.emoji.isNotEmpty)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: formTheme.formPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                pregunta.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          )
        else
          const SizedBox(width: 40, height: 40),
        const SizedBox(width: 12),
        // Texto de la pregunta
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  pregunta.encabezado.isNotEmpty
                      ? pregunta.encabezado
                      : pregunta.descripcion,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
              ),
              if (actionButton != null) actionButton!,
            ],
          ),
        ),
      ],
    );
  }
}

