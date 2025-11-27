import 'package:calet/features/auth/presentation/home_screen.dart';
import 'package:calet/features/cards/presentation/widgets/barra_flotante.dart';
import 'package:flutter/material.dart';
import 'package:calet/features/cards/presentation/screens/screen_cards.dart';
import 'package:calet/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';
import 'package:calet/core/theme/app_theme_extension.dart';
import 'package:calet/features/chats/chats_screen.dart';

class HomeScreenApp extends ConsumerStatefulWidget {
  const HomeScreenApp({super.key});

  @override
  ConsumerState<HomeScreenApp> createState() => _HomeScreenAppState();
}

class _HomeScreenAppState extends ConsumerState<HomeScreenApp> {
  int _selectedIndex =
      0; //variable que identifica el index seleccionado para saber cual mostrar en pantalla

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ScreenCards(),
    ChatsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return VerticalViewStandard(
      title: 'Inicio',
      showBackButton: false,
      showAppBar: false,
      padding: EdgeInsets.zero,
      separationHeight: 0,
      child: Stack(
        children: [
          // Contenido principal
          Center(child: _widgetOptions.elementAt(_selectedIndex)),
          // Bottom Navigation Bar flotante
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: BarraFlotante(
                text: '', // No se usa texto aquí
                trasparency: 1.0,
                backgroundColor: Theme.of(
                  context,
                ).extension<AppThemeExtension>()!.barColor,
                borderColor: Theme.of(
                  context,
                ).extension<AppThemeExtension>()!.barBorder.withOpacity(0.4),
                radius: 80,
                isFullyRound: false, // Usamos radio específico
                child: BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Icon(Icons.home),
                      ),
                      activeIcon: Icon(Icons.home),
                      label: 'Inicio',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Icon(Icons.all_inbox_rounded),
                      ),
                      activeIcon: Icon(Icons.all_inbox_rounded),
                      label: 'Cartas',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Icon(Icons.chat_bubble),
                      ),
                      activeIcon: Icon(Icons.chat_bubble),
                      label: 'Chats',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Icon(Icons.person),
                      ),
                      activeIcon: Icon(Icons.person),
                      label: 'Perfil',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  type: BottomNavigationBarType.fixed,
                  showUnselectedLabels: false,
                  showSelectedLabels: true,
                  selectedFontSize: 12.0,
                  unselectedFontSize: 0.0, // Force icon to center vertically
                  backgroundColor: Theme.of(
                    context,
                  ).extension<AppThemeExtension>()!.barColor.withOpacity(0.7),
                  selectedItemColor: Theme.of(context).colorScheme.onSurface,
                  unselectedItemColor: Theme.of(
                    context,
                  ).extension<AppThemeExtension>()!.barBorder,
                  onTap: _onItemTapped,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
