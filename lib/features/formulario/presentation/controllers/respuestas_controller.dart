import 'package:calet/features/formulario/presentation/providers/respuestas_state.dart';
import 'package:calet/features/formulario/application/use_cases/use_cases.dart';
import 'package:calet/features/formulario/domain/repositories/respuestas_repository.dart';
import 'package:calet/core/providers/session_provider.dart';
import 'package:calet/core/di/injection.dart';
import 'package:calet/app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' show log;

/// Controlador para manejar la UI y navegación de respuestas
class RespuestasController {
  final WidgetRef ref;

  RespuestasController(this.ref);

  /// Muestra el resumen de respuestas en un modal
  void mostrarResumenRespuestas(
    BuildContext context,
    RespuestasState respuestasState,
  ) {
    log('Mostrando modal con ${respuestasState.todasLasRespuestas.length} respuestas');

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
            onPressed: () => _guardarYFinalizar(context, respuestasState),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

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

    try {
      // Mostrar indicador de carga
      _mostrarLoading(context);

      // Obtener el repositorio de GetIt y ejecutar el use case
      final repository = getIt<RespuestasRepository>();
      final useCase = FinalizarFormularioUseCase(repository: repository);
      await useCase.execute(
        userId: user.id,
        respuestasState: respuestasState,
      );

      // Cerrar loading y diálogo de resumen
      if (Navigator.canPop(context)) Navigator.of(context).pop(); // Cierra loading
      if (Navigator.canPop(context)) Navigator.of(context).pop(); // Cierra modal de resumen

      // Navegar a home (si el context todavía está montado)
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (e) {
      // Cerrar loading si está abierto
      if (Navigator.canPop(context)) Navigator.of(context).pop();
      // Mostrar error
      _mostrarError(context, 'Error al guardar las respuestas: $e');
    }
  }

  /// Muestra un indicador de carga
  void _mostrarLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator()),
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
      mostrarResumenRespuestas(context, respuestasState);
    }
  }

  /// Obtiene el use case para guardar respuestas
  GuardarRespuestaUseCase get guardarRespuestaUseCase =>
      GuardarRespuestaUseCase(ref);
}

