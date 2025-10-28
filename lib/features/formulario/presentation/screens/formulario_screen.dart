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
    return const PreguntasScreen();
  }
}

