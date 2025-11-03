import 'package:calet/core/providers/session_provider.dart';
import 'package:calet/app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Confiamos en que `App.dart` nos protege. Si estamos aquí, el usuario
    // está autenticado y no será nulo.
    // Usamos `ref.read` porque no necesitamos que este widget se reconstruya
    // si el usuario cambia (ej. al cerrar sesión). `App.dart` se encargará de eso.
    final user = ref.read(currentUserProvider)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(user.displayName ?? 'Inicio'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
            icon: const Icon(Icons.person),
            tooltip: 'Mi Perfil',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  if (user.photoURL != null)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(user.photoURL!),
                    )
                  else
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    user.displayName ?? 'Usuario',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email ?? '',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 48),
                    SizedBox(height: 16),
                    Text(
                      '¡Sesión iniciada exitosamente!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ya puedes acceder a todas las funcionalidades de la app.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Ejemplos de navegación manual
            const Text(
              'Ejemplos de Navegación Manual:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('Mi Perfil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.formulario);
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Formulario'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.cards);
                  },
                  icon: const Icon(Icons.credit_card),
                  label: const Text('Cards'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Navegación manual a /settings'),
                      ),
                    );
                    // Navigator.pushNamed(context, AppRoutes.settings);
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Configuración'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Navegación manual a /dashboard'),
                      ),
                    );
                    // Navigator.pushNamed(context, AppRoutes.dashboard);
                  },
                  icon: const Icon(Icons.dashboard),
                  label: const Text('Dashboard'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
