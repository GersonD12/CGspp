import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'respuestas.dart';

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
                //icono de las respuestas guardadas
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

// Widget para mostrar estadísticas detalladas
class RespuestasStatsWidget extends ConsumerWidget {
  const RespuestasStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final respuestasState = ref.watch(respuestasProvider);

    if (respuestasState.totalRespuestas == 0) {
      return const SizedBox.shrink();
    }

    final stats = _calcularEstadisticas(respuestasState);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas de Respuestas',
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Total',
                '${stats['total']}',
                Icons.quiz,
                Colors.blue,
              ),
              _buildStatItem(
                'Texto',
                '${stats['texto']}',
                Icons.text_fields,
                Colors.orange,
              ),
              _buildStatItem(
                'Imagen',
                '${stats['imagen']}',
                Icons.image,
                Colors.purple,
              ),
              _buildStatItem(
                'Opciones',
                '${stats['opciones']}',
                Icons.radio_button_checked,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.8), fontSize: 10),
        ),
      ],
    );
  }

  Map<String, int> _calcularEstadisticas(RespuestasState respuestasState) {
    final respuestas = respuestasState.todasLasRespuestas;

    return {
      'total': respuestas.length,
      'texto': respuestas.where((r) => r.respuestaTexto != null).length,
      'imagen': respuestas.where((r) => r.respuestaImagen != null).length,
      'opciones': respuestas.where((r) => r.respuestaOpciones != null).length,
    };
  }
}

// Widget para mostrar el progreso de respuestas
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
