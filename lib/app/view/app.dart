import 'package:calet/app/routes/routes.dart';
import 'package:calet/core/providers/config_provider.dart';
import 'package:calet/core/providers/session_provider.dart';
import 'package:calet/features/auth/screen/google_login_screen.dart';
import 'package:calet/features/auth/screen/home_screen.dart';
import 'package:calet/features/formulario/pantalla_formulario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);
    final session = ref.watch(sessionProvider);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: config.theme,
      // Rutas para navegación manual
      routes: routes,
      // Navegación automática para autenticación
      home: session.when(
        data: (sessionData) {
          if (sessionData.user != null) {
            if (sessionData.isNew) {
              return const PantallaFormulario();
            } else {
              return const HomeScreen();
            }
          } else {
            return const GoogleLoginScreen();
          }
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => Scaffold(
          body: Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }
}