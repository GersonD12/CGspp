import 'package:calet/features/formulario/presentation/helpers/formulario_theme_helper.dart';
import 'package:calet/features/formulario/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

/// Widget para los botones de navegación (Atrás/Siguiente) en la pantalla de preguntas
class PreguntasNavigationButtons extends StatelessWidget {
  final bool puedeRetroceder;
  final bool puedeAvanzar;
  final bool preguntaRespondida;
  final bool esUltimaPregunta;
  final VoidCallback? onAtras;
  final VoidCallback? onSiguiente;
  final VoidCallback? onFinalizar;

  const PreguntasNavigationButtons({
    super.key,
    required this.puedeRetroceder,
    required this.puedeAvanzar,
    required this.preguntaRespondida,
    required this.esUltimaPregunta,
    this.onAtras,
    this.onSiguiente,
    this.onFinalizar,
  });

  @override
  Widget build(BuildContext context) {
    final formTheme = FormularioThemeHelper.getThemeExtension(context);
    final scaffoldBg = FormularioThemeHelper.getScaffoldBackground(context);
    final textColor = FormularioThemeHelper.getTextColor(context);
    
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: 16.0 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón Atrás
          puedeRetroceder
              ? Boton(
                  onPressed: onAtras,
                  icon: Icons.arrow_back_ios_outlined,
                  texto: 'Atrás',
                  color: scaffoldBg,
                  textColor: textColor,
                  elevation: 4.0,
                  height: 60,
                  width: 120,
                )
              : const SizedBox(width: 120),
          // Botón Siguiente/Finalizar
          Boton(
            texto: esUltimaPregunta ? 'Ver respuestas' : 'Siguiente',
            onPressed: esUltimaPregunta
                ? onFinalizar
                : (preguntaRespondida ? onSiguiente : null),
            color: (!esUltimaPregunta && !preguntaRespondida)
                ? formTheme.formButtonDisabled
                : scaffoldBg,
            icon: esUltimaPregunta
                ? Icons.check_rounded
                : Icons.arrow_forward_ios_outlined,
            elevation: (!esUltimaPregunta && !preguntaRespondida) ? 0.0 : 5.0,
            textColor: textColor,
            fontSize: 16,
            width: 150,
            height: 60,
          ),
        ],
      ),
    );
  }
}
