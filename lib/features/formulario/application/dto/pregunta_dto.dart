import 'package:cloud_firestore/cloud_firestore.dart';

class PreguntaDTO {
  final String id; // ID del documento en Firestore
  final String grupoId; // ID del grupo/sección al que pertenece
  final DateTime createdAt;
  final String descripcion;
  final String tipo;
  final List<String> opciones;
  final String encabezado;
  final bool allowCustomOption;
  final String customOptionLabel;

  PreguntaDTO({
    required this.id,
    required this.grupoId,
    required this.createdAt,
    required this.descripcion,
    required this.tipo,
    required this.opciones,
    required this.encabezado,
    required this.allowCustomOption,
    required this.customOptionLabel,
  });

  factory PreguntaDTO.fromMap(String id, String grupoId, Map<String, dynamic> map) {
    return PreguntaDTO(
      id: id,
      grupoId: grupoId,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      descripcion: map['descripcion'] as String? ?? '',
      tipo: map['tipo'] as String? ?? 'texto',
      opciones: map['opciones'] != null
          ? List<String>.from(map['opciones'] as List<dynamic>)
          : <String>[],
      allowCustomOption: map['allowCustomOption'] as bool? ?? false,
      customOptionLabel: map['customOptionLabel'] as String? ?? 'Otro',
      encabezado: map['encabezado'] as String? ?? '',
    );
  }
}

