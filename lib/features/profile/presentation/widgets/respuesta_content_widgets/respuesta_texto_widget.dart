import 'package:flutter/material.dart';
import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/formulario/presentation/helpers/formulario_theme_helper.dart';
import 'package:calet/features/profile/presentation/widgets/respuesta_content_widgets/glass_container_widget.dart';

/// Widget que muestra una respuesta de tipo texto
class RespuestaTextoWidget extends StatelessWidget {
  final RespuestaDTO respuesta;

  const RespuestaTextoWidget({
    super.key,
    required this.respuesta,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = FormularioThemeHelper.getTextColor(context);

    if (respuesta.respuestaTexto == null || respuesta.respuestaTexto!.isEmpty) {
      return const SizedBox.shrink();
    }

    return GlassContainerWidget(
      child: Text(
        respuesta.respuestaTexto!,
        style: TextStyle(
          fontSize: 15,
          color: textColor,
          height: 1.4,
        ),
      ),
    );
  }
}

