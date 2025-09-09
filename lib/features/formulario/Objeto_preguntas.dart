import 'package:flutter/material.dart';

class ObjPreguntas extends StatefulWidget {
  final String pregunta;
  final List<String> opciones;
  final bool allowCustomOption;
  final String customOptionLabel;

  const ObjPreguntas({
    super.key,
    required this.pregunta,
    required this.opciones, //se añadio allowCustomOption y customOptionLabel para poder agregar una opcion personalizada
    this.allowCustomOption = false,
    this.customOptionLabel = 'Otro',
  });
  @override
  State<ObjPreguntas> createState() => _ObjPreguntasState();
}

class _ObjPreguntasState extends State<ObjPreguntas> {
  String? _respuestaSeleccionada;
  final TextEditingController _customTextController = TextEditingController();
  bool _isCustomSelected = false;

  @override
  void dispose() {
    _customTextController.dispose();
    super.dispose();
  }

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
                _isCustomSelected = false;
              });
              print('Opción seleccionada: $value');
            },
          );
        }).toList(),

        // Opción personalizada si está habilitada
        if (widget.allowCustomOption) ...[
          RadioListTile<String>(
            title: Text(widget.customOptionLabel),
            value: widget.customOptionLabel,
            groupValue: _respuestaSeleccionada,
            onChanged: (String? value) {
              setState(() {
                _respuestaSeleccionada = value;
                _isCustomSelected = true;
              });
              print('Opción personalizada seleccionada');
            },
          ),

          // Campo de texto para opción personalizada
          if (_isCustomSelected)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _customTextController,
                decoration: const InputDecoration(
                  hintText: 'Escribe tu respuesta...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _respuestaSeleccionada = value.isNotEmpty
                        ? value
                        : widget.customOptionLabel;
                  });
                },
              ),
            ),
        ],
      ],
    );
  }
}
