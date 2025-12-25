import 'package:cloud_firestore/cloud_firestore.dart';

/// DTO para representar la información de una sección/grupo
class SeccionDTO {
  final String id; // ID del documento en Firestore
  final String titulo;
  final String descripcion;
  final int orden;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SeccionDTO({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.orden,
    this.createdAt,
    this.updatedAt,
  });

  /// Convierte fecha desde formato {_seconds, _nanoseconds}
  static DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    
    if (dateValue is Timestamp) {
      return dateValue.toDate();
    }
    
    if (dateValue is Map<String, dynamic>) {
      final seconds = dateValue['_seconds'] as int?;
      if (seconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    }
    
    return null;
  }

  factory SeccionDTO.fromMap(String id, Map<String, dynamic> map) {
    return SeccionDTO(
      id: id,
      titulo: map['titulo'] as String? ?? '',
      descripcion: map['descripcion'] as String? ?? '',
      orden: map['orden'] != null ? (map['orden'] as num).toInt() : 0,
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }
}

