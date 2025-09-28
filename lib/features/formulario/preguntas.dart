import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Objeto_preguntas.dart';
import 'boton.dart';
import 'Cuadrado.dart';
import 'Progreso.dart';
import 'obj_foto_texto.dart';
import '../../shared/widgets/vertical_view_standard.dart';
import 'questiond_dto.dart';
import 'respuestas.dart';
import 'respuestas_service.dart';
import 'respuestas_indicator.dart';

class Preguntas extends ConsumerStatefulWidget {
  const Preguntas({super.key});

  @override
  ConsumerState<Preguntas> createState() => _PreguntasState();
}

class _PreguntasState extends ConsumerState<Preguntas> {
  int contador = 0;
  List<PreguntaDTO> _preguntas = [];
  bool _isLoading = true; // Indica si se están cargando los datos
  String _error = ''; // Almacena mensaje de error

  @override
  void initState() {
    super.initState();
    _fetchPreguntasFromFirestore();
  }

  Future<void> _fetchPreguntasFromFirestore() async {
    try {
      print('Iniciando carga de preguntas desde Firestore...');

      // Obtener todos los documentos de la colección 'questions'
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('questions')
          .orderBy('orden', descending: false)
          .get();

      print('Documentos encontrados: ${querySnapshot.docs.length}');

      // Mapear los documentos a una lista de DTOs
      _preguntas = querySnapshot.docs.map((doc) {
        print('Procesando documento: ${doc.id}');
        print('Datos del documento: ${doc.data()}');
        return PreguntaDTO.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      print('Preguntas cargadas exitosamente: ${_preguntas.length}');

      setState(() {
        _isLoading = false;
        _error = ''; // Limpiar error si la carga fue exitosa
      });
    } catch (e) {
      print('Error al cargar preguntas: $e');
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar las preguntas: $e';
      });
    }
  }

  void siguientePregunta() {
    setState(() {
      if (contador < _preguntas.length - 1) {
        contador++;
      }
    });
  }

  void anteriorPregunta() {
    setState(() {
      if (contador > 0) {
        contador--;
      }
    });
  }

