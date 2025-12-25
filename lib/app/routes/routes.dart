import 'package:flutter/material.dart';
import 'package:calet/features/auth/presentation/screens.dart';
import 'package:calet/features/formulario/presentation/screens/formulario_screen.dart';
import 'package:calet/features/cards/presentation/screens/screen_cards.dart';
import 'package:calet/shared/screens/pagina_usuario.dart';
import 'package:calet/features/profile/presentation/screens/profile_screen.dart';
import 'package:calet/features/solicitudes/presentation/solicitudes_screen.dart';
import 'package:calet/features/chats/presentation/screens/list_chats_screen.dart';
import 'package:calet/features/chats/presentation/screens/chat.dart';

// Sistema de rutas híbrido:
// - Navegación automática para autenticación (login/home)
// - Navegación manual para otras pantallas
final routes = <String, WidgetBuilder>{
  // Rutas para navegación manual
  '/profile': (context) => const ProfileScreen(),
  '/formulario': (context) => const FormularioScreen(),
  '/home': (context) => const HomeScreen(),
  '/cards': (context) => const ScreenCards(),
  '/user_detail': (context) => const UserDetailScreen(),
  '/solicitudes': (context) => const SolicitudesScreen(),
  '/listChats': (context) => const ListChatsScreen(),
  '/chat': (context) => const ChatScreen(),

  // '/settings': (context) => const SettingsScreen(),
  // '/dashboard': (context) => const DashboardScreen(),
  // '/details': (context) => const DetailsScreen(),

  // Nota: / y /home se manejan automáticamente con Riverpod
  // en el App widget basándose en el estado de autenticación
};

// Constantes para rutas (evita errores de tipeo)
class AppRoutes {
  // Rutas para navegación manual+
  static const String profile = '/profile';
  static const String formulario = '/formulario';
  static const String pantallaFormulario = '/pantallaFormulario';
  static const String cards = '/cards';
  static const String solicitudes = '/solicitudes';
  static const String listChats = '/listChats';
  static const String chat = '/chat';
  // static const String settings = '/settings';
  // static const String dashboard = '/dashboard';
  // static const String details = '/details';

  // Rutas de autenticación (manejadas automáticamente)
  static const String login = '/'; // Solo para referencia
  static const String home = '/home'; // Solo para referencia
  static const String userDetail = '/user_detail';
}
