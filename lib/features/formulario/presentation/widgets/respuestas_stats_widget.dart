import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/respuestas_provider.dart';
import '../providers/respuestas_state.dart';

/// Widget para mostrar estadísticas detalladas de respuestas
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
      'imagen': respuestas.where((r) => r.respuestaImagenes != null && r.respuestaImagenes!.isNotEmpty).length,
      'opciones': respuestas.where((r) => r.respuestaOpciones != null).length,
    };
  }
}

