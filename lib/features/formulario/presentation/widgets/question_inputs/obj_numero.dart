import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Un campo de texto que solo acepta números dentro de un rango específico.
class ObjNumero extends StatelessWidget {
  /// El controlador para el campo de texto.
  final TextEditingController? controller;

  /// El texto que se muestra como etiqueta flotante sobre el campo de texto.
  final String textoPlaceholder;
  final String titulo;
  final String? emoji; // Emoji para mostrar junto al título

  /// El número máximo permitido.
  final int? maxNumber;
  
  /// El número mínimo permitido.
  final int? minNumber;
  
  final Function(String)? onChanged;

  const ObjNumero({
    super.key,
    this.controller,
    required this.textoPlaceholder,
    required this.titulo,
    this.emoji,
    this.maxNumber,
    this.minNumber,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            if (emoji != null && emoji!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  emoji!,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            Expanded(
              child: Text(titulo),
            ),
          ],
        ),
        Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return TextFormField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: textoPlaceholder,
                labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                helperStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.3)
                        : theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.3)
                        : theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: theme.brightness == Brightness.dark
                    ? theme.colorScheme.surface
                    : theme.colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.all(16),
                // Mostrar el rango permitido si está definido
                helperText: _getHelperText(),
              ),
              // Muestra el teclado numérico.
              keyboardType: TextInputType.number,
              // Filtra la entrada para permitir solo dígitos.
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              // Validación para asegurar que el número esté en el rango permitido.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Este campo es obligatorio.';
                }
                
                final numero = int.tryParse(value);
                if (numero == null) {
                  return 'Debe ingresar un número válido.';
                }
                
                if (minNumber != null && numero < minNumber!) {
                  return 'El número debe ser mayor o igual a $minNumber.';
                }
                
                if (maxNumber != null && numero > maxNumber!) {
                  return 'El número debe ser menor o igual a $maxNumber.';
                }
                
                return null;
              },
            );
          },
        ),
      ],
    );
  }
  
  /// Genera el texto de ayuda que muestra el rango permitido
  String? _getHelperText() {
    if (minNumber != null && maxNumber != null) {
      return 'Rango permitido: $minNumber - $maxNumber';
    } else if (minNumber != null) {
      return 'Mínimo: $minNumber';
    } else if (maxNumber != null) {
      return 'Máximo: $maxNumber';
    }
    return null;
  }
}
