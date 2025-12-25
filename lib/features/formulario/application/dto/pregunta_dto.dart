import 'package:cloud_firestore/cloud_firestore.dart';

/// DTO para representar una opción de una pregunta
class OpcionDTO {
  final String text;
  final String value;
  final String emoji;
  final String icon;
  final String iconType;

  OpcionDTO({
    required this.text,
    required this.value,
    this.emoji = '',
    this.icon = '',
    this.iconType = 'material',
  });

  factory OpcionDTO.fromMap(Map<String, dynamic> map) {
    return OpcionDTO(
      text: map['text'] as String? ?? '',
      value: map['value'] as String? ?? map['text'] as String? ?? '',
      emoji: map['emoji'] as String? ?? '',
      icon: map['icon'] as String? ?? '',
      iconType: map['iconType'] as String? ?? 'material',
    );
  }

  /// Convierte una opción antigua (String) a OpcionDTO
  factory OpcionDTO.fromString(String opcion) {
    return OpcionDTO(
      text: opcion,
      value: opcion,
    );
  }
}

class PreguntaDTO {
  final String id; // ID del documento en Firestore
  final String idpregunta; // ID único de la pregunta para matching con respuestas
  final String grupoId; // ID del grupo/sección al que pertenece
  final DateTime createdAt;
  final DateTime updatedAt;
  final String descripcion;
  final String tipo;
  final List<OpcionDTO> opciones; // Cambiado a List<OpcionDTO>
  final String encabezado;
  final bool allowCustomOption;
  final String customOptionLabel;
  final int? maxNumber; // Límite superior para preguntas de tipo número
  final int? minNumber; // Límite inferior para preguntas de tipo número
  final int? cantidadImagenes; // Cantidad de imágenes permitidas para preguntas de tipo imagen
  final int orden; // Orden de la pregunta dentro de la sección
  final String emoji; // Emoji de la pregunta
  final String icon; // Icono de la pregunta
  final String iconType; // Tipo de icono (material, etc.)
  final bool estado; // Estado activo/inactivo de la pregunta
  final int? maxOpcionesSeleccionables; // Máximo de opciones seleccionables
  final DateTime? fechaInicial; // Fecha mínima permitida para preguntas de tipo fecha
  final DateTime? fechaFinal; // Fecha máxima permitida para preguntas de tipo fecha

  PreguntaDTO({
    required this.id,
    required this.idpregunta,
    required this.grupoId,
    required this.createdAt,
    required this.updatedAt,
    required this.descripcion,
    required this.tipo,
    required this.opciones,
    required this.encabezado,
    required this.allowCustomOption,
    required this.customOptionLabel,
    this.maxNumber,
    this.minNumber,
    this.cantidadImagenes,
    this.orden = 0,
    this.emoji = '',
    this.icon = '',
    this.iconType = 'material',
    this.estado = true,
    this.maxOpcionesSeleccionables,
    this.fechaInicial,
    this.fechaFinal,
  });

  /// Convierte fecha desde formato {_seconds, _nanoseconds}
  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    
    if (dateValue is Timestamp) {
      return dateValue.toDate();
    }
    
    if (dateValue is Map<String, dynamic>) {
      final seconds = dateValue['_seconds'] as int?;
      if (seconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    }
    
    return DateTime.now();
  }

  factory PreguntaDTO.fromMap(String id, String grupoId, Map<String, dynamic> map) {
    // Parsear opciones: pueden ser objetos o strings (compatibilidad hacia atrás)
    List<OpcionDTO> opcionesList = [];
    if (map['opciones'] != null) {
      final opcionesData = map['opciones'] as List<dynamic>;
      opcionesList = opcionesData.map((opcion) {
        if (opcion is Map<String, dynamic>) {
          return OpcionDTO.fromMap(opcion);
        } else if (opcion is String) {
          return OpcionDTO.fromString(opcion);
        }
        return OpcionDTO(text: opcion.toString(), value: opcion.toString());
      }).toList();
    }

    return PreguntaDTO(
      id: id,
      idpregunta: map['idpregunta'] as String? ?? id, // Usar idpregunta si existe, sino usar id como fallback
      grupoId: grupoId,
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
      descripcion: map['descripcion'] as String? ?? '',
      tipo: map['tipo'] as String? ?? 'texto',
      opciones: opcionesList,
      allowCustomOption: map['allowCustomOption'] as bool? ?? false,
      customOptionLabel: map['customOptionLabel'] as String? ?? 'Otro',
      encabezado: map['encabezado'] as String? ?? '',
      maxNumber: map['maxNumber'] != null ? (map['maxNumber'] as num).toInt() : null,
      minNumber: map['minNumber'] != null ? (map['minNumber'] as num).toInt() : null,
      cantidadImagenes: map['cantidad_imagenes'] != null ? (map['cantidad_imagenes'] as num).toInt() : null,
      orden: map['orden'] != null ? (map['orden'] as num).toInt() : 0,
      emoji: map['emoji'] as String? ?? '',
      icon: map['icon'] as String? ?? '',
      iconType: map['iconType'] as String? ?? 'material',
      estado: map['estado'] as bool? ?? true,
      maxOpcionesSeleccionables: map['maxOpcionesSeleccionables'] != null 
          ? (map['maxOpcionesSeleccionables'] as num).toInt() 
          : null,
      fechaInicial: map['fechaInicial'] != null ? _parseDate(map['fechaInicial']) : null,
      fechaFinal: map['fechaFinal'] != null ? _parseDate(map['fechaFinal']) : null,
    );
  }

  /// Obtiene las opciones como lista de strings (para compatibilidad)
  List<String> get opcionesStrings => opciones.map((o) => o.value).toList();
}

