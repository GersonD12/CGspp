import 'dart:developer' as console;

import 'package:calet/features/auth/infrastructure/google_auth_service.dart';
import 'package:calet/shared/widgets/boton_widget.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calet/core/theme/app_theme_extension.dart';

class GoogleLoginScreen extends ConsumerStatefulWidget {
  const GoogleLoginScreen({super.key});

  @override
  ConsumerState<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends ConsumerState<GoogleLoginScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _handleLogin() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final cred = await GoogleAuthService.instance.signInWithGoogle();
      if (cred == null) {
        // Usuario canceló el login
        setState(() {
          _error = 'Login cancelado por el usuario';
        });
      }
      // Si el login es exitoso, el sessionProvider automáticamente
      // redirigirá a HomeScreen
    } catch (e) {
      console.log('Error al iniciar sesión: $e');
      setState(() {
        _error = 'Error al iniciar sesión: $e';
      });
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VerticalViewStandardScrollable(
      title: 'Iniciar Sesión',
      showBackButton: false,
      padding: const EdgeInsets.all(24.0),
      headerColor: Theme.of(context).appBarTheme.backgroundColor,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 200),
            Icon(
              Icons.account_circle,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 24),
            Text(
              'Bienvenido a Calet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Inicia sesión con tu cuenta de Google para continuar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 32),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),

            Boton(
              onPressed: _loading ? null : _handleLogin,
              icon: _loading ? null : Icons.login,
              texto: _loading ? 'Iniciando sesión...' : 'Continuar con Google',
              color: Theme.of(
                context,
              ).extension<AppThemeExtension>()!.buttonColor,
              textColor: Theme.of(context).colorScheme.onSurface,
              borderRadius: 30,
              shadowColor: Theme.of(
                context,
              ).extension<AppThemeExtension>()!.shadowColor.withOpacity(0.2),
              elevation: 2,
              width: 250,
            ),
          ],
        ),
      ),
    );
  }
}
