class BajarListaChats {
  final String createdAt;
  final String estado;
  final String fromUsuario;
  final String toUsuario;
  final String mensaje;
  final String idChat;

  // Informacion del otro usuario (con quien se chatea)
  final String otherUserUid;
  final String otherUserDisplayName;
  final String otherUserProfileImage;

  BajarListaChats({
    required this.createdAt,
    required this.estado,
    required this.fromUsuario,
    required this.toUsuario,
    required this.mensaje,
    required this.idChat,
    required this.otherUserUid,
    required this.otherUserDisplayName,
    this.otherUserProfileImage = '',
  });

  factory BajarListaChats.fromFirestore({
    required Map<String, dynamic> json,
    required String idChat,
    required String currentUserUid,
    required String otherUserDisplayName,
    String otherUserProfileImage = '',
  }) {
    // El uid del otro usuario ya viene en el json o se pasa
    final String uidOtro =
        json['otherUserUid'] ??
        ((json['fromUsuario'] == currentUserUid)
            ? (json['toUsuario'] ?? '')
            : (json['fromUsuario'] ?? ''));

    return BajarListaChats(
      createdAt: json['createdAt'] ?? '',
      estado: json['estado'] ?? '',
      fromUsuario: json['fromUsuario'] ?? '',
      toUsuario: json['toUsuario'] ?? '',
      mensaje: json['mensaje'] ?? '',
      idChat: idChat,
      otherUserUid: uidOtro,
      otherUserDisplayName: otherUserDisplayName,
      otherUserProfileImage: otherUserProfileImage,
    );
  }
}
