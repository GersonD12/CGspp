import 'package:flutter/material.dart';

/// Widget que muestra un mensaje cuando no hay respuesta
class SinRespuestaWidget extends StatelessWidget {
  const SinRespuestaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Sin respuesta válida',
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

