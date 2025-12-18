class BajarSolicitudes {
  final String idUsuario;
  final String createdAt;
  final String mensaje;
  final String estado;
  final String fromUsuario;
  final String toUsuario;
  final String idChat;
  final String updateAt;

  final String idSolicitud; // ID of the request (the map key)

  BajarSolicitudes({
    required this.idSolicitud,
    required this.idUsuario,
    required this.createdAt,
    required this.mensaje,
    required this.estado,
    required this.fromUsuario,
    required this.toUsuario,
    required this.idChat,
    required this.updateAt,
  });

  factory BajarSolicitudes.fromFirestore(
    Map<String, dynamic> json,
    String idSolicitud,
  ) {
    return BajarSolicitudes(
      idSolicitud: idSolicitud,
      idUsuario: json['idUsuario'] ?? '',
      createdAt: json['createdAt'] ?? '',
      mensaje: json['mensaje'] ?? '',
      estado: json['estado'] ?? '',
      fromUsuario: json['fromUsuario'] ?? '',
      toUsuario: json['toUsuario'] ?? '',
      idChat: json['idChat'] ?? '',
      updateAt: json['updateAt'] ?? '',
    );
  }
}
