import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/formulario/presentation/widgets/question_inputs/pregunta_widget_factory.dart';
import 'package:flutter/material.dart';

/// Widget para mostrar un grupo de preguntas múltiples agrupadas
class PreguntasMultipleGroupWidget extends StatelessWidget {
  final List<PreguntaDTO> preguntas;
  final Map<String, RespuestaDTO> respuestasGuardadas;
  final Function(String preguntaId, String grupoId, String tipo, String descripcion, String encabezado, String? emoji, List<String> respuestas, Map<String, String>? opcionesConEmoji, Map<String, String>? opcionesConText) onMultipleChanged;
  final Function(String preguntaId, String grupoId, String tipo, String descripcion, String encabezado, String? emoji, String? texto) onTextoChanged;
  final Function(String preguntaId, String grupoId, String tipo, String descripcion, String encabezado, String? emoji, String? numero) onNumeroChanged;
  final Function(String preguntaId, String grupoId, String tipo, String descripcion, String encabezado, String? emoji, List<String> imagenes) onImagenChanged;
  final Function(String preguntaId, String grupoId, String tipo, String descripcion, String encabezado, String? emoji, String telefono) onTelefonoChanged;
  final Function(String preguntaId, String grupoId, String tipo, String descripcion, String encabezado, String? emoji, String codigoPais) onPaisChanged;
  final Function(String preguntaId, String grupoId, String tipo, String descripcion, String encabezado, String? emoji, String fecha) onFechaChanged;

  const PreguntasMultipleGroupWidget({
    super.key,
    required this.preguntas,
    required this.respuestasGuardadas,
    required this.onMultipleChanged,
    required this.onTextoChanged,
    required this.onNumeroChanged,
    required this.onImagenChanged,
    required this.onTelefonoChanged,
    required this.onPaisChanged,
    required this.onFechaChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: preguntas.map((pregunta) {
          final respuestaGuardada = respuestasGuardadas[pregunta.idpregunta];
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: PreguntaWidgetFactory.create(
              pregunta: pregunta,
              respuestaGuardada: respuestaGuardada,
              onMultipleChanged: onMultipleChanged,
              onTextoChanged: onTextoChanged,
              onNumeroChanged: onNumeroChanged,
              onImagenChanged: onImagenChanged,
              onTelefonoChanged: onTelefonoChanged,
              onPaisChanged: onPaisChanged,
              onFechaChanged: onFechaChanged,
            ),
          );
        }).toList(),
      ),
    );
  }
}

