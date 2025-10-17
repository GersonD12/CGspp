import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calet/core/providers/session_provider.dart';
import 'respuestas.dart';
import 'package:calet/app/routes/routes.dart';
import 'dart:developer' show log;

class RespuestasService {
  // Método para subir las respuestas a Firestore
  static Future<void> _uploadRespuestas(
    String userId,
    RespuestasState respuestasState,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final userDocRef = firestore.collection('users').doc(userId);

    // Convertir las respuestas a un mapa, usando preguntaId como clave
    final Map<String, dynamic> answersMap = {};
    for (final respuesta in respuestasState.todasLasRespuestas) {
      // Usamos el ID de la pregunta como clave para el mapa
      answersMap[respuesta.preguntaId] = respuesta.toMap();
    }

    // Crear el mapa final que se subirá a Firestore
    final respuestasMap = {
      'form_responses': {
        'completed_at': FieldValue.serverTimestamp(),
        'answers': answersMap, // Ahora es un mapa, no una lista
      },
    };

    // Subir las respuestas al documento del usuario
    await userDocRef.set(respuestasMap, SetOptions(merge: true));
  }

  // Mostrar resumen de respuestas en un modal
  static void mostrarResumenRespuestas(
    BuildContext context,
    RespuestasState respuestasState,
    WidgetRef ref,
  ) {
    log('mostrarResumenRespuestas llamado');
    log(
      'Mostrando modal con ${respuestasState.todasLasRespuestas.length} respuestas',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resumen de Respuestas'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: respuestasState.todasLasRespuestas.length,
            itemBuilder: (context, index) {
              final respuesta = respuestasState.todasLasRespuestas[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pregunta ${index + 1}: ${respuesta.descripcionPregunta}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      if (respuesta.respuestaTexto != null)
                        Text('Texto: ${respuesta.respuestaTexto}'),
                      if (respuesta.respuestaImagen != null)
                        Text('Imagen: ${respuesta.respuestaImagen}'),
                      if (respuesta.respuestaOpciones != null)
                        Text(
                          'Opciones: ${respuesta.respuestaOpciones!.join(', ')}',
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = ref.read(currentUserProvider);
              if (user != null) {
                try {
                  // Mostrar un indicador de carga
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  await _uploadRespuestas(user.id, respuestasState);

                  // Cerrar el indicador de carga
                  Navigator.of(context).pop();

                  // Navegar a la pantalla de inicio
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                } catch (e) {
                  // Cerrar el indicador de carga
                  Navigator.of(context).pop();
                  // Mostrar un error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al guardar las respuestas: $e'),
                    ),
                  );
                }
              } else {
                // Manejar el caso en que el usuario no esté autenticado
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No se pudo guardar, usuario no autenticado.',
                    ),
                  ),
                );
              }
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  // Mostrar resumen de respuestas y navegar a home
  static void finalizarFormulario(
    BuildContext context,
    RespuestasState respuestasState,
    WidgetRef ref,
  ) {
    log('finalizarFormulario llamado');
    log('Total respuestas: ${respuestasState.totalRespuestas}');

    if (respuestasState.totalRespuestas > 0) {
      // Si hay respuestas, mostrar resumen
      log('Mostrando resumen de respuestas...');
      mostrarResumenRespuestas(context, respuestasState, ref);
    } else {
      // Si no hay respuestas, ir directamente a home
      log('No hay respuestas, navegando a home...');
    }
  }

  // Guardar respuesta para pregunta de radio/múltiple
  static void guardarRespuestaRadio(
    WidgetRef ref,
    String preguntaId,
    String tipoPregunta,
    String descripcionPregunta,
    String respuesta,
  ) {
    final respuestasNotifier = ref.read(respuestasProvider.notifier);
    respuestasNotifier.agregarRespuesta(
      preguntaId,
      tipoPregunta,
      descripcionPregunta,
      respuestaOpciones: [respuesta],
    );
  }

  // Guardar respuesta de texto
  static void guardarRespuestaTexto(
    WidgetRef ref,
    String preguntaId,
    String tipoPregunta,
    String descripcionPregunta,
    String texto,
  ) {
    final respuestasNotifier = ref.read(respuestasProvider.notifier);
    respuestasNotifier.agregarRespuesta(
      preguntaId,
      tipoPregunta,
      descripcionPregunta,
      respuestaTexto: texto,
    );
  }

  // Guardar respuesta de imagen
  static void guardarRespuestaImagen(
    WidgetRef ref,
    String preguntaId,
    String tipoPregunta,
    String descripcionPregunta,
    String rutaImagen,
  ) {
    final respuestasNotifier = ref.read(respuestasProvider.notifier);
    respuestasNotifier.agregarRespuesta(
      preguntaId,
      tipoPregunta,
      descripcionPregunta,
      respuestaImagen: rutaImagen,
    );
  }

  // Obtener estadísticas de respuestas
  static Map<String, dynamic> obtenerEstadisticas(
    RespuestasState respuestasState,
  ) {
    final respuestas = respuestasState.todasLasRespuestas;

    return {
      'totalRespuestas': respuestas.length,
      'respuestasTexto': respuestas
          .where((r) => r.respuestaTexto != null)
          .length,
      'respuestasImagen': respuestas
          .where((r) => r.respuestaImagen != null)
          .length,
      'respuestasOpciones': respuestas
          .where((r) => r.respuestaOpciones != null)
          .length,
      'fechaUltimaRespuesta': respuestas.isNotEmpty
          ? respuestas
                .map((r) => r.fechaRespuesta)
                .reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
    };
  }

  // Exportar respuestas a formato JSON
  static Map<String, dynamic> exportarRespuestas(
    RespuestasState respuestasState,
  ) {
    return {
      'fechaExportacion': DateTime.now().toIso8601String(),
      'totalRespuestas': respuestasState.totalRespuestas,
      'respuestas': respuestasState.todasLasRespuestas
          .map((r) => r.toMap())
          .toList(),
    };
  }

  // Limpiar todas las respuestas
  static void limpiarRespuestas(WidgetRef ref) {
    final respuestasNotifier = ref.read(respuestasProvider.notifier);
    respuestasNotifier.limpiarRespuestas();
  }
}
