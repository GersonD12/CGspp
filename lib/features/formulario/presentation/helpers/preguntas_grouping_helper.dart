import 'package:calet/features/formulario/application/dto/dto.dart';

/// Helper para agrupar preguntas múltiples de la misma sección
/// 
/// Todas las preguntas múltiples de una sección se agrupan juntas y se ordenan por 'orden'
/// Las preguntas no múltiples mantienen su posición original relativa
class PreguntasGroupingHelper {
  /// Agrupa las preguntas múltiples de la misma sección
  static List<List<PreguntaDTO>> agruparPreguntasMultiples(
    List<PreguntaDTO> preguntas,
  ) {
    if (preguntas.isEmpty) return [];

    // 1. Agrupar todas las preguntas múltiples por sección y ordenarlas
    final Map<String, List<PreguntaDTO>> multiplesPorSeccion = {};
    for (final pregunta in preguntas) {
      if (pregunta.tipo.toLowerCase().trim() == 'multiple') {
        multiplesPorSeccion
            .putIfAbsent(pregunta.grupoId, () => [])
            .add(pregunta);
      }
    }

    // Ordenar múltiples dentro de cada sección por 'orden'
    for (final lista in multiplesPorSeccion.values) {
      lista.sort((a, b) => a.orden.compareTo(b.orden));
    }

    // 2. Construir lista final: cuando encontramos la primera múltiple de una sección,
    // agregamos todas las múltiples de esa sección agrupadas
    final List<List<PreguntaDTO>> grupos = [];
    final Set<String> seccionesMultiplesProcesadas = {};

    for (final pregunta in preguntas) {
      final esMultiple = pregunta.tipo.toLowerCase().trim() == 'multiple';

      if (esMultiple) {
        // Primera vez que encontramos una múltiple de esta sección
        if (!seccionesMultiplesProcesadas.contains(pregunta.grupoId)) {
          grupos.add(multiplesPorSeccion[pregunta.grupoId]!);
          seccionesMultiplesProcesadas.add(pregunta.grupoId);
        }
        // Si ya procesamos esta sección, saltamos esta pregunta (ya está en el grupo)
      } else {
        // Pregunta no múltiple: agregar individualmente
        grupos.add([pregunta]);
      }
    }

    return grupos;
  }
}

