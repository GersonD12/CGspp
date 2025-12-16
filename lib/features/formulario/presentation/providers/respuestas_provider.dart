import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/dto/respuesta_dto.dart';
import 'respuestas_state.dart';

/// Notifier para manejar el estado de las respuestas usando Riverpod
class RespuestasNotifier extends StateNotifier<RespuestasState> {
  RespuestasNotifier() : super(const RespuestasState());

  /// Agregar o actualizar una respuesta
  /// NUEVO FORMATO: Usa idpregunta como clave principal
  void agregarRespuesta(
    String idpregunta, // Cambiado de preguntaId a idpregunta
    String grupoId,
    String? tipoPregunta, // Ya no necesario, opcional para compatibilidad
    String? descripcionPregunta, // Ya no necesario, opcional para compatibilidad
    {
    String encabezadoPregunta = '',
    String? emojiPregunta,
    String? respuestaTexto,
    List<String>? respuestaImagenes,
    List<String>? respuestaOpciones, // Solo valores (values) de opciones seleccionadas
    List<OpcionSeleccionadaDTO>? respuestaOpcionesCompletas, // Deprecated
    String? preguntaId, // Compatibilidad hacia atrás
  }) {
    final ahora = DateTime.now();
    final nuevaRespuesta = RespuestaDTO(
      idpregunta: idpregunta,
      preguntaId: preguntaId, // Compatibilidad hacia atrás
      grupoId: grupoId,
      tipoPregunta: tipoPregunta, // Ya no necesario en nuevo formato
      descripcionPregunta: descripcionPregunta, // Ya no necesario en nuevo formato
      encabezadoPregunta: encabezadoPregunta.isNotEmpty 
          ? encabezadoPregunta 
          : descripcionPregunta ?? '', // Fallback a descripcion si no hay encabezado
      emojiPregunta: emojiPregunta, // Ya no necesario en nuevo formato
      respuestaTexto: respuestaTexto,
      respuestaImagenes: respuestaImagenes,
      respuestaOpciones: respuestaOpciones, // Solo valores para búsquedas eficientes
      respuestaOpcionesCompletas: respuestaOpcionesCompletas, // Deprecated
      createdAt: ahora,
      updatedAt: ahora,
    );

    final nuevasRespuestas = Map<String, RespuestaDTO>.from(state.respuestas);
    nuevasRespuestas[idpregunta] = nuevaRespuesta; // Usar idpregunta como clave

    state = state.copyWith(respuestas: nuevasRespuestas, error: null);
  }

  /// Actualizar solo el texto de una respuesta
  /// NUEVO FORMATO: Usa idpregunta como clave
  void actualizarRespuestaTexto(String idpregunta, String texto) {
    final respuestaExistente = state.respuestas[idpregunta];
    if (respuestaExistente != null) {
      final respuestaActualizada = respuestaExistente.copyWith(
        respuestaTexto: texto,
        updatedAt: DateTime.now(),
      );

      final nuevasRespuestas = Map<String, RespuestaDTO>.from(state.respuestas);
      nuevasRespuestas[idpregunta] = respuestaActualizada;

      state = state.copyWith(respuestas: nuevasRespuestas);
    }
  }

  /// Actualizar imágenes de una respuesta (puede ser una o múltiples)
  /// NUEVO FORMATO: Usa idpregunta como clave
  void actualizarRespuestaImagenes(String idpregunta, List<String> rutasImagenes) {
    final respuestaExistente = state.respuestas[idpregunta];
    if (respuestaExistente != null) {
      final respuestaActualizada = respuestaExistente.copyWith(
        respuestaImagenes: rutasImagenes,
        updatedAt: DateTime.now(),
      );

      final nuevasRespuestas = Map<String, RespuestaDTO>.from(state.respuestas);
      nuevasRespuestas[idpregunta] = respuestaActualizada;

      state = state.copyWith(respuestas: nuevasRespuestas);
    }
  }

  /// Actualizar solo las opciones de una respuesta (solo valores)
  /// NUEVO FORMATO: Usa idpregunta como clave y solo guarda valores
  void actualizarRespuestaOpciones(String idpregunta, List<String> opciones) {
    final respuestaExistente = state.respuestas[idpregunta];
    if (respuestaExistente != null) {
      final respuestaActualizada = respuestaExistente.copyWith(
        respuestaOpciones: opciones, // Solo valores para búsquedas eficientes
        updatedAt: DateTime.now(),
      );

      final nuevasRespuestas = Map<String, RespuestaDTO>.from(state.respuestas);
      nuevasRespuestas[idpregunta] = respuestaActualizada;

      state = state.copyWith(respuestas: nuevasRespuestas);
    }
  }

  /// Eliminar una respuesta
  /// NUEVO FORMATO: Usa idpregunta como clave
  void eliminarRespuesta(String idpregunta) {
    final nuevasRespuestas = Map<String, RespuestaDTO>.from(state.respuestas);
    nuevasRespuestas.remove(idpregunta);

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

/// Provider para obtener una respuesta específica por idpregunta
final respuestaProvider = Provider.family<RespuestaDTO?, String>((
  ref,
  idpregunta,
) {
  final respuestasState = ref.watch(respuestasProvider);
  return respuestasState.getRespuesta(idpregunta);
});

/// Provider para verificar si hay respuestas
final tieneRespuestasProvider = Provider<bool>((ref) {
  final respuestasState = ref.watch(respuestasProvider);
  return respuestasState.totalRespuestas > 0;
});

