import 'package:calet/features/formulario/presentation/providers/respuestas_provider.dart';
import 'package:calet/features/formulario/application/dto/respuesta_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Use case para guardar una respuesta
class GuardarRespuestaUseCase {
  final WidgetRef ref;

  GuardarRespuestaUseCase(this.ref);

  /// Guardar respuesta para pregunta de radio/múltiple (una o múltiples opciones)
  void guardarRespuestaRadio(
    String preguntaId,
    String grupoId,
    String tipoPregunta,
    String descripcionPregunta,
    String encabezadoPregunta,
    String? emojiPregunta,
    List<String> valoresSeleccionados, // Valores seleccionados
    Map<String, String>? opcionesConEmoji, // Mapa de value -> emoji (opcional)
    Map<String, String>? opcionesConText, // Mapa de value -> text (opcional)
  ) {
    final respuestasNotifier = ref.read(respuestasProvider.notifier);
    
    // Convertir a OpcionSeleccionadaDTO si hay información adicional disponible
    List<OpcionSeleccionadaDTO>? opcionesCompletas;
    if (valoresSeleccionados.isNotEmpty && 
        (opcionesConEmoji != null || opcionesConText != null)) {
      opcionesCompletas = valoresSeleccionados.map((valor) {
        return OpcionSeleccionadaDTO(
          text: opcionesConText?[valor] ?? valor,
          value: valor,
          emoji: opcionesConEmoji?[valor] ?? '',
        );
      }).toList();
    }
    
    respuestasNotifier.agregarRespuesta(
      preguntaId,
      grupoId,
      tipoPregunta,
      descripcionPregunta,
      encabezadoPregunta: encabezadoPregunta,
      emojiPregunta: emojiPregunta,
      respuestaOpciones: valoresSeleccionados.isNotEmpty ? valoresSeleccionados : null,
      respuestaOpcionesCompletas: opcionesCompletas,
    );
  }

  /// Guardar respuesta de texto
  void guardarRespuestaTexto(
    String preguntaId,
    String grupoId,
    String tipoPregunta,
    String descripcionPregunta,
    String encabezadoPregunta,
    String? emojiPregunta,
    String texto,
  ) {
    final respuestasNotifier = ref.read(respuestasProvider.notifier);
    final respuestaExistente = ref
        .read(respuestasProvider)
        .respuestas[preguntaId];

    if (respuestaExistente != null) {
      // Actualizar manteniendo otros valores
      respuestasNotifier.actualizarRespuestaTexto(preguntaId, texto);
    } else {
      // Crear nueva respuesta
      respuestasNotifier.agregarRespuesta(
        preguntaId,
        grupoId,
        tipoPregunta,
        descripcionPregunta,
        encabezadoPregunta: encabezadoPregunta,
        emojiPregunta: emojiPregunta,
        respuestaTexto: texto,
      );
    }
  }

  /// Guardar respuesta de imagen (una o múltiples imágenes)
  void guardarRespuestaImagenes(
    String preguntaId,
    String grupoId,
    String tipoPregunta,
    String descripcionPregunta,
    String encabezadoPregunta,
    String? emojiPregunta,
    List<String> imageUrls,
  ) {
    final respuestasNotifier = ref.read(respuestasProvider.notifier);
    final respuestaExistente = ref
        .read(respuestasProvider)
        .respuestas[preguntaId];

    if (respuestaExistente != null) {
      // Actualizar manteniendo otros valores
      respuestasNotifier.actualizarRespuestaImagenes(preguntaId, imageUrls);
    } else {
      // Crear nueva respuesta
      respuestasNotifier.agregarRespuesta(
        preguntaId,
        grupoId,
        tipoPregunta,
        descripcionPregunta,
        encabezadoPregunta: encabezadoPregunta,
        emojiPregunta: emojiPregunta,
        respuestaImagenes: imageUrls,
      );
    }
  }

  /// Guardar respuesta de número
  void guardarRespuestaNumero(
    String preguntaId,
    String grupoId,
    String tipoPregunta,
    String descripcionPregunta,
    String encabezadoPregunta,
    String? emojiPregunta,
    String numero,
  ) {
    final respuestasNotifier = ref.read(respuestasProvider.notifier);
    final respuestaExistente = ref
        .read(respuestasProvider)
        .respuestas[preguntaId];

    if (respuestaExistente != null) {
      // Actualizar manteniendo otros valores
      respuestasNotifier.actualizarRespuestaTexto(preguntaId, numero);
    } else {
      // Crear nueva respuesta
      respuestasNotifier.agregarRespuesta(
        preguntaId,
        grupoId,
        tipoPregunta,
        descripcionPregunta,
        encabezadoPregunta: encabezadoPregunta,
        emojiPregunta: emojiPregunta,
        respuestaTexto: numero,
      );
    }
  }
}
