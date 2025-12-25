import 'package:calet/features/formulario/domain/repositories/preguntas_repository.dart';
import 'package:calet/features/formulario/application/dto/dto.dart';

/// Use case para obtener todas las preguntas activas
class ObtenerPreguntasUseCase {
  final PreguntasRepository _repository;

  ObtenerPreguntasUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener preguntas
  /// Retorna un mapa con 'preguntas' (List<PreguntaDTO>) y 'secciones' (Map<String, SeccionDTO>)
  Future<Map<String, dynamic>> execute() async {
    final resultado = await _repository.obtenerPreguntas();
    
    // Ordenar secciones por el campo orden
    final secciones = resultado['secciones'] as Map<String, SeccionDTO>;
    final seccionesOrdenadas = secciones.values.toList()
      ..sort((a, b) => a.orden.compareTo(b.orden));
    
    // Ordenar preguntas según el orden de las secciones y luego por orden dentro de cada sección
    final todasLasPreguntas = resultado['preguntas'] as List<PreguntaDTO>;
    final ordenSecciones = seccionesOrdenadas.map((s) => s.id).toList();
    
    final preguntasOrdenadas = <PreguntaDTO>[];
    for (final grupoId in ordenSecciones) {
      final preguntasDelGrupo = todasLasPreguntas
          .where((p) => p.grupoId == grupoId)
          .toList()
        ..sort((a, b) => a.orden.compareTo(b.orden));
      preguntasOrdenadas.addAll(preguntasDelGrupo);
    }

    // Agrupar preguntas por grupoId
    final preguntasPorGrupo = <String, List<PreguntaDTO>>{};
    for (final pregunta in preguntasOrdenadas) {
      if (!preguntasPorGrupo.containsKey(pregunta.grupoId)) {
        preguntasPorGrupo[pregunta.grupoId] = [];
      }
      preguntasPorGrupo[pregunta.grupoId]!.add(pregunta);
    }

    return {
      'preguntas': preguntasOrdenadas,
      'secciones': secciones,
      'ordenSecciones': ordenSecciones,
      'preguntasPorGrupo': preguntasPorGrupo,
    };
  }
}

