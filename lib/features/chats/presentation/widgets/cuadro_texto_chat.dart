import 'package:flutter/material.dart';
import 'package:calet/shared/widgets/barra_flotante.dart';
import 'package:calet/shared/widgets/cuadro_texto.dart';

class CuadroTextoChat extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const CuadroTextoChat({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      width: double.infinity,
      child: BarraFlotante(
        child: Row(
          children: [
            const SizedBox(width: 5),
            const Icon(Icons.attach_file),
            const SizedBox(width: 5),
            Expanded(
              child: TextBox(
                controller: controller,
                maxLines: 1,
                borderRadius: 50,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: 45,
              height: 45,
              child: BarraFlotante(
                trasparency: 0.0,
                onTap: onSend,
                child: const Icon(Icons.send),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
