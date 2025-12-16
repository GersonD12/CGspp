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
  List<List<PreguntaDTO>> _preguntasAgrupadas =
      []; // Lista de bloques: cada bloque puede ser una pregunta o un grupo de múltiples
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
      _preguntasPorGrupo =
          resultado['preguntasPorGrupo'] as Map<String, List<PreguntaDTO>>;

      // Agrupar preguntas múltiples de la misma sección
      _preguntasAgrupadas = _agruparPreguntasMultiples(_preguntas);

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

  /// Agrupa las preguntas múltiples de la misma sección
  /// Todas las preguntas múltiples de una sección se agrupan juntas y se ordenan por 'orden'
  /// Las preguntas no múltiples mantienen su posición original relativa
  List<List<PreguntaDTO>> _agruparPreguntasMultiples(
    List<PreguntaDTO> preguntas,
  ) {
    if (preguntas.isEmpty) return [];

    // 1. Agrupar todas las preguntas múltiples por sección y ordenarlas
    final Map<String, List<PreguntaDTO>> multiplesPorSeccion = {};
    for (final pregunta in preguntas) {
      if (pregunta.tipo.toLowerCase().trim() == 'multiple') {
        multiplesPorSeccion
            .putIfAbsent(pregunta.grupoId, () => [])
            .add(pregunta);
      }
    }

    // Ordenar múltiples dentro de cada sección por 'orden'
    for (final lista in multiplesPorSeccion.values) {
      lista.sort((a, b) => a.orden.compareTo(b.orden));
    }

    // 2. Construir lista final: cuando encontramos la primera múltiple de una sección,
    // agregamos todas las múltiples de esa sección agrupadas
    final List<List<PreguntaDTO>> grupos = [];
    final Set<String> seccionesMultiplesProcesadas = {};

    for (final pregunta in preguntas) {
      final esMultiple = pregunta.tipo.toLowerCase().trim() == 'multiple';

      if (esMultiple) {
        // Primera vez que encontramos una múltiple de esta sección
        if (!seccionesMultiplesProcesadas.contains(pregunta.grupoId)) {
          grupos.add(multiplesPorSeccion[pregunta.grupoId]!);
          seccionesMultiplesProcesadas.add(pregunta.grupoId);
        }
        // Si ya procesamos esta sección, saltamos esta pregunta (ya está en el grupo)
      } else {
        // Pregunta no múltiple: agregar individualmente
        grupos.add([pregunta]);
      }
    }

    return grupos;
  }

  Future<void> _loadRespuestasGuardadas() async {
    if (_preguntas.isEmpty) return;

    final preguntasActivasIds = _preguntas.map((p) => p.idpregunta).toSet(); // Usar idpregunta
    final useCase = CargarRespuestasGuardadasUseCase(ref: ref);
    await useCase.execute(preguntasActivasIds: preguntasActivasIds);
  }

  /// Obtiene el bloque actual de preguntas (puede ser una sola o un grupo de múltiples)
  List<PreguntaDTO> _getBloqueActual() {
    if (_preguntasAgrupadas.isEmpty || contador >= _preguntasAgrupadas.length) {
      return [];
    }
    return _preguntasAgrupadas[contador];
  }

  void _continuarASiguienteSeccion() {
    setState(() {
      if (_mostrarPantallaInicial) {
        _mostrarPantallaInicial = false;
      } else {
        // Avanzar a la siguiente sección
        if (_seccionCompletadaId != null) {
          final siguienteSeccionId =
              PreguntasNavigationHelper.getSiguienteSeccion(
                seccionActualId: _seccionCompletadaId!,
                ordenSecciones: _ordenSecciones,
              );

          if (siguienteSeccionId != null) {
            // Encontrar el primer bloque de la siguiente sección
            final indicePrimerBloque = _preguntasAgrupadas.indexWhere(
              (bloque) =>
                  bloque.isNotEmpty &&
                  bloque.first.grupoId == siguienteSeccionId,
            );
            if (indicePrimerBloque != -1) {
              contador = indicePrimerBloque;
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
      final indiceUltimaPregunta =
          PreguntasNavigationHelper.getIndiceUltimaPreguntaSeccion(
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
        final indiceUltimaPregunta =
            PreguntasNavigationHelper.getIndiceUltimaPreguntaSeccion(
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
        respuestasMap[respuesta.idpregunta] = respuesta; // Usar idpregunta como clave
      }
      final seccionState = RespuestasState(respuestas: respuestasMap);

      final repository = getIt<RespuestasRepository>();
      await repository.uploadRespuestas(user.id, seccionState);
    } catch (e) {
      // No mostrar error al usuario para no interrumpir el flujo
    }
  }

  void siguientePregunta() async {
    if (contador >= _preguntasAgrupadas.length - 1) return;

    final bloqueActual = _getBloqueActual();
    if (bloqueActual.isEmpty) return;

    final preguntaActual = bloqueActual.first;
    final grupoIdActual = preguntaActual.grupoId;

    // Verificar si el siguiente bloque es de otra sección
    if (contador < _preguntasAgrupadas.length - 1) {
      final siguienteBloque = _preguntasAgrupadas[contador + 1];
      if (siguienteBloque.isNotEmpty &&
          siguienteBloque.first.grupoId != grupoIdActual) {
        // Cambiamos de sección, guardar y mostrar pantalla intermedia
        await _guardarRespuestasDeSeccion(grupoIdActual);
        setState(() {
          _mostrandoPantallaIntermedia = true;
          _seccionCompletadaId = grupoIdActual;
        });
        return;
      }
    }

    // Verificar si es el último bloque de la sección actual
    bool esUltimoBloqueSeccion = true;
    for (int i = contador + 1; i < _preguntasAgrupadas.length; i++) {
      final bloque = _preguntasAgrupadas[i];  
      if (bloque.isNotEmpty && bloque.first.grupoId == grupoIdActual) {
        esUltimoBloqueSeccion = false;
        break;
      }
    }

    if (esUltimoBloqueSeccion) {
      // Estamos en el último bloque de la sección
      await _guardarRespuestasDeSeccion(grupoIdActual);
      setState(() {
        _mostrandoPantallaIntermedia = true;
        _seccionCompletadaId = grupoIdActual;
      });
    } else {
      // Avanzar al siguiente bloque
      setState(() {
        contador++;
      });
    }
  }

  void anteriorPregunta() async {
    if (contador == 0) return;

    final bloqueActual = _getBloqueActual();
    if (bloqueActual.isEmpty) return;

    final preguntaActual = bloqueActual.first;

    // Verificar si el bloque anterior es de otra sección
    if (contador > 0) {
      final bloqueAnterior = _preguntasAgrupadas[contador - 1];
      if (bloqueAnterior.isNotEmpty &&
          bloqueAnterior.first.grupoId != preguntaActual.grupoId) {
        // Cambiamos de sección, mostrar pantalla intermedia
        setState(() {
          _mostrandoPantallaIntermedia = true;
          _seccionCompletadaId = null;
        });
        return;
      }
    }

    // Verificar si es la primera pregunta de la sección
    final esPrimeraPreguntaDeSeccion =
        PreguntasNavigationHelper.esPrimeraPreguntaDeSeccion(
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

  /// Callbacks para guardar respuestas
  void _onMultipleChanged(
    String preguntaId,
    String grupoId,
    String tipo,
    String descripcion,
    String encabezado,
    String? emoji,
    List<String> respuestas,
    Map<String, String>? opcionesConEmoji,
    Map<String, String>? opcionesConText,
  ) {
    // Buscar la pregunta para obtener su idpregunta
    final pregunta = _preguntas.firstWhere(
      (p) => p.id == preguntaId,
      orElse: () => _preguntas.firstWhere((p) => p.idpregunta == preguntaId),
    );
    
    _controller?.guardarRespuestaUseCase.guardarRespuestaRadio(
      pregunta.idpregunta, // Usar idpregunta en lugar de preguntaId
      grupoId,
      tipo,
      descripcion,
      encabezado,
      emoji,
      respuestas,
      opcionesConEmoji,
      opcionesConText,
      pregunta.id, // Compatibilidad hacia atrás (parámetro posicional)
    );
  }

  void _onTextoChanged(
    String preguntaId,
    String grupoId,
    String tipo,
    String descripcion,
    String encabezado,
    String? emoji,
    String? texto,
  ) {
    // Buscar la pregunta para obtener su idpregunta
    final pregunta = _preguntas.firstWhere(
      (p) => p.id == preguntaId,
      orElse: () => _preguntas.firstWhere((p) => p.idpregunta == preguntaId),
    );
    
    _controller?.guardarRespuestaUseCase.guardarRespuestaTexto(
      pregunta.idpregunta, // Usar idpregunta en lugar de preguntaId
      grupoId,
      tipo,
      descripcion,
      encabezado,
      emoji,
      texto ?? '',
      pregunta.id, // Compatibilidad hacia atrás (parámetro posicional)
    );
  }

  void _onNumeroChanged(
    String preguntaId,
    String grupoId,
    String tipo,
    String descripcion,
    String encabezado,
    String? emoji,
    String? numero,
  ) {
    // Buscar la pregunta para obtener su idpregunta
    final pregunta = _preguntas.firstWhere(
      (p) => p.id == preguntaId,
      orElse: () => _preguntas.firstWhere((p) => p.idpregunta == preguntaId),
    );
    
    _controller?.guardarRespuestaUseCase.guardarRespuestaNumero(
      pregunta.idpregunta, // Usar idpregunta en lugar de preguntaId
      grupoId,
      tipo,
      descripcion,
      encabezado,
      emoji,
      numero ?? '',
      pregunta.id, // Compatibilidad hacia atrás (parámetro posicional)
    );
  }

  void _onImagenChanged(
    String preguntaId,
    String grupoId,
    String tipo,
    String descripcion,
    String encabezado,
    String? emoji,
    List<String> imagenes,
  ) {
    // Buscar la pregunta para obtener su idpregunta
    final pregunta = _preguntas.firstWhere(
      (p) => p.id == preguntaId,
      orElse: () => _preguntas.firstWhere((p) => p.idpregunta == preguntaId),
    );
    
    _controller?.guardarRespuestaUseCase.guardarRespuestaImagenes(
      pregunta.idpregunta, // Usar idpregunta en lugar de preguntaId
      grupoId,
      tipo,
      descripcion,
      encabezado,
      emoji,
      imagenes,
      pregunta.id, // Compatibilidad hacia atrás (parámetro posicional)
    );
  }

  void _onTelefonoChanged(
    String preguntaId,
    String grupoId,
    String tipo,
    String descripcion,
    String encabezado,
    String? emoji,
    String telefono,
  ) {
    // Buscar la pregunta para obtener su idpregunta
    final pregunta = _preguntas.firstWhere(
      (p) => p.id == preguntaId,
      orElse: () => _preguntas.firstWhere((p) => p.idpregunta == preguntaId),
    );
    
    _controller?.guardarRespuestaUseCase.guardarRespuestaTelefono(
      pregunta.idpregunta, // Usar idpregunta en lugar de preguntaId
      grupoId,
      tipo,
      descripcion,
      encabezado,
      emoji,
      telefono, // Número completo con código de país
      pregunta.id, // Compatibilidad hacia atrás (parámetro posicional)
    );
  }

  void _onPaisChanged(
    String preguntaId,
    String grupoId,
    String tipo,
    String descripcion,
    String encabezado,
    String? emoji,
    String codigoPais,
  ) {
    // Buscar la pregunta para obtener su idpregunta
    final pregunta = _preguntas.firstWhere(
      (p) => p.id == preguntaId,
      orElse: () => _preguntas.firstWhere((p) => p.idpregunta == preguntaId),
    );
    
    _controller?.guardarRespuestaUseCase.guardarRespuestaPais(
      pregunta.idpregunta, // Usar idpregunta en lugar de preguntaId
      grupoId,
      tipo,
      descripcion,
      encabezado,
      emoji,
      codigoPais, // Código ISO 3166-1 alpha-2 (ej: "US", "MX", "ES")
      pregunta.id, // Compatibilidad hacia atrás (parámetro posicional)
    );
  }

  void _onFechaChanged(
    String preguntaId,
    String grupoId,
    String tipo,
    String descripcion,
    String encabezado,
    String? emoji,
    String fecha,
  ) {
    // Buscar la pregunta para obtener su idpregunta
    final pregunta = _preguntas.firstWhere(
      (p) => p.id == preguntaId,
      orElse: () => _preguntas.firstWhere((p) => p.idpregunta == preguntaId),
    );
    
    _controller?.guardarRespuestaUseCase.guardarRespuestaFecha(
      pregunta.idpregunta, // Usar idpregunta en lugar de preguntaId
      grupoId,
      tipo,
      descripcion,
      encabezado,
      emoji,
      fecha, // Fecha en formato ISO 8601 (YYYY-MM-DD)
      pregunta.id, // Compatibilidad hacia atrás (parámetro posicional)
    );
  }

  Widget _buildPreguntaWidget() {
    if (_error.isNotEmpty) {
      return Center(
        child: Text(_error, style: const TextStyle(color: Colors.black87)),
      );
    }

    final bloqueActual = _getBloqueActual();
    if (bloqueActual.isEmpty) {
      return const Center(
        child: Text(
          'No hay preguntas para mostrar.',
          style: TextStyle(color: Colors.black87),
        ),
      );
    }

    final respuestasState = ref.watch(respuestasProvider);
    final respuestasMap = {
      for (final r in respuestasState.todasLasRespuestas) r.idpregunta: r,
    };

    // Si hay múltiples preguntas, usar el widget de grupo
    if (bloqueActual.length > 1) {
      return PreguntasMultipleGroupWidget(
        preguntas: bloqueActual,
        respuestasGuardadas: respuestasMap,
        onMultipleChanged: _onMultipleChanged,
        onTextoChanged: _onTextoChanged,
        onNumeroChanged: _onNumeroChanged,
        onImagenChanged: _onImagenChanged,
        onTelefonoChanged: _onTelefonoChanged,
        onPaisChanged: _onPaisChanged,
        onFechaChanged: _onFechaChanged,
      );
    }

    // Una sola pregunta
    final pregunta = bloqueActual.first;
    final respuestaGuardada = respuestasMap[pregunta.idpregunta];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: PreguntaWidgetFactory.create(
        pregunta: pregunta,
        respuestaGuardada: respuestaGuardada,
        onMultipleChanged: _onMultipleChanged,
        onTextoChanged: _onTextoChanged,
        onNumeroChanged: _onNumeroChanged,
        onImagenChanged: _onImagenChanged,
        onTelefonoChanged: _onTelefonoChanged,
        onPaisChanged: _onPaisChanged,
        onFechaChanged: _onFechaChanged,
      ),
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
    } else if (_mostrandoPantallaIntermedia &&
        _seccionCompletadaId == null &&
        contador < _preguntas.length) {
      // Retrocediendo: mostrar la sección actual
      final grupoIdActual = _preguntas[contador].grupoId;
      seccionAMostrar = _secciones[grupoIdActual];
      esRetroceso = true;
      onRetroceder = _retrocederDesdePantallaIntermedia;
    }

    if (seccionAMostrar == null) {
      // En lugar de retornar SizedBox.shrink(), mostrar un mensaje útil
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 248, 226, 185),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 64,
                  color: Color.fromARGB(255, 76, 94, 175),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cargando sección...',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 76, 94, 175),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
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
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.fromARGB(255, 76, 94, 175),
            ),
          ),
        ),
      );
    }

    // Mostrar error si hay alguno
    if (_error.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 248, 226, 185),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error al cargar el formulario',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _error,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = '';
                    });
                    _fetchPreguntasFromFirestore();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_mostrandoPantallaIntermedia || _mostrarPantallaInicial) {
      final pantallaIntermedia = _buildPantallaIntermedia();
      // Si la pantalla intermedia retorna SizedBox.shrink(), mostrar loading
      if (pantallaIntermedia is SizedBox && pantallaIntermedia.width == 0 && pantallaIntermedia.height == 0) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 248, 226, 185),
          body: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 76, 94, 175),
              ),
            ),
          ),
        );
      }
      return pantallaIntermedia;
    }

    final respuestasState = ref.watch(respuestasProvider);
    final bloqueActual = _getBloqueActual();

    // Verificar si todas las preguntas del bloque actual están respondidas
    bool isCurrentQuestionAnswered = false;
    if (bloqueActual.isNotEmpty) {
      if (bloqueActual.length > 1) {
        // Si hay múltiples preguntas en el bloque, verificar que todas estén respondidas
        isCurrentQuestionAnswered = bloqueActual.every((pregunta) {
          return PreguntasProgressHelper.isPreguntaRespondida(
            idpregunta: pregunta.idpregunta, // Usar idpregunta
            respuestasState: respuestasState,
          );
        });
      } else {
        // Solo una pregunta en el bloque
        isCurrentQuestionAnswered =
            PreguntasProgressHelper.isPreguntaRespondida(
              idpregunta: bloqueActual.first.idpregunta, // Usar idpregunta
              respuestasState: respuestasState,
            );
      }
    }

    final grupoIdActual = bloqueActual.isNotEmpty
        ? bloqueActual.first.grupoId
        : '';

    // Calcular el progreso basado en bloques (páginas) dentro de la sección actual
    int indiceBloqueEnSeccion = 0;
    int totalBloquesEnSeccion = 0;

    if (grupoIdActual.isNotEmpty) {
      // Contar bloques de la sección actual
      for (int i = 0; i < _preguntasAgrupadas.length; i++) {
        final bloque = _preguntasAgrupadas[i];
        if (bloque.isNotEmpty && bloque.first.grupoId == grupoIdActual) {
          if (i == contador) {
            indiceBloqueEnSeccion = totalBloquesEnSeccion;
          }
          totalBloquesEnSeccion++;
        }
      }
    }

    final progreso = PreguntasProgressHelper.calcularProgreso(
      indicePreguntaEnSeccion: indiceBloqueEnSeccion,
      totalPreguntasEnSeccion: totalBloquesEnSeccion,
    );

    final titulo = PreguntasProgressHelper.generarTitulo(
      contador: indiceBloqueEnSeccion,
      totalPreguntas: totalBloquesEnSeccion,
      indiceEnSeccion: indiceBloqueEnSeccion,
      totalPreguntasSeccion: totalBloquesEnSeccion,
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
                    showBackButton:
                        false, // Nunca mostrar botón de retroceso en la pantalla de preguntas
                    padding: EdgeInsets.zero, // Sin padding adicional
                    physics:
                        const BouncingScrollPhysics(), // Permitir scroll cuando hay múltiples preguntas
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Título de la sección en el contenido principal
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
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
                        // Contenido de la pregunta sin tarjeta blanca
                        _buildPreguntaWidget(),
                      ],
                    ),
                  ),
                ),
                // Botones de navegación
                PreguntasNavigationButtons(
                  puedeRetroceder: puedeRetroceder,
                  puedeAvanzar: contador < _preguntasAgrupadas.length - 1,
                  preguntaRespondida: isCurrentQuestionAnswered,
                  esUltimaPregunta: contador >= _preguntasAgrupadas.length - 1,
                  onAtras: anteriorPregunta,
                  onSiguiente: siguientePregunta,
                  onFinalizar: () async {
                    final bloqueActual = _getBloqueActual();
                    if (bloqueActual.isNotEmpty) {
                      await _guardarRespuestasDeSeccion(
                        bloqueActual.first.grupoId,
                      );
                    }
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
}
