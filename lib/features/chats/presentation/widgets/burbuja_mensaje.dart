import 'package:calet/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';

class BurbujaMensaje extends StatelessWidget {
  final String mensaje;
  final String hora;
  final bool esMio;

  const BurbujaMensaje({
    super.key,
    this.mensaje = '',
    this.hora = '',
    this.esMio = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppThemeExtension>();

    return Align(
      alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: esMio
              ? (customColors?.barIconprecionado ?? theme.colorScheme.primary)
              : (customColors?.buttonColor ?? theme.colorScheme.surfaceVariant),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(esMio ? 16 : 0),
            bottomRight: Radius.circular(esMio ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // El texto empieza a la izquierda
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mensaje,
              style: TextStyle(
                color: esMio ? Colors.white : theme.colorScheme.onSurface,
                fontSize: 15,
              ),
              softWrap: true,
            ),
            if (hora.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hora,
                    style: TextStyle(
                      color:
                          (esMio ? Colors.white : theme.colorScheme.onSurface)
                              .withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
