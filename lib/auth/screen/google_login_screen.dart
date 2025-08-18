import 'package:calet/auth/screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:calet/auth/service/google_auth.dart'; // Asegúrate de que este archivo exista y contenga la clase FirebaseServices

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

class GoogleLoginScreen extends StatefulWidget {
  const GoogleLoginScreen({super.key});

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      if (mounted && account != null) {
        // Redirige al usuario si ya ha iniciado sesión
        _navigateToAdminScreen();
      }
    });

    _googleSignIn.signInSilently();
  }

  void _navigateToAdminScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ), // Reemplaza AdminHomeScreen con tu pantalla de inicio
    );
  }

Future<void> _handleGoogleSignIn() async {
  try {
    // opcional: mostrar loading
    // setState(() => _loading = true);

    final user = await FirebaseServices.instance.signInWithGoogle();

    if (!mounted) return; // evita usar context si el widget ya no está

    if (user != null) {
      _navigateToAdminScreen(); // login OK
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("El inicio de sesión con Google fue cancelado o falló."),
        ),
      );
    }
  } on FirebaseAuthException catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error de autenticación: ${e.message ?? e.code}")),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Ocurrió un error inesperado: $e")),
    );
  } finally {
    // opcional: ocultar loading
    // if (mounted) setState(() => _loading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 33, 30, 247),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: _handleGoogleSignIn,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Usa una imagen local en lugar de Image.network
                  Image.network(
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Google_Favicon_2025.svg/250px-Google_Favicon_2025.svg.png", // Asegúrate de tener esta imagen en tus assets
                    height: 40,
                    width: 40,
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    "Continuar con Google",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
