import 'package:flutter/material.dart';

class Cuadrado extends StatelessWidget {
  final Widget? child;
  const Cuadrado({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 350, // Ancho del cuadrado
      height: 600, // Alto del cuadrado
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest, // El color del cuadrado según el tema
        borderRadius: BorderRadius.circular(30), // El radio de los bordes
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black54
                : Colors.black26,
            offset: const Offset(5, 8),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}

