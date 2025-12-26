import 'dart:io';
import 'package:flutter/material.dart';
import 'package:calet/core/di/injection.dart';
import 'package:calet/core/infrastructure/storage_service.dart';
import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/formulario/domain/repositories/respuestas_repository.dart';
import 'package:calet/features/formulario/presentation/providers/respuestas_state.dart';
import 'package:image_picker/image_picker.dart';

/// Widget especializado para editar imágenes con espacios fijos (FIFO)
class ImagenesEditorWidget extends StatefulWidget {
  final PreguntaDTO pregunta;
  final RespuestaDTO? respuesta;
  final String userId;
  final VoidCallback? onRespuestaGuardada;

  const ImagenesEditorWidget({
    super.key,
    required this.pregunta,
    this.respuesta,
    required this.userId,
    this.onRespuestaGuardada,
  });

  @override
  State<ImagenesEditorWidget> createState() => _ImagenesEditorWidgetState();
}

class _ImagenesEditorWidgetState extends State<ImagenesEditorWidget> {
  bool _isSavingImages = false;
  final ImagePicker _imagePicker = ImagePicker();

  /// Obtiene la cantidad máxima de imágenes permitidas
  int get _cantidadMaxima => widget.pregunta.cantidadImagenes ?? 1;

  /// Obtiene las imágenes actuales
  List<String> get _imagenesActuales => List<String>.from(widget.respuesta?.respuestaImagenes ?? []);

  /// Agrega una imagen en el primer espacio vacío disponible (FIFO)
  /// Ignora el índice pasado y siempre busca el primer espacio vacío
  Future<void> _agregarImagenEnIndice(int indiceDestino) async {
    try {
      final XFile? imagen = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (imagen == null) return;

      // Verificar si ya se alcanzó el límite
      final imagenesActuales = _imagenesActuales;
      if (imagenesActuales.length >= _cantidadMaxima) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ya has alcanzado el límite de $_cantidadMaxima imagen${_cantidadMaxima > 1 ? 'es' : ''}')),
          );
        }
        return;
      }

      setState(() {
        _isSavingImages = true;
      });

      // Subir imagen a Firebase Storage
      final storageService = StorageService();
      final archivo = File(imagen.path);
      final imagenUrl = await storageService.uploadFile(archivo);

      if (imagenUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al subir la imagen')),
          );
        }
        return;
      }

      // Agregar la imagen al final (FIFO - siempre se agrega al siguiente espacio disponible)
      final nuevasImagenes = [...imagenesActuales, imagenUrl];

      // Guardar respuesta actualizada
      await _guardarRespuestaImagenes(nuevasImagenes);

      if (mounted && widget.onRespuestaGuardada != null) {
        widget.onRespuestaGuardada!();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingImages = false;
        });
      }
    }
  }

  /// Elimina una imagen con confirmación (FIFO - desplaza las demás)
  Future<void> _eliminarImagen(int index) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar imagen'),
        content: const Text('¿Estás seguro de que quieres eliminar esta imagen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      setState(() {
        _isSavingImages = true;
      });

      final imagenesActuales = _imagenesActuales;
      imagenesActuales.removeAt(index);

      // Guardar respuesta actualizada
      await _guardarRespuestaImagenes(imagenesActuales);

      if (mounted && widget.onRespuestaGuardada != null) {
        widget.onRespuestaGuardada!();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingImages = false;
        });
      }
    }
  }

  /// Guarda las imágenes en Firestore
  Future<void> _guardarRespuestaImagenes(List<String> imagenes) async {
    final ahora = DateTime.now();
    final respuestaAGuardar = RespuestaDTO(
      idpregunta: widget.pregunta.idpregunta,
      preguntaId: widget.pregunta.id,
      grupoId: widget.pregunta.grupoId,
      tipoPregunta: widget.pregunta.tipo,
      descripcionPregunta: widget.pregunta.descripcion,
      encabezadoPregunta: widget.pregunta.encabezado,
      emojiPregunta: widget.pregunta.emoji,
      respuestaImagenes: imagenes.isNotEmpty ? imagenes : null,
      createdAt: widget.respuesta?.createdAt ?? ahora,
      updatedAt: ahora,
    );

    final respuestasState = RespuestasState(
      respuestas: {widget.pregunta.idpregunta: respuestaAGuardar},
    );

    final repository = getIt<RespuestasRepository>();
    await repository.uploadRespuestas(widget.userId, respuestasState);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imagenesActuales = _imagenesActuales;
    
    // Crear lista de espacios (siempre mostrar cantidadMaxima espacios)
    final espacios = List.generate(_cantidadMaxima, (index) {
      if (index < imagenesActuales.length) {
        return imagenesActuales[index]; // Imagen existente
      }
      return null; // Espacio vacío
    });

    // Diseño tipo galería sin fondo blanco ni efectos glass - 3 columnas fijas
    final espacioEntreColumnas = 12.0;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // No hacer scroll independiente
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Siempre 3 columnas
        crossAxisSpacing: espacioEntreColumnas,
        mainAxisSpacing: espacioEntreColumnas,
        childAspectRatio: 1 / 1.6, // Relación ancho/alto para formato vertical (más alto que ancho)
      ),
      itemCount: espacios.length,
      itemBuilder: (context, index) {
        final imagenUrl = espacios[index];

        return imagenUrl == null
            ? // Espacio vacío - botón para agregar
              InkWell(
                  onTap: _isSavingImages ? null : () => _agregarImagenEnIndice(index),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.5),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    child: _isSavingImages
                        ? Center(
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                size: 32,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                  ),
                )
            : // Espacio ocupado - mostrar imagen con botón X
              Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imagenUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: theme.colorScheme.errorContainer,
                            child: Icon(
                              Icons.broken_image,
                              color: theme.colorScheme.onErrorContainer,
                              size: 32,
                            ),
                          );
                        },
                      ),
                    ),
                    // Botón X para eliminar
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: _isSavingImages ? null : () => _eliminarImagen(index),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
      },
    );
  }
}

