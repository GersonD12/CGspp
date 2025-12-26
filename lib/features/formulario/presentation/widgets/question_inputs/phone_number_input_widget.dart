import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

/// Convierte un código telefónico internacional a código ISO de país
/// Ejemplo: +502 -> GT, +1 -> US, +52 -> MX
String _getCountryCodeFromPhoneCode(String phoneNumber) {
  if (!phoneNumber.startsWith('+')) return 'US';
  
  // Mapa de códigos telefónicos a códigos ISO de países
  // Incluye los códigos más comunes
  final phoneCodeToCountry = {
    '1': 'US',      // USA/Canadá
    '52': 'MX',     // México
    '502': 'GT',    // Guatemala
    '503': 'SV',    // El Salvador
    '504': 'HN',    // Honduras
    '505': 'NI',    // Nicaragua
    '506': 'CR',    // Costa Rica
    '507': 'PA',    // Panamá
    '51': 'PE',     // Perú
    '54': 'AR',     // Argentina
    '55': 'BR',     // Brasil
    '56': 'CL',     // Chile
    '57': 'CO',     // Colombia
    '58': 'VE',     // Venezuela
    '591': 'BO',    // Bolivia
    '592': 'GY',    // Guyana
    '593': 'EC',    // Ecuador
    '594': 'GF',    // Guayana Francesa
    '595': 'PY',    // Paraguay
    '596': 'MQ',    // Martinica
    '597': 'SR',    // Surinam
    '598': 'UY',    // Uruguay
    '599': 'CW',    // Curazao
    '34': 'ES',     // España
    '33': 'FR',     // Francia
    '44': 'GB',     // Reino Unido
    '49': 'DE',     // Alemania
    '39': 'IT',     // Italia
  };
  
  // Extraer el código telefónico (1-3 dígitos después del +)
  for (int length = 3; length >= 1; length--) {
    if (phoneNumber.length > length) {
      final code = phoneNumber.substring(1, length + 1);
      if (phoneCodeToCountry.containsKey(code)) {
        return phoneCodeToCountry[code]!;
      }
    }
  }
  
  return 'US'; // Por defecto
}

/// Extrae el número sin el código de país del formato internacional
/// Ejemplo: +50251593189 -> 51593189
String _extractPhoneNumber(String phoneNumber) {
  if (!phoneNumber.startsWith('+')) return phoneNumber;
  
  // Intentar extraer el número después del código de país
  // Los códigos pueden ser de 1 a 3 dígitos
  for (int codeLength = 3; codeLength >= 1; codeLength--) {
    if (phoneNumber.length > codeLength + 1) {
      final code = phoneNumber.substring(1, codeLength + 1);
      // Verificar si es un código válido (solo dígitos)
      if (RegExp(r'^\d+$').hasMatch(code)) {
        final number = phoneNumber.substring(codeLength + 1);
        if (number.isNotEmpty) {
          return number;
        }
      }
    }
  }
  
  return phoneNumber.substring(1); // Si no se puede parsear, devolver sin el +
}

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
  String _initialCountryCode = 'US';

  @override
  void initState() {
    super.initState();
    // Si hay un número inicial, intentar parsearlo
    if (widget.numeroInicial != null && widget.numeroInicial!.isNotEmpty) {
      // Si el número tiene formato internacional (+código+número)
      if (widget.numeroInicial!.startsWith('+')) {
        // Detectar el código del país desde el código telefónico
        _initialCountryCode = _getCountryCodeFromPhoneCode(widget.numeroInicial!);
        // Extraer solo el número sin el código de país
        _controller.text = _extractPhoneNumber(widget.numeroInicial!);
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
          initialCountryCode: _initialCountryCode, // Código del país detectado del número inicial
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

