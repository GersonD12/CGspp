import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/respuestas_provider.dart';

/// Widget que muestra el indicador de respuestas guardadas
class RespuestasIndicator extends ConsumerWidget {
  const RespuestasIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final respuestasState = ref.watch(respuestasProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: respuestasState.totalRespuestas > 0
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: respuestasState.totalRespuestas > 0
              ? Colors.green
              : Colors.grey,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                respuestasState.totalRespuestas > 0
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                size: 16,
                color: respuestasState.totalRespuestas > 0
                    ? Colors.green[700]
                    : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Respuestas guardadas: ${respuestasState.totalRespuestas}',
                style: TextStyle(
                  color: respuestasState.totalRespuestas > 0
                      ? Colors.green[700]
                      : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

