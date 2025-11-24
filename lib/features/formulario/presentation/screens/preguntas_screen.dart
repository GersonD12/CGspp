import 'package:calet/core/di/injection.dart';
import 'package:calet/core/providers/session_provider.dart';
import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/formulario/application/use_cases/use_cases.dart';
import 'package:calet/features/formulario/domain/repositories/respuestas_repository.dart';
import 'package:calet/features/formulario/presentation/controllers/respuestas_controller.dart';
import 'package:calet/features/formulario/presentation/helpers/helpers.dart';
import 'package:calet/features/formulario/presentation/providers/respuestas_provider.dart';
import 'package:calet/features/formulario/presentation/providers/respuestas_state.dart';
import 'package:calet/features/formulario/presentation/widgets/widgets.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreguntasScreen extends ConsumerStatefulWidget {
  const PreguntasScreen({super.key});

  @override
  ConsumerState<PreguntasScreen> createState() => _PreguntasScreenState();
}

class _PreguntasScreenState extends ConsumerState<PreguntasScreen> {
  int contador = 0;
  List<PreguntaDTO> _preguntas = [];
  Map<String, List<PreguntaDTO>> _preguntasPorGrupo = {};
  Map<String, SeccionDTO> _secciones = {};
  List<String> _ordenSecciones = [];
  bool _isLoading = true;
  String _error = '';
  RespuestasController? _controller;
  bool _respuestasCargadas = false;
  bool _mostrandoPantallaIntermedia = false;
  String? _seccionCompletadaId;
  bool _mostrarPantallaInicial = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      _controller = RespuestasController(ref);
      // Cargar preguntas después de que el controller esté inicializado
      _fetchPreguntasFromFirestore();
    }
  }

  Future<void> _fetchPreguntasFromFirestore() async {
    if (_controller == null) return;
    
    try {
      final resultado = await _controller!.obtenerPreguntasUseCase.execute();

      _preguntas = resultado['preguntas'] as List<PreguntaDTO>;
      _secciones = resultado['secciones'] as Map<String, SeccionDTO>;
      _ordenSecciones = resultado['ordenSecciones'] as List<String>;
      _preguntasPorGrupo = resultado['preguntasPorGrupo'] as Map<String, List<PreguntaDTO>>;

      setState(() {
        _isLoading = false;
        _error = '';
        if (_ordenSecciones.isNotEmpty) {
          _mostrarPantallaInicial = true;
        }
      });

      if (!_respuestasCargadas) {
        await _loadRespuestasGuardadas();
        _respuestasCargadas = true;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar las preguntas: $e';
      });
    }
  }

  Future<void> _loadRespuestasGuardadas() async {
    if (_preguntas.isEmpty) return;

    final preguntasActivasIds = _preguntas.map((p) => p.id).toSet();
    final useCase = CargarRespuestasGuardadasUseCase(ref: ref);
    await useCase.execute(preguntasActivasIds: preguntasActivasIds);
  }

  List<PreguntaDTO> _getPreguntasDeSeccionActual() {
    if (_preguntas.isEmpty || contador >= _preguntas.length) {
      return [];
    }
    final grupoIdActual = _preguntas[contador].grupoId;
    return PreguntasProgressHelper.getPreguntasDeSeccion(
      grupoId: grupoIdActual,
      preguntasPorGrupo: _preguntasPorGrupo,
    );
  }

  void _continuarASiguienteSeccion() {
    setState(() {
      if (_mostrarPantallaInicial) {
        _mostrarPantallaInicial = false;
      } else {
        // Avanzar a la siguiente sección
        if (_seccionCompletadaId != null) {
          final siguienteSeccionId = PreguntasNavigationHelper.getSiguienteSeccion(
            seccionActualId: _seccionCompletadaId!,
            ordenSecciones: _ordenSecciones,
          );
          
          if (siguienteSeccionId != null) {
            // Encontrar la primera pregunta de la siguiente sección
            final preguntasSiguienteSeccion = _preguntasPorGrupo[siguienteSeccionId] ?? [];
            if (preguntasSiguienteSeccion.isNotEmpty) {
              final primeraPreguntaSiguiente = preguntasSiguienteSeccion.first;
              final indicePrimeraPregunta = _preguntas.indexWhere(
                (p) => p.id == primeraPreguntaSiguiente.id
              );
              if (indicePrimeraPregunta != -1) {
                contador = indicePrimeraPregunta;
              }
            }
          }
        }
        _mostrandoPantallaIntermedia = false;
        _seccionCompletadaId = null;
      }
    });
  }

  void _retrocederDesdePantallaIntermedia() {
    if (_seccionCompletadaId != null) {
      // Retroceder a la última pregunta de la sección que se acaba de completar
      final indiceUltimaPregunta = PreguntasNavigationHelper.getIndiceUltimaPreguntaSeccion(
        seccionId: _seccionCompletadaId!,
        preguntas: _preguntas,
        preguntasPorGrupo: _preguntasPorGrupo,
      );
      
      if (indiceUltimaPregunta != null) {
        setState(() {
          contador = indiceUltimaPregunta;
          _mostrandoPantallaIntermedia = false;
          _seccionCompletadaId = null;
        });
      } else {
        setState(() {
          _mostrandoPantallaIntermedia = false;
          _seccionCompletadaId = null;
        });
      }
    } else if (contador < _preguntas.length) {
      // Retroceder normalmente dentro de la misma sección
      final grupoIdActual = _preguntas[contador].grupoId;
      final indiceSeccionActual = _ordenSecciones.indexOf(grupoIdActual);
      
      if (indiceSeccionActual > 0) {
        final seccionAnteriorId = _ordenSecciones[indiceSeccionActual - 1];
        final indiceUltimaPregunta = PreguntasNavigationHelper.getIndiceUltimaPreguntaSeccion(
          seccionId: seccionAnteriorId,
          preguntas: _preguntas,
          preguntasPorGrupo: _preguntasPorGrupo,
        );
        
        if (indiceUltimaPregunta != null) {
          setState(() {
            contador = indiceUltimaPregunta;
            _mostrandoPantallaIntermedia = false;
            _seccionCompletadaId = null;
          });
        }
      } else {
        setState(() {
          _mostrandoPantallaIntermedia = false;
          _seccionCompletadaId = null;
        });
      }
    }
  }

  Future<void> _guardarRespuestasDeSeccion(String grupoId) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final respuestasState = ref.read(respuestasProvider);
      final respuestasDeSeccion = respuestasState.todasLasRespuestas
          .where((r) => r.grupoId == grupoId)
          .toList();

      if (respuestasDeSeccion.isEmpty) return;

      final Map<String, RespuestaDTO> respuestasMap = {};
      for (final respuesta in respuestasDeSeccion) {
        respuestasMap[respuesta.preguntaId] = respuesta;
      }
      final seccionState = RespuestasState(respuestas: respuestasMap);

      final repository = getIt<RespuestasRepository>();
      await repository.uploadRespuestas(user.id, seccionState);
    } catch (e) {
      // No mostrar error al usuario para no interrumpir el flujo
    }
  }

  void siguientePregunta() async {
    if (contador >= _preguntas.length - 1) return;
    
    final preguntaActual = _preguntas[contador];
    final grupoIdActual = preguntaActual.grupoId;
    
    // Verificar ANTES de avanzar si estamos en la última pregunta de la sección actual
    final esUltimaPreguntaDeSeccion = PreguntasNavigationHelper.esUltimaPreguntaDeSeccion(
      preguntaActual: preguntaActual,
      preguntasPorGrupo: _preguntasPorGrupo,
    );
    
    if (esUltimaPreguntaDeSeccion) {
      // Estamos en la última pregunta de la sección actual
      // Guardar respuestas y mostrar pantalla intermedia ANTES de avanzar
      await _guardarRespuestasDeSeccion(grupoIdActual);
      
      setState(() {
        _mostrandoPantallaIntermedia = true;
        _seccionCompletadaId = grupoIdActual;
      });
    } else {
      // No es la última pregunta, avanzar normalmente
      setState(() {
        contador++;
      });
    }
  }

  void anteriorPregunta() async {
    if (contador == 0) return;
    
    final preguntaActual = _preguntas[contador];
    final esPrimeraPreguntaDeSeccion = PreguntasNavigationHelper.esPrimeraPreguntaDeSeccion(
      preguntaActual: preguntaActual,
      preguntasPorGrupo: _preguntasPorGrupo,
    );
    
    if (esPrimeraPreguntaDeSeccion) {
      setState(() {
        _mostrandoPantallaIntermedia = true;
        _seccionCompletadaId = null;
      });
    } else {
      setState(() {
        contador--;
      });
    }
  }

  Widget _buildPreguntaWidget() {
    if (_error.isNotEmpty) {
      return Center(
        child: Text(
          _error,
          style: const TextStyle(color: Colors.black87),
        ),
      );
    }
    if (_preguntas.isEmpty) {
      return const Center(
        child: Text(
          'No hay preguntas para mostrar.',
          style: TextStyle(color: Colors.black87),
        ),
      );
    }

    final preguntaActual = _preguntas[contador];
    final preguntaId = preguntaActual.id;
    final grupoId = preguntaActual.grupoId;
    final respuestasState = ref.watch(respuestasProvider);
    final ahora = DateTime.now();
    
    final respuestaGuardadaObjeto = respuestasState.todasLasRespuestas.firstWhere(
      (r) => r.preguntaId == preguntaId,
      orElse: () => RespuestaDTO(
        preguntaId: '',
        grupoId: grupoId,
        tipoPregunta: '',
        descripcionPregunta: '',
        encabezadoPregunta: '',
        createdAt: ahora,
        updatedAt: ahora,
      ),
    );

    return PreguntaWidgetFactory.create(
      pregunta: preguntaActual,
      respuestaGuardada: respuestaGuardadaObjeto,
      onMultipleChanged: (
        preguntaId,
        grupoId,
        tipo,
        descripcion,
        encabezado,
        emoji,
        respuestas,
        opcionesConEmoji,
        opcionesConText,
      ) {
        _controller?.guardarRespuestaUseCase.guardarRespuestaRadio(
          preguntaId,
          grupoId,
          tipo,
          descripcion,
          encabezado,
          emoji,
          respuestas,
          opcionesConEmoji,
          opcionesConText,
        );
      },
      onTextoChanged: (preguntaId, grupoId, tipo, descripcion, encabezado, emoji, texto) {
        _controller?.guardarRespuestaUseCase.guardarRespuestaTexto(
          preguntaId,
          grupoId,
          tipo,
          descripcion,
          encabezado,
          emoji,
          texto,
        );
      },
      onNumeroChanged: (preguntaId, grupoId, tipo, descripcion, encabezado, emoji, numero) {
        _controller?.guardarRespuestaUseCase.guardarRespuestaNumero(
          preguntaId,
          grupoId,
          tipo,
          descripcion,
          encabezado,
          emoji,
          numero,
        );
      },
      onImagenChanged: (preguntaId, grupoId, tipo, descripcion, encabezado, emoji, imagenes) {
        _controller?.guardarRespuestaUseCase.guardarRespuestaImagenes(
          preguntaId,
          grupoId,
          tipo,
          descripcion,
          encabezado,
          emoji,
          imagenes,
        );
      },
    );
  }

  Widget _buildPantallaIntermedia() {
    SeccionDTO? seccionAMostrar;
    bool esRetroceso = false;
    VoidCallback? onRetroceder;
    
    if (_mostrarPantallaInicial && _ordenSecciones.isNotEmpty) {
      final primeraSeccionId = _ordenSecciones.first;
      seccionAMostrar = _secciones[primeraSeccionId];
      // En la pantalla inicial, no hay retroceso
      onRetroceder = null;
    } else if (_mostrandoPantallaIntermedia && _seccionCompletadaId != null) {
      // Mostrar la siguiente sección después de completar una
      final siguienteSeccionId = PreguntasNavigationHelper.getSiguienteSeccion(
        seccionActualId: _seccionCompletadaId!,
        ordenSecciones: _ordenSecciones,
      );
      
      if (siguienteSeccionId == null) {
        // No hay siguiente sección, continuar normalmente
        _continuarASiguienteSeccion();
        return const SizedBox.shrink();
      }
      
      seccionAMostrar = _secciones[siguienteSeccionId];
      // Siempre permitir retroceder a la última pregunta de la sección completada
      onRetroceder = _retrocederDesdePantallaIntermedia;
    } else if (_mostrandoPantallaIntermedia && _seccionCompletadaId == null && contador < _preguntas.length) {
      // Retrocediendo: mostrar la sección actual
      final grupoIdActual = _preguntas[contador].grupoId;
      seccionAMostrar = _secciones[grupoIdActual];
      esRetroceso = true;
      onRetroceder = _retrocederDesdePantallaIntermedia;
    }

    if (seccionAMostrar == null) {
      return const SizedBox.shrink();
    }

    return SeccionIntermediaWidget(
      seccion: seccionAMostrar,
      esRetroceso: esRetroceso,
      mostrarPantallaInicial: _mostrarPantallaInicial,
      onContinuar: _continuarASiguienteSeccion,
      onRetroceder: onRetroceder,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading mientras se cargan las preguntas
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 248, 226, 185),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 76, 94, 175)),
          ),
        ),
      );
    }

    if (_mostrandoPantallaIntermedia || _mostrarPantallaInicial) {
      return _buildPantallaIntermedia();
    }

    final respuestasState = ref.watch(respuestasProvider);
    final preguntaId = contador < _preguntas.length ? _preguntas[contador].id : '';
    final isCurrentQuestionAnswered = PreguntasProgressHelper.isPreguntaRespondida(
      preguntaId: preguntaId,
      respuestasState: respuestasState,
    );

    final preguntasSeccionActual = _getPreguntasDeSeccionActual();
    final grupoIdActual = contador < _preguntas.length ? _preguntas[contador].grupoId : '';
    final preguntaActual = contador < _preguntas.length ? _preguntas[contador] : null;
    
    final indiceEnSeccion = preguntaActual != null
        ? PreguntasProgressHelper.getIndiceEnSeccion(
            pregunta: preguntaActual,
            preguntasSeccion: preguntasSeccionActual,
          )
        : 0;
    
    final progreso = PreguntasProgressHelper.calcularProgreso(
      indicePreguntaEnSeccion: indiceEnSeccion,
      totalPreguntasEnSeccion: preguntasSeccionActual.length,
    );
    
    final totalPreguntasSeccion = preguntasSeccionActual.length;
    final titulo = PreguntasProgressHelper.generarTitulo(
      contador: contador,
      totalPreguntas: _preguntas.length,
      indiceEnSeccion: indiceEnSeccion,
      totalPreguntasSeccion: totalPreguntasSeccion,
      seccionActual: _secciones[grupoIdActual],
    );

    // Puede retroceder si no es la primera pregunta (contador > 0)
    final puedeRetroceder = contador > 0;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 226, 185),
      body: Column(
        children: [
          // Pequeño espacio arriba de la barra de progreso
          const SizedBox(height: 60),
          // Barra de progreso arriba del todo, sin bordes redondeados, ocupa todo el ancho
          SizedBox(
            width: double.infinity,
            child: ProgresoAnimado(
              progress: progreso,
              color: const Color.fromARGB(255, 76, 94, 175),
              height: 10.0,
              backgroundColor: const Color.fromARGB(255, 226, 219, 204),
              borderRadius: BorderRadius.zero, // Sin bordes redondeados
              duration: const Duration(milliseconds: 300),
            ),
          ),
          // AppBar y contenido
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: VerticalViewStandardScrollable(
                    title: '', // Sin título en el AppBar
                    headerColor: const Color.fromARGB(255, 248, 226, 185),
                    foregroundColor: Colors.black,
                    backgroundColor: const Color.fromARGB(255, 248, 226, 185),
                    centerTitle: true,
                    showBackButton: false, // Nunca mostrar botón de retroceso en la pantalla de preguntas
                    padding: EdgeInsets.zero, // Sin padding adicional
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Título de la sección en el contenido principal
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            titulo,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Tarjeta blanca con el contenido de la pregunta
                        Expanded(
                          child: Center(
                            child: Cuadrado(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(16.0),
                                child: _buildPreguntaWidget(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Botones de navegación fuera de la tarjeta, siempre en la parte inferior
                // Respetar el safe area inferior para que no queden muy abajo
                Padding(
                  padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: 16.0 + MediaQuery.of(context).padding.bottom, // Agregar padding del safe area inferior
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón Atrás
                      puedeRetroceder
                          ? BotonSiguiente(
                              onPressed: anteriorPregunta,
                              icon: Icons.arrow_back_ios_outlined,
                              texto: 'Atrás',
                              color: const Color.fromARGB(255, 248, 226, 185),
                              textColor: const Color.fromARGB(255, 0, 0, 0),
                              elevation: 4.0,
                              height: 60,
                              width: 120,
                            )
                          : const SizedBox(width: 120), // Espacio para mantener centrado el botón siguiente
                      // Botón Siguiente
                      BotonSiguiente(
                        texto: contador >= _preguntas.length - 1 ? 'Ver respuestas' : 'Siguiente',
                        onPressed: contador < _preguntas.length - 1
                            ? (isCurrentQuestionAnswered ? siguientePregunta : () {})
                            : () async {
                                if (contador < _preguntas.length) {
                                  final grupoIdActual = _preguntas[contador].grupoId;
                                  await _guardarRespuestasDeSeccion(grupoIdActual);
                                }
                                _controller?.finalizarFormulario(context, respuestasState);
                              },
                        color: (contador < _preguntas.length - 1 && !isCurrentQuestionAnswered)
                            ? const Color.fromARGB(255, 235, 213, 172)
                            : const Color.fromARGB(255, 248, 226, 185),
                        icon: contador < _preguntas.length - 1
                            ? Icons.arrow_forward_ios_outlined
                            : Icons.check_rounded,
                        elevation: (contador < _preguntas.length - 1 && !isCurrentQuestionAnswered) ? 0.0 : 5.0,
                        textColor: const Color.fromARGB(255, 0, 0, 0),
                        fontSize: 16,
                        width: 150,
                        height: 60,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
