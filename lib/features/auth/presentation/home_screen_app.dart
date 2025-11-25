import 'package:calet/features/auth/presentation/home_screen.dart';
import 'package:calet/features/formulario/presentation/screens/formulario_screen.dart';
import 'package:flutter/material.dart';
import 'package:calet/features/cards/presentation/screens/screen_cards.dart';
import 'package:calet/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';

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
    ProfileScreen(),
    FormularioScreen(),
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
            child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(80),
                border: Border.all(
                  color: const Color.fromARGB(
                    124,
                    206,
                    206,
                    206,
                  ).withOpacity(0.2),
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(80),
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
                        child: Icon(Icons.person),
                      ),
                      activeIcon: Icon(Icons.person),
                      label: 'Perfil',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Icon(Icons.analytics_outlined),
                      ),
                      activeIcon: Icon(Icons.analytics_outlined),
                      label: 'Formulario',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  type: BottomNavigationBarType.fixed,
                  showUnselectedLabels: false,
                  showSelectedLabels: true,
                  selectedFontSize: 12.0,
                  unselectedFontSize: 0.0, // Force icon to center vertically
                  backgroundColor: const Color.fromARGB(225, 255, 255, 255),
                  selectedItemColor: const Color.fromARGB(255, 6, 80, 141),
                  unselectedItemColor: Colors.black,
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
