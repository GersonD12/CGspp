import 'package:flutter/material.dart';

class RadioQuestionWidget extends StatefulWidget {
  final String pregunta;
  final List<String> opciones;
  final bool allowCustomOption;
  final String customOptionLabel;
  final String? respuestaActual;
  final ValueChanged<String> onRespuestaChanged;

  const RadioQuestionWidget({
    super.key,
    required this.pregunta,
    required this.opciones,
    this.allowCustomOption = false,
    this.customOptionLabel = 'Otro',
    required this.onRespuestaChanged,
    this.respuestaActual,
  });

  @override
  State<RadioQuestionWidget> createState() => _RadioQuestionWidgetState();
}

class _RadioQuestionWidgetState extends State<RadioQuestionWidget> {
  late final TextEditingController _controller;

  // Función para determinar si el valor actual es un texto personalizado
  bool _isCustomText(String? actual) {
    if (actual == null ||
        widget.opciones.contains(actual) ||
        actual == widget.customOptionLabel) {
      return false;
    }
    return true;
  }

  // Función para obtener el valor que debe controlar el RadioGroup
  String? _getGroupValue(String? actual) {
    if (actual == null) {
      return null;
    }
    if (_isCustomText(actual)) {
      return widget.customOptionLabel;
    }
    return actual;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _isCustomText(widget.respuestaActual) ? widget.respuestaActual : '',
    );
  }

  @override
  void didUpdateWidget(covariant RadioQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.respuestaActual != widget.respuestaActual) {
      _controller.text = _isCustomText(widget.respuestaActual)
          ? widget.respuestaActual!
          : '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? groupValue = _getGroupValue(widget.respuestaActual);
    final bool showCustomTextField =
        _isCustomText(widget.respuestaActual) ||
        widget.respuestaActual == widget.customOptionLabel;

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

        // Opciones como píldoras (Chips)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              ...widget.opciones.map((opcion) {
                return ChoiceChip(
                  label: Text(opcion),
                  selected: groupValue == opcion,
                  onSelected: (selected) {
                    if (selected) {
                      widget.onRespuestaChanged(opcion);
                    }
                  },
                  //modificar color de las píldoras.
                  backgroundColor: Colors.white,
                  selectedColor: const Color.fromARGB(255, 214, 214, 214),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  labelStyle: TextStyle(
                    color: groupValue == opcion ? Colors.black : Colors.black,
                  ),
                );
              }),
              if (widget.allowCustomOption)
                ChoiceChip(
                  label: Text(widget.customOptionLabel),
                  selected: groupValue == widget.customOptionLabel,
                  onSelected: (selected) {
                    if (selected) {
                      widget.onRespuestaChanged(widget.customOptionLabel);
                    }
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  labelStyle: TextStyle(
                    color: groupValue == widget.customOptionLabel
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
            ],
          ),
        ),

        if (widget.allowCustomOption && showCustomTextField)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: TextField(
              controller: _controller,
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
                widget.onRespuestaChanged(
                  value.isNotEmpty ? value : widget.customOptionLabel,
                );
              },
            ),
          ),
      ],
    );
  }
}
