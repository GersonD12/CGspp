import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

/// Widget para ingresar número de teléfono con selector de país
class PhoneNumberInputWidget extends StatefulWidget {
  /// El texto que se muestra como título
  final String titulo;
  
  /// Emoji para mostrar junto al título
  final String? emoji;
  
  /// El texto que se muestra como placeholder
  final String textoPlaceholder;
  
  /// Número de teléfono inicial (en formato completo con código de país)
  final String? numeroInicial;
  
  /// Callback cuando cambia el número de teléfono
  /// Recibe el número completo en formato string (incluye código de país)
  final Function(String numeroCompleto)? onChanged;

  const PhoneNumberInputWidget({
    super.key,
    required this.titulo,
    this.emoji,
    required this.textoPlaceholder,
    this.numeroInicial,
    this.onChanged,
  });

  @override
  State<PhoneNumberInputWidget> createState() => _PhoneNumberInputWidgetState();
}

class _PhoneNumberInputWidgetState extends State<PhoneNumberInputWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Si hay un número inicial, intentar parsearlo
    if (widget.numeroInicial != null && widget.numeroInicial!.isNotEmpty) {
      // Si el número tiene formato internacional (+código+número), extraer solo el número
      if (widget.numeroInicial!.startsWith('+')) {
        // Intentar extraer el número sin el código de país
        // Por ejemplo: +1234567890 -> 234567890
        final match = RegExp(r'^\+\d{1,3}(\d+)$').firstMatch(widget.numeroInicial!);
        if (match != null) {
          _controller.text = match.group(1)!;
        } else {
          _controller.text = widget.numeroInicial!;
        }
      } else {
        _controller.text = widget.numeroInicial!;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.emoji != null && widget.emoji!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  widget.emoji!,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            Expanded(
              child: Text(
                widget.titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        IntlPhoneField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.textoPlaceholder,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          initialCountryCode: 'US', // País por defecto (puede cambiarse según necesidad)
          onChanged: (PhoneNumber phone) {
            // phone.completeNumber contiene el número completo con código de país
            // Ejemplo: "+1234567890"
            if (phone.completeNumber.isNotEmpty) {
              widget.onChanged?.call(phone.completeNumber);
            } else {
              widget.onChanged?.call('');
            }
          },
          keyboardType: TextInputType.phone,
          disableLengthCheck: false,
        ),
      ],
    );
  }
}

