class BajarConversacion {
  final String id;
  final String createdAt;
  final String estado;
  final String fromUsuario;
  final String toUsuario;
  final String mensaje;

  BajarConversacion({
    required this.id,
    required this.createdAt,
    required this.estado,
    required this.fromUsuario,
    required this.toUsuario,
    required this.mensaje,
  });

  factory BajarConversacion.fromFirestore(
    String id,
    Map<String, dynamic> json,
  ) {
    return BajarConversacion(
      id: id,
      createdAt: json['createdAt'] ?? '',
      estado: json['estado'] ?? '',
      fromUsuario: json['fromUsuario'] ?? '',
      toUsuario: json['toUsuario'] ?? '',
      mensaje: json['mensaje'] ?? '',
    );
  }

  /// Helper para saber si el mensaje lo envió un usuario específico
  bool esMio(String currentUserUid) => fromUsuario == currentUserUid;
}
