/// DTO (Data Transfer Object) para representar una respuesta
/// 
/// Este modelo se usa para la transferencia de datos entre las capas
/// data y presentation. No contiene lógica de negocio específica.
class RespuestaDTO {
  final String preguntaId;
  final String tipoPregunta;
  final String descripcionPregunta;
  final String? respuestaTexto;
  final String? respuestaImagen;
  final List<String>? respuestaOpciones;
  final DateTime fechaRespuesta;

  const RespuestaDTO({
    required this.preguntaId,
    required this.tipoPregunta,
    required this.descripcionPregunta,
    this.respuestaTexto,
    this.respuestaImagen,
    this.respuestaOpciones,
    required this.fechaRespuesta,
  });

  /// Convertir a Map para serialización
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

  /// Crear desde Map
  factory RespuestaDTO.fromMap(Map<String, dynamic> map) {
    return RespuestaDTO(
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

  /// Crear copia con cambios
  RespuestaDTO copyWith({
    String? preguntaId,
    String? tipoPregunta,
    String? descripcionPregunta,
    String? respuestaTexto,
    String? respuestaImagen,
    List<String>? respuestaOpciones,
    DateTime? fechaRespuesta,
  }) {
    return RespuestaDTO(
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

