import 'package:flutter/material.dart';

class RadioQuestionWidget extends StatelessWidget {
  final String pregunta;
  final List<String> opciones;
  final bool allowCustomOption;
  final String customOptionLabel;
  final String? respuestaActual;
  final Function(String) onRespuestaChanged;

  const RadioQuestionWidget({
    super.key,
    required this.pregunta,
    required this.opciones,
    this.allowCustomOption = false,
    this.customOptionLabel = 'Otro',
    required this.onRespuestaChanged,
    this.respuestaActual,
  });

  // Función para determinar si el valor actual es un texto personalizado
  bool _isCustomText(String? actual) {
    if (actual == null ||
        opciones.contains(actual) ||
        actual == customOptionLabel) {
      return false; // Es nulo, es una opción estándar, o es la etiqueta 'Otro'.
    }
    return true; // Es cualquier otra cosa (texto escrito).
  }

  // Función para obtener el valor que debe controlar el RadioGroup
  String? _getGroupValue(String? actual) {
    if (actual == null) {
      return null;
    }
    // Si la respuesta actual es un texto personalizado,
    // usamos la etiqueta 'Otro' (customOptionLabel) como valor de grupo.
    if (_isCustomText(actual)) {
      return customOptionLabel;
    }
    // Si es una opción estándar o la etiqueta 'Otro', usamos el valor tal cual.
    return actual;
  }

  @override
  Widget build(BuildContext context) {
    // El valor del grupo de radio (lo que está seleccionado)
    final String? groupValue = _getGroupValue(respuestaActual);

    // Si la respuesta actual es un texto personalizado, debemos mostrar el TextField.
    final bool showCustomTextField =
        _isCustomText(respuestaActual) || respuestaActual == customOptionLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            pregunta,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // Opciones estándar
        ...opciones.map((opcion) {
          return RadioListTile<String>(
            title: Text(opcion),
            value: opcion,
            // Usamos el valor calculado para mantener la selección
            groupValue: groupValue,
            onChanged: (String? value) {
              if (value != null) {
                // Notificar al padre (Riverpod)
                onRespuestaChanged(value);
              }
            },
          );
        }),

        // Opción personalizada
        if (allowCustomOption) ...[
          RadioListTile<String>(
            title: Text(customOptionLabel),
            value: customOptionLabel,
            // Usamos el valor calculado. Si es texto personalizado, groupValue será 'Otro'.
            groupValue: groupValue,
            onChanged: (String? value) {
              if (value != null) {
                // Si el usuario selecciona 'Otro', lo guardamos.
                onRespuestaChanged(value);
              }
            },
          ),

          // Campo de texto para opción personalizada
          if (showCustomTextField)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                // Mostramos el texto guardado si es personalizado.
                controller: TextEditingController(
                  text: _isCustomText(respuestaActual) ? respuestaActual : '',
                ),
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
                  // Guardamos el texto escrito
                  onRespuestaChanged(
                    value.isNotEmpty ? value : customOptionLabel,
                  );
                },
              ),
            ),
        ],
      ],
    );
  }
}

