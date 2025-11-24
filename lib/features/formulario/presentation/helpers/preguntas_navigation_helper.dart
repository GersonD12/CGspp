import 'package:calet/features/formulario/application/dto/dto.dart';

/// Helper para lógica de navegación entre preguntas y secciones
class PreguntasNavigationHelper {
  /// Verifica si estamos en la primera pregunta de una sección
  static bool esPrimeraPreguntaDeSeccion({
    required PreguntaDTO preguntaActual,
    required Map<String, List<PreguntaDTO>> preguntasPorGrupo,
  }) {
    final preguntasSeccionActual = preguntasPorGrupo[preguntaActual.grupoId] ?? [];
    return preguntasSeccionActual.isNotEmpty && 
        preguntaActual.id == preguntasSeccionActual.first.id;
  }

  /// Obtiene el índice de la última pregunta de la sección anterior
  static int? getIndiceUltimaPreguntaSeccionAnterior({
    required int contador,
    required List<PreguntaDTO> preguntas,
    required Map<String, List<PreguntaDTO>> preguntasPorGrupo,
    required List<String> ordenSecciones,
  }) {
    if (contador == 0 || preguntas.isEmpty) return null;
    
    final grupoIdActual = preguntas[contador].grupoId;
    final preguntasSeccionActual = preguntasPorGrupo[grupoIdActual] ?? [];
    
    // Si estamos en la primera pregunta de una sección, buscar la última pregunta de la sección anterior
    if (preguntasSeccionActual.isNotEmpty && 
        preguntas[contador].id == preguntasSeccionActual.first.id) {
      final indiceSeccionActual = ordenSecciones.indexOf(grupoIdActual);
      if (indiceSeccionActual > 0) {
        final seccionAnteriorId = ordenSecciones[indiceSeccionActual - 1];
        final preguntasSeccionAnterior = preguntasPorGrupo[seccionAnteriorId] ?? [];
        if (preguntasSeccionAnterior.isNotEmpty) {
          final ultimaPreguntaAnterior = preguntasSeccionAnterior.last;
          final indiceUltimaPregunta = preguntas.indexWhere(
            (p) => p.id == ultimaPreguntaAnterior.id
          );
          if (indiceUltimaPregunta != -1) {
            return indiceUltimaPregunta;
          }
        }
      }
    }
    
    return null;
  }

  /// Obtiene el índice de la última pregunta de una sección específica
  static int? getIndiceUltimaPreguntaSeccion({
    required String seccionId,
    required List<PreguntaDTO> preguntas,
    required Map<String, List<PreguntaDTO>> preguntasPorGrupo,
  }) {
    final preguntasSeccion = preguntasPorGrupo[seccionId] ?? [];
    if (preguntasSeccion.isEmpty) return null;
    
    final ultimaPregunta = preguntasSeccion.last;
    return preguntas.indexWhere((p) => p.id == ultimaPregunta.id);
  }

  /// Verifica si se completó una sección al cambiar de grupo
  static bool seCompletoSeccion({
    required String grupoIdAnterior,
    required String grupoIdActual,
  }) {
    return grupoIdAnterior != grupoIdActual && grupoIdAnterior.isNotEmpty;
  }

  /// Obtiene la siguiente sección en el orden
  static String? getSiguienteSeccion({
    required String seccionActualId,
    required List<String> ordenSecciones,
  }) {
    final indice = ordenSecciones.indexOf(seccionActualId);
    if (indice == -1 || indice >= ordenSecciones.length - 1) {
      return null;
    }
    return ordenSecciones[indice + 1];
  }
}

