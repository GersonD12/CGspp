import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/dto/respuesta_dto.dart';
import 'respuestas_state.dart';

/// Notifier para manejar el estado de las respuestas usando Riverpod
class RespuestasNotifier extends StateNotifier<RespuestasState> {
  RespuestasNotifier() : super(const RespuestasState());

  /// Agregar o actualizar una respuesta
  void agregarRespuesta(
    String preguntaId,
    String tipoPregunta,
    String descripcionPregunta, {
    String? respuestaTexto,
    String? respuestaImagen,
    List<String>? respuestaOpciones,
  }) {
    final nuevaRespuesta = RespuestaDTO(
      preguntaId: preguntaId,
      tipoPregunta: tipoPregunta,
      descripcionPregunta: descripcionPregunta,
      respuestaTexto: respuestaTexto,
      respuestaImagen: respuestaImagen,
      respuestaOpciones: respuestaOpciones,
      fechaRespuesta: DateTime.now(),
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
        fechaRespuesta: DateTime.now(),
      );

      final nuevasRespuestas = Map<String, RespuestaDTO>.from(state.respuestas);
      nuevasRespuestas[preguntaId] = respuestaActualizada;

      state = state.copyWith(respuestas: nuevasRespuestas);
    }
  }

  /// Actualizar solo la imagen de una respuesta
  void actualizarRespuestaImagen(String preguntaId, String rutaImagen) {
    final respuestaExistente = state.respuestas[preguntaId];
    if (respuestaExistente != null) {
      final respuestaActualizada = respuestaExistente.copyWith(
        respuestaImagen: rutaImagen,
        fechaRespuesta: DateTime.now(),
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
        fechaRespuesta: DateTime.now(),
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

