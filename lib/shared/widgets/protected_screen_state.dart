import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calet/core/providers/session_provider.dart';
import 'package:calet/core/domain/entities/entities.dart';

/// Base para pantallas que requieren autenticación
abstract class ProtectedScreenState<T extends ProtectedScreenStatefulWidget> extends ConsumerState<T> {

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    return session.when(
      data: (sessionData) {
        if (sessionData.user == null) {
          // Si no hay usuario, redirigir inmediatamente al login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (route) => false,
              );
            }
          });

          // Mientras tanto, mostrar loading
          return _buildLoadingScreen();
        }
        return buildProtectedContent(context, sessionData.user!);
      },
      loading: () => _buildLoadingScreen(),
      error: (error, stack) => _buildErrorScreen(error),
    );
  }

  /// Contenido principal de la pantalla protegida
  Widget buildProtectedContent(BuildContext context, UserEntity user);

  /// Pantalla de carga
  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Pantalla de error
  Widget _buildErrorScreen(Object error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error', style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: const Text('Reintentar')
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget base para pantallas protegidas
abstract class ProtectedScreenStatefulWidget extends ConsumerStatefulWidget {
  const ProtectedScreenStatefulWidget({super.key});
}
