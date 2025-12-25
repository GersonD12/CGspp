import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> enviarSolicitud({
  required String idUsuario,
  required String createdAt,
  required String mensaje,
  required String estado,
  required String fromUsuario,
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
    'idUsuario': idUsuario,
    'createdAt': createdAt,
    'mensaje': mensaje,
    'estado': estado,
    'fromUsuario': fromUsuario,
    'toUsuario': toUsuario,
    'idChat': idChat,
    'updateAt': updateAt,
  };

  try {
    // Guardar la solicitud en el documento del usuario que envía (fromUsuario)
    DocumentReference senderDoc = firestore
        .collection('solicitudes')
        .doc(fromUsuario);

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

Future<void> actualizarEstadoSolicitud({
  required String idSolicitud,
  required String estado,
  required String fromUsuario, // The user who sent the ORIGINAL request
  required String toUsuario, // The user who received the ORIGINAL request
}) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final now = DateTime.now().toIso8601String();

  try {
    // Update in sender's document
    await firestore.collection('solicitudes').doc(fromUsuario).update({
      '$idSolicitud.estado': estado,
      '$idSolicitud.updateAt': now,
    });

    // Update in recipient's document
    await firestore.collection('solicitudes').doc(toUsuario).update({
      '$idSolicitud.estado': estado,
      '$idSolicitud.updateAt': now,
    });
  } on FirebaseException catch (e) {
    print('Error al actualizar estado: $e');
    throw Exception('Error al actualizar estado');
  }
}
