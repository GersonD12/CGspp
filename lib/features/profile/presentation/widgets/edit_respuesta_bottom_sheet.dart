import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:calet/core/theme/app_theme_extension.dart';
import 'package:calet/core/di/injection.dart';
import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/formulario/application/use_cases/use_cases.dart';
import 'package:calet/features/formulario/domain/repositories/preguntas_repository.dart';
import 'package:calet/features/formulario/domain/repositories/respuestas_repository.dart';
import 'package:calet/features/formulario/presentation/widgets/question_inputs/pregunta_widget_factory.dart';
import 'package:calet/features/formulario/presentation/providers/respuestas_state.dart';
import 'package:calet/core/infrastructure/storage_service.dart';

/// Modal bottom sheet para editar una respuesta
class EditRespuestaBottomSheet extends StatefulWidget {
  final String idpregunta;
  final String grupoId;
  final String userId;
  final RespuestaDTO? respuesta;

  const EditRespuestaBottomSheet({
    super.key,
    required this.idpregunta,
    required this.grupoId,
    required this.userId,
    this.respuesta,
  });

  @override
  State<EditRespuestaBottomSheet> createState() => _EditRespuestaBottomSheetState();

  static Future<bool?> show(BuildContext context, String idpregunta, String grupoId, String userId, RespuestaDTO? respuesta) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5), // Oscurece el fondo detrás del bottom sheet
      builder: (context) => EditRespuestaBottomSheet(
        idpregunta: idpregunta,
        grupoId: grupoId,
        userId: userId,
        respuesta: respuesta,
      ),
    );
  }
}

