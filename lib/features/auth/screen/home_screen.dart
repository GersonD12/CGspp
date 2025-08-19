import 'package:calet/features/auth/service/google_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(user?.displayName ?? 'Inicio'),
        actions: [
          IconButton(
            onPressed: () async {
              await GoogleAuthService.instance.signOut();
              // Si quieres forzar re-consentir en el siguiente login:
              // await GoogleAuthService.instance.signOut(revoke: true);
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user?.photoURL != null)
              CircleAvatar(radius: 40, backgroundImage: NetworkImage(user!.photoURL!)),
            const SizedBox(height: 12),
            Text(user?.email ?? ''),
          ],
        ),
      ),
    );
  }
}
