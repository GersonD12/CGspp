/// Interfaz del repositorio para operaciones con preguntas
/// Define el contrato sin depender de implementaciones específicas (Firebase, API, etc.)
/// 
/// Retorna un Map genérico que será convertido a DTOs en la capa Application
abstract class PreguntasRepository {
  /// Obtiene todas las preguntas activas agrupadas por sección
  /// Retorna un mapa genérico con las preguntas y las secciones en formato raw
  Future<Map<String, dynamic>> obtenerPreguntas();
}

