import 'dart:developer';
import 'dart:io';
import 'package:calet/features/formulario/presentation/Boton.dart';
import 'package:calet/features/formulario/presentation/widgets/modal_helper.dart';
import 'package:calet/core/infrastructure/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> getImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  return image;
}

class ImagePickerWidget extends StatefulWidget {
  final IconData iconData;
  final double imgSize;
  final String? imagenInicialPath;
  final String titulo;
  final Function(XFile?)? onFotoChanged;
  final bool esObligatorio;
  final String? textoPlaceholder;

  const ImagePickerWidget({
    super.key,
    required this.iconData,
    required this.imgSize,
    this.imagenInicialPath,
    required this.titulo,
    this.onFotoChanged,
    this.esObligatorio = false,
    this.textoPlaceholder,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  XFile? _imagenSeleccionada;
  bool _isUploading = false; // Mover _isUploading al estado del widget

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),
        Text(
          widget.titulo,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 300,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ), // Cierre de BoxDecoration
          child: _imagenSeleccionada == null
              ? Center(
                  // Muestra el ícono si no hay imagen
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.grey,
                    size: widget.imgSize * 0.3,
                  ),
                )
              : ClipRRect(
                  // Muestra la imagen seleccionada
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    File(_imagenSeleccionada!.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
        ),
        const SizedBox(height: 16),
        BotonSiguiente(
          onPressed: () {
            showReusableModal(
              context: context,
              title: 'Seleccionar una imagen',
              content: _buildModalContent(context),
              barrierDismissible: false, // Bloquea el cierre al tocar fuera
            );
          },
          texto: 'Seleccionar Imagen',
          icon: widget.iconData,
          color: Colors.blue,
          textColor: Colors.white,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildModalContent(BuildContext context) {
    // Usamos StatefulBuilder para permitir que el contenido del modal se actualice
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter modalSetState) {
        return PopScope(
          canPop: !_isUploading, // Bloquea el cierre si se está subiendo
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 270,
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _imagenSeleccionada == null
                        ? Center(
                            child: Icon(
                              widget.iconData,
                              color: Colors.grey,
                              size: widget.imgSize * 0.3,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(
                              File(_imagenSeleccionada!.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                  ),
                  if (_imagenSeleccionada == null)
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Desde la cámara'),
                      onTap: _isUploading
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                    ),
                  if (_imagenSeleccionada == null)
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Desde la galería'),
                      onTap: _isUploading
                          ? null
                          : () async {
                              final imagen = await getImage();
                              if (imagen != null && mounted) {
                                setState(() {
                                  _imagenSeleccionada = imagen;
                                });
                                modalSetState(() {});
                              }
                            },
                    ),
                  if (_imagenSeleccionada != null)
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text(
                        'Eliminar imagen',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: _isUploading
                          ? null
                          : () {
                              if (mounted) {
                                setState(() {
                                  _imagenSeleccionada = null;
                                });
                                modalSetState(() {});
                                Navigator.of(context).pop();
                              }
                            },
                    ),
                  if (_imagenSeleccionada != null)
                    ListTile(
                      leading: const Icon(
                        Icons.cloud_upload,
                        color: Colors.green,
                      ),
                      title: const Text(
                        'Subir Imagen',
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: _isUploading
                          ? null
                          : () async {
                              if (_imagenSeleccionada == null) {
                                log('No hay imagen seleccionada para subir.');
                                return;
                              }

                              if (!mounted) return;

                              setState(() {
                                _isUploading = true;
                              });
                              modalSetState(() {});

                              try {
                                log(
                                  'Iniciando subida de: ${_imagenSeleccionada!}',
                                );
                                final storageService = StorageService();
                                await storageService.uploadFile(
                                  File(_imagenSeleccionada!.path),
                                );
                              } catch (e) {
                                log('Error al subir la imagen: $e');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error al subir la imagen: $e',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } finally {
                                // Aseguramos que el modal se cierre sin importar el resultado
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                                // Resetear el estado de carga solo si el widget sigue montado
                                if (mounted) {
                                  setState(() {
                                    _isUploading = false;
                                  });
                                }
                              }
                            },
                    ),
                ],
              ),
              if (_isUploading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

