import 'package:flutter/material.dart';

// Sistema de rutas híbrido:
// - Navegación automática para autenticación (login/home)
// - Navegación manual para otras pantallas
final routes = <String, WidgetBuilder>{
  // Rutas para navegación manual (descomenta cuando crees las pantallas)
  // '/profile': (context) => const ProfileScreen(),
  // '/settings': (context) => const SettingsScreen(),
  // '/dashboard': (context) => const DashboardScreen(),
  // '/details': (context) => const DetailsScreen(),
  
  // Nota: / y /home se manejan automáticamente con Riverpod
  // en el App widget basándose en el estado de autenticación
};

// Constantes para rutas (evita errores de tipeo)
class AppRoutes {
  // Rutas para navegación manual (descomenta cuando crees las pantallas)
  // static const String profile = '/profile';
  // static const String settings = '/settings';
  // static const String dashboard = '/dashboard';
  // static const String details = '/details';
  
  // Rutas de autenticación (manejadas automáticamente)
  static const String login = '/'; // Solo para referencia
  static const String home = '/home'; // Solo para referencia
}







