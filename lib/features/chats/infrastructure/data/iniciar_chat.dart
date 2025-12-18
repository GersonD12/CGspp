import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> iniciarNuevoChat({
  required String idChat,
  required String fromUsuario,
  required String toUsuario,
  required String createdAt,
  required String mensaje,
  required String estado,
}) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Map<String, dynamic> datosMensaje = {
    'mensaje': mensaje,
    'createdAt': createdAt,
    'estado': estado,
    'fromUsuario': fromUsuario,
    'toUsuario': toUsuario,
  };

  try {
    // 1. Guardar en la colección de CHATS (Historia completa)
    await firestore.collection('chats').doc(idChat).set({
      createdAt: datosMensaje,
    }, SetOptions(merge: true));

    // 2. Sincronizar con la colección de lista_chats (Para la previsualización en la lista)
    // Actualizamos para ambos usuarios

    // Para el que envía: el otro es toUsuario
    await firestore.collection('lista_chats').doc(fromUsuario).set({
      idChat: {
        'mensaje': mensaje,
        'createdAt': createdAt,
        'otherUserUid': toUsuario,
        'fromUsuario': fromUsuario,
        'toUsuario': toUsuario,
        'estado': estado,
      },
    }, SetOptions(merge: true));

    // Para el que recibe: el otro es fromUsuario
    await firestore.collection('lista_chats').doc(toUsuario).set({
      idChat: {
        'mensaje': mensaje,
        'createdAt': createdAt,
        'otherUserUid': fromUsuario,
        'fromUsuario': fromUsuario,
        'toUsuario': toUsuario,
        'estado': estado,
      },
    }, SetOptions(merge: true));
  } on FirebaseException catch (e) {
    print('Error al enviar mensaje: $e');
    throw Exception('Error al enviar mensaje');
  }
}

Future<void> actualizarMensajesChat({
  required String idChat,
  required String createdAtKey, // El timestamp usado como llave
  required String nuevoEstado,
}) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final now = DateTime.now().toIso8601String();

  try {
    await firestore.collection('chats').doc(idChat).update({
      '$createdAtKey.estado': nuevoEstado,
      '$createdAtKey.updateAt': now,
    });
  } on FirebaseException catch (e) {
    print('Error al actualizar el mensaje: $e');
    throw Exception('Error al actualizar mensaje');
  }
}
