import 'package:cloud_firestore/cloud_firestore.dart';

/// DTO para representar una opción seleccionada en una respuesta
class OpcionSeleccionadaDTO {
  final String text;
  final String value;
  final String emoji;

  OpcionSeleccionadaDTO({
    required this.text,
    required this.value,
    this.emoji = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'value': value,
      if (emoji.isNotEmpty) 'emoji': emoji,
    };
  }

  factory OpcionSeleccionadaDTO.fromMap(Map<String, dynamic> map) {
    return OpcionSeleccionadaDTO(
      text: map['text'] as String? ?? '',
      value: map['value'] as String? ?? map['text'] as String? ?? '',
      emoji: map['emoji'] as String? ?? '',
    );
  }

  /// Convierte desde un String simple (compatibilidad hacia atrás)
  factory OpcionSeleccionadaDTO.fromString(String valor, {String text = '', String emoji = ''}) {
    return OpcionSeleccionadaDTO(
      text: text.isNotEmpty ? text : valor,
      value: valor,
      emoji: emoji,
    );
  }
}

/// DTO (Data Transfer Object) para representar una respuesta
/// 
/// Este modelo se usa para la transferencia de datos entre las capas
/// data y presentation. No contiene lógica de negocio específica.
class RespuestaDTO {
  final String preguntaId;
  final String grupoId; // ID del grupo/sección al que pertenece la pregunta
  final String tipoPregunta;
  final String descripcionPregunta;
  final String encabezadoPregunta; // Encabezado de la pregunta (para mostrar en perfil)
  final String? emojiPregunta; // Emoji de la pregunta (para mostrar en perfil)
  final String? respuestaTexto;
  final List<String>? respuestaImagenes; // Array de imágenes (puede tener 1 o más elementos)
  final List<String>? respuestaOpciones; // Compatibilidad: valores simples (deprecated)
  final List<OpcionSeleccionadaDTO>? respuestaOpcionesCompletas; // Nuevo: opciones con emoji y text
  final DateTime createdAt;
  final DateTime updatedAt;

  const RespuestaDTO({
    required this.preguntaId,
    required this.grupoId,
    required this.tipoPregunta,
    required this.descripcionPregunta,
    required this.encabezadoPregunta,
    this.emojiPregunta,
    this.respuestaTexto,
    this.respuestaImagenes,
    this.respuestaOpciones,
    this.respuestaOpcionesCompletas,
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
      'encabezadoPregunta': encabezadoPregunta,
      'respuestaTexto': respuestaTexto,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
    
    // Guardar emoji si está disponible
    if (emojiPregunta != null && emojiPregunta!.isNotEmpty) {
      map['emojiPregunta'] = emojiPregunta;
    }
    
    // Guardar imágenes en respuestaImagenes (array)
    if (respuestaImagenes != null && respuestaImagenes!.isNotEmpty) {
      map['respuestaImagenes'] = respuestaImagenes;
    }
    
    // Priorizar respuestaOpcionesCompletas sobre respuestaOpciones (formato antiguo)
    if (respuestaOpcionesCompletas != null && respuestaOpcionesCompletas!.isNotEmpty) {
      map['respuestaOpcionesCompletas'] = respuestaOpcionesCompletas!
          .map((opcion) => opcion.toMap())
          .toList();
      // También guardar valores simples para compatibilidad
      map['respuestaOpciones'] = respuestaOpcionesCompletas!
          .map((opcion) => opcion.value)
          .toList();
    } else if (respuestaOpciones != null && respuestaOpciones!.isNotEmpty) {
      // Compatibilidad con formato antiguo
      map['respuestaOpciones'] = respuestaOpciones;
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
      encabezadoPregunta: map['encabezadoPregunta'] as String? ?? 
                         map['descripcionPregunta'] as String, // Compatibilidad: usar descripcion si no hay encabezado
      emojiPregunta: map['emojiPregunta'] as String?,
      respuestaTexto: map['respuestaTexto'] as String?,
      respuestaImagenes: imagenes, // Array de imágenes
      // Leer respuestaOpcionesCompletas (nuevo formato) o respuestaOpciones (formato antiguo)
      respuestaOpcionesCompletas: map['respuestaOpcionesCompletas'] != null
          ? (map['respuestaOpcionesCompletas'] as List<dynamic>)
              .map((opcion) => OpcionSeleccionadaDTO.fromMap(opcion as Map<String, dynamic>))
              .toList()
          : null,
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
    String? encabezadoPregunta,
    String? emojiPregunta,
    String? respuestaTexto,
    List<String>? respuestaImagenes,
    List<String>? respuestaOpciones,
    List<OpcionSeleccionadaDTO>? respuestaOpcionesCompletas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RespuestaDTO(
      preguntaId: preguntaId ?? this.preguntaId,
      grupoId: grupoId ?? this.grupoId,
      tipoPregunta: tipoPregunta ?? this.tipoPregunta,
      descripcionPregunta: descripcionPregunta ?? this.descripcionPregunta,
      encabezadoPregunta: encabezadoPregunta ?? this.encabezadoPregunta,
      emojiPregunta: emojiPregunta ?? this.emojiPregunta,
      respuestaTexto: respuestaTexto ?? this.respuestaTexto,
      respuestaImagenes: respuestaImagenes ?? this.respuestaImagenes,
      respuestaOpciones: respuestaOpciones ?? this.respuestaOpciones,
      respuestaOpcionesCompletas: respuestaOpcionesCompletas ?? this.respuestaOpcionesCompletas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Obtiene las opciones seleccionadas como lista de strings (compatibilidad)
  List<String> get opcionesSeleccionadasValues {
    if (respuestaOpcionesCompletas != null && respuestaOpcionesCompletas!.isNotEmpty) {
      return respuestaOpcionesCompletas!.map((op) => op.value).toList();
    }
    return respuestaOpciones ?? [];
  }
}

