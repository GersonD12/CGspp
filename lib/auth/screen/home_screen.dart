import 'package:flutter/material.dart';
import 'google_login_screen.dart';
import 'package:calet/auth/service/google_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla Principal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              try {
                await FirebaseServices.instance.signInWithGoogle();
              } catch (e) {
                debugPrint('Error al cerrar sesión: $e');
              }

              // Limpia el stack y lleva a login
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const GoogleLoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: const Center(child: Text('¡Bienvenido!')),
    );
  }
}
