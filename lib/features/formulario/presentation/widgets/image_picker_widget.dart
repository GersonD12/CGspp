import 'dart:io';
import 'package:calet/features/formulario/presentation/widgets/boton_siguiente_widget.dart';
import 'package:calet/features/formulario/presentation/widgets/modal_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Determina si una cadena es una URL (HTTP/HTTPS)
bool _isUrl(String? path) {
  if (path == null || path.isEmpty) return false;
  return path.startsWith('http://') || path.startsWith('https://');
}

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
  final Function(String?)? onFotoChanged; // Recibe ruta local del archivo
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

  @override
  Widget build(BuildContext context) {
    final imagenDisplayPath = widget.imagenInicialPath ?? _imagenSeleccionada?.path;
    final isNetworkImage = _isUrl(imagenDisplayPath);
    
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
          child: imagenDisplayPath == null
              ? Center(
                  // Muestra el ícono si no hay imagen
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.grey,
                    size: widget.imgSize * 0.3,
                  ),
                )
              : ClipRRect(
                  // Muestra la imagen (URL de red o archivo local)
                  borderRadius: BorderRadius.circular(8.0),
                  child: isNetworkImage
                      ? Image.network(
                          imagenDisplayPath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: widget.imgSize * 0.3,
                              ),
                            );
                          },
                        )
                      : Image.file(
                          File(imagenDisplayPath),
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
        return Column(
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
                leading: const Icon(Icons.photo_library),
                title: const Text('Desde la galería'),
                onTap: () async {
                  final imagen = await getImage();
                  if (imagen != null && mounted) {
                    setState(() {
                      _imagenSeleccionada = imagen;
                    });
                    // Notificar con la ruta local inmediatamente
                    widget.onFotoChanged?.call(imagen.path);
                    modalSetState(() {});
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
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
                onTap: () {
                  if (mounted) {
                    setState(() {
                      _imagenSeleccionada = null;
                    });
                    // Notificar que se eliminó
                    widget.onFotoChanged?.call(null);
                    modalSetState(() {});
                    Navigator.of(context).pop();
                  }
                },
              ),
            if (_imagenSeleccionada != null)
              ListTile(
                leading: const Icon(
                  Icons.check,
                  color: Colors.green,
                ),
                title: const Text(
                  'Confirmar',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
          ],
        );
      },
    );
  }
}

