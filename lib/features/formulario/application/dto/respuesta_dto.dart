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
/// 
/// IMPORTANTE: Ahora usa idpregunta como clave principal para matching eficiente.
/// Las respuestas solo almacenan idpregunta y valores (values) de opciones seleccionadas.
class RespuestaDTO {
  final String idpregunta; // ID único de la pregunta (clave principal para matching)
  final String? preguntaId; // ID del documento Firestore (compatibilidad hacia atrás)
  final String grupoId; // ID del grupo/sección al que pertenece la pregunta
  final String? tipoPregunta; // Ya no necesario, se obtiene de la pregunta cacheada
  final String? descripcionPregunta; // Ya no necesario, se obtiene de la pregunta cacheada
  final String? encabezadoPregunta; // Ya no necesario, se obtiene de la pregunta cacheada
  final String? emojiPregunta; // Ya no necesario, se obtiene de la pregunta cacheada
  final String? respuestaTexto;
  final List<String>? respuestaImagenes; // Array de imágenes (puede tener 1 o más elementos)
  final List<String>? respuestaOpciones; // Valores (values) de opciones seleccionadas para búsquedas eficientes
  final List<OpcionSeleccionadaDTO>? respuestaOpcionesCompletas; // Deprecated: ya no se guarda, solo values
  final DateTime createdAt;
  final DateTime updatedAt;

  const RespuestaDTO({
    required this.idpregunta,
    this.preguntaId,
    required this.grupoId,
    this.tipoPregunta,
    this.descripcionPregunta,
    this.encabezadoPregunta,
    this.emojiPregunta,
    this.respuestaTexto,
    this.respuestaImagenes,
    this.respuestaOpciones,
    this.respuestaOpcionesCompletas,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertir a Map para serialización
  /// NUEVO FORMATO: Solo guarda idpregunta y valores (values) de opciones seleccionadas
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'idpregunta': idpregunta, // Clave principal para matching
      'grupoId': grupoId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
    
    // Guardar preguntaId solo para compatibilidad hacia atrás
    if (preguntaId != null) {
      map['preguntaId'] = preguntaId;
    }
    
    // Guardar respuesta de texto
    if (respuestaTexto != null && respuestaTexto!.isNotEmpty) {
      map['respuestaTexto'] = respuestaTexto;
    }
    
    // Guardar imágenes en respuestaImagenes (array)
    if (respuestaImagenes != null && respuestaImagenes!.isNotEmpty) {
      map['respuestaImagenes'] = respuestaImagenes;
    }
    
    // Guardar solo los valores (values) de las opciones seleccionadas para búsquedas eficientes
    if (respuestaOpciones != null && respuestaOpciones!.isNotEmpty) {
      map['respuestaOpciones'] = respuestaOpciones; // Solo valores, no texto ni emoji
    } else if (respuestaOpcionesCompletas != null && respuestaOpcionesCompletas!.isNotEmpty) {
      // Extraer solo los valores de respuestaOpcionesCompletas
      map['respuestaOpciones'] = respuestaOpcionesCompletas!
          .map((opcion) => opcion.value)
          .toList();
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
    
    // Leer idpregunta (nuevo formato) o preguntaId (formato antiguo)
    final idpreguntaValue = map['idpregunta'] as String? ?? map['preguntaId'] as String?;
    if (idpreguntaValue == null) {
      throw Exception('RespuestaDTO.fromMap: Se requiere idpregunta o preguntaId');
    }
    
    return RespuestaDTO(
      idpregunta: idpreguntaValue,
      preguntaId: map['preguntaId'] as String?, // Compatibilidad hacia atrás
      grupoId: map['grupoId'] as String? ?? '', // Compatibilidad con datos antiguos
      tipoPregunta: map['tipoPregunta'] as String?, // Ya no necesario en nuevo formato
      descripcionPregunta: map['descripcionPregunta'] as String?, // Ya no necesario en nuevo formato
      encabezadoPregunta: map['encabezadoPregunta'] as String?, // Ya no necesario en nuevo formato
      emojiPregunta: map['emojiPregunta'] as String?, // Ya no necesario en nuevo formato
      respuestaTexto: map['respuestaTexto'] as String?,
      respuestaImagenes: imagenes, // Array de imágenes
      // Leer respuestaOpcionesCompletas (formato antiguo) o respuestaOpciones (nuevo formato con solo values)
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
    String? idpregunta,
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
      idpregunta: idpregunta ?? this.idpregunta,
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

