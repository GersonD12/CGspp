import 'package:cloud_firestore/cloud_firestore.dart';

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
  final DateTime createdAt;
  final DateTime updatedAt;

  const RespuestaDTO({
    required this.preguntaId,
    required this.tipoPregunta,
    required this.descripcionPregunta,
    this.respuestaTexto,
    this.respuestaImagen,
    this.respuestaOpciones,
    required this.createdAt,
    required this.updatedAt,
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
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Crear desde Map
  factory RespuestaDTO.fromMap(Map<String, dynamic> map) {
    DateTime createdAt;
    DateTime updatedAt;
    
    // Leer createdAt
    final createdAtValue = map['createdAt'];
    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is int || createdAtValue is num) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(
        (createdAtValue as num).toInt()
      );
    } else {
      createdAt = DateTime.now();
    }

    // Leer updatedAt
    final updatedAtValue = map['updatedAt'];
    if (updatedAtValue is Timestamp) {
      updatedAt = updatedAtValue.toDate();
    } else if (updatedAtValue is int || updatedAtValue is num) {
      updatedAt = DateTime.fromMillisecondsSinceEpoch(
        (updatedAtValue as num).toInt()
      );
    } else {
      updatedAt = DateTime.now();
    }

    return RespuestaDTO(
      preguntaId: map['preguntaId'] as String,
      tipoPregunta: map['tipoPregunta'] as String,
      descripcionPregunta: map['descripcionPregunta'] as String,
      respuestaTexto: map['respuestaTexto'] as String?,
      respuestaImagen: map['respuestaImagen'] as String?,
      respuestaOpciones: map['respuestaOpciones'] != null
          ? List<String>.from(map['respuestaOpciones'] as List<dynamic>)
          : null,
      createdAt: createdAt,
      updatedAt: updatedAt,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RespuestaDTO(
      preguntaId: preguntaId ?? this.preguntaId,
      tipoPregunta: tipoPregunta ?? this.tipoPregunta,
      descripcionPregunta: descripcionPregunta ?? this.descripcionPregunta,
      respuestaTexto: respuestaTexto ?? this.respuestaTexto,
      respuestaImagen: respuestaImagen ?? this.respuestaImagen,
      respuestaOpciones: respuestaOpciones ?? this.respuestaOpciones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