  Widget obtenerPregunta() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(child: Text(_error));
    }
    if (_preguntas.isEmpty) {
      return const Center(child: Text('No hay preguntas para mostrar.'));
    }

    final preguntaActual = _preguntas[contador];
    final preguntaId = 'pregunta_${contador + 1}';
    final respuestasState = ref.watch(respuestasProvider);
    final respuestaGuardadaObjeto = respuestasState.todasLasRespuestas
        .firstWhere(
          (r) => r.preguntaId == preguntaId,
          orElse: () => Respuesta(
            preguntaId: '',
            tipoPregunta: '',
            descripcionPregunta: '',
            fechaRespuesta: DateTime.now(),
          ),
        );

    final String? respuestaActual =
        respuestaGuardadaObjeto.respuestaOpciones?.first;
    print(
      'DEBUG: Pregunta ID: $preguntaId, Respuesta cargada: $respuestaActual',
    );

    // Usar un switch para manejar diferentes tipos de preguntas
    print('Tipo de pregunta: "${preguntaActual.tipo}"');
    print('Opciones: ${preguntaActual.opciones}');

    switch (preguntaActual.tipo.toLowerCase().trim()) {
      case 'radio':
      case 'opcion_multiple':
      case 'multiple':
        return ObjPreguntas(
          pregunta: preguntaActual.descripcion,
          opciones: preguntaActual.opciones,
          allowCustomOption: preguntaActual.allowCustomOption,
          customOptionLabel: preguntaActual.customOptionLabel,
          respuestaActual: respuestaActual,
          onRespuestaChanged: (respuesta) {
            RespuestasService.guardarRespuestaRadio(
              ref,
              preguntaId,
              preguntaActual.tipo,
              preguntaActual.descripcion,
              respuesta,
            );
          },
        );

      case 'foto_texto':
      case 'foto':
      case 'imagen_texto':
      case 'imput':
      case 'texto_imagen':
        return ObjFotoTexto(
          titulo: preguntaActual.descripcion,
          textoPlaceholder: 'Escribe tu nombre...',
          lineasTexto: 1,
          onFotoChanged: (imagen) {
            if (imagen != null) {
              print('Imagen seleccionada: ${imagen.path}');
              RespuestasService.guardarRespuestaImagen(
                ref,
                preguntaId,
                preguntaActual.tipo,
                preguntaActual.descripcion,
                imagen.path,
              );
            }
          },
          onTextoChanged: (texto) {
            RespuestasService.guardarRespuestaTexto(
              ref,
              preguntaId,
              preguntaActual.tipo,
              preguntaActual.descripcion,
              texto,
            );
          },
        );
      default:
        return Column(
          children: [
            Text('Tipo de pregunta no reconocido: "${preguntaActual.tipo}"'),
            const SizedBox(height: 10),
            Text('Descripción: ${preguntaActual.descripcion}'),
            const SizedBox(height: 10),
            Text('Opciones: ${preguntaActual.opciones}'),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el estado de las respuestas
    final respuestasState = ref.watch(respuestasProvider);

    // Verifica si la pregunta actual ha sido respondida
    final preguntaId = 'pregunta_${contador + 1}';
    final isCurrentQuestionAnswered = respuestasState.todasLasRespuestas.any((
      r,
    ) {
      if (r.preguntaId != preguntaId) return false;
      // Para radio/opción múltiple, verifica que haya una selección no vacía
      if (r.respuestaOpciones?.isNotEmpty ?? false) {
        return r.respuestaOpciones!.first.isNotEmpty;
      }
      // Para texto, verifica que no esté vacío
      if (r.respuestaTexto?.isNotEmpty ?? false) {
        return true;
      }
      // Para imagen, verifica que haya una ruta
      if (r.respuestaImagen?.isNotEmpty ?? false) {
        return true;
      }
      return false;
    });

    // Calcular el progreso basado en la pregunta actual
    double progreso = _preguntas.isNotEmpty
        ? contador / _preguntas.length
        : 0.0;

    return VerticalViewStandardScrollable(
      title: contador >= _preguntas.length - 1
          ? '¡Formulario completado!'
          : 'Pregunta ${contador + 1} de ${_preguntas.length}',
      headerColor: const Color.fromARGB(255, 248, 226, 185),
      foregroundColor: Colors.black,
      backgroundColor: const Color.fromARGB(
        255,
        248,
        226,
        185,
      ), // Color de toda la pantalla
      centerTitle: true,
      showBackButton: false, // Deshabilitar el botón de retroceso
      child: Column(
        children: [
          const SizedBox(height: 20), // Espacio arriba
          // Barra de progreso debajo del título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ProgresoAnimado(
              progress: progreso,
              color: const Color.fromARGB(255, 76, 94, 175),
              height: 25.0,
              backgroundColor: const Color.fromARGB(255, 226, 219, 204),
              borderRadius: BorderRadius.circular(15.0),
              duration: const Duration(milliseconds: 300),
            ),
          ),
          const SizedBox(height: 60), // Espacio entre progreso y contenido
          Center(
            child: Cuadrado(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        contador > 0
                            ? BotonSiguiente(
                                onPressed: contador > 0
                                    ? anteriorPregunta
                                    : () {},
                                icon: Icons.arrow_back_ios_outlined,
                                texto: '', // Solo icono
                                color: const Color.fromARGB(255, 248, 226, 185),
                                textColor: const Color.fromARGB(255, 0, 0, 0),
                                elevation: 4.0,
                                height: 40,
                                width: 40,
                              )
                            : const SizedBox(
                                width: 56,
                              ), // Espacio si no hay botón
                      ],
                    ),
                    obtenerPregunta(),
                    const SizedBox(height: 10),
                    // Indicador de respuestas guardadas
                    const RespuestasIndicator(),

                    // Progreso de respuestas
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BotonSiguiente(
                          texto: contador >= _preguntas.length - 1
                              ? 'Ver respuestas'
                              : 'Siguiente',
                          onPressed: contador < _preguntas.length - 1
                              ? (isCurrentQuestionAnswered
                                    ? siguientePregunta
                                    : () {}) // función vacía si no hay respuesta
                              : () {
                                  // Finalizar formulario usando el servicio
                                  RespuestasService.finalizarFormulario(
                                    context,
                                    respuestasState,
                                  );
                                },
                          color:
                              (contador < _preguntas.length - 1 &&
                                  !isCurrentQuestionAnswered)
                              ? const Color.fromARGB(255, 235, 213, 172)
                              : const Color.fromARGB(255, 248, 226, 185),
                          icon: contador < _preguntas.length - 1
                              ? Icons.arrow_forward_ios_outlined
                              : Icons.check_rounded,
                          elevation:
                              (contador < _preguntas.length - 1 &&
                                  !isCurrentQuestionAnswered)
                              ? 0.0
                              : 5.0,
                          textColor:
                              (contador < _preguntas.length - 1 &&
                                  !isCurrentQuestionAnswered)
                              ? const Color.fromARGB(255, 0, 0, 0)
                              : const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 16,
                          width: 150,
                          height: 60,
                        ),
                      ],
                    ),
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
