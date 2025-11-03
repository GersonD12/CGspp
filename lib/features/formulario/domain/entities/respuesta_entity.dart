/// Entidad de Respuesta del dominio de formulario
/// 
/// Esta entidad es independiente de la fuente de datos (Firestore, API, etc.)
/// Define la estructura y comportamiento de las respuestas en el negocio
class RespuestaEntity {
  final String preguntaId;
  final String tipoPregunta;
  final String descripcionPregunta;
  final String? respuestaTexto;
  final String? respuestaImagen;
  final List<String>? respuestaOpciones;
  final DateTime fechaRespuesta;

  const RespuestaEntity({
    required this.preguntaId,
    required this.tipoPregunta,
    required this.descripcionPregunta,
    this.respuestaTexto,
    this.respuestaImagen,
    this.respuestaOpciones,
    required this.fechaRespuesta,
  });

  /// Crea una copia de la entidad con cambios
  RespuestaEntity copyWith({
    String? preguntaId,
    String? tipoPregunta,
    String? descripcionPregunta,
    String? respuestaTexto,
    String? respuestaImagen,
    List<String>? respuestaOpciones,
    DateTime? fechaRespuesta,
  }) {
    return RespuestaEntity(
      preguntaId: preguntaId ?? this.preguntaId,
      tipoPregunta: tipoPregunta ?? this.tipoPregunta,
      descripcionPregunta: descripcionPregunta ?? this.descripcionPregunta,
      respuestaTexto: respuestaTexto ?? this.respuestaTexto,
      respuestaImagen: respuestaImagen ?? this.respuestaImagen,
      respuestaOpciones: respuestaOpciones ?? this.respuestaOpciones,
      fechaRespuesta: fechaRespuesta ?? this.fechaRespuesta,
    );
  }

  /// Verifica si la respuesta está completa
  bool get estaCompleta {
    if (tipoPregunta == 'texto') return respuestaTexto != null && respuestaTexto!.isNotEmpty;
    if (tipoPregunta == 'imagen') return respuestaImagen != null && respuestaImagen!.isNotEmpty;
    if (tipoPregunta == 'radio' || tipoPregunta == 'multiple') {
      return respuestaOpciones != null && respuestaOpciones!.isNotEmpty;
    }
    return false;
  }

  /// Obtiene el valor de la respuesta como string
  String get valorRespHata {
    if (respuestaTexto != null) return respuestaTexto!;
    if (respuestaImagen != null) return respuestaImagen!;
    if (respuestaOpciones != null && respuestaOpciones!.isNotEmpty) {
      return respuestaOpciones!.join(', ');
    }
    return '';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RespuestaEntity && 
           other.preguntaId == preguntaId &&
           other.fechaRespuesta == fechaRespuesta;
  }

  @override
  int get hashCode => preguntaId.hashCode ^ fechaRespuesta.hashCode;

  @override
  String toString() {
    return 'RespuestaEntity(preguntaId: $preguntaId, tipo: $tipoPregunta, completa: $estaCompleta)';
  }
}

