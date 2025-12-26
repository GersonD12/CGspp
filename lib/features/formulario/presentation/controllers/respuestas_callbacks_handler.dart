import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/formulario/presentation/controllers/respuestas_controller.dart';

/// Handler unificado para todos los callbacks de respuestas
class RespuestasCallbacksHandler {
  final RespuestasController controller;
  final List<PreguntaDTO> preguntas;

  RespuestasCallbacksHandler({
    required this.controller,
    required this.preguntas,
  });

  /// Busca una pregunta por su ID (puede ser id o idpregunta)
  PreguntaDTO _buscarPregunta(String preguntaId) {
    return preguntas.firstWhere(
      (p) => p.id == preguntaId,
      orElse: () => preguntas.firstWhere((p) => p.idpregunta == preguntaId),
    );
  }

  /// Callback para respuestas múltiples
  void onMultipleChanged(
    String preguntaId,
    String grupoId,
    String tipo,
    String descripcion,
    String encabezado,
    String? emoji,
    List<String> respuestas,
    Map<String, String>? opcionesConEmoji,
    Map<String, String>? opcionesConText,
  ) {
    final pregunta = _buscarPregunta(preguntaId);
    controller.guardarRespuestaUseCase.guardarRespuestaRadio(
      pregunta.idpregunta,
      grupoId,
      tipo,
      descripcion,
      encabezado,
      emoji,
      respuestas,
      opcionesConEmoji,
      opcionesConText,
      pregunta.id,
    );
  }

  /// Callback para respuestas de texto
  void onTextoChanged(
    String preguntaId,
    String grupoId,
    String tipo,
    String descripcion,
    String encabezado,
    String? emoji,
    String? texto,
  ) {
    final pregunta = _buscarPregunta(preguntaId);
    controller.guardarRespuestaUseCase.guardarRespuestaTexto(
      pregunta.idpregunta,
      grupoId,
      tipo,
      descripcion,
      encabezado,
      emoji,
      texto ?? '',
      pregunta.id,
    );
  }

  /// Callback para respuestas numéricas
  void onNumeroChanged(
    String preguntaId,
    String grupoId,
    String tipo,
    String descripcion,
    String encabezado,
    String? emoji,
    String? numero,
  ) {
    final pregunta = _buscarPregunta(preguntaId);
    controller.guardarRespuestaUseCase.guardarRespuestaNumero(
      pregunta.idpregunta,
      grupoId,
      tipo,
      descripcion,
      encabezado,
      emoji,
      numero ?? '',
      pregunta.id,
    );
  }

  /// Callback para respuestas con imágenes
  void onImagenChanged(
    String preguntaId,
    String grupoId,
    String tipo,
    String descripcion,
    String encabezado,
    String? emoji,
    List<String> imagenes,
  ) {
    final pregunta = _buscarPregunta(preguntaId);
    controller.guardarRespuestaUseCase.guardarRespuestaImagenes(
      pregunta.idpregunta,
      grupoId,
      tipo,
      descripcion,
      encabezado,
      emoji,
      imagenes,
      pregunta.id,
    );
  }

  /// Callback para respuestas de teléfono
  void onTelefonoChanged(
    String preguntaId,
    String grupoId,
    String tipo,
    String descripcion,
    String encabezado,
    String? emoji,
    String telefono,
  ) {
    final pregunta = _buscarPregunta(preguntaId);
    controller.guardarRespuestaUseCase.guardarRespuestaTelefono(
      pregunta.idpregunta,
      grupoId,
      tipo,
      descripcion,
      encabezado,
      emoji,
      telefono,
      pregunta.id,
    );
  }

  /// Callback para respuestas de país
  void onPaisChanged(
    String preguntaId,
    String grupoId,
    String tipo,
    String descripcion,
    String encabezado,
    String? emoji,
    String codigoPais,
  ) {
    final pregunta = _buscarPregunta(preguntaId);
    controller.guardarRespuestaUseCase.guardarRespuestaPais(
      pregunta.idpregunta,
      grupoId,
      tipo,
      descripcion,
      encabezado,
      emoji,
      codigoPais,
      pregunta.id,
    );
  }

  /// Callback para respuestas de fecha
  void onFechaChanged(
    String preguntaId,
    String grupoId,
    String tipo,
    String descripcion,
    String encabezado,
    String? emoji,
    String fecha,
  ) {
    final pregunta = _buscarPregunta(preguntaId);
    controller.guardarRespuestaUseCase.guardarRespuestaFecha(
      pregunta.idpregunta,
      grupoId,
      tipo,
      descripcion,
      encabezado,
      emoji,
      fecha,
      pregunta.id,
    );
  }
}

