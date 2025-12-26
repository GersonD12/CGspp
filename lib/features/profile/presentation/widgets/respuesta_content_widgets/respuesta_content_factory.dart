import 'package:flutter/material.dart';
import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/profile/presentation/widgets/respuesta_content_widgets/respuesta_pais_widget.dart';
import 'package:calet/features/profile/presentation/widgets/respuesta_content_widgets/respuesta_texto_widget.dart';
import 'package:calet/features/profile/presentation/widgets/respuesta_content_widgets/respuesta_opciones_widget.dart';
import 'package:calet/features/profile/presentation/widgets/respuesta_content_widgets/respuesta_imagenes_preview_widget.dart';
import 'package:calet/features/profile/presentation/widgets/respuesta_content_widgets/sin_respuesta_widget.dart';

/// Factory que crea el widget apropiado según el tipo de respuesta
class RespuestaContentFactory {
  static Widget build({
    required BuildContext context,
    required PreguntaDTO pregunta,
    required RespuestaDTO respuesta,
  }) {
    final tipoPregunta = pregunta.tipo.toLowerCase();

    // Respuesta de tipo país - mostrar bandera y nombre del país
    if (tipoPregunta == 'pais' &&
        respuesta.respuestaTexto != null &&
        respuesta.respuestaTexto!.isNotEmpty) {
      return RespuestaPaisWidget(respuesta: respuesta);
    }

    // Respuesta de texto (para otros tipos)
    if (respuesta.respuestaTexto != null && respuesta.respuestaTexto!.isNotEmpty) {
      return RespuestaTextoWidget(respuesta: respuesta);
    }

    // Respuesta de opciones múltiples
    if (respuesta.respuestaOpciones != null && respuesta.respuestaOpciones!.isNotEmpty) {
      return RespuestaOpcionesWidget(
        pregunta: pregunta,
        respuesta: respuesta,
      );
    }

    // Respuesta de imágenes
    if (respuesta.respuestaImagenes != null && respuesta.respuestaImagenes!.isNotEmpty) {
      return RespuestaImagenesPreviewWidget(respuesta: respuesta);
    }

    // Sin respuesta válida
    return const SinRespuestaWidget();
  }
}

