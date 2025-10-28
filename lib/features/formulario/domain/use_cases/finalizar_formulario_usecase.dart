import 'package:calet/features/formulario/presentation/providers/respuestas_state.dart';
import 'package:calet/features/formulario/domain/repositories/respuestas_repository.dart';
import 'dart:developer' show log;

/// Use case para finalizar el formulario
class FinalizarFormularioUseCase {
  final RespuestasRepository _repository;

  FinalizarFormularioUseCase({required RespuestasRepository repository})
      : _repository = repository;

  /// Ejecuta la finalización del formulario
  Future<void> execute({
    required String userId,
    required RespuestasState respuestasState,
  }) async {
    log('Finalizando formulario...');
    log('Total respuestas: ${respuestasState.totalRespuestas}');

    if (respuestasState.totalRespuestas > 0) {
      // Subir respuestas a Firestore
      await _repository.uploadRespuestas(userId, respuestasState);
      log('Respuestas subidas exitosamente');
    } else {
      log('No hay respuestas para subir');
    }
  }
}

