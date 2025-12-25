import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';

/// Servicio para manejar operaciones de almacenamiento
/// Abstrae el acceso a Firebase Storage usando patrón Singleton
class StorageService {
  final FirebaseStorage _storage;
  final Random _random = Random();

  // Constructor privado para Singleton
  StorageService._internal(this._storage);

  // Instancia única
  static final StorageService _instance = 
      StorageService._internal(FirebaseStorage.instance);

  // Factory para obtener la instancia
  factory StorageService() => _instance;

  /// Sube un archivo a Firebase Storage
  /// 
  /// [imageFile] El archivo a subir
  /// [path] Ruta opcional dentro de "images/", por defecto genera un nombre único
  /// 
  /// Retorna la URL de descarga del archivo subido
  Future<String?> uploadFile(File imageFile, {String? path}) async {
    try {
      String storagePath;
      
      if (path != null) {
        // Si se proporciona un path personalizado, usarlo
        storagePath = path;
      } else {
        // Generar un nombre único basado en timestamp y número aleatorio
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final randomSuffix = _random.nextInt(1000000);
        final extension = imageFile.path.split('.').last;
        storagePath = 'images/$timestamp$randomSuffix.$extension';
      }
      
      final ref = _storage.ref().child(storagePath);
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();
      
      return url;
    } catch (e) {
      return null;
    }
  }

  /// Elimina un archivo de Firebase Storage
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      // Manejo de error silencioso
    }
  }

  /// Obtiene la URL de descarga de un archivo
  Future<String?> getDownloadURL(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}

