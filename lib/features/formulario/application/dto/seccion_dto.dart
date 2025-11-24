/// DTO para representar la información de una sección/grupo
class SeccionDTO {
  final String id; // ID del documento en Firestore
  final String titulo;
  final String descripcion;
  final int orden;

  SeccionDTO({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.orden,
  });

  factory SeccionDTO.fromMap(String id, Map<String, dynamic> map) {
    return SeccionDTO(
      id: id,
      titulo: map['titulo'] as String? ?? '',
      descripcion: map['descripcion'] as String? ?? '',
      orden: map['orden'] != null ? (map['orden'] as num).toInt() : 0,
    );
  }
}

