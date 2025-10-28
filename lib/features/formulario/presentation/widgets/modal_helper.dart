import 'package:flutter/material.dart';

/// Helper function para mostrar un diálogo modal reutilizable y personalizable.
///
/// [context]: El BuildContext actual, necesario para mostrar el diálogo.
/// [title]: El texto que aparecerá en el título del modal.
/// [content]: El widget principal que se mostrará en el cuerpo del modal.
///            Aquí es donde reside la mayor parte de la personalización.
/// [actions]: Una lista de widgets (generalmente botones como TextButton o
///            ElevatedButton) que se mostrarán en la parte inferior.
/// [barrierDismissible]: Si es true, permite cerrar el modal tocando fuera de él.
///
/// Devuelve un `Future` que se completa con el valor que se pasa a `Navigator.pop`,
/// si lo hubiera.
Future<T?> showReusableModal<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  List<Widget>? actions,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: content,
        actions: actions,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      );
    },
  );
}

