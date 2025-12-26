import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/formulario/presentation/helpers/helpers.dart';

/// Controller para manejar la navegación entre preguntas y secciones
class PreguntasNavigationController {
  final List<List<PreguntaDTO>> _preguntasAgrupadas;
  final List<PreguntaDTO> _preguntas;
  final Map<String, List<PreguntaDTO>> _preguntasPorGrupo;
  final List<String> _ordenSecciones;
  final Map<String, SeccionDTO> _secciones;

  int _contador = 0;
  bool _mostrandoPantallaIntermedia = false;
  String? _seccionCompletadaId;
  bool _mostrarPantallaInicial = true;

  PreguntasNavigationController({
    required List<List<PreguntaDTO>> preguntasAgrupadas,
    required List<PreguntaDTO> preguntas,
    required Map<String, List<PreguntaDTO>> preguntasPorGrupo,
    required List<String> ordenSecciones,
    required Map<String, SeccionDTO> secciones,
  })  : _preguntasAgrupadas = preguntasAgrupadas,
        _preguntas = preguntas,
        _preguntasPorGrupo = preguntasPorGrupo,
        _ordenSecciones = ordenSecciones,
        _secciones = secciones;

  // Getters
  int get contador => _contador;
  bool get mostrandoPantallaIntermedia => _mostrandoPantallaIntermedia;
  String? get seccionCompletadaId => _seccionCompletadaId;
  bool get mostrarPantallaInicial => _mostrarPantallaInicial;

  /// Obtiene el bloque actual de preguntas
  List<PreguntaDTO> getBloqueActual() {
    if (_preguntasAgrupadas.isEmpty || _contador >= _preguntasAgrupadas.length) {
      return [];
    }
    return _preguntasAgrupadas[_contador];
  }

  /// Avanza a la siguiente pregunta
  void siguientePregunta() {
    if (_contador >= _preguntasAgrupadas.length - 1) return;

    final bloqueActual = getBloqueActual();
    if (bloqueActual.isEmpty) return;

    final preguntaActual = bloqueActual.first;
    final grupoIdActual = preguntaActual.grupoId;

    // Verificar si el siguiente bloque es de otra sección
    if (_contador < _preguntasAgrupadas.length - 1) {
      final siguienteBloque = _preguntasAgrupadas[_contador + 1];
      if (siguienteBloque.isNotEmpty &&
          siguienteBloque.first.grupoId != grupoIdActual) {
        // Cambiamos de sección, mostrar pantalla intermedia
        _mostrandoPantallaIntermedia = true;
        _seccionCompletadaId = grupoIdActual;
        return;
      }
    }

    // Verificar si es el último bloque de la sección actual
    bool esUltimoBloqueSeccion = true;
    for (int i = _contador + 1; i < _preguntasAgrupadas.length; i++) {
      final bloque = _preguntasAgrupadas[i];
      if (bloque.isNotEmpty && bloque.first.grupoId == grupoIdActual) {
        esUltimoBloqueSeccion = false;
        break;
      }
    }

    if (esUltimoBloqueSeccion) {
      // Estamos en el último bloque de la sección
      _mostrandoPantallaIntermedia = true;
      _seccionCompletadaId = grupoIdActual;
    } else {
      // Avanzar al siguiente bloque
      _contador++;
    }
  }

