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

  Future<void> _verificarYGuardarSeccionCompletada(String grupoIdAnterior, {bool esAvance = true}) async {
    if (contador >= _preguntas.length) return;
    
    final grupoIdActual = _preguntas[contador].grupoId;
    
    if (PreguntasNavigationHelper.seCompletoSeccion(
      grupoIdAnterior: grupoIdAnterior,
      grupoIdActual: grupoIdActual,
    )) {
      await _guardarRespuestasDeSeccion(grupoIdAnterior);
      
      if (esAvance) {
        setState(() {
          _mostrandoPantallaIntermedia = true;
          _seccionCompletadaId = grupoIdAnterior;
        });
      }
    }
  }

  void _continuarASiguienteSeccion() {
    setState(() {
      if (_mostrarPantallaInicial) {
        _mostrarPantallaInicial = false;
      } else {
        _mostrandoPantallaIntermedia = false;
        _seccionCompletadaId = null;
      }
    });
  }

  void _retrocederDesdePantallaIntermedia() {
    if (contador == 0) return;
    
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
    
    final grupoIdAnterior = _preguntas[contador].grupoId;
    
    setState(() {
      contador++;
    });

    await _verificarYGuardarSeccionCompletada(grupoIdAnterior, esAvance: true);
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
    
    if (_mostrarPantallaInicial && _ordenSecciones.isNotEmpty) {
      final primeraSeccionId = _ordenSecciones.first;
      seccionAMostrar = _secciones[primeraSeccionId];
    } else if (_mostrandoPantallaIntermedia && _seccionCompletadaId != null) {
      final siguienteSeccionId = PreguntasNavigationHelper.getSiguienteSeccion(
        seccionActualId: _seccionCompletadaId!,
        ordenSecciones: _ordenSecciones,
      );
      
      if (siguienteSeccionId == null) {
        _continuarASiguienteSeccion();
        return const SizedBox.shrink();
      }
      
      seccionAMostrar = _secciones[siguienteSeccionId];
    } else if (_mostrandoPantallaIntermedia && _seccionCompletadaId == null && contador < _preguntas.length) {
      final grupoIdActual = _preguntas[contador].grupoId;
      seccionAMostrar = _secciones[grupoIdActual];
      esRetroceso = true;
    }

    if (seccionAMostrar == null) {
      return const SizedBox.shrink();
    }

    return SeccionIntermediaWidget(
      seccion: seccionAMostrar,
      esRetroceso: esRetroceso,
      mostrarPantallaInicial: _mostrarPantallaInicial,
      onContinuar: _continuarASiguienteSeccion,
      onRetroceder: esRetroceso && !_mostrarPantallaInicial ? _retrocederDesdePantallaIntermedia : null,
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

    final esPrimeraPreguntaPrimeraSeccion = PreguntasProgressHelper.esPrimeraPreguntaPrimeraSeccion(
      contador: contador,
      preguntas: _preguntas,
      ordenSecciones: _ordenSecciones,
    );

    final puedeRetroceder = contador > 0 || 
        PreguntasNavigationHelper.getIndiceUltimaPreguntaSeccionAnterior(
          contador: contador,
          preguntas: _preguntas,
          preguntasPorGrupo: _preguntasPorGrupo,
          ordenSecciones: _ordenSecciones,
        ) != null;

    return VerticalViewStandardScrollable(
      title: titulo,
      headerColor: const Color.fromARGB(255, 248, 226, 185),
      foregroundColor: Colors.black,
      backgroundColor: const Color.fromARGB(255, 248, 226, 185),
      centerTitle: true,
      showBackButton: esPrimeraPreguntaPrimeraSeccion,
      child: Column(
        children: [
          const SizedBox(height: 20),
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
          const SizedBox(height: 60),
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
                        puedeRetroceder
                            ? BotonSiguiente(
                                onPressed: anteriorPregunta,
                                icon: Icons.arrow_back_ios_outlined,
                                texto: '',
                                color: const Color.fromARGB(255, 248, 226, 185),
                                textColor: const Color.fromARGB(255, 0, 0, 0),
                                elevation: 4.0,
                                height: 40,
                                width: 40,
                              )
                            : const SizedBox(width: 56),
                      ],
                    ),
                    _buildPreguntaWidget(),
                    const SizedBox(height: 10),
                    const RespuestasIndicator(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
