import 'package:calet/features/formulario/presentation/widgets/obj_numero.dart';
import 'package:calet/features/formulario/presentation/widgets/widgets.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';
import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/formulario/presentation/providers/respuestas_provider.dart';
import 'package:calet/features/formulario/presentation/providers/respuestas_state.dart';
import 'package:calet/features/formulario/presentation/controllers/respuestas_controller.dart';
import 'package:calet/core/providers/session_provider.dart';
import 'package:calet/core/di/injection.dart';
import 'package:calet/features/formulario/domain/repositories/respuestas_repository.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreguntasScreen extends ConsumerStatefulWidget {
  const PreguntasScreen({super.key});

  @override
  ConsumerState<PreguntasScreen> createState() => _PreguntasScreenState();
}

class _PreguntasScreenState extends ConsumerState<PreguntasScreen> {
  int contador = 0;
  List<PreguntaDTO> _preguntas = [];
  Map<String, List<PreguntaDTO>> _preguntasPorGrupo = {}; // Preguntas agrupadas por grupoId
  Map<String, SeccionDTO> _secciones = {}; // Información de las secciones por grupoId
  List<String> _ordenSecciones = []; // Orden de las secciones según el campo orden
  bool _isLoading = true; // Indica si se están cargando los datos
  String _error = ''; // Almacena mensaje de error
  late RespuestasController _controller; // Controlador para las respuestas
  bool _respuestasCargadas =
      false; // Flag para evitar cargar respuestas múltiples veces
  bool _mostrandoPantallaIntermedia = false; // Flag para mostrar pantalla intermedia
  String? _seccionCompletadaId; // ID de la sección que se acaba de completar
  bool _mostrarPantallaInicial = true; // Flag para mostrar pantalla inicial de la primera sección

  @override
  void initState() {
    super.initState();
    _fetchPreguntasFromFirestore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = RespuestasController(ref);
    // Las respuestas se cargarán después de que las preguntas estén listas
    // Ver _fetchPreguntasFromFirestore para el momento exacto
  }

