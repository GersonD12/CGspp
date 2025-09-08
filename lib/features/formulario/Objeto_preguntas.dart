import 'package:flutter/material.dart';

class ObjPreguntas extends StatefulWidget {
  final String pregunta;
  final List<String> opciones;

  const ObjPreguntas({
    super.key,
    required this.pregunta,
    required this.opciones,
  });
  @override
  State<ObjPreguntas> createState() => _ObjPreguntasState();
}

class _ObjPreguntasState extends State<ObjPreguntas> {
  String? _respuestaSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            widget.pregunta,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...widget.opciones.map((opcion) {
          // El 'RadioListTile' es ideal para opciones de selección única
          return RadioListTile<String>(
            title: Text(opcion),
            value: opcion,
            groupValue: _respuestaSeleccionada,
            onChanged: (String? value) {
              // 'setState' notifica a Flutter que el estado ha cambiado
              setState(() {
                _respuestaSeleccionada = value;
              });
              print('Opción seleccionada: $value');
            },
          );
        }).toList(),
      ],
    );
  }
}
