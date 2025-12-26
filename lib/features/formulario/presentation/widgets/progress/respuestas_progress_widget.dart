import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/respuestas_provider.dart';

/// Widget para mostrar el progreso de respuestas
class RespuestasProgressWidget extends ConsumerWidget {
  final int totalPreguntas;

  const RespuestasProgressWidget({super.key, required this.totalPreguntas});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final respuestasState = ref.watch(respuestasProvider);
    final progreso = totalPreguntas > 0
        ? respuestasState.totalRespuestas / totalPreguntas
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso de Respuestas',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${respuestasState.totalRespuestas}/$totalPreguntas',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progreso,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              progreso >= 1.0 ? Colors.green : Colors.blue,
            ),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}

