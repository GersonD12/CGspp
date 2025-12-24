import 'package:calet/features/chats/infrastructure/data/bajar_conversacion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' show log;

class BajarConversacionRepository {
  /// Obtiene todos los mensajes de un chat específico (idChat)
  /// Retorna una lista ordenada cronológicamente
  Future<List<BajarConversacion>> bajarMensajes(String idChat) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(idChat)
          .get();

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return [];
      }

      final data = docSnapshot.data()!;
      final List<BajarConversacion> mensajes = [];

      // Iterar por cada entrada del mapa (cada llave es un timestamp de mensaje)
      data.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          mensajes.add(BajarConversacion.fromFirestore(key, value));
        }
      });

      // Ordenar por fecha de creación (createdAt)
      mensajes.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return mensajes;
    } catch (e) {
      log('Error al bajar mensajes del chat $idChat: $e');
      return [];
    }
  }

  /// Permite escuchar cambios en tiempo real del chat
  Stream<List<BajarConversacion>> escucharMensajes(String idChat) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(idChat)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) return [];

          final data = snapshot.data()!;
          final List<BajarConversacion> mensajes = [];

          data.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              mensajes.add(BajarConversacion.fromFirestore(key, value));
            }
          });

          mensajes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return mensajes;
        });
  }
}
