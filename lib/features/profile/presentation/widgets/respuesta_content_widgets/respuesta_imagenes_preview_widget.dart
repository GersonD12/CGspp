import 'package:flutter/material.dart';
import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/profile/presentation/widgets/respuesta_content_widgets/glass_container_widget.dart';

/// Widget que muestra un preview de imágenes en una respuesta
class RespuestaImagenesPreviewWidget extends StatelessWidget {
  final RespuestaDTO respuesta;

  const RespuestaImagenesPreviewWidget({
    super.key,
    required this.respuesta,
  });

  @override
  Widget build(BuildContext context) {
    if (respuesta.respuestaImagenes == null || respuesta.respuestaImagenes!.isEmpty) {
      return const SizedBox.shrink();
    }

    return GlassContainerWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.photo_library,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  '${respuesta.respuestaImagenes!.length} imagen${respuesta.respuestaImagenes!.length > 1 ? 'es' : ''}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: respuesta.respuestaImagenes!.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(
                    right: index == respuesta.respuestaImagenes!.length - 1 ? 0 : 12,
                  ),
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      respuesta.respuestaImagenes![index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: Icon(
                            Icons.broken_image,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

