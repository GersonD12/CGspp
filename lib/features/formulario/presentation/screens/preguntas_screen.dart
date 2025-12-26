import 'package:calet/core/di/injection.dart';
import 'package:calet/core/providers/session_provider.dart';
import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/formulario/application/use_cases/use_cases.dart';
import 'package:calet/features/formulario/domain/repositories/respuestas_repository.dart';
import 'package:calet/features/formulario/presentation/controllers/respuestas_callbacks_handler.dart';
import 'package:calet/features/formulario/presentation/controllers/respuestas_controller.dart';
import 'package:calet/features/formulario/presentation/controllers/preguntas_navigation_controller.dart';
import 'package:calet/features/formulario/presentation/helpers/helpers.dart';
import 'package:calet/features/formulario/presentation/helpers/formulario_theme_helper.dart';
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
  // Estado de carga
  bool _isLoading = true;
  String _error = '';
  bool _respuestasCargadas = false;

  // Datos del formulario
  List<PreguntaDTO> _preguntas = [];
  List<List<PreguntaDTO>> _preguntasAgrupadas = [];
  Map<String, List<PreguntaDTO>> _preguntasPorGrupo = {};
  Map<String, SeccionDTO> _secciones = {};
  List<String> _ordenSecciones = [];

  // Controllers y handlers
  RespuestasController? _controller;
  PreguntasNavigationController? _navigationController;
  RespuestasCallbacksHandler? _callbacksHandler;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      _controller = RespuestasController(ref);
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
      _preguntasPorGrupo =
          resultado['preguntasPorGrupo'] as Map<String, List<PreguntaDTO>>;

      // Agrupar preguntas múltiples usando el helper
      _preguntasAgrupadas = PreguntasGroupingHelper.agruparPreguntasMultiples(
        _preguntas,
      );

      // Inicializar controllers
      _navigationController = PreguntasNavigationController(
        preguntasAgrupadas: _preguntasAgrupadas,
        preguntas: _preguntas,
        preguntasPorGrupo: _preguntasPorGrupo,
        ordenSecciones: _ordenSecciones,
        secciones: _secciones,
      );

      _callbacksHandler = RespuestasCallbacksHandler(
        controller: _controller!,
        preguntas: _preguntas,
      );

      setState(() {
        _isLoading = false;
        _error = '';
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

    final preguntasActivasIds = _preguntas.map((p) => p.idpregunta).toSet();
    final useCase = CargarRespuestasGuardadasUseCase(ref: ref);
    await useCase.execute(preguntasActivasIds: preguntasActivasIds);
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
        respuestasMap[respuesta.idpregunta] = respuesta;
      }
      final seccionState = RespuestasState(respuestas: respuestasMap);

      final repository = getIt<RespuestasRepository>();
      await repository.uploadRespuestas(user.id, seccionState);
    } catch (e) {
      // No mostrar error al usuario para no interrumpir el flujo
    }
  }

  void _siguientePregunta() async {
    if (_navigationController == null) return;

    final bloqueActual = _navigationController!.getBloqueActual();
    if (bloqueActual.isEmpty) return;

    // Guardar respuestas si cambiamos de sección
    if (_navigationController!.mostrandoPantallaIntermedia &&
        _navigationController!.seccionCompletadaId != null) {
      await _guardarRespuestasDeSeccion(
        _navigationController!.seccionCompletadaId!,
      );
    }

    _navigationController!.siguientePregunta();
    setState(() {});
  }

  void _anteriorPregunta() {
    if (_navigationController == null) return;
    _navigationController!.anteriorPregunta();
    setState(() {});
  }

  void _continuarASiguienteSeccion() {
    if (_navigationController == null) return;
    _navigationController!.continuarASiguienteSeccion();
    setState(() {});
  }

  void _retrocederDesdePantallaIntermedia() {
    if (_navigationController == null) return;
    _navigationController!.retrocederDesdePantallaIntermedia();
    setState(() {});
  }

  Widget _buildPantallaIntermedia() {
    if (_navigationController == null) {
      return const PreguntasLoadingWidget();
    }

    final seccionAMostrar = _navigationController!.getSeccionParaPantallaIntermedia();
    if (seccionAMostrar == null) {
      return const PreguntasLoadingWidget();
    }

    return SeccionIntermediaWidget(
      seccion: seccionAMostrar,
      esRetroceso: _navigationController!.esRetrocesoEnPantallaIntermedia(),
      mostrarPantallaInicial: _navigationController!.mostrarPantallaInicial,
      onContinuar: _continuarASiguienteSeccion,
      onRetroceder: _navigationController!.mostrarPantallaInicial
          ? null
          : _retrocederDesdePantallaIntermedia,
    );
  }

  Widget _buildContenidoPrincipal() {
    if (_navigationController == null || _callbacksHandler == null) {
      return const SizedBox.shrink();
    }

    final respuestasState = ref.watch(respuestasProvider);
    final bloqueActual = _navigationController!.getBloqueActual();

    // Verificar si todas las preguntas del bloque actual están respondidas
    bool isCurrentQuestionAnswered = false;
    if (bloqueActual.isNotEmpty) {
      if (bloqueActual.length > 1) {
        isCurrentQuestionAnswered = bloqueActual.every((pregunta) {
          return PreguntasProgressHelper.isPreguntaRespondida(
            idpregunta: pregunta.idpregunta,
            respuestasState: respuestasState,
          );
        });
      } else {
        isCurrentQuestionAnswered = PreguntasProgressHelper.isPreguntaRespondida(
          idpregunta: bloqueActual.first.idpregunta,
          respuestasState: respuestasState,
        );
      }
    }

    final respuestasMap = {
      for (final r in respuestasState.todasLasRespuestas) r.idpregunta: r,
    };

    final progreso = _navigationController!.calcularProgreso();
    final titulo = _navigationController!.generarTitulo();

    final formTheme = FormularioThemeHelper.getThemeExtension(context);
    
    return Scaffold(
      backgroundColor: FormularioThemeHelper.getScaffoldBackground(context),
      body: Column(
        children: [
          const SizedBox(height: 60),
          SizedBox(
            width: double.infinity,
            child: ProgresoAnimado(
              progress: progreso,
              color: formTheme.formPrimary,
              height: 10.0,
              backgroundColor: formTheme.formProgressBackground,
              borderRadius: BorderRadius.zero,
              duration: const Duration(milliseconds: 300),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: VerticalViewStandardScrollable(
                    title: '',
                    headerColor: FormularioThemeHelper.getScaffoldBackground(context),
                    foregroundColor: FormularioThemeHelper.getTextColor(context),
                    backgroundColor: FormularioThemeHelper.getScaffoldBackground(context),
                    centerTitle: true,
                    showBackButton: false,
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            titulo,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: FormularioThemeHelper.getTextColor(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 10),
                        PreguntasContentWidget(
                          bloqueActual: bloqueActual,
                          respuestasMap: respuestasMap,
                          callbacksHandler: _callbacksHandler!,
                        ),
                      ],
                    ),
                  ),
                ),
                PreguntasNavigationButtons(
                  puedeRetroceder: _navigationController!.puedeRetroceder(),
                  puedeAvanzar: _navigationController!.puedeAvanzar(),
                  preguntaRespondida: isCurrentQuestionAnswered,
                  esUltimaPregunta: _navigationController!.esUltimaPregunta(),
                  onAtras: _anteriorPregunta,
                  onSiguiente: _siguientePregunta,
                  onFinalizar: () async {
                    final bloqueActual = _navigationController!.getBloqueActual();
                    if (bloqueActual.isNotEmpty) {
                      await _guardarRespuestasDeSeccion(
                        bloqueActual.first.grupoId,
                      );
                    }
                    if (!mounted) return;
                    _controller?.finalizarFormulario(context, respuestasState);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading mientras se cargan las preguntas
    if (_isLoading) {
      return const PreguntasLoadingWidget();
    }

    // Mostrar error si hay alguno
    if (_error.isNotEmpty) {
      return PreguntasErrorWidget(
        error: _error,
        onRetry: () {
          setState(() {
            _isLoading = true;
            _error = '';
          });
          _fetchPreguntasFromFirestore();
        },
      );
    }

    // Mostrar pantalla intermedia si corresponde
    if (_navigationController != null &&
        (_navigationController!.mostrandoPantallaIntermedia ||
            _navigationController!.mostrarPantallaInicial)) {
      return _buildPantallaIntermedia();
    }

    // Mostrar contenido principal
    return _buildContenidoPrincipal();
  }
}
