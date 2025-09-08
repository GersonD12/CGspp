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
              Container(
                width: 350,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white, // El color del cuadrado
                  borderRadius: BorderRadius.circular(
                    30,
                  ), // El radio de los bordes
                  boxShadow: const [
                    //  sombra
                    BoxShadow(
                      color: Colors
                          .black26, // Color de la sombra (gris oscuro, 26% opaco)
                      offset: Offset(
                        5,
                        8,
                      ), // Desplazamiento: 0 horizontal, 8px vertical
                      blurRadius: 20, // Desenfoque de 10px
                      spreadRadius:
                          2, // La sombra se extiende 2px más allá del contenedor
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://storage.googleapis.com/cms-storage-bucket/icon_flutter.0dbfcc7a59cd1cf16282.png',
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Cuéntanos',
                        style: TextStyle(fontSize: 35, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Sobre ti',
                        style: TextStyle(fontSize: 35, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 250),
              SizedBox(
                width: 250,
                height: 80,
                child: ElevatedButton(
                  onPressed: () {
                    //Navigator.pushNamed(context, AppRoutes.pantallaFormulario);
                  },
                  child: const Text(
                    'Inicio',
                    style: const TextStyle(fontSize: 30, color: Colors.black),
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