  Future<void> _fetchPreguntasFromFirestore() async {
    try {
      // Lista para almacenar todas las preguntas de todos los grupos
      List<PreguntaDTO> todasLasPreguntas = [];
      Map<String, SeccionDTO> seccionesTemp = {};

      // Intentar obtener el documento 'questions' que contiene todas las secciones
      final questionsDoc = await FirebaseFirestore.instance
          .collection('questions')
          .doc('questions')
          .get();

      if (questionsDoc.exists) {
        // Nuevo formato: documento único con estructura anidada
        final questionsData = questionsDoc.data();
        if (questionsData != null && questionsData.containsKey('questions')) {
          final sectionsMap = questionsData['questions'] as Map<String, dynamic>;
          
          // Procesar cada sección
          for (final sectionEntry in sectionsMap.entries) {
            final sectionId = sectionEntry.key;
            final sectionData = sectionEntry.value as Map<String, dynamic>;
            
            // Crear SeccionDTO
            final seccionDTO = SeccionDTO.fromMap(sectionId, sectionData);
            seccionesTemp[sectionId] = seccionDTO;
            
            // Obtener las preguntas de la subcolección
            final subcollections = sectionData['_subcollections'] as Map<String, dynamic>?;
            if (subcollections != null) {
              final questionsSubcollection = subcollections['questions'] as Map<String, dynamic>?;
              if (questionsSubcollection != null) {
                // Procesar cada pregunta
                for (final questionEntry in questionsSubcollection.entries) {
                  final questionId = questionEntry.key;
                  final questionData = questionEntry.value as Map<String, dynamic>;
                  
                  // Solo procesar preguntas activas (estado == true)
                  final estado = questionData['estado'] as bool? ?? true;
                  if (!estado) continue;
                  
                  final pregunta = PreguntaDTO.fromMap(
                    questionId,
                    sectionId,
                    questionData,
                  );
                  todasLasPreguntas.add(pregunta);
                }
              }
            }
          }
        }
      } else {
        // Formato antiguo: subcolecciones de Firestore
        final QuerySnapshot gruposSnapshot = await FirebaseFirestore.instance
            .collection('questions')
            .get();

        // Para cada documento (grupo), obtener su información y subcolección 'questions'
        final List<Future<void>> futures = gruposSnapshot.docs.map((grupoDoc) async {
          try {
            // Cargar información de la sección (titulo, descripcion, orden)
            final seccionData = grupoDoc.data() as Map<String, dynamic>;
            final seccionDTO = SeccionDTO.fromMap(
              grupoDoc.id,
              seccionData,
            );
            seccionesTemp[grupoDoc.id] = seccionDTO;
            
            // Obtener la subcolección 'questions' de este grupo
            final QuerySnapshot preguntasSnapshot = await grupoDoc.reference
                .collection('questions')
                .get();

            // Mapear las preguntas de esta subcolección a DTOs
            final preguntasDelGrupo = preguntasSnapshot.docs.map((preguntaDoc) {
              final preguntaData = preguntaDoc.data() as Map<String, dynamic>;
              
              // Solo procesar preguntas activas (estado == true)
              final estado = preguntaData['estado'] as bool? ?? true;
              if (!estado) return null;
              
              final pregunta = PreguntaDTO.fromMap(
                preguntaDoc.id,
                grupoDoc.id, // Pasar el ID del grupo
                preguntaData,
              );
              
              return pregunta;
            }).where((p) => p != null).cast<PreguntaDTO>().toList();

            // Agregar las preguntas de este grupo a la lista total
            todasLasPreguntas.addAll(preguntasDelGrupo);
          } catch (e) {
            // Si hay un error al obtener las preguntas de un grupo, continuar con los demás
          }
        }).toList();

        // Esperar a que todas las consultas se completen
        await Future.wait(futures);
      }

      // Ordenar secciones por el campo orden
      final seccionesOrdenadas = seccionesTemp.values.toList()
        ..sort((a, b) => a.orden.compareTo(b.orden));
      
      _ordenSecciones = seccionesOrdenadas.map((s) => s.id).toList();
      _secciones = seccionesTemp;

      // Ordenar preguntas según el orden de las secciones y luego por orden dentro de cada sección
      final preguntasOrdenadas = <PreguntaDTO>[];
      for (final grupoId in _ordenSecciones) {
        final preguntasDelGrupo = todasLasPreguntas
            .where((p) => p.grupoId == grupoId)
            .toList()
          ..sort((a, b) => a.orden.compareTo(b.orden));
        preguntasOrdenadas.addAll(preguntasDelGrupo);
      }

      // Asignar todas las preguntas ordenadas a la lista del estado
      _preguntas = preguntasOrdenadas;

      // Agrupar preguntas por grupoId para facilitar el cálculo de progreso por sección
      _preguntasPorGrupo = {};
      for (final pregunta in _preguntas) {
        if (!_preguntasPorGrupo.containsKey(pregunta.grupoId)) {
          _preguntasPorGrupo[pregunta.grupoId] = [];
        }
        _preguntasPorGrupo[pregunta.grupoId]!.add(pregunta);
      }

      setState(() {
        _isLoading = false;
        _error = ''; // Limpiar error si la carga fue exitosa
        // Mostrar pantalla inicial de la primera sección si hay secciones
        if (_ordenSecciones.isNotEmpty) {
          _mostrarPantallaInicial = true;
        }
      });

      // Cargar respuestas guardadas después de que las preguntas estén cargadas
      // Esto asegura que solo se carguen respuestas de preguntas activas
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

  /// Carga las respuestas guardadas del usuario desde Firestore
  /// Solo carga respuestas de preguntas que están activas (estado == true)
  Future<void> _loadRespuestasGuardadas() async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        return;
      }

      // Esperar a que las preguntas estén cargadas para poder filtrar
      if (_preguntas.isEmpty) {
        return;
      }

      // Crear un Set con los IDs de las preguntas activas para filtrado rápido
      final preguntasActivasIds = _preguntas.map((p) => p.id).toSet();
      
      final repository = getIt<RespuestasRepository>();
      final respuestasState = await repository.downloadRespuestas(user.id);

      if (respuestasState != null && respuestasState.totalRespuestas > 0) {
        
        // Cargar solo las respuestas de preguntas que están activas
        final notifier = ref.read(respuestasProvider.notifier);
        for (final respuesta in respuestasState.todasLasRespuestas) {
          // Solo cargar si la pregunta sigue activa
          if (preguntasActivasIds.contains(respuesta.preguntaId)) {
            notifier.agregarRespuesta(
              respuesta.preguntaId,
              respuesta.grupoId,
              respuesta.tipoPregunta,
              respuesta.descripcionPregunta,
              encabezadoPregunta: respuesta.encabezadoPregunta,
              emojiPregunta: respuesta.emojiPregunta,
              respuestaTexto: respuesta.respuestaTexto,
              respuestaImagenes: respuesta.respuestaImagenes,
              respuestaOpciones: respuesta.respuestaOpciones,
              respuestaOpcionesCompletas: respuesta.respuestaOpcionesCompletas,
            );
          }
        }
        
      }
    } catch (e) {
      // No mostrar error al usuario, simplemente continuar sin respuestas previas
    }
  }

  /// Obtiene las preguntas de la sección actual
  List<PreguntaDTO> _getPreguntasDeSeccionActual() {
    if (_preguntas.isEmpty || contador >= _preguntas.length) {
      return [];
    }
    final grupoIdActual = _preguntas[contador].grupoId;
    return _preguntasPorGrupo[grupoIdActual] ?? [];
  }

  /// Verifica si se completó la sección actual al avanzar
  Future<void> _verificarYGuardarSeccionCompletada(String grupoIdAnterior, {bool esAvance = true}) async {
    if (contador >= _preguntas.length) return;
    
    final grupoIdActual = _preguntas[contador].grupoId;
    
    // Si cambió de grupo, guardar las respuestas del grupo anterior
    if (grupoIdAnterior != grupoIdActual && grupoIdAnterior.isNotEmpty) {
      await _guardarRespuestasDeSeccion(grupoIdAnterior);
      
      // Solo mostrar pantalla intermedia si es un avance (no si es retroceso)
      if (esAvance) {
        // Mostrar pantalla intermedia con información de la siguiente sección
        setState(() {
          _mostrandoPantallaIntermedia = true;
          _seccionCompletadaId = grupoIdAnterior;
        });
      }
    }
  }

  /// Continúa a la siguiente sección después de mostrar la pantalla intermedia
  void _continuarASiguienteSeccion() {
    setState(() {
      if (_mostrarPantallaInicial) {
        // Si es la pantalla inicial, ocultarla y mostrar las preguntas
        _mostrarPantallaInicial = false;
      } else {
        // Si es pantalla intermedia entre secciones, ocultarla
        _mostrandoPantallaIntermedia = false;
        _seccionCompletadaId = null;
      }
    });
  }

  /// Retrocede desde la pantalla intermedia a la última pregunta de la sección anterior
  void _retrocederDesdePantallaIntermedia() {
    if (contador == 0) return;
    
    final grupoIdActual = _preguntas[contador].grupoId;
    final indiceSeccionActual = _ordenSecciones.indexOf(grupoIdActual);
    
    if (indiceSeccionActual > 0) {
      // Ir a la última pregunta de la sección anterior
      final seccionAnteriorId = _ordenSecciones[indiceSeccionActual - 1];
      final preguntasSeccionAnterior = _preguntasPorGrupo[seccionAnteriorId] ?? [];
      
      if (preguntasSeccionAnterior.isNotEmpty) {
        final ultimaPreguntaAnterior = preguntasSeccionAnterior.last;
        final indiceUltimaPregunta = _preguntas.indexWhere((p) => p.id == ultimaPreguntaAnterior.id);
        
        if (indiceUltimaPregunta != -1) {
          setState(() {
            contador = indiceUltimaPregunta;
            _mostrandoPantallaIntermedia = false;
            _seccionCompletadaId = null;
          });
        }
      }
    } else {
      // Si es la primera sección, solo ocultar la pantalla intermedia
      setState(() {
        _mostrandoPantallaIntermedia = false;
        _seccionCompletadaId = null;
      });
    }
  }

  /// Guarda las respuestas de una sección específica
  Future<void> _guardarRespuestasDeSeccion(String grupoId) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final respuestasState = ref.read(respuestasProvider);
      
      // Filtrar solo las respuestas de esta sección
      final respuestasDeSeccion = respuestasState.todasLasRespuestas
          .where((r) => r.grupoId == grupoId)
          .toList();

      if (respuestasDeSeccion.isEmpty) return;

      // Crear un RespuestasState temporal solo con las respuestas de esta sección
      final Map<String, RespuestaDTO> respuestasMap = {};
      for (final respuesta in respuestasDeSeccion) {
        respuestasMap[respuesta.preguntaId] = respuesta;
      }
      final seccionState = RespuestasState(respuestas: respuestasMap);

      // Subir las respuestas de esta sección
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

    // Verificar si se completó una sección y guardarla (mostrar pantalla intermedia si es avance)
    await _verificarYGuardarSeccionCompletada(grupoIdAnterior, esAvance: true);
  }

  /// Obtiene el índice de la última pregunta de la sección anterior
  int? _getIndiceUltimaPreguntaSeccionAnterior() {
    if (contador == 0 || _preguntas.isEmpty) return null;
    
    final grupoIdActual = _preguntas[contador].grupoId;
    
    // Si estamos en la primera pregunta de una sección, buscar la última pregunta de la sección anterior
    final preguntasSeccionActual = _preguntasPorGrupo[grupoIdActual] ?? [];
    if (preguntasSeccionActual.isNotEmpty && _preguntas[contador].id == preguntasSeccionActual.first.id) {
      // Estamos en la primera pregunta de esta sección
      // Buscar la sección anterior en el orden
      final indiceSeccionActual = _ordenSecciones.indexOf(grupoIdActual);
      if (indiceSeccionActual > 0) {
        final seccionAnteriorId = _ordenSecciones[indiceSeccionActual - 1];
        final preguntasSeccionAnterior = _preguntasPorGrupo[seccionAnteriorId] ?? [];
        if (preguntasSeccionAnterior.isNotEmpty) {
          // Encontrar el índice de la última pregunta de la sección anterior en _preguntas
          final ultimaPreguntaAnterior = preguntasSeccionAnterior.last;
          final indiceUltimaPregunta = _preguntas.indexWhere((p) => p.id == ultimaPreguntaAnterior.id);
          if (indiceUltimaPregunta != -1) {
            return indiceUltimaPregunta;
          }
        }
      }
    }
    
    return null;
  }

  void anteriorPregunta() async {
    if (contador == 0) return;
    
    final grupoIdActual = _preguntas[contador].grupoId;
    final preguntasSeccionActual = _preguntasPorGrupo[grupoIdActual] ?? [];
    
    // Verificar si estamos en la primera pregunta de la sección actual
    final esPrimeraPreguntaDeSeccion = preguntasSeccionActual.isNotEmpty && 
        _preguntas[contador].id == preguntasSeccionActual.first.id;
    
    if (esPrimeraPreguntaDeSeccion) {
      // Si estamos en la primera pregunta de una sección, mostrar la pantalla intermedia de esta sección
      setState(() {
        _mostrandoPantallaIntermedia = true;
        _seccionCompletadaId = null; // No hay sección completada, solo mostrar la actual
      });
    } else {
      // Retroceder normalmente dentro de la misma sección
      setState(() {
        contador--;
      });
    }
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
    final preguntaId = preguntaActual.id; // Usar el ID real de Firestore
    final grupoId = preguntaActual.grupoId; // ID del grupo al que pertenece
    final respuestasState = ref.watch(respuestasProvider);
    final ahora = DateTime.now();
    final respuestaGuardadaObjeto = respuestasState.todasLasRespuestas
        .firstWhere(
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

    // For radio/multiple buttons - ahora soporta múltiples selecciones
    // Priorizar respuestaOpcionesCompletas si está disponible, sino usar respuestaOpciones
    final List<String>? respuestasOpcionesActuales = 
        respuestaGuardadaObjeto.respuestaOpcionesCompletas != null
            ? respuestaGuardadaObjeto.respuestaOpcionesCompletas!
                .map((op) => op.value)
                .toList()
            : respuestaGuardadaObjeto.respuestaOpciones;

    // For text input
    final String? respuestaTextoActual = respuestaGuardadaObjeto.respuestaTexto;

    // For image input
    final List<String>? respuestaImagenesActuales =
        respuestaGuardadaObjeto.respuestaImagenes;
    
    // Determinar cantidad de imágenes permitidas (default: 1)
    final cantidadImagenes = preguntaActual.cantidadImagenes ?? 1;
    switch (preguntaActual.tipo.toLowerCase().trim()) {
      case 'multiple':
        return PillQuestionWidget(
          pregunta: preguntaActual.descripcion,
          emojiPregunta: preguntaActual.emoji.isNotEmpty ? preguntaActual.emoji : null,
          opciones: preguntaActual.opciones,
          allowCustomOption: preguntaActual.allowCustomOption,
          customOptionLabel: preguntaActual.customOptionLabel,
          respuestasActuales: respuestasOpcionesActuales,
          maxOpcionesSeleccionables: preguntaActual.maxOpcionesSeleccionables,
          onRespuestasChanged: (respuestas) {
            // Crear mapas de value -> emoji y value -> text para las opciones
            final Map<String, String> opcionesConEmoji = {};
            final Map<String, String> opcionesConText = {};
            
            for (final opcion in preguntaActual.opciones) {
              if (opcion.emoji.isNotEmpty) {
                opcionesConEmoji[opcion.value] = opcion.emoji;
              }
              opcionesConText[opcion.value] = opcion.text;
            }
            
            _controller.guardarRespuestaUseCase.guardarRespuestaRadio(
              preguntaId,
              grupoId,
              preguntaActual.tipo,
              preguntaActual.descripcion,
              preguntaActual.encabezado,
              preguntaActual.emoji.isNotEmpty ? preguntaActual.emoji : null,
              respuestas,
              opcionesConEmoji.isNotEmpty ? opcionesConEmoji : null,
              opcionesConText.isNotEmpty ? opcionesConText : null,
            );
          },
        );

      case 'imagen_texto':
        return ObjFotoTexto(
          key: ValueKey(preguntaId), // Añadir Key única
          titulo: preguntaActual.descripcion,
          emoji: preguntaActual.emoji.isNotEmpty ? preguntaActual.emoji : null,
          textoPlaceholder: preguntaActual.encabezado,
          textoInicial: respuestaTextoActual, // Pass the initial text here
          imagenInicialPath: respuestaImagenesActuales?.isNotEmpty == true ? respuestaImagenesActuales!.first : null,
          textoArriba: false,
          lineasTexto: 1,
          onFotoChanged: (imageUrl) {
            _controller.guardarRespuestaUseCase.guardarRespuestaImagenes(
              preguntaId,
              grupoId,
              preguntaActual.tipo,
              preguntaActual.descripcion,
              preguntaActual.encabezado,
              preguntaActual.emoji.isNotEmpty ? preguntaActual.emoji : null,
              imageUrl != null ? [imageUrl] : [], // Ruta local del archivo (se subirá al finalizar)
            );
          },
          onTextoChanged: (texto) {
            _controller.guardarRespuestaUseCase.guardarRespuestaTexto(
              preguntaId,
              grupoId,
              preguntaActual.tipo,
              preguntaActual.descripcion,
              preguntaActual.encabezado,
              preguntaActual.emoji.isNotEmpty ? preguntaActual.emoji : null,
              texto,
            );
          },
        );

      case 'texto':
        return ObjFotoTexto(
          key: ValueKey(preguntaId), // Añadir Key única
          titulo: preguntaActual.descripcion,
          emoji: preguntaActual.emoji.isNotEmpty ? preguntaActual.emoji : null,
          textoPlaceholder: preguntaActual.encabezado,
          textoInicial: respuestaTextoActual,
          mostrarImagen: false,
          onTextoChanged: (texto) {
            _controller.guardarRespuestaUseCase.guardarRespuestaTexto(
              preguntaId,
              grupoId,
              preguntaActual.tipo,
              preguntaActual.descripcion,
              preguntaActual.encabezado,
              preguntaActual.emoji.isNotEmpty ? preguntaActual.emoji : null,
              texto,
            );
          },
        );

      case 'numero':
        return ObjNumero(
          key: ValueKey(preguntaId), // Añadir Key única
          titulo: preguntaActual.descripcion,
          emoji: preguntaActual.emoji.isNotEmpty ? preguntaActual.emoji : null,
          textoPlaceholder: preguntaActual.encabezado,
          maxNumber: preguntaActual.maxNumber,
          minNumber: preguntaActual.minNumber,
          controller: TextEditingController(text: respuestaTextoActual ?? ''),
          onChanged: (numero) {
            _controller.guardarRespuestaUseCase.guardarRespuestaNumero(
              preguntaId,
              grupoId,
              preguntaActual.tipo,
              preguntaActual.descripcion,
              preguntaActual.encabezado,
              preguntaActual.emoji.isNotEmpty ? preguntaActual.emoji : null,
              numero,
            );
          },
        );

      case 'imagen':
        return ImagePickerWidget(
          iconData: Icons.add_photo_alternate,
          imgSize: 200,
          key: ValueKey(preguntaId), // Añadir Key única
          titulo: preguntaActual.descripcion,
          emoji: preguntaActual.emoji.isNotEmpty ? preguntaActual.emoji : null,
          textoPlaceholder: preguntaActual.encabezado,
          imagenInicialPath: cantidadImagenes == 1 && respuestaImagenesActuales?.isNotEmpty == true 
              ? respuestaImagenesActuales!.first 
              : null,
          imagenesIniciales: cantidadImagenes > 1 ? respuestaImagenesActuales : null,
          cantidadImagenes: cantidadImagenes,
          onFotoChanged: cantidadImagenes == 1
              ? (imageUrl) {
                  _controller.guardarRespuestaUseCase.guardarRespuestaImagenes(
                    preguntaId,
                    grupoId,
                    preguntaActual.tipo,
                    preguntaActual.descripcion,
                    preguntaActual.encabezado,
                    preguntaActual.emoji.isNotEmpty ? preguntaActual.emoji : null,
                    imageUrl != null ? [imageUrl] : [], // Ruta local del archivo (se subirá al finalizar)
                  );
                }
              : null,
          onFotosChanged: cantidadImagenes > 1
              ? (imageUrls) {
                  _controller.guardarRespuestaUseCase.guardarRespuestaImagenes(
                    preguntaId,
                    grupoId,
                    preguntaActual.tipo,
                    preguntaActual.descripcion,
                    preguntaActual.encabezado,
                    preguntaActual.emoji.isNotEmpty ? preguntaActual.emoji : null,
                    imageUrls, // Rutas locales de los archivos (se subirán al finalizar)
                  );
                }
              : null,
        );

      default:
        return Column(
          children: [
            Text('Tipo de pregunta no reconocido: "${preguntaActual.tipo}"'),
            const SizedBox(height: 10),
            Text('Descripción: ${preguntaActual.descripcion}'),
            const SizedBox(height: 10),
            Text('Opciones: ${preguntaActual.opcionesStrings}'),
          ],
        );
    }
  }

  /// Widget para mostrar la pantalla intermedia entre secciones
  Widget _buildPantallaIntermedia() {
    SeccionDTO? seccionAMostrar;
    bool esRetroceso = false;
    
    // Si es la pantalla inicial, mostrar la primera sección
    if (_mostrarPantallaInicial && _ordenSecciones.isNotEmpty) {
      final primeraSeccionId = _ordenSecciones.first;
      seccionAMostrar = _secciones[primeraSeccionId];
    }
    // Si es pantalla intermedia entre secciones, mostrar la siguiente sección
    else if (_mostrandoPantallaIntermedia && _seccionCompletadaId != null) {
      // Obtener la siguiente sección
      final indiceSeccionCompletada = _ordenSecciones.indexOf(_seccionCompletadaId!);
      if (indiceSeccionCompletada == -1 || 
          indiceSeccionCompletada >= _ordenSecciones.length - 1) {
        // No hay siguiente sección, continuar normalmente
        _continuarASiguienteSeccion();
        return const SizedBox.shrink();
      }

      final siguienteSeccionId = _ordenSecciones[indiceSeccionCompletada + 1];
      seccionAMostrar = _secciones[siguienteSeccionId];
    }
    // Si estamos retrocediendo y estamos en la primera pregunta de una sección
    else if (_mostrandoPantallaIntermedia && _seccionCompletadaId == null && contador < _preguntas.length) {
      // Mostrar la sección actual
      final grupoIdActual = _preguntas[contador].grupoId;
      seccionAMostrar = _secciones[grupoIdActual];
      esRetroceso = true;
    }

    if (seccionAMostrar == null) {
      return const SizedBox.shrink();
    }

    // Determinar si mostrar botón de retroceso en el header
    final mostrarBackButtonHeader = _mostrarPantallaInicial || esRetroceso;
    
    return VerticalViewStandardScrollable(
      title: seccionAMostrar.titulo,
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
                  seccionAMostrar.titulo,
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
                  seccionAMostrar.descripcion,
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
                    if (esRetroceso && !_mostrarPantallaInicial)
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: BotonSiguiente(
                          texto: 'Atrás',
                          onPressed: _retrocederDesdePantallaIntermedia,
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
                      onPressed: _continuarASiguienteSeccion,
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

  @override
  Widget build(BuildContext context) {
    // Si se está mostrando la pantalla intermedia o la pantalla inicial, mostrarla
    if (_mostrandoPantallaIntermedia || _mostrarPantallaInicial) {
      return _buildPantallaIntermedia();
    }

    // Obtener el estado de las respuestas
    final respuestasState = ref.watch(respuestasProvider);

    // Verifica si la pregunta actual ha sido respondida
    final preguntaId = contador < _preguntas.length
        ? _preguntas[contador].id
        : '';
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
      // Para imagen, verifica que haya imágenes
      if (r.respuestaImagenes?.isNotEmpty ?? false) {
        return true;
      }
      return false;
    });

    // Calcular el progreso basado en la sección actual
    final preguntasSeccionActual = _getPreguntasDeSeccionActual();
    final grupoIdActual = contador < _preguntas.length 
        ? _preguntas[contador].grupoId 
        : '';
    
    // Encontrar el índice de la pregunta actual dentro de su sección
    int indiceEnSeccion = 0;
    if (contador < _preguntas.length) {
      indiceEnSeccion = preguntasSeccionActual.indexWhere(
        (p) => p.id == _preguntas[contador].id
      );
      if (indiceEnSeccion == -1) indiceEnSeccion = 0;
    }
    
    // Calcular progreso de la sección actual
    double progreso = preguntasSeccionActual.isNotEmpty
        ? (indiceEnSeccion + 1) / preguntasSeccionActual.length
        : 0.0;
    
    final totalPreguntasSeccion = preguntasSeccionActual.length;
    
    // Título que muestra la sección y progreso dentro de ella
    String titulo = '';
    if (contador >= _preguntas.length - 1) {
      titulo = '¡Formulario completado!';
    } else if (preguntasSeccionActual.isNotEmpty) {
      final seccionActual = _secciones[grupoIdActual];
      final nombreSeccion = seccionActual?.titulo ?? grupoIdActual;
      titulo = '$nombreSeccion - Pregunta ${indiceEnSeccion + 1} de $totalPreguntasSeccion';
    } else {
      titulo = 'Pregunta ${contador + 1} de ${_preguntas.length}';
    }

    // Determinar si mostrar el botón de retroceso del header
    // Solo mostrar si estamos en la primera pregunta de la primera sección
    final esPrimeraPreguntaPrimeraSeccion = contador == 0 && 
        (_ordenSecciones.isEmpty || 
         _preguntas.isEmpty || 
         _preguntas[0].grupoId == _ordenSecciones.first);

    return VerticalViewStandardScrollable(
      title: titulo,
      headerColor: const Color.fromARGB(255, 248, 226, 185),
      foregroundColor: Colors.black,
      backgroundColor: const Color.fromARGB(
        255,
        248,
        226,
        185,
      ), // Color de toda la pantalla
      centerTitle: true,
      showBackButton: esPrimeraPreguntaPrimeraSeccion, // Solo permitir volver a home si estamos en la primera pregunta de la primera sección
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
                        // Mostrar botón de retroceso si hay preguntas anteriores (incluso en otras secciones)
                        (contador > 0 || _getIndiceUltimaPreguntaSeccionAnterior() != null)
                            ? BotonSiguiente(
                                onPressed: anteriorPregunta,
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
                              : () async {
                                  // Guardar la última sección antes de finalizar
                                  if (contador < _preguntas.length) {
                                    final grupoIdActual = _preguntas[contador].grupoId;
                                    await _guardarRespuestasDeSeccion(grupoIdActual);
                                  }
                                  // Finalizar formulario usando el controlador
                                  _controller.finalizarFormulario(
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
