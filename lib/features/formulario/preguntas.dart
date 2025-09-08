import 'package:flutter/material.dart';
import 'Objeto_preguntas.dart';
import 'Boton.dart';
import 'Cuadrado.dart'; // Asegúrate de que este import exista

class Preguntas extends StatefulWidget {
  const Preguntas({super.key});

  @override
  State<Preguntas> createState() => _PreguntasState();
}

class _PreguntasState extends State<Preguntas> {
  int contador = 0;

  void SiguientePregunta() {
    setState(() {
      if (contador < 7) {
        contador++;
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
            'Otro',
          ],
        );
      case 1:
        return const ObjPreguntas(
          pregunta: '¿Cuál es tu color favorito?',
          opciones: [
            'Rojo',
            'Azul',
            'Verde',
            'Amarillo',
            'Blanco',
            'Negro',
            'Otro',
          ],
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
            'Otro',
          ],
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
            'Otro',
          ],
        );
      case 4:
        return const ObjPreguntas(
          pregunta: '¿Cuál es tu deporte favorito?',
          opciones: [
            'Fútbol',
            'Baloncesto',
            'Tenis',
            'Natación',
            'Ciclismo',
            'Otro',
          ],
        );
      case 5:
        return const ObjPreguntas(
          pregunta: '¿Cuál es tu animal favorito?',
          opciones: [
            'Perro',
            'Gato',
            'Pájaro',
            'Conejo',
            'León',
            'Mariposa',
            'Otro',
          ],
        );
      case 6:
        return const ObjPreguntas(
          pregunta: '¿Cuál es tu libro de la biblia favorito?',
          opciones: ['Daniel', 'Cantáres', 'Proverbios', 'Salmos', 'Otro'],
        );
      default:
        return const Center(child: Text('¡Formulario completado!'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 226, 185),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Pregunta ${contador + 1}'),
        backgroundColor: const Color.fromARGB(255, 248, 226, 185),
        elevation: 0,
      ),
      body: Center(
        child: Cuadrado(
          child: SingleChildScrollView(
            child: Column(
              children: [
                obtenerPregunta(),
                const SizedBox(height: 20),
                BotonSiguiente(
                  texto: 'Siguiente',
                  onPressed: SiguientePregunta,
                  color: const Color.fromARGB(255, 248, 226, 185),
                  textColor: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
