import 'package:flutter/material.dart';
//import 'package:calet/auth/service/google_auth.dart'; // Importa la clase FirebaseServices

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: GestureDetector(
          onTap: () {
            // Aquí se ejecutaría la lógica del botón, como
            // llamar a la función de inicio de sesión de Google.
            // Por ejemplo: await FirebaseServices().signInWithGoogle();
          },
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Centra el contenido horizontalmente
            children: [
              Image.network(
                "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Google_Favicon_2025.svg/250px-Google_Favicon_2025.svg.png",
                height: 40,
                width: 40,
              ),
              const SizedBox(
                width: 10,
              ), // Añade un espacio entre la imagen y el texto
              const Text("Bienvenido inicio de sesión con google"),
            ],
          ),
        ),
      ),
    );
  }
}
