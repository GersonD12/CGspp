import 'package:cloud_firestore/cloud_firestore.dart';
import 'questiond_dto.dart'; // Importa tu DTO

Future<PreguntaDTO> getPregunta() async {
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('questions')
        .doc('4ZOmpfB98ISOgwe46lXj')
        .get();

    if (doc.exists) {
      // Separa los campos al crear una instancia del DTO
      return PreguntaDTO.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      throw Exception("El documento no existe.");
    }
  } catch (e) {
    throw Exception("Error al obtener la pregunta: $e");
  }
}