  /// Retrocede a la pregunta anterior
  void anteriorPregunta() {
    if (_contador == 0) return;

    final bloqueActual = getBloqueActual();
    if (bloqueActual.isEmpty) return;

    final preguntaActual = bloqueActual.first;

    // Verificar si el bloque anterior es de otra sección
    if (_contador > 0) {
      final bloqueAnterior = _preguntasAgrupadas[_contador - 1];
      if (bloqueAnterior.isNotEmpty &&
          bloqueAnterior.first.grupoId != preguntaActual.grupoId) {
        // Cambiamos de sección, mostrar pantalla intermedia
        _mostrandoPantallaIntermedia = true;
        _seccionCompletadaId = null;
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
      _mostrandoPantallaIntermedia = true;
      _seccionCompletadaId = null;
    } else {
      _contador--;
    }
  }

  /// Continúa a la siguiente sección
  void continuarASiguienteSeccion() {
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
            _contador = indicePrimerBloque;
          }
        }
      }
      _mostrandoPantallaIntermedia = false;
      _seccionCompletadaId = null;
    }
  }

  /// Retrocede desde la pantalla intermedia
  void retrocederDesdePantallaIntermedia() {
    if (_seccionCompletadaId != null) {
      // Retroceder a la última pregunta de la sección que se acaba de completar
      final indiceUltimaPregunta =
          PreguntasNavigationHelper.getIndiceUltimaPreguntaSeccion(
            seccionId: _seccionCompletadaId!,
            preguntas: _preguntas,
            preguntasPorGrupo: _preguntasPorGrupo,
          );

      if (indiceUltimaPregunta != null) {
        _contador = indiceUltimaPregunta;
        _mostrandoPantallaIntermedia = false;
        _seccionCompletadaId = null;
      } else {
        _mostrandoPantallaIntermedia = false;
        _seccionCompletadaId = null;
      }
    } else if (_contador < _preguntas.length) {
      // Retroceder normalmente dentro de la misma sección
      final grupoIdActual = _preguntas[_contador].grupoId;
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
          _contador = indiceUltimaPregunta;
          _mostrandoPantallaIntermedia = false;
          _seccionCompletadaId = null;
        }
      } else {
        _mostrandoPantallaIntermedia = false;
        _seccionCompletadaId = null;
      }
    }
  }

  /// Obtiene la sección para mostrar en la pantalla intermedia
  SeccionDTO? getSeccionParaPantallaIntermedia() {
    if (_mostrarPantallaInicial && _ordenSecciones.isNotEmpty) {
      final primeraSeccionId = _ordenSecciones.first;
      return _secciones[primeraSeccionId];
    } else if (_mostrandoPantallaIntermedia && _seccionCompletadaId != null) {
      // Mostrar la siguiente sección después de completar una
      final siguienteSeccionId = PreguntasNavigationHelper.getSiguienteSeccion(
        seccionActualId: _seccionCompletadaId!,
        ordenSecciones: _ordenSecciones,
      );

      if (siguienteSeccionId == null) {
        return null;
      }

      return _secciones[siguienteSeccionId];
    } else if (_mostrandoPantallaIntermedia &&
        _seccionCompletadaId == null &&
        _contador < _preguntas.length) {
      // Retrocediendo: mostrar la sección actual
      final grupoIdActual = _preguntas[_contador].grupoId;
      return _secciones[grupoIdActual];
    }

    return null;
  }

  /// Verifica si es retroceso en la pantalla intermedia
  bool esRetrocesoEnPantallaIntermedia() {
    return _mostrandoPantallaIntermedia &&
        _seccionCompletadaId == null &&
        _contador < _preguntas.length;
  }

  /// Calcula el progreso de la sección actual
  double calcularProgreso() {
    final bloqueActual = getBloqueActual();
    if (bloqueActual.isEmpty) return 0.0;

    final grupoIdActual = bloqueActual.first.grupoId;

    // Calcular el progreso basado en bloques (páginas) dentro de la sección actual
    int indiceBloqueEnSeccion = 0;
    int totalBloquesEnSeccion = 0;

    if (grupoIdActual.isNotEmpty) {
      // Contar bloques de la sección actual
      for (int i = 0; i < _preguntasAgrupadas.length; i++) {
        final bloque = _preguntasAgrupadas[i];
        if (bloque.isNotEmpty && bloque.first.grupoId == grupoIdActual) {
          if (i == _contador) {
            indiceBloqueEnSeccion = totalBloquesEnSeccion;
          }
          totalBloquesEnSeccion++;
        }
      }
    }

    return PreguntasProgressHelper.calcularProgreso(
      indicePreguntaEnSeccion: indiceBloqueEnSeccion,
      totalPreguntasEnSeccion: totalBloquesEnSeccion,
    );
  }

  /// Genera el título de la sección actual
  String generarTitulo() {
    final bloqueActual = getBloqueActual();
    if (bloqueActual.isEmpty) return '';

    final grupoIdActual = bloqueActual.first.grupoId;

    int indiceBloqueEnSeccion = 0;
    int totalBloquesEnSeccion = 0;

    if (grupoIdActual.isNotEmpty) {
      for (int i = 0; i < _preguntasAgrupadas.length; i++) {
        final bloque = _preguntasAgrupadas[i];
        if (bloque.isNotEmpty && bloque.first.grupoId == grupoIdActual) {
          if (i == _contador) {
            indiceBloqueEnSeccion = totalBloquesEnSeccion;
          }
          totalBloquesEnSeccion++;
        }
      }
    }

    return PreguntasProgressHelper.generarTitulo(
      contador: indiceBloqueEnSeccion,
      totalPreguntas: totalBloquesEnSeccion,
      indiceEnSeccion: indiceBloqueEnSeccion,
      totalPreguntasSeccion: totalBloquesEnSeccion,
      seccionActual: _secciones[grupoIdActual],
    );
  }

  /// Verifica si puede retroceder
  bool puedeRetroceder() => _contador > 0;

  /// Verifica si puede avanzar
  bool puedeAvanzar() => _contador < _preguntasAgrupadas.length - 1;

  /// Verifica si es la última pregunta
  bool esUltimaPregunta() => _contador >= _preguntasAgrupadas.length - 1;
}

