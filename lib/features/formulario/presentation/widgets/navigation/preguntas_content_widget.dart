import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/formulario/presentation/controllers/respuestas_callbacks_handler.dart';
import 'package:calet/features/formulario/presentation/helpers/formulario_theme_helper.dart';
import 'package:calet/features/formulario/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

/// Widget que muestra el contenido de las preguntas (una o múltiples)
class PreguntasContentWidget extends StatelessWidget {
  final List<PreguntaDTO> bloqueActual;
  final Map<String, RespuestaDTO> respuestasMap;
  final RespuestasCallbacksHandler callbacksHandler;

  const PreguntasContentWidget({
    super.key,
    required this.bloqueActual,
    required this.respuestasMap,
    required this.callbacksHandler,
  });

  @override
  Widget build(BuildContext context) {
    if (bloqueActual.isEmpty) {
      return Center(
        child: Text(
          'No hay preguntas para mostrar.',
          style: TextStyle(
            color: FormularioThemeHelper.getTextColor(context),
          ),
        ),
      );
    }

    // Si hay múltiples preguntas, usar el widget de grupo
    if (bloqueActual.length > 1) {
      return PreguntasMultipleGroupWidget(
        preguntas: bloqueActual,
        respuestasGuardadas: respuestasMap,
        onMultipleChanged: callbacksHandler.onMultipleChanged,
        onTextoChanged: callbacksHandler.onTextoChanged,
        onNumeroChanged: callbacksHandler.onNumeroChanged,
        onImagenChanged: callbacksHandler.onImagenChanged,
        onTelefonoChanged: callbacksHandler.onTelefonoChanged,
        onPaisChanged: callbacksHandler.onPaisChanged,
        onFechaChanged: callbacksHandler.onFechaChanged,
      );
    }

    // Una sola pregunta
    final pregunta = bloqueActual.first;
    final respuestaGuardada = respuestasMap[pregunta.idpregunta];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: PreguntaWidgetFactory.create(
        pregunta: pregunta,
        respuestaGuardada: respuestaGuardada,
        onMultipleChanged: callbacksHandler.onMultipleChanged,
        onTextoChanged: callbacksHandler.onTextoChanged,
        onNumeroChanged: callbacksHandler.onNumeroChanged,
        onImagenChanged: callbacksHandler.onImagenChanged,
        onTelefonoChanged: callbacksHandler.onTelefonoChanged,
        onPaisChanged: callbacksHandler.onPaisChanged,
        onFechaChanged: callbacksHandler.onFechaChanged,
      ),
    );
  }
}

