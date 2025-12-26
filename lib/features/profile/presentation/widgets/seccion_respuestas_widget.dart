import 'package:flutter/material.dart';
import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/profile/presentation/widgets/respuesta_item_widget.dart';

/// Widget que muestra una sección con todas sus respuestas
class SeccionRespuestasWidget extends StatelessWidget {
  final SeccionDTO seccion;
  final List<PreguntaDTO> preguntas;
  final Map<String, RespuestaDTO> respuestas;
  final String userId;
  final VoidCallback? onRespuestaGuardada;

  const SeccionRespuestasWidget({
    super.key,
    required this.seccion,
    required this.preguntas,
    required this.respuestas,
    required this.userId,
    this.onRespuestaGuardada,
  });

  @override
  Widget build(BuildContext context) {
    // Ordenar preguntas por orden
    final preguntasOrdenadas = List<PreguntaDTO>.from(preguntas)
      ..sort((a, b) => a.orden.compareTo(b.orden));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado de la sección
        Padding(
          padding: const EdgeInsets.only(bottom: 16, top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                seccion.titulo,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (seccion.descripcion.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  seccion.descripcion,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Preguntas y respuestas
        if (preguntasOrdenadas.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              'No hay preguntas en esta sección',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...preguntasOrdenadas.map((pregunta) {
            final respuesta = respuestas[pregunta.idpregunta];
            return RespuestaItemWidget(
              pregunta: pregunta,
              respuesta: respuesta,
              userId: userId,
              onRespuestaGuardada: onRespuestaGuardada,
            );
          }),
        
        const SizedBox(height: 24),
        Divider(
          height: 1,
          thickness: 1,
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ],
    );
  }
}

