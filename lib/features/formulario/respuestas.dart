import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modelo para una respuesta individual
class Respuesta {
  final String preguntaId;
  final String tipoPregunta;
  final String descripcionPregunta;
  final String? respuestaTexto;
  final String? respuestaImagen;
  final List<String>? respuestaOpciones;
  final DateTime fechaRespuesta;

  Respuesta({
    required this.preguntaId,
    required this.tipoPregunta,
    required this.descripcionPregunta,
    this.respuestaTexto,
    this.respuestaImagen,
    this.respuestaOpciones,
    required this.fechaRespuesta,
  });

  // Convertir a Map para serialización
  Map<String, dynamic> toMap() {
    return {
      'preguntaId': preguntaId,
      'tipoPregunta': tipoPregunta,
      'descripcionPregunta': descripcionPregunta,
      'respuestaTexto': respuestaTexto,
      'respuestaImagen': respuestaImagen,
      'respuestaOpciones': respuestaOpciones,
      'fechaRespuesta': fechaRespuesta.millisecondsSinceEpoch,
    };
  }

  // Crear desde Map
  factory Respuesta.fromMap(Map<String, dynamic> map) {
    return Respuesta(
      preguntaId: map['preguntaId'] as String,
      tipoPregunta: map['tipoPregunta'] as String,
      descripcionPregunta: map['descripcionPregunta'] as String,
      respuestaTexto: map['respuestaTexto'] as String?,
      respuestaImagen: map['respuestaImagen'] as String?,
      respuestaOpciones: map['respuestaOpciones'] != null
          ? List<String>.from(map['respuestaOpciones'] as List<dynamic>)
          : null,
      fechaRespuesta: DateTime.fromMillisecondsSinceEpoch(
        map['fechaRespuesta'] as int,
      ),
    );
  }

  // Crear copia con cambios
  Respuesta copyWith({
    String? preguntaId,
    String? tipoPregunta,
    String? descripcionPregunta,
    String? respuestaTexto,
    String? respuestaImagen,
    List<String>? respuestaOpciones,
    DateTime? fechaRespuesta,
  }) {
    return Respuesta(
      preguntaId: preguntaId ?? this.preguntaId,
      tipoPregunta: tipoPregunta ?? this.tipoPregunta,
      descripcionPregunta: descripcionPregunta ?? this.descripcionPregunta,
      respuestaTexto: respuestaTexto ?? this.respuestaTexto,
      respuestaImagen: respuestaImagen ?? this.respuestaImagen,
      respuestaOpciones: respuestaOpciones ?? this.respuestaOpciones,
      fechaRespuesta: fechaRespuesta ?? this.fechaRespuesta,
    );
  }
}

// Estado de las respuestas
class RespuestasState {
  final Map<String, Respuesta> respuestas;
  final bool isLoading;
  final String? error;

  const RespuestasState({
    this.respuestas = const {},
    this.isLoading = false,
    this.error,
  });

  // Obtener respuesta por ID de pregunta
  Respuesta? getRespuesta(String preguntaId) {
    return respuestas[preguntaId];
  }

  // Verificar si hay respuesta para una pregunta
  bool tieneRespuesta(String preguntaId) {
    return respuestas.containsKey(preguntaId);
  }

  // Obtener todas las respuestas como lista
  List<Respuesta> get todasLasRespuestas => respuestas.values.toList();

  // Contar respuestas
  int get totalRespuestas => respuestas.length;

  // Crear copia con cambios
  RespuestasState copyWith({
    Map<String, Respuesta>? respuestas,
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

// Notifier para manejar el estado de las respuestas
class RespuestasNotifier extends StateNotifier<RespuestasState> {
  RespuestasNotifier() : super(const RespuestasState());

  // Agregar o actualizar una respuesta
  void agregarRespuesta(
    String preguntaId,
    String tipoPregunta,
    String descripcionPregunta, {
    String? respuestaTexto,
    String? respuestaImagen,
    List<String>? respuestaOpciones,
  }) {
    final nuevaRespuesta = Respuesta(
      preguntaId: preguntaId,
      tipoPregunta: tipoPregunta,
      descripcionPregunta: descripcionPregunta,
      respuestaTexto: respuestaTexto,
      respuestaImagen: respuestaImagen,
      respuestaOpciones: respuestaOpciones,
      fechaRespuesta: DateTime.now(),
    );

    final nuevasRespuestas = Map<String, Respuesta>.from(state.respuestas);
    nuevasRespuestas[preguntaId] = nuevaRespuesta;

    state = state.copyWith(respuestas: nuevasRespuestas, error: null);

    print('Respuesta guardada para $preguntaId: ${nuevaRespuesta.toMap()}');
  }

  // Actualizar solo el texto de una respuesta
  void actualizarRespuestaTexto(String preguntaId, String texto) {
    final respuestaExistente = state.respuestas[preguntaId];
    if (respuestaExistente != null) {
      final respuestaActualizada = respuestaExistente.copyWith(
        respuestaTexto: texto,
        fechaRespuesta: DateTime.now(),
      );

      final nuevasRespuestas = Map<String, Respuesta>.from(state.respuestas);
      nuevasRespuestas[preguntaId] = respuestaActualizada;

      state = state.copyWith(respuestas: nuevasRespuestas);
    }
  }

  // Actualizar solo la imagen de una respuesta
  void actualizarRespuestaImagen(String preguntaId, String rutaImagen) {
    final respuestaExistente = state.respuestas[preguntaId];
    if (respuestaExistente != null) {
      final respuestaActualizada = respuestaExistente.copyWith(
        respuestaImagen: rutaImagen,
        fechaRespuesta: DateTime.now(),
      );

      final nuevasRespuestas = Map<String, Respuesta>.from(state.respuestas);
      nuevasRespuestas[preguntaId] = respuestaActualizada;

      state = state.copyWith(respuestas: nuevasRespuestas);
    }
  }

  // Actualizar solo las opciones de una respuesta
  void actualizarRespuestaOpciones(String preguntaId, List<String> opciones) {
    final respuestaExistente = state.respuestas[preguntaId];
    if (respuestaExistente != null) {
      final respuestaActualizada = respuestaExistente.copyWith(
        respuestaOpciones: opciones,
        fechaRespuesta: DateTime.now(),
      );

      final nuevasRespuestas = Map<String, Respuesta>.from(state.respuestas);
      nuevasRespuestas[preguntaId] = respuestaActualizada;

      state = state.copyWith(respuestas: nuevasRespuestas);
    }
  }

  // Eliminar una respuesta
  void eliminarRespuesta(String preguntaId) {
    final nuevasRespuestas = Map<String, Respuesta>.from(state.respuestas);
    nuevasRespuestas.remove(preguntaId);

    state = state.copyWith(respuestas: nuevasRespuestas);
  }

  // Limpiar todas las respuestas
  void limpiarRespuestas() {
    state = const RespuestasState();
  }

  // Establecer estado de carga
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  // Establecer error
  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  // Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider para el notifier de respuestas
final respuestasProvider =
    StateNotifierProvider<RespuestasNotifier, RespuestasState>((ref) {
      return RespuestasNotifier();
    });

// Provider para obtener una respuesta específica
final respuestaProvider = Provider.family<Respuesta?, String>((
  ref,
  preguntaId,
) {
  final respuestasState = ref.watch(respuestasProvider);
  return respuestasState.getRespuesta(preguntaId);
});

// Provider para verificar si hay respuestas
final tieneRespuestasProvider = Provider<bool>((ref) {
  final respuestasState = ref.watch(respuestasProvider);
  return respuestasState.totalRespuestas > 0;
});
