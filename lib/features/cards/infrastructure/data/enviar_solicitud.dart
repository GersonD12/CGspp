import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> enviarSolicitud({
  required String idUsuario,
  required String createdAt,
  required String mensaje,
  required String estado,
  required String formUsuario,
  required String toUsuario,
  required String idChat,
  required String updateAt,
}) async {
  // Obtener instancia de firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Generar un ID aleatorio para esta solicitud (el mismo para ambos usuarios)
  String idAleatorio = firestore.collection('solicitudes').doc().id;

  // Crear el mapa con los datos de la solicitud
  Map<String, dynamic> solicitud = {
    'createdAt': createdAt,
    'mensaje': mensaje,
    'estado': estado,
    'formUsuario': formUsuario,
    'toUsuario': toUsuario,
    'idChat': idChat,
    'updateAt': updateAt,
  };

  try {
    // Guardar la solicitud en el documento del usuario que envía (formUsuario)
    DocumentReference senderDoc = firestore
        .collection('solicitudes')
        .doc(formUsuario);

    await senderDoc.set({idAleatorio: solicitud}, SetOptions(merge: true));

    // Guardar la misma solicitud en el documento del usuario que recibe (toUsuario)
    DocumentReference recipientDoc = firestore
        .collection('solicitudes')
        .doc(toUsuario);

    await recipientDoc.set({idAleatorio: solicitud}, SetOptions(merge: true));
  } on FirebaseException catch (e) {
    print('Error al enviar la solicitud: $e');
    throw Exception('Error al enviar la solicitud');
  }
}
