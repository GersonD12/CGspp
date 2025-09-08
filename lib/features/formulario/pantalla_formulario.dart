import 'package:calet/features/formulario/preguntas.dart';
import 'package:flutter/material.dart';

class PantallaFormulario extends StatelessWidget {
  const PantallaFormulario({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Preguntas(),
    );
  }
}
