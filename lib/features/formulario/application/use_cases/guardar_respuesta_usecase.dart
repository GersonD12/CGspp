import 'package:calet/features/formulario/presentation/providers/respuestas_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Use case para guardar una respuesta
class GuardarRespuestaUseCase {
  final WidgetRef ref;

  GuardarRespuestaUseCase(this.ref);

  /// Guardar respuesta para pregunta de radio/múltiple (una o múltiples opciones)
  /// NUEVO FORMATO: Usa idpregunta y solo guarda valores (values) de opciones seleccionadas
  void guardarRespuestaRadio(
    String idpregunta, // Cambiado de preguntaId a idpregunta
    String grupoId,
    String? tipoPregunta, // Ya no necesario, opcional
    String? descripcionPregunta, // Ya no necesario, opcional
    String encabezadoPregunta,
    String? emojiPregunta,
    List<String> valoresSeleccionados, // Solo valores (values) seleccionados
    Map<String, String>? opcionesConEmoji, // Deprecated: ya no se guarda
    Map<String, String>? opcionesConText, // Deprecated: ya no se guarda
    String? preguntaId, // Compatibilidad hacia atrás
  ) {
    final respuestasNotifier = ref.read(respuestasProvider.notifier);
    
    // En el nuevo formato solo guardamos los valores (values), no texto ni emoji
    // Esto permite búsquedas eficientes e internacionales
    respuestasNotifier.agregarRespuesta(
      idpregunta,
      grupoId,
      tipoPregunta,
      descripcionPregunta,
      encabezadoPregunta: encabezadoPregunta,
      emojiPregunta: emojiPregunta,
      respuestaOpciones: valoresSeleccionados.isNotEmpty ? valoresSeleccionados : null,
      respuestaOpcionesCompletas: null, // Ya no se guarda en nuevo formato
      preguntaId: preguntaId, // Compatibilidad hacia atrás
    );
  }

  /// Guardar respuesta de texto
  /// NUEVO FORMATO: Usa idpregunta como clave
  void guardarRespuestaTexto(
    String idpregunta, // Cambiado de preguntaId a idpregunta
    String grupoId,
    String? tipoPregunta, // Ya no necesario, opcional
    String? descripcionPregunta, // Ya no necesario, opcional
    String encabezadoPregunta,
    String? emojiPregunta,
    String texto,
    String? preguntaId, // Compatibilidad hacia atrás
  ) {
    final respuestasNotifier = ref.read(respuestasProvider.notifier);
    final respuestaExistente = ref
        .read(respuestasProvider)
        .respuestas[idpregunta];

    if (respuestaExistente != null) {
      // Actualizar manteniendo otros valores
      respuestasNotifier.actualizarRespuestaTexto(idpregunta, texto);
    } else {
      // Crear nueva respuesta
      respuestasNotifier.agregarRespuesta(
        idpregunta,
        grupoId,
        tipoPregunta,
        descripcionPregunta,
        encabezadoPregunta: encabezadoPregunta,
        emojiPregunta: emojiPregunta,
        respuestaTexto: texto,
        preguntaId: preguntaId, // Compatibilidad hacia atrás
      );
    }
  }

  /// Guardar respuesta de imagen (una o múltiples imágenes)
  /// NUEVO FORMATO: Usa idpregunta como clave
  void guardarRespuestaImagenes(
    String idpregunta, // Cambiado de preguntaId a idpregunta
    String grupoId,
    String? tipoPregunta, // Ya no necesario, opcional
    String? descripcionPregunta, // Ya no necesario, opcional
    String encabezadoPregunta,
    String? emojiPregunta,
    List<String> imageUrls,
    String? preguntaId, // Compatibilidad hacia atrás
  ) {
    final respuestasNotifier = ref.read(respuestasProvider.notifier);
    final respuestaExistente = ref
        .read(respuestasProvider)
        .respuestas[idpregunta];

    if (respuestaExistente != null) {
      // Actualizar manteniendo otros valores
      respuestasNotifier.actualizarRespuestaImagenes(idpregunta, imageUrls);
    } else {
      // Crear nueva respuesta
      respuestasNotifier.agregarRespuesta(
        idpregunta,
        grupoId,
        tipoPregunta,
        descripcionPregunta,
        encabezadoPregunta: encabezadoPregunta,
        emojiPregunta: emojiPregunta,
        respuestaImagenes: imageUrls,
        preguntaId: preguntaId, // Compatibilidad hacia atrás
      );
    }
  }

