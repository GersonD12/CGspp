import 'dart:io';
import 'package:calet/shared/widgets/boton_widget.dart';
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
  final List<String>? imagenesIniciales; // Lista de imágenes iniciales
  final String titulo;
  final String? emoji; // Emoji para mostrar junto al título
  final Function(String?)?
  onFotoChanged; // Recibe ruta local del archivo (una imagen)
  final Function(List<String>)?
  onFotosChanged; // Recibe lista de rutas locales (múltiples imágenes)
  final bool esObligatorio;
  final String? textoPlaceholder;
  final int
  cantidadImagenes; // Cantidad máxima de imágenes permitidas (default: 1)

  const ImagePickerWidget({
    super.key,
    required this.iconData,
    required this.imgSize,
    this.imagenInicialPath,
    this.imagenesIniciales,
    required this.titulo,
    this.emoji,
    this.onFotoChanged,
    this.onFotosChanged,
    this.esObligatorio = false,
    this.textoPlaceholder,
    this.cantidadImagenes = 1, // Por defecto solo una imagen
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  XFile? _imagenSeleccionada;
  List<XFile> _imagenesSeleccionadas = [];
  List<String> _imagenesCargadas = []; // Para imágenes desde URL o ya guardadas

  @override
  void initState() {
    super.initState();
    // Cargar imágenes iniciales
    if (widget.imagenesIniciales != null &&
        widget.imagenesIniciales!.isNotEmpty) {
      _imagenesCargadas = List<String>.from(widget.imagenesIniciales!);
    } else if (widget.imagenInicialPath != null &&
        widget.imagenInicialPath!.isNotEmpty) {
      _imagenesCargadas = [widget.imagenInicialPath!];
    }
  }

  bool get _permiteMultiplesImagenes => widget.cantidadImagenes > 1;

  @override
  Widget build(BuildContext context) {
    final todasLasImagenes = [
      ..._imagenesCargadas,
      ..._imagenesSeleccionadas.map((x) => x.path),
    ];

    final imagenDisplayPath =
        widget.imagenInicialPath ?? _imagenSeleccionada?.path;
    final isNetworkImage = _isUrl(imagenDisplayPath);

    return Column(
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            if (widget.emoji != null && widget.emoji!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  widget.emoji!,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            Expanded(
              child: Text(
                widget.titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        if (widget.textoPlaceholder != null &&
            widget.textoPlaceholder!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              widget.textoPlaceholder!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        const SizedBox(height: 5),
        // Mostrar grid de imágenes si permite múltiples, o una sola imagen si no
        if (_permiteMultiplesImagenes)
          _buildGridImagenes(todasLasImagenes)
        else
          _buildSingleImage(imagenDisplayPath, isNetworkImage),
        const SizedBox(height: 16),
        Boton(
          onPressed: todasLasImagenes.length >= widget.cantidadImagenes
              ? null // Deshabilitar si ya se alcanzó el límite
              : () {
                  showReusableModal(
                    context: context,
                    title: _permiteMultiplesImagenes
                        ? 'Seleccionar imágenes (${todasLasImagenes.length}/${widget.cantidadImagenes})'
                        : 'Seleccionar una imagen',
                    content: _buildModalContent(context),
                    barrierDismissible: false,
                  );
                },
          texto: _permiteMultiplesImagenes
              ? 'Agregar Imagen${todasLasImagenes.length > 0 ? " (${todasLasImagenes.length}/${widget.cantidadImagenes})" : ""}'
              : 'Seleccionar Imagen',
          icon: widget.iconData,
          color: todasLasImagenes.length >= widget.cantidadImagenes
              ? Colors.grey
              : Colors.blue,
          textColor: Colors.white,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSingleImage(String? imagenDisplayPath, bool isNetworkImage) {
    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: imagenDisplayPath == null
          ? Center(
              child: Icon(
                Icons.image_outlined,
                color: Colors.grey,
                size: widget.imgSize * 0.3,
              ),
            )
          : ClipRRect(
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
    );
  }

  Widget _buildGridImagenes(List<String> imagenes) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 400),
      child: imagenes.isEmpty
          ? Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  color: Colors.grey,
                  size: widget.imgSize * 0.3,
                ),
              ),
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: imagenes.length,
              itemBuilder: (context, index) {
                final imagenPath = imagenes[index];
                final isNetworkImage = _isUrl(imagenPath);
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: isNetworkImage
                            ? Image.network(
                                imagenPath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.broken_image);
                                },
                              )
                            : Image.file(File(imagenPath), fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _eliminarImagen(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  void _eliminarImagen(int index) {
    setState(() {
      if (index < _imagenesCargadas.length) {
        _imagenesCargadas.removeAt(index);
      } else {
        final indiceEnSeleccionadas = index - _imagenesCargadas.length;
        _imagenesSeleccionadas.removeAt(indiceEnSeleccionadas);
      }
      _notificarCambio();
    });
  }

  void _notificarCambio() {
    final todasLasImagenes = [
      ..._imagenesCargadas,
      ..._imagenesSeleccionadas.map((x) => x.path),
    ];

    if (_permiteMultiplesImagenes) {
      widget.onFotosChanged?.call(todasLasImagenes);
    } else {
      widget.onFotoChanged?.call(
        todasLasImagenes.isNotEmpty ? todasLasImagenes.first : null,
      );
    }
  }

  Widget _buildModalContent(BuildContext context) {
    final todasLasImagenes = [
      ..._imagenesCargadas,
      ..._imagenesSeleccionadas.map((x) => x.path),
    ];
    final puedeAgregarMas = todasLasImagenes.length < widget.cantidadImagenes;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter modalSetState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_permiteMultiplesImagenes && todasLasImagenes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Imágenes seleccionadas: ${todasLasImagenes.length}/${widget.cantidadImagenes}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            if (!_permiteMultiplesImagenes)
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
            if (puedeAgregarMas)
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Desde la galería'),
                onTap: () async {
                  final imagen = await getImage();
                  if (imagen != null && mounted) {
                    setState(() {
                      if (_permiteMultiplesImagenes) {
                        _imagenesSeleccionadas.add(imagen);
                      } else {
                        _imagenSeleccionada = imagen;
                      }
                    });
                    _notificarCambio();
                    modalSetState(() {});
                    if (context.mounted && !_permiteMultiplesImagenes) {
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            if (!_permiteMultiplesImagenes && _imagenSeleccionada != null)
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
                    _notificarCambio();
                    modalSetState(() {});
                    Navigator.of(context).pop();
                  }
                },
              ),
            if (!_permiteMultiplesImagenes && _imagenSeleccionada != null)
              ListTile(
                leading: const Icon(Icons.check, color: Colors.green),
                title: const Text('Confirmar'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            if (_permiteMultiplesImagenes)
              ListTile(
                leading: const Icon(Icons.check, color: Colors.green),
                title: const Text('Cerrar'),
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
