import 'package:calet/features/formulario/preguntas.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(pantallaFormulario());
}

class pantallaFormulario extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Preguntas());
  }
}
