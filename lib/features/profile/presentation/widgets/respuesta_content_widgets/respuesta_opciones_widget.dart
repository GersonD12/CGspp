import 'package:flutter/material.dart';
import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/formulario/presentation/helpers/formulario_theme_helper.dart';
import 'package:calet/features/profile/presentation/widgets/respuesta_content_widgets/glass_container_widget.dart';

/// Widget que muestra una respuesta de opciones múltiples
class RespuestaOpcionesWidget extends StatelessWidget {
  final PreguntaDTO pregunta;
  final RespuestaDTO respuesta;

  const RespuestaOpcionesWidget({
    super.key,
    required this.pregunta,
    required this.respuesta,
  });

  @override
  Widget build(BuildContext context) {
    if (respuesta.respuestaOpciones == null || respuesta.respuestaOpciones!.isEmpty) {
      return const SizedBox.shrink();
    }

    final formTheme = FormularioThemeHelper.getThemeExtension(context);

    return GlassContainerWidget(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: respuesta.respuestaOpciones!.map((opcion) {
          // Buscar el texto de la opción en las opciones de la pregunta
          final opcionDTO = pregunta.opciones.firstWhere(
            (o) => o.value == opcion,
            orElse: () => OpcionDTO(text: opcion, value: opcion),
          );

          return Chip(
            padding: const EdgeInsets.all(8),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (opcionDTO.emoji.isNotEmpty) ...[
                  Text(opcionDTO.emoji),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    opcionDTO.text.isNotEmpty ? opcionDTO.text : opcionDTO.value,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: formTheme.formPrimary,
            labelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            shape: const StadiumBorder(),
          );
        }).toList(),
      ),
    );
  }
}

