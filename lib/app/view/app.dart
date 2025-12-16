import 'package:calet/app/routes/routes.dart';
import 'package:calet/core/providers/config_provider.dart';
import 'package:calet/core/providers/session_provider.dart';
import 'package:calet/features/auth/presentation/google_login_screen.dart';
import 'package:calet/features/auth/presentation/home_screen_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);
    final session = ref.watch(sessionProvider);

    return HeroMode(
      enabled: false, // Deshabilitar animaciones Hero para evitar conflictos
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: config.theme,
        // Configurar localizaciones para soportar español y otros idiomas
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'), // Español
          Locale('en', 'US'), // Inglés
        ],
        locale: const Locale('es', 'ES'), // Idioma por defecto: español
        // Rutas para navegación manual
        routes: routes,
        // Navegación automática para autenticación
        home: session.when(
          data: (sessionData) {
            if (sessionData.user != null) {
              return const HomeScreenApp();
            } else {
              return const GoogleLoginScreen();
            }
          },
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stack) =>
              Scaffold(body: Center(child: Text('Error: $error'))),
        ),
      ),
    );
  }
}
