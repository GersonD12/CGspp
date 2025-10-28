import 'package:calet/features/formulario/presentation/providers/respuestas_state.dart';

/// Interfaz del repositorio para operaciones con respuestas
/// Define el contrato sin depender de implementaciones específicas (Firebase, API, etc.)
abstract class RespuestasRepository {
  /// Sube las respuestas del formulario
  Future<void> uploadRespuestas(
    String userId,
    RespuestasState respuestasState,
  );
}

