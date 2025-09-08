import 'package:flutter/material.dart';

void main() {
  runApp(const Formulario());
}

class Formulario extends StatelessWidget {
  const Formulario({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 248, 226, 185),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 250),
              SizedBox(
                width: 250,
                height: 80,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/cuadroPreguntas');
                  },
                  child: const Text(
                    'Inicio',
                    style: const TextStyle(fontSize: 25, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
