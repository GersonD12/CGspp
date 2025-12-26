import 'package:calet/features/formulario/presentation/helpers/formulario_theme_helper.dart';
import 'package:flutter/material.dart';

/// Widget que muestra un error con opción de reintentar
class PreguntasErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const PreguntasErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = FormularioThemeHelper.getTextColor(context);
    
    return Scaffold(
      backgroundColor: FormularioThemeHelper.getScaffoldBackground(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar el formulario',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

