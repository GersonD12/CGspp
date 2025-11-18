import 'package:calet/features/formulario/presentation/providers/respuestas_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Use case para guardar una respuesta
class GuardarRespuestaUseCase {
  final WidgetRef ref;

  GuardarRespuestaUseCase(this.ref);

  /// Guardar respuesta para pregunta de radio/múltiple
  void guardarRespuestaRadio(
    String preguntaId,
    String tipoPregunta,
    String descripcionPregunta,
    String respuesta,
  ) {
    final respuestasNotifier = ref.read(respuestasProvider.notifier);
    respuestasNotifier.agregarRespuesta(
      preguntaId,
      tipoPregunta,
      descripcionPregunta,
      respuestaOpciones: [respuesta],
    );
  }

  /// Guardar respuesta de texto
  void guardarRespuestaTexto(
    String preguntaId,
    String tipoPregunta,
    String descripcionPregunta,
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
        tipoPregunta,
        descripcionPregunta,
        respuestaTexto: texto,
      );
    }
  }

  /// Guardar respuesta de imagen
  void guardarRespuestaImagen(
    String preguntaId,
    String tipoPregunta,
    String descripcionPregunta,
    String? imageUrl,
  ) {
    final respuestasNotifier = ref.read(respuestasProvider.notifier);
    final respuestaExistente = ref
        .read(respuestasProvider)
        .respuestas[preguntaId];

    if (respuestaExistente != null) {
      // Actualizar manteniendo otros valores
      respuestasNotifier.actualizarRespuestaImagen(preguntaId, imageUrl ?? '');
    } else {
      // Crear nueva respuesta
      respuestasNotifier.agregarRespuesta(
        preguntaId,
        tipoPregunta,
        descripcionPregunta,
        respuestaImagen: imageUrl,
      );
    }
  }

  /// Guardar respuesta de número
  void guardarRespuestaNumero(
    String preguntaId,
    String tipoPregunta,
    String descripcionPregunta,
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
        tipoPregunta,
        descripcionPregunta,
        respuestaTexto: numero,
      );
    }
  }
}