  /// Guardar respuesta de número
  /// NUEVO FORMATO: Usa idpregunta como clave
  void guardarRespuestaNumero(
    String idpregunta, // Cambiado de preguntaId a idpregunta
    String grupoId,
    String? tipoPregunta, // Ya no necesario, opcional
    String? descripcionPregunta, // Ya no necesario, opcional
    String encabezadoPregunta,
    String? emojiPregunta,
    String numero,
    String? preguntaId, // Compatibilidad hacia atrás
  ) {
    final respuestasNotifier = ref.read(respuestasProvider.notifier);
    final respuestaExistente = ref
        .read(respuestasProvider)
        .respuestas[idpregunta];

    if (respuestaExistente != null) {
      // Actualizar manteniendo otros valores
      respuestasNotifier.actualizarRespuestaTexto(idpregunta, numero);
    } else {
      // Crear nueva respuesta
      respuestasNotifier.agregarRespuesta(
        idpregunta,
        grupoId,
        tipoPregunta,
        descripcionPregunta,
        encabezadoPregunta: encabezadoPregunta,
        emojiPregunta: emojiPregunta,
        respuestaTexto: numero,
        preguntaId: preguntaId, // Compatibilidad hacia atrás
      );
    }
  }

  /// Guardar respuesta de teléfono
  /// NUEVO FORMATO: Usa idpregunta como clave
  /// Guarda el número completo en formato string (incluye código de país)
  void guardarRespuestaTelefono(
    String idpregunta, // Cambiado de preguntaId a idpregunta
    String grupoId,
    String? tipoPregunta, // Ya no necesario, opcional
    String? descripcionPregunta, // Ya no necesario, opcional
    String encabezadoPregunta,
    String? emojiPregunta,
    String telefono, // Número completo con código de país (ej: +1234567890)
    String? preguntaId, // Compatibilidad hacia atrás
  ) {
    final respuestasNotifier = ref.read(respuestasProvider.notifier);
    final respuestaExistente = ref
        .read(respuestasProvider)
        .respuestas[idpregunta];

    if (respuestaExistente != null) {
      // Actualizar manteniendo otros valores
      respuestasNotifier.actualizarRespuestaTexto(idpregunta, telefono);
    } else {
      // Crear nueva respuesta
      respuestasNotifier.agregarRespuesta(
        idpregunta,
        grupoId,
        tipoPregunta,
        descripcionPregunta,
        encabezadoPregunta: encabezadoPregunta,
        emojiPregunta: emojiPregunta,
        respuestaTexto: telefono, // Guardar número completo como string
        preguntaId: preguntaId, // Compatibilidad hacia atrás
      );
    }
  }

  /// Guardar respuesta de país
  /// NUEVO FORMATO: Usa idpregunta como clave
  /// Guarda el código del país en formato ISO 3166-1 alpha-2 (ej: "US", "MX", "ES")
  void guardarRespuestaPais(
    String idpregunta, // Cambiado de preguntaId a idpregunta
    String grupoId,
    String? tipoPregunta, // Ya no necesario, opcional
    String? descripcionPregunta, // Ya no necesario, opcional
    String encabezadoPregunta,
    String? emojiPregunta,
    String codigoPais, // Código ISO 3166-1 alpha-2 (ej: "US", "MX", "ES")
    String? preguntaId, // Compatibilidad hacia atrás
  ) {
    final respuestasNotifier = ref.read(respuestasProvider.notifier);
    final respuestaExistente = ref
        .read(respuestasProvider)
        .respuestas[idpregunta];

    if (respuestaExistente != null) {
      // Actualizar manteniendo otros valores
      respuestasNotifier.actualizarRespuestaTexto(idpregunta, codigoPais);
    } else {
      // Crear nueva respuesta
      respuestasNotifier.agregarRespuesta(
        idpregunta,
        grupoId,
        tipoPregunta,
        descripcionPregunta,
        encabezadoPregunta: encabezadoPregunta,
        emojiPregunta: emojiPregunta,
        respuestaTexto: codigoPais, // Guardar código del país como string
        preguntaId: preguntaId, // Compatibilidad hacia atrás
      );
    }
  }

  /// Guardar respuesta de fecha
  /// NUEVO FORMATO: Usa idpregunta como clave
  /// Guarda la fecha en formato ISO 8601 string (YYYY-MM-DD)
  void guardarRespuestaFecha(
    String idpregunta, // Cambiado de preguntaId a idpregunta
    String grupoId,
    String? tipoPregunta, // Ya no necesario, opcional
    String? descripcionPregunta, // Ya no necesario, opcional
    String encabezadoPregunta,
    String? emojiPregunta,
    String fecha, // Fecha en formato ISO 8601 (YYYY-MM-DD)
    String? preguntaId, // Compatibilidad hacia atrás
  ) {
    final respuestasNotifier = ref.read(respuestasProvider.notifier);
    final respuestaExistente = ref
        .read(respuestasProvider)
        .respuestas[idpregunta];

    if (respuestaExistente != null) {
      // Actualizar manteniendo otros valores
      respuestasNotifier.actualizarRespuestaTexto(idpregunta, fecha);
    } else {
      // Crear nueva respuesta
      respuestasNotifier.agregarRespuesta(
        idpregunta,
        grupoId,
        tipoPregunta,
        descripcionPregunta,
        encabezadoPregunta: encabezadoPregunta,
        emojiPregunta: emojiPregunta,
        respuestaTexto: fecha, // Guardar fecha en formato ISO 8601 como string
        preguntaId: preguntaId, // Compatibilidad hacia atrás
      );
    }
  }
}
