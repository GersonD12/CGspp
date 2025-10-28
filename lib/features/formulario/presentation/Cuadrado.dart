import 'package:flutter/material.dart';

void main() {
  runApp(const Cuadrado());
}

class Cuadrado extends StatelessWidget {
  final Widget? child;
  const Cuadrado({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350, // Ancho del cuadrado
      height: 600, // Alto del cuadrado
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255), // El color del cuadrado
        borderRadius: BorderRadius.circular(30), // El radio de los bordes
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(5, 8),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}
