import 'dart:io';
import 'dart:developer' show log;
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage storage = FirebaseStorage.instance;

Future<String?> uploadImage(File imageFile) async {
  log('Iniciando subida de imagen: ${imageFile.path}');
  final String namefile = imageFile.path.split('/').last;

  Reference ref = storage.ref().child("images").child(namefile);
  final UploadTask uploadTask = ref.putFile(imageFile);
  log(uploadTask.toString());
  final TaskSnapshot snapshot =
      await uploadTask; // Espera directamente a que la tarea finalice
  log(snapshot.toString());
  final String url = await snapshot.ref.getDownloadURL();
  log('Imagen subida con éxito. URL: $url');

  return url; // Devuelve la URL de descarga
}
