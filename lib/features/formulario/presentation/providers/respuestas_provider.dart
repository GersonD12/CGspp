import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/dto/respuesta_dto.dart';
import 'respuestas_state.dart';

/// Notifier para manejar el estado de las respuestas usando Riverpod
class RespuestasNotifier extends StateNotifier<RespuestasState> {
  RespuestasNotifier() : super(const RespuestasState());

  /// Agregar o actualizar una respuesta
  void agregarRespuesta(
    String preguntaId,
    String grupoId,
    String tipoPregunta,
    String descripcionPregunta, {
    String encabezadoPregunta = '',
    String? emojiPregunta,
    String? respuestaTexto,
    List<String>? respuestaImagenes,
    List<String>? respuestaOpciones,
    List<OpcionSeleccionadaDTO>? respuestaOpcionesCompletas,
  }) {
    final ahora = DateTime.now();
    final nuevaRespuesta = RespuestaDTO(
      preguntaId: preguntaId,
      grupoId: grupoId,
      tipoPregunta: tipoPregunta,
      descripcionPregunta: descripcionPregunta,
      encabezadoPregunta: encabezadoPregunta.isNotEmpty 
          ? encabezadoPregunta 
          : descripcionPregunta, // Fallback a descripcion si no hay encabezado
      emojiPregunta: emojiPregunta,
      respuestaTexto: respuestaTexto,
      respuestaImagenes: respuestaImagenes,
      respuestaOpciones: respuestaOpciones,
      respuestaOpcionesCompletas: respuestaOpcionesCompletas,
      createdAt: ahora,
      updatedAt: ahora,
    );

    final nuevasRespuestas = Map<String, RespuestaDTO>.from(state.respuestas);
    nuevasRespuestas[preguntaId] = nuevaRespuesta;

    state = state.copyWith(respuestas: nuevasRespuestas, error: null);
  }

  /// Actualizar solo el texto de una respuesta
  void actualizarRespuestaTexto(String preguntaId, String texto) {
    final respuestaExistente = state.respuestas[preguntaId];
    if (respuestaExistente != null) {
      final respuestaActualizada = respuestaExistente.copyWith(
        respuestaTexto: texto,
        updatedAt: DateTime.now(),
      );

      final nuevasRespuestas = Map<String, RespuestaDTO>.from(state.respuestas);
      nuevasRespuestas[preguntaId] = respuestaActualizada;

      state = state.copyWith(respuestas: nuevasRespuestas);
    }
  }

  /// Actualizar imágenes de una respuesta (puede ser una o múltiples)
  void actualizarRespuestaImagenes(String preguntaId, List<String> rutasImagenes) {
    final respuestaExistente = state.respuestas[preguntaId];
    if (respuestaExistente != null) {
      final respuestaActualizada = respuestaExistente.copyWith(
        respuestaImagenes: rutasImagenes,
        updatedAt: DateTime.now(),
      );

      final nuevasRespuestas = Map<String, RespuestaDTO>.from(state.respuestas);
      nuevasRespuestas[preguntaId] = respuestaActualizada;

      state = state.copyWith(respuestas: nuevasRespuestas);
    }
  }

  /// Actualizar solo las opciones de una respuesta
  void actualizarRespuestaOpciones(String preguntaId, List<String> opciones) {
    final respuestaExistente = state.respuestas[preguntaId];
    if (respuestaExistente != null) {
      final respuestaActualizada = respuestaExistente.copyWith(
        respuestaOpciones: opciones,
        updatedAt: DateTime.now(),
      );

      final nuevasRespuestas = Map<String, RespuestaDTO>.from(state.respuestas);
      nuevasRespuestas[preguntaId] = respuestaActualizada;

      state = state.copyWith(respuestas: nuevasRespuestas);
    }
  }

  /// Eliminar una respuesta
  void eliminarRespuesta(String preguntaId) {
    final nuevasRespuestas = Map<String, RespuestaDTO>.from(state.respuestas);
    nuevasRespuestas.remove(preguntaId);

    state = state.copyWith(respuestas: nuevasRespuestas);
  }

  /// Limpiar todas las respuestas
  void limpiarRespuestas() {
    state = const RespuestasState();
  }

  /// Establecer estado de carga
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// Establecer error
  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider para el notifier de respuestas
final respuestasProvider =
    StateNotifierProvider<RespuestasNotifier, RespuestasState>((ref) {
  return RespuestasNotifier();
});

/// Provider para obtener una respuesta específica
final respuestaProvider = Provider.family<RespuestaDTO?, String>((
  ref,
  preguntaId,
) {
  final respuestasState = ref.watch(respuestasProvider);
  return respuestasState.getRespuesta(preguntaId);
});

/// Provider para verificar si hay respuestas
final tieneRespuestasProvider = Provider<bool>((ref) {
  final respuestasState = ref.watch(respuestasProvider);
  return respuestasState.totalRespuestas > 0;
});

