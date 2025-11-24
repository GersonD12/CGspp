import 'package:cloud_firestore/cloud_firestore.dart';

/// DTO (Data Transfer Object) para representar una respuesta
/// 
/// Este modelo se usa para la transferencia de datos entre las capas
/// data y presentation. No contiene lógica de negocio específica.
class RespuestaDTO {
  final String preguntaId;
  final String grupoId; // ID del grupo/sección al que pertenece la pregunta
  final String tipoPregunta;
  final String descripcionPregunta;
  final String? respuestaTexto;
  final List<String>? respuestaImagenes; // Array de imágenes (puede tener 1 o más elementos)
  final List<String>? respuestaOpciones;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RespuestaDTO({
    required this.preguntaId,
    required this.grupoId,
    required this.tipoPregunta,
    required this.descripcionPregunta,
    this.respuestaTexto,
    this.respuestaImagenes,
    this.respuestaOpciones,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertir a Map para serialización
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'preguntaId': preguntaId,
      'grupoId': grupoId,
      'tipoPregunta': tipoPregunta,
      'descripcionPregunta': descripcionPregunta,
      'respuestaTexto': respuestaTexto,
      'respuestaOpciones': respuestaOpciones,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
    
    // Guardar imágenes en respuestaImagenes (array)
    if (respuestaImagenes != null && respuestaImagenes!.isNotEmpty) {
      map['respuestaImagenes'] = respuestaImagenes;
    }
    
    return map;
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

    // Manejar compatibilidad: si hay respuestaImagenes, usarla; si no, usar respuestaImagen (formato antiguo)
    List<String>? imagenes;
    
    if (map['respuestaImagenes'] != null) {
      imagenes = List<String>.from(map['respuestaImagenes'] as List<dynamic>);
    } else if (map['respuestaImagen'] != null) {
      // Compatibilidad con formato antiguo: convertir imagen única a lista
      final imagenUnica = map['respuestaImagen'] as String?;
      if (imagenUnica != null && imagenUnica.isNotEmpty) {
        imagenes = [imagenUnica];
      }
    }
    
    return RespuestaDTO(
      preguntaId: map['preguntaId'] as String,
      grupoId: map['grupoId'] as String? ?? '', // Compatibilidad con datos antiguos
      tipoPregunta: map['tipoPregunta'] as String,
      descripcionPregunta: map['descripcionPregunta'] as String,
      respuestaTexto: map['respuestaTexto'] as String?,
      respuestaImagenes: imagenes, // Array de imágenes
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
    String? grupoId,
    String? tipoPregunta,
    String? descripcionPregunta,
    String? respuestaTexto,
    List<String>? respuestaImagenes,
    List<String>? respuestaOpciones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RespuestaDTO(
      preguntaId: preguntaId ?? this.preguntaId,
      grupoId: grupoId ?? this.grupoId,
      tipoPregunta: tipoPregunta ?? this.tipoPregunta,
      descripcionPregunta: descripcionPregunta ?? this.descripcionPregunta,
      respuestaTexto: respuestaTexto ?? this.respuestaTexto,
      respuestaImagenes: respuestaImagenes ?? this.respuestaImagenes,
      respuestaOpciones: respuestaOpciones ?? this.respuestaOpciones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

