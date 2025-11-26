import 'package:calet/core/providers/config_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Botón para cambiar entre tema claro y oscuro
///
/// Este widget puede ser usado en cualquier parte de la aplicación,
/// por ejemplo en el AppBar o en la página de perfil.
///
/// Ejemplo de uso:
/// ```dart
/// ThemeToggleButton()
/// ```
class ThemeToggleButton extends ConsumerWidget {
  /// Constructor del botón de cambio de tema
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);
    final isDarkMode = config.brightness == Brightness.dark;

    return IconButton(
      icon: Icon(
        isDarkMode ? Icons.light_mode : Icons.dark_mode,
        color: Theme.of(context).iconTheme.color,
      ),
      tooltip: isDarkMode ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
      onPressed: () {
        ref.read(configProvider.notifier).toggleTheme();
      },
    );
  }
}
