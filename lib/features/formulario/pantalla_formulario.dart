import 'package:flutter/material.dart';

void main() {
  runApp(const pantalla_formulario());
}

class pantalla_formulario extends StatelessWidget {
  const pantalla_formulario({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 248, 226, 185),
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Progreso Cuestionario'),
          backgroundColor: const Color.fromARGB(0, 148, 37, 37),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 350,
                height: 600,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: const Text('Siguiente', style: TextStyle(color: Colors.black)),
          backgroundColor: Color.fromARGB(255, 248, 226, 185),
        ),
      ),
    );
  }
}
