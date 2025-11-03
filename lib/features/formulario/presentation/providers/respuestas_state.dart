import '../../application/dto/respuesta_dto.dart';

/// Estado que representa el estado de las respuestas del formulario
/// 
/// Pertenece a la capa de presentación ya que contiene estado UI
/// (isLoading, error) además de las respuestas
class RespuestasState {
  final Map<String, RespuestaDTO> respuestas;
  final bool isLoading;
  final String? error;

  const RespuestasState({
    this.respuestas = const {},
    this.isLoading = false,
    this.error,
  });

  /// Obtener respuesta por ID de pregunta
  RespuestaDTO? getRespuesta(String preguntaId) {
    return respuestas[preguntaId];
  }

  /// Verificar si hay respuesta para una pregunta
  bool tieneRespuesta(String preguntaId) {
    return respuestas.containsKey(preguntaId);
  }

  /// Obtener todas las respuestas como lista
  List<RespuestaDTO> get todasLasRespuestas => respuestas.values.toList();

  /// Contar respuestas
  int get totalRespuestas => respuestas.length;

  /// Crear copia con cambios
  RespuestasState copyWith({
    Map<String, RespuestaDTO>? respuestas,
    bool? isLoading,
    String? error,
  }) {
    return RespuestasState(
      respuestas: respuestas ?? this.respuestas,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

