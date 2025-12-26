import 'package:flutter/material.dart';
import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/profile/presentation/widgets/edit_respuesta_bottom_sheet.dart';
import 'package:calet/features/profile/presentation/widgets/imagenes_editor_widget.dart';
import 'package:calet/features/profile/presentation/widgets/respuesta_content_widgets/widgets.dart';

/// Widget que muestra una pregunta con su respuesta
class RespuestaItemWidget extends StatefulWidget {
  final PreguntaDTO pregunta;
  final RespuestaDTO? respuesta;
  final String userId;
  final VoidCallback? onRespuestaGuardada;

  const RespuestaItemWidget({
    super.key,
    required this.pregunta,
    this.respuesta,
    required this.userId,
    this.onRespuestaGuardada,
  });

  @override
  State<RespuestaItemWidget> createState() => _RespuestaItemWidgetState();
}

class _RespuestaItemWidgetState extends State<RespuestaItemWidget> {
  Future<void> _showEditBottomSheet(BuildContext context) async {
    final resultado = await EditRespuestaBottomSheet.show(
      context,
      widget.pregunta.idpregunta,
      widget.pregunta.grupoId,
      widget.userId,
      widget.respuesta,
    );
    
    // Si se guardó exitosamente, refrescar los datos
    if (resultado == true && widget.onRespuestaGuardada != null) {
      widget.onRespuestaGuardada!();
    }
  }

  /// Verifica si la pregunta es de tipo imagen
  bool get _esTipoImagen => widget.pregunta.tipo.toLowerCase() == 'imagen';

  @override
  Widget build(BuildContext context) {
    // Si es tipo imagen, usar diseño especial tipo galería
    if (_esTipoImagen) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PreguntaHeaderWidget(pregunta: widget.pregunta),
            const SizedBox(height: 16),
            ImagenesEditorWidget(
              pregunta: widget.pregunta,
              respuesta: widget.respuesta,
              userId: widget.userId,
              onRespuestaGuardada: widget.onRespuestaGuardada,
            ),
          ],
        ),
      );
    }
    
    // Para otros tipos de preguntas
    return Padding(
      padding: const EdgeInsets.only(bottom: 52),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PreguntaHeaderWidget(
            pregunta: widget.pregunta,
            actionButton: _buildActionButton(context),
          ),
          const SizedBox(height: 10),
          if (widget.respuesta == null)
            _buildSinRespuestaPlaceholder(context)
          else
            RespuestaContentFactory.build(
              context: context,
              pregunta: widget.pregunta,
              respuesta: widget.respuesta!,
            ),
        ],
      ),
    );
  }

  Widget? _buildActionButton(BuildContext context) {
    if (widget.respuesta == null) {
      // Círculo rojo para responder
      return InkWell(
        onTap: () => _showEditBottomSheet(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.error.withOpacity(0),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.add,
            size: 18,
            color: Colors.white,
          ),
        ),
      );
    } else {
      // Icono de lápiz para editar respuesta existente
      return InkWell(
        onTap: () => _showEditBottomSheet(context),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            Icons.edit_outlined,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
  }

  Widget _buildSinRespuestaPlaceholder(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.help_outline,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Responde esta pregunta',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
