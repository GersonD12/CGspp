import 'package:calet/features/formulario/presentation/helpers/formulario_theme_helper.dart';
import 'package:flutter/material.dart';

/// Widget que muestra un indicador de carga
class PreguntasLoadingWidget extends StatelessWidget {
  const PreguntasLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final formTheme = FormularioThemeHelper.getThemeExtension(context);
    
    return Scaffold(
      backgroundColor: FormularioThemeHelper.getScaffoldBackground(context),
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            formTheme.formPrimary,
          ),
        ),
      ),
    );
  }
}

