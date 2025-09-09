import 'package:flutter/material.dart';
import 'Objeto_preguntas.dart';
import 'boton.dart';
import 'Cuadrado.dart';
import 'Progreso.dart';
import '../../shared/widgets/vertical_view_standard.dart';

class Preguntas extends StatefulWidget {
  const Preguntas({super.key});

  @override
  State<Preguntas> createState() => _PreguntasState();
}

class _PreguntasState extends State<Preguntas> {
  int contador = 0;

  void siguientePregunta() {
    setState(() {
      if (contador < 7) {
        contador++;
      }
    });
  }

  void atrasPregunta() {
    setState(() {
      if (contador > 0) {
        contador--;
      }
    });
  }

  Widget obtenerPregunta() {
    switch (contador) {
      case 0:
        return const ObjPreguntas(
          pregunta: '¿Cuál es tu evento favorito?',
          opciones: [
            'Nudos',
            'Marchas',
            'Amarras',
            'Predicador',
            'Conexion Biblica',
            'Ruta',
            'Drama/Cortometraje',
          ],
          allowCustomOption: true,
          customOptionLabel: 'Otro',
        );
      case 1:
        return const ObjPreguntas(
          pregunta: '¿Cuál es tu color favorito?',
          opciones: ['Rojo', 'Azul', 'Verde', 'Amarillo', 'Blanco', 'Negro'],
          allowCustomOption: true,
          customOptionLabel: 'Otro',
        );
      case 2:
        return const ObjPreguntas(
          pregunta: '¿Cuál es tu pasatiempo favorito?',
          opciones: [
            'Leer',
            'Escribir',
            'Dibujar',
            'Jugar',
            'Cocinar',
            'Viajar',
          ],
          allowCustomOption: true,
          customOptionLabel: 'Otro',
        );
      case 3:
        return const ObjPreguntas(
          pregunta: '¿Cuál es tu comida favorita?',
          opciones: [
            'Pizza',
            'Sushi',
            'Tacos',
            'Ensalada',
            'Pasta',
            'Hamburguesa',
          ],
          allowCustomOption: true,
          customOptionLabel: 'Otro',
        );
      case 4:
        return const ObjPreguntas(
          pregunta: '¿Cuál es tu deporte favorito?',
          opciones: ['Fútbol', 'Baloncesto', 'Tenis', 'Natación', 'Ciclismo'],
          allowCustomOption: true,
          customOptionLabel: 'Otro',
        );
      case 5:
        return const ObjPreguntas(
          pregunta: '¿Cuál es tu animal favorito?',
          opciones: ['Perro', 'Gato', 'Pájaro', 'Conejo', 'León', 'Mariposa'],
          allowCustomOption: true,
          customOptionLabel: 'Otro',
        );
      case 6:
        return const ObjPreguntas(
          pregunta: '¿Cuál es tu libro de la biblia favorito?',
          opciones: ['Daniel', 'Cantáres', 'Proverbios', 'Salmos'],
          allowCustomOption: true,
          customOptionLabel: 'Otro',
        );
      default:
        return const Center(child: Text('¡Formulario completado!'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calcular el progreso basado en la pregunta actual
    // Hay 7 preguntas (0-6), así que el progreso va de 0 a 1
    double progreso = contador / 7.0;

    return VerticalViewStandardScrollable(
      title: 'Pregunta ${contador + 1}',
      headerColor: const Color.fromARGB(255, 248, 226, 185),
      foregroundColor: Colors.black,
      backgroundColor: const Color.fromARGB(
        255,
        248,
        226,
        185,
      ), // Color de toda la pantalla
      centerTitle: true,
      showBackButton: true,
      onBackPressed: () {
        atrasPregunta();
      },
      child: Column(
        children: [
          const SizedBox(height: 20), // Espacio arriba
          // Barra de progreso debajo del título
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ), //tamaño de la barra de progreso numero mejor == mas grande, numero mayor == mas pequeño
            child: ProgresoAnimado(
              progress: progreso,
              color: const Color.fromARGB(
                255,
                76,
                94,
                175,
              ), //color de la barra de progreso
              height: 25.0, //altura de la barra de progreso
              backgroundColor: const Color.fromARGB(
                255,
                226,
                219,
                204,
              )!, //color de fondo de la barra de progreso
              borderRadius: BorderRadius.circular(
                15.0,
              ), //redondeo de la barra de progreso
              duration: const Duration(
                milliseconds: 300,
              ), //tiempo de animacion de la barra de progreso
            ),
          ),
          const SizedBox(height: 70), // Espacio entre progreso y contenido
          Center(
            child: Cuadrado(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    obtenerPregunta(),
                    const SizedBox(height: 20),
                    BotonSiguiente(
                      texto: 'Siguiente',
                      onPressed: siguientePregunta,
                      color: const Color.fromARGB(255, 248, 226, 185),
                      textColor: Colors.black,
                    ),
                    const SizedBox(height: 20), // Extra space at bottom
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
