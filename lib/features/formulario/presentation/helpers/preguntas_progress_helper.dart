import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/formulario/presentation/providers/respuestas_state.dart';

/// Helper para cálculos de progreso y validación de respuestas
class PreguntasProgressHelper {
  /// Obtiene las preguntas de una sección específica
  static List<PreguntaDTO> getPreguntasDeSeccion({
    required String grupoId,
    required Map<String, List<PreguntaDTO>> preguntasPorGrupo,
  }) {
    return preguntasPorGrupo[grupoId] ?? [];
  }

  /// Calcula el progreso de la sección actual
  static double calcularProgreso({
    required int indicePreguntaEnSeccion,
    required int totalPreguntasEnSeccion,
  }) {
    if (totalPreguntasEnSeccion == 0) return 0.0;
    return (indicePreguntaEnSeccion + 1) / totalPreguntasEnSeccion;
  }

  /// Obtiene el índice de una pregunta dentro de su sección
  static int getIndiceEnSeccion({
    required PreguntaDTO pregunta,
    required List<PreguntaDTO> preguntasSeccion,
  }) {
    final indice = preguntasSeccion.indexWhere((p) => p.id == pregunta.id);
    return indice != -1 ? indice : 0;
  }

  /// Genera el título de la pantalla con información de progreso
  /// Ahora usa bloques/páginas en lugar de preguntas individuales
  static String generarTitulo({
    required int contador,
    required int totalPreguntas,
    required int indiceEnSeccion,
    required int totalPreguntasSeccion,
    required SeccionDTO? seccionActual,
  }) {
    // Mostrar el título de la sección con el progreso de páginas/bloques
    if (totalPreguntasSeccion > 0 && seccionActual != null) {
      return '${seccionActual.titulo} - Página ${indiceEnSeccion + 1} de $totalPreguntasSeccion';
    } else {
      return 'Página ${contador + 1} de $totalPreguntas';
    }
  }

  /// Verifica si una pregunta ha sido respondida
  static bool isPreguntaRespondida({
    required String preguntaId,
    required RespuestasState respuestasState,
  }) {
    final respuesta = respuestasState.todasLasRespuestas.firstWhere(
      (r) => r.preguntaId == preguntaId,
      orElse: () => RespuestaDTO(
        preguntaId: '',
        grupoId: '',
        tipoPregunta: '',
        descripcionPregunta: '',
        encabezadoPregunta: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    // Para radio/opción múltiple, verifica que haya una selección no vacía
    if (respuesta.respuestaOpciones?.isNotEmpty ?? false) {
      return respuesta.respuestaOpciones!.first.isNotEmpty;
    }
    // Para texto, verifica que no esté vacío
    if (respuesta.respuestaTexto?.isNotEmpty ?? false) {
      return true;
    }
    // Para imagen, verifica que haya imágenes
    if (respuesta.respuestaImagenes?.isNotEmpty ?? false) {
      return true;
    }
    return false;
  }

  /// Verifica si estamos en la primera pregunta de la primera sección
  static bool esPrimeraPreguntaPrimeraSeccion({
    required int contador,
    required List<PreguntaDTO> preguntas,
    required List<String> ordenSecciones,
  }) {
    return contador == 0 && 
        (ordenSecciones.isEmpty || 
         preguntas.isEmpty || 
         preguntas[0].grupoId == ordenSecciones.first);
  }
}

