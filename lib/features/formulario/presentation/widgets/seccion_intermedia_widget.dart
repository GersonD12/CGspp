import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/formulario/presentation/widgets/widgets.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';
import 'package:flutter/material.dart';

/// Widget para mostrar la pantalla intermedia entre secciones
class SeccionIntermediaWidget extends StatelessWidget {
  final SeccionDTO seccion;
  final bool esRetroceso;
  final bool mostrarPantallaInicial;
  final VoidCallback onContinuar;
  final VoidCallback? onRetroceder;

  const SeccionIntermediaWidget({
    super.key,
    required this.seccion,
    this.esRetroceso = false,
    this.mostrarPantallaInicial = false,
    required this.onContinuar,
    this.onRetroceder,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar si mostrar botón de retroceso en el header
    final mostrarBackButtonHeader = mostrarPantallaInicial || esRetroceso;

    return VerticalViewStandardScrollable(
      title: seccion.titulo,
      headerColor: const Color.fromARGB(255, 248, 226, 185),
      foregroundColor: Colors.black,
      backgroundColor: const Color.fromARGB(255, 248, 226, 185),
      centerTitle: true,
      showBackButton: mostrarBackButtonHeader,
      child: Center(
        child: Cuadrado(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Título de la sección
                Text(
                  seccion.titulo,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 76, 94, 175),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                // Descripción de la sección
                Text(
                  seccion.descripcion,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                // Botones de navegación
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botón retroceder (solo si no es la pantalla inicial y es retroceso)
                    if (esRetroceso && !mostrarPantallaInicial && onRetroceder != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: BotonSiguiente(
                          texto: 'Atrás',
                          onPressed: onRetroceder!,
                          color: const Color.fromARGB(255, 248, 226, 185),
                          icon: Icons.arrow_back_ios_outlined,
                          elevation: 5.0,
                          textColor: Colors.black,
                          fontSize: 18,
                          width: 150,
                          height: 60,
                        ),
                      ),
                    // Botón continuar
                    BotonSiguiente(
                      texto: 'Continuar',
                      onPressed: onContinuar,
                      color: const Color.fromARGB(255, 248, 226, 185),
                      icon: Icons.arrow_forward_ios_outlined,
                      elevation: 5.0,
                      textColor: Colors.black,
                      fontSize: 18,
                      width: 200,
                      height: 60,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

