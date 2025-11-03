import 'dart:io';
import 'package:calet/features/formulario/presentation/providers/respuestas_state.dart';
import 'package:calet/features/formulario/domain/repositories/respuestas_repository.dart';
import 'package:calet/features/formulario/application/dto/respuesta_dto.dart';
import 'package:calet/core/infrastructure/storage_service.dart';
import 'dart:developer' show log;

/// Use case para finalizar el formulario
class FinalizarFormularioUseCase {
  final RespuestasRepository _repository;
  final StorageService _storageService;

  FinalizarFormularioUseCase({
    required RespuestasRepository repository,
    StorageService? storageService,
  })  : _repository = repository,
        _storageService = storageService ?? StorageService();

  /// Ejecuta la finalización del formulario
  Future<void> execute({
    required String userId,
    required RespuestasState respuestasState,
  }) async {
    log('Finalizando formulario...');
    log('Total respuestas: ${respuestasState.totalRespuestas}');

    if (respuestasState.totalRespuestas > 0) {
      // Primero subir todas las imágenes locales a Firebase Storage
      final respuestasStateConImagenesSubidas =
          await _subirImagenesLocales(respuestasState);

      // Luego subir respuestas a Firestore
      await _repository.uploadRespuestas(
        userId,
        respuestasStateConImagenesSubidas,
      );
      log('Respuestas subidas exitosamente');
    } else {
      log('No hay respuestas para subir');
    }
  }

  /// Sube todas las imágenes locales a Firebase Storage y actualiza las URLs
  Future<RespuestasState> _subirImagenesLocales(
    RespuestasState respuestasState,
  ) async {
    final nuevasRespuestas = <String, RespuestaDTO>{};

    for (final respuesta in respuestasState.todasLasRespuestas) {
      String? imagenUrl = respuesta.respuestaImagen;

      // Si la imagen es una ruta local (no URL), subirla
      if (imagenUrl != null &&
          !imagenUrl.startsWith('http://') &&
          !imagenUrl.startsWith('https://')) {
        try {
          log('Subiendo imagen local: $imagenUrl');
          final archivo = File(imagenUrl);
          if (await archivo.exists()) {
            imagenUrl = await _storageService.uploadFile(archivo);
            log('Imagen subida exitosamente: $imagenUrl');
          } else {
            log('Archivo no existe: $imagenUrl');
            imagenUrl = null;
          }
        } catch (e) {
          log('Error al subir imagen $imagenUrl: $e');
          imagenUrl = null;
        }
      }

      // Actualizar la respuesta con la nueva URL (o mantener la que ya era URL)
      nuevasRespuestas[respuesta.preguntaId] = respuesta.copyWith(
        respuestaImagen: imagenUrl,
      );
    }

    return respuestasState.copyWith(respuestas: nuevasRespuestas);
  }
}
