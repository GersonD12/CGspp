import 'package:flutter/material.dart';
import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/formulario/presentation/helpers/formulario_theme_helper.dart';
import 'package:calet/features/profile/presentation/widgets/respuesta_content_widgets/glass_container_widget.dart';
import 'package:country_picker/country_picker.dart';

/// Widget que muestra una respuesta de tipo país con bandera
class RespuestaPaisWidget extends StatelessWidget {
  final RespuestaDTO respuesta;

  const RespuestaPaisWidget({
    super.key,
    required this.respuesta,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = FormularioThemeHelper.getTextColor(context);

    if (respuesta.respuestaTexto == null || respuesta.respuestaTexto!.isEmpty) {
      return const SizedBox.shrink();
    }

    try {
      final country = Country.parse(respuesta.respuestaTexto!);
      return GlassContainerWidget(
        child: Row(
          children: [
            // Bandera del país
            Text(
              country.flagEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            // Nombre del país
            Expanded(
              child: Text(
                country.name,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      // Si no se puede parsear el código del país, mostrar el código como texto
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
}

