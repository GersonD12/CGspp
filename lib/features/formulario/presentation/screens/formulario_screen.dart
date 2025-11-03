import 'preguntas_screen.dart';
import 'package:flutter/material.dart';

/// Pantalla principal del formulario de ingreso de datos
/// 
/// Actúa como punto de entrada para el feature de formulario
/// y delega el contenido principal a PreguntasScreen
class FormularioScreen extends StatelessWidget {
  const FormularioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usar PopScope para manejar el botón de retroceso del dispositivo
    return PopScope(
      canPop: false, // Bloquea el retroceso por defecto
      onPopInvoked: (didPop) {
        // No permitir retroceso cuando esta pantalla es la home
        // El usuario debe completar el formulario para continuar
      },
      child: const PreguntasScreen(),
    );
  }
}

