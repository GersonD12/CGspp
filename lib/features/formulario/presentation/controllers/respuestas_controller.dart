import 'package:calet/features/formulario/presentation/providers/respuestas_state.dart';
import 'package:calet/features/formulario/application/use_cases/use_cases.dart';
import 'package:calet/features/formulario/domain/repositories/respuestas_repository.dart';
import 'package:calet/features/formulario/domain/repositories/preguntas_repository.dart';
import 'package:calet/features/formulario/infrastructure/preguntas_repository_impl.dart';
import 'package:calet/core/providers/session_provider.dart';
import 'package:calet/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' show log;

/// Controlador para manejar la UI y navegación de respuestas
class RespuestasController {
  final WidgetRef ref;

  RespuestasController(this.ref);

  /// Guarda y finaliza el formulario
  Future<void> _guardarYFinalizar(
    BuildContext context,
    RespuestasState respuestasState,
  ) async {
    final user = ref.read(currentUserProvider);
    
    if (user == null) {
      _mostrarError(context, 'No se pudo guardar, usuario no autenticado.');
      return;
    }

    // Capturar el navigator antes de abrir cualquier diálogo
    final navigator = Navigator.of(context);

    try {
      log('Mostrando loading...');
      // Mostrar indicador de carga
      _mostrarLoading(context);

      log('Ejecutando use case...');
      // Obtener el repositorio de GetIt y ejecutar el use case
      final repository = getIt<RespuestasRepository>();
      final useCase = FinalizarFormularioUseCase(repository: repository);
      await useCase.execute(
        userId: user.id,
        respuestasState: respuestasState,
      );

      log('Respuestas guardadas exitosamente');
      // Cerrar loading (el diálogo)
      if (context.mounted && navigator.canPop()) {
        navigator.pop();
        log('Loading cerrado');
      }

      log('Navegando a home...');
      // Cerrar el formulario y volver a la pantalla anterior
      if (context.mounted) {
        navigator.pop();
        log('Navegación a home completada');
      }
    } catch (e) {
      log('Error al guardar: $e');
      // Cerrar loading si está abierto
      if (context.mounted && navigator.canPop()) {
        navigator.pop();
      }
      // Mostrar error
      _mostrarError(context, 'Error al guardar las respuestas: $e');
    }
  }

  /// Muestra un indicador de carga
  void _mostrarLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  /// Muestra un error
  void _mostrarError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  /// Finaliza el formulario (método público)
  void finalizarFormulario(
    BuildContext context,
    RespuestasState respuestasState,
  ) {
    log('finalizarFormulario llamado');
    log('Total respuestas: ${respuestasState.totalRespuestas}');

    if (respuestasState.totalRespuestas > 0) {
      log('Iniciando guardado de respuestas...');
      // Guardar directamente sin mostrar resumen
      _guardarYFinalizar(context, respuestasState);
    } else {
      log('No hay respuestas para guardar');
    }
  }

  /// Obtiene el use case para guardar respuestas
  GuardarRespuestaUseCase get guardarRespuestaUseCase =>
      GuardarRespuestaUseCase(ref);

  /// Obtiene el use case para obtener preguntas
  ObtenerPreguntasUseCase get obtenerPreguntasUseCase {
    // Verificar primero si está registrado, si no, registrarlo como fallback
    if (!getIt.isRegistered<PreguntasRepository>()) {
      getIt.registerLazySingleton<PreguntasRepository>(
        () => PreguntasRepositoryImpl(),
      );
    }
    
    final repository = getIt<PreguntasRepository>();
    return ObtenerPreguntasUseCase(repository);
  }
}

