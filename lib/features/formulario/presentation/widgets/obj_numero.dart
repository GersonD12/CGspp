import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Un campo de texto que solo acepta una cantidad específica de dígitos numéricos.
class ObjNumero extends StatelessWidget {
  /// El controlador para el campo de texto.
  final TextEditingController? controller;

  /// El texto que se muestra como etiqueta flotante sobre el campo de texto.
  final String textoPlaceholder;
  final String titulo;

  /// El número máximo de dígitos que el usuario puede introducir.
  final int maxLength;
  final Function(String)? onChanged;

  const ObjNumero({
    super.key,
    this.controller,
    required this.textoPlaceholder,
    required this.titulo,
    required this.maxLength,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(titulo),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          // 1. Limita la longitud del texto y muestra un contador.
          maxLength: maxLength,
          decoration: InputDecoration(
            labelText: textoPlaceholder,
            // Oculta el contador de caracteres por defecto si no lo deseas.
            // Puedes quitar esta línea si quieres que se vea "0/10".
            counterText: '',
            border: const OutlineInputBorder(),
          ),
          // 2. Muestra el teclado numérico.
          keyboardType: TextInputType.number,
          // 3. Filtra la entrada para permitir solo dígitos.
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          // (Opcional) Añade validación para asegurarte de que el campo no esté vacío.
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo es obligatorio.';
            }
            if (value.length < maxLength) {
              return 'Se requieren $maxLength dígitos.';
            }
            return null;
          },
        ),
      ],
    );
  }
}
