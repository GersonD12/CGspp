import 'package:calet/features/auth/service/google_auth.dart';
import 'package:flutter/material.dart';

class GoogleLoginScreen extends StatefulWidget {
  const GoogleLoginScreen({super.key});

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _handleLogin() async {
    if (_loading) return;
    setState(() { _loading = true; _error = null; });
    try {
      final cred = await GoogleAuthService.instance.signInWithGoogle();
      if (cred == null) {
        // Usuario canceló; opcionalmente muestra algo
      }
    } catch (e) {
      setState(() { _error = 'No se pudo iniciar sesión. Inténtalo de nuevo.'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text('Continuar con Google'),
                  ),
                ],
              ),
      ),
    );
  }
}
