import 'package:calet/core/di/injection.dart';
import 'package:calet/core/providers/session_provider.dart';
import 'package:calet/features/formulario/domain/repositories/respuestas_repository.dart';
import 'package:calet/features/formulario/presentation/providers/respuestas_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Use case para cargar respuestas guardadas del usuario
/// Solo carga respuestas de preguntas que están activas
class CargarRespuestasGuardadasUseCase {
  final WidgetRef ref;
  final RespuestasRepository repository;

  CargarRespuestasGuardadasUseCase({
    required this.ref,
    RespuestasRepository? repository,
  }) : repository = repository ?? getIt<RespuestasRepository>();

  /// Carga las respuestas guardadas del usuario desde Firestore
  /// Solo carga respuestas de preguntas que están activas (estado == true)
  Future<void> execute({
    required Set<String> preguntasActivasIds,
  }) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        return;
      }

      if (preguntasActivasIds.isEmpty) {
        return;
      }

      final respuestasState = await repository.downloadRespuestas(user.id);

      if (respuestasState != null && respuestasState.totalRespuestas > 0) {
        // Cargar solo las respuestas de preguntas que están activas
        final notifier = ref.read(respuestasProvider.notifier);
        for (final respuesta in respuestasState.todasLasRespuestas) {
          // Solo cargar si la pregunta sigue activa
          if (preguntasActivasIds.contains(respuesta.preguntaId)) {
            notifier.agregarRespuesta(
              respuesta.preguntaId,
              respuesta.grupoId,
              respuesta.tipoPregunta,
              respuesta.descripcionPregunta,
              encabezadoPregunta: respuesta.encabezadoPregunta,
              emojiPregunta: respuesta.emojiPregunta,
              respuestaTexto: respuesta.respuestaTexto,
              respuestaImagenes: respuesta.respuestaImagenes,
              respuestaOpciones: respuesta.respuestaOpciones,
              respuestaOpcionesCompletas: respuesta.respuestaOpcionesCompletas,
            );
          }
        }
      }
    } catch (e) {
      // No mostrar error al usuario, simplemente continuar sin respuestas previas
    }
  }
}

