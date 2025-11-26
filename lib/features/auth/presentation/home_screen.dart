import 'package:calet/app/routes/routes.dart';
import 'package:calet/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';
import 'package:calet/shared/widgets/boton_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return VerticalViewStandardScrollable(
      title: 'Inicio',
      appBarFloats: true,
      headerColor: Theme.of(context).appBarTheme.backgroundColor,
      foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      showBackButton: false,
      hasFloatingNavBar: true,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.profile);
          },
          icon: const Icon(Icons.person),
          tooltip: 'Mi Perfil',
        ),
      ],
      child: Column(
        children: [
          const SizedBox(height: 230),
          Text(
            'Bienvenido a \n CALET',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Boton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.formulario);
            },
            height: 45,
            width: 145,
            borderRadius: 45,
            shadowColor: Theme.of(
              context,
            ).extension<AppThemeExtension>()!.shadowColor,
            elevation: 1,
            texto: 'Formulario',
            icon: Icons.list,
            color: Theme.of(
              context,
            ).extension<AppThemeExtension>()!.buttonColor,
            textColor: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}