class _EditRespuestaBottomSheetState extends State<EditRespuestaBottomSheet> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  PreguntaDTO? _preguntaEncontrada;
  
  // Estado local para capturar los cambios del usuario
  String? _respuestaTexto;
  List<String>? _respuestaImagenes;
  List<String>? _respuestaOpciones;

  // ============================================
  // CONTROLES DE INTENSIDAD DEL EFECTO DE REFRACCIÓN
  // ============================================
  // Ajusta estos valores para cambiar la intensidad:
  
  /// Intensidad del blur del fondo (mayor = más intenso)
  /// Rango recomendado: 5.0 - 20.0
  static const double blurIntensity = 19.5;
  
  /// Opacidad del color de fondo del gradiente (modo oscuro)
  /// Rango recomendado: 0.15 - 0.4
  static const double gradientOpacityDarkTop = 0.25;
  static const double gradientOpacityDarkBottom = 0.15;
  
  /// Opacidad del color de fondo del gradiente (modo claro)
  /// Rango recomendado: 0.2 - 0.5
  static const double gradientOpacityLightTop = 0.35;
  static const double gradientOpacityLightBottom = 0.25;
  
  /// Opacidad del overlay de vidrio sobre el blur
  /// Rango recomendado: 0.02 - 0.1
  static const double glassOverlayOpacity = 0.2;
  
  /// Intensidad de las sombras (mayor = más intenso)
  /// Rango recomendado: 10.0 - 30.0
  static const double shadowBlurRadius1 = 20.0;
  static const double shadowBlurRadius2 = 10.0;
  
  /// Opacidad de las sombras (modo oscuro)
  /// Rango recomendado: 0.1 - 0.4
  static const double shadowOpacityDark1 = 0.3;
  static const double shadowOpacityDark2 = 0.2;
  
  /// Opacidad de las sombras (modo claro)
  /// Rango recomendado: 0.05 - 0.15
  static const double shadowOpacityLight1 = 0.1;
  static const double shadowOpacityLight2 = 0.05;
  
  /// Opacidad del borde superior
  /// Rango recomendado: 0.1 - 0.3
  static const double borderOpacity = 0.15;
  // ============================================

  @override
  void initState() {
    super.initState();
    // Inicializar estado local con la respuesta guardada si existe
    if (widget.respuesta != null) {
      _respuestaTexto = widget.respuesta!.respuestaTexto;
      _respuestaImagenes = widget.respuesta!.respuestaImagenes;
      _respuestaOpciones = widget.respuesta!.respuestaOpciones;
    }
    _loadPreguntaFromFirestore();
  }

  Future<void> _loadPreguntaFromFirestore() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Descargar todas las preguntas desde Firestore
      final preguntasRepository = getIt<PreguntasRepository>();
      final obtenerPreguntasUseCase = ObtenerPreguntasUseCase(preguntasRepository);
      final resultado = await obtenerPreguntasUseCase.execute();

      if (!mounted) return;

      final todasLasPreguntas = resultado['preguntas'] as List<PreguntaDTO>;

      // Buscar la pregunta específica por idpregunta y grupoId
      final preguntaEncontrada = todasLasPreguntas.firstWhere(
        (p) => p.idpregunta == widget.idpregunta && p.grupoId == widget.grupoId,
        orElse: () => throw Exception('Pregunta no encontrada'),
      );

      if (!mounted) return;
      setState(() {
        _preguntaEncontrada = preguntaEncontrada;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar la pregunta: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = theme.extension<AppThemeExtension>();
    final barColor = appTheme?.barColor ?? theme.colorScheme.surfaceContainerHighest;
    final barBorder = appTheme?.barBorder ?? theme.colorScheme.outline;
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.5,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              barColor.withOpacity(isDark ? gradientOpacityDarkTop : gradientOpacityLightTop),
              barColor.withOpacity(isDark ? gradientOpacityDarkBottom : gradientOpacityLightBottom),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(
            top: BorderSide(
              color: barBorder.withOpacity(borderOpacity),
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? shadowOpacityDark1 : shadowOpacityLight1),
              blurRadius: shadowBlurRadius1,
              spreadRadius: 0,
              offset: const Offset(0, -4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? shadowOpacityDark2 : shadowOpacityLight2),
              blurRadius: shadowBlurRadius2,
              spreadRadius: 0,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurIntensity, sigmaY: blurIntensity),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              // Mantener el efecto de vidrio pero con mejor contraste en modo claro
              color: isDark 
                  ? Colors.white.withOpacity(glassOverlayOpacity)
                  : Colors.white.withOpacity(glassOverlayOpacity * 2), // Más opacidad en modo claro para mejor contraste
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom > 0 
                  ? MediaQuery.of(context).viewInsets.bottom + 30.0
                  : 30.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar con efecto de refracción
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                // Botones de acción (iconos)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón Cancelar (icono)
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        tooltip: 'Cancelar',
                      ),
                      // Botón Aceptar (icono)
                      IconButton(
                        onPressed: _isSaving ? null : _guardarRespuesta,
                        icon: _isSaving
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.primary,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.check,
                                color: theme.colorScheme.primary,
                              ),
                        tooltip: 'Aceptar',
                      ),
                    ],
                  ),
                ),
                // Contenido del editor
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                    child: _buildContent(),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom > 0 
                      ? MediaQuery.of(context).viewInsets.bottom 
                      : 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPreguntaFromFirestore,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_preguntaEncontrada == null) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text('No se encontró la pregunta'),
        ),
      );
    }

    // Crear respuesta guardada actualizada con el estado local
    RespuestaDTO? respuestaActualizada;
    if (widget.respuesta != null) {
      respuestaActualizada = widget.respuesta!.copyWith(
        respuestaTexto: _respuestaTexto,
        respuestaImagenes: _respuestaImagenes,
        respuestaOpciones: _respuestaOpciones,
      );
    } else if (_respuestaTexto != null || _respuestaImagenes != null || _respuestaOpciones != null) {
      // Crear nueva respuesta si no existe pero hay datos
      final ahora = DateTime.now();
      respuestaActualizada = RespuestaDTO(
        idpregunta: widget.idpregunta,
        grupoId: widget.grupoId,
        tipoPregunta: _preguntaEncontrada!.tipo,
        descripcionPregunta: _preguntaEncontrada!.descripcion,
        encabezadoPregunta: _preguntaEncontrada!.encabezado,
        emojiPregunta: _preguntaEncontrada!.emoji,
        respuestaTexto: _respuestaTexto,
        respuestaImagenes: _respuestaImagenes,
        respuestaOpciones: _respuestaOpciones,
        createdAt: ahora,
        updatedAt: ahora,
      );
    }

    // Mostrar la pregunta usando el factory con callbacks funcionales
    return PreguntaWidgetFactory.create(
      pregunta: _preguntaEncontrada!,
      respuestaGuardada: respuestaActualizada,
      // Callbacks que actualizan el estado local
      onMultipleChanged: (preguntaId, grupoId, tipo, descripcion, encabezado, emoji, respuestas, opcionesConEmoji, opcionesConText) {
        setState(() {
          _respuestaOpciones = respuestas.isNotEmpty ? respuestas : null;
        });
      },
      onTextoChanged: (preguntaId, grupoId, tipo, descripcion, encabezado, emoji, texto) {
        setState(() {
          _respuestaTexto = texto.isNotEmpty ? texto : null;
        });
      },
      onNumeroChanged: (preguntaId, grupoId, tipo, descripcion, encabezado, emoji, numero) {
        setState(() {
          _respuestaTexto = numero.isNotEmpty ? numero : null;
        });
      },
      onImagenChanged: (preguntaId, grupoId, tipo, descripcion, encabezado, emoji, imagenes) {
        setState(() {
          _respuestaImagenes = imagenes.isNotEmpty ? imagenes : null;
        });
      },
      onTelefonoChanged: (preguntaId, grupoId, tipo, descripcion, encabezado, emoji, telefono) {
        setState(() {
          _respuestaTexto = telefono.isNotEmpty ? telefono : null;
        });
      },
      onPaisChanged: (preguntaId, grupoId, tipo, descripcion, encabezado, emoji, codigoPais) {
        setState(() {
          _respuestaTexto = codigoPais.isNotEmpty ? codigoPais : null;
        });
      },
      onFechaChanged: (preguntaId, grupoId, tipo, descripcion, encabezado, emoji, fecha) {
        setState(() {
          _respuestaTexto = fecha.isNotEmpty ? fecha : null;
        });
      },
    );
  }

  /// Guarda la respuesta usando la misma lógica del formulario
  Future<void> _guardarRespuesta() async {
    if (_preguntaEncontrada == null) return;

    try {
      if (!mounted) return;
      setState(() {
        _isSaving = true;
        _error = null;
      });

      final ahora = DateTime.now();
      
      // Crear RespuestaDTO con los datos actuales
      final respuestaAGuardar = RespuestaDTO(
        idpregunta: widget.idpregunta,
        preguntaId: _preguntaEncontrada!.id,
        grupoId: widget.grupoId,
        tipoPregunta: _preguntaEncontrada!.tipo,
        descripcionPregunta: _preguntaEncontrada!.descripcion,
        encabezadoPregunta: _preguntaEncontrada!.encabezado,
        emojiPregunta: _preguntaEncontrada!.emoji,
        respuestaTexto: _respuestaTexto,
        respuestaImagenes: _respuestaImagenes,
        respuestaOpciones: _respuestaOpciones,
        createdAt: widget.respuesta?.createdAt ?? ahora,
        updatedAt: ahora,
      );

      // Si es tipo imagen, subir las imágenes locales primero
      RespuestaDTO respuestaFinal = respuestaAGuardar;
      if (_preguntaEncontrada!.tipo.toLowerCase() == 'imagen' &&
          respuestaAGuardar.respuestaImagenes != null &&
          respuestaAGuardar.respuestaImagenes!.isNotEmpty) {
        respuestaFinal = await _subirImagenesLocales(respuestaAGuardar);
      }

      // Crear un RespuestasState temporal solo con esta respuesta
      final respuestasState = RespuestasState(
        respuestas: {widget.idpregunta: respuestaFinal},
      );

      // Guardar usando el repositorio (aplica las mismas validaciones)
      final respuestasRepository = getIt<RespuestasRepository>();
      await respuestasRepository.uploadRespuestas(
        widget.userId,
        respuestasState,
      );

      if (!mounted) return;
      
      // Cerrar el bottom sheet
      Navigator.of(context).pop(true); // Retornar true para indicar que se guardó
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _error = 'Error al guardar la respuesta: $e';
      });
      
      // Mostrar error al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Sube las imágenes locales a Firebase Storage y actualiza las URLs
  Future<RespuestaDTO> _subirImagenesLocales(RespuestaDTO respuesta) async {
    if (respuesta.respuestaImagenes == null || respuesta.respuestaImagenes!.isEmpty) {
      return respuesta;
    }

    final storageService = StorageService();
    final List<String> imagenesSubidas = [];

    for (final imagenPath in respuesta.respuestaImagenes!) {
      String? imagenUrl = imagenPath;

      // Si la imagen es una ruta local (no URL), subirla
      if (imagenPath.isNotEmpty &&
          !imagenPath.startsWith('http://') &&
          !imagenPath.startsWith('https://')) {
        try {
          final archivo = File(imagenPath);
          if (await archivo.exists()) {
            imagenUrl = await storageService.uploadFile(archivo);
          } else {
            imagenUrl = null;
          }
        } catch (e) {
          imagenUrl = null;
        }
      }

      if (imagenUrl != null && imagenUrl.isNotEmpty) {
        imagenesSubidas.add(imagenUrl);
      }
    }

    return respuesta.copyWith(respuestaImagenes: imagenesSubidas.isNotEmpty ? imagenesSubidas : null);
  }
}

