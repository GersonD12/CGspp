import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ObjFotoTexto extends StatefulWidget {
  final String? imagenInicialPath;
  final String titulo;
  final String? textoPlaceholder;
  final String? textoInicial;
  final Function(String)? onTextoChanged;
  final Function(XFile?)? onFotoChanged;
  final bool esObligatorio;
  final double? alturaImagen;
  final double? anchoImagen;
  final bool mostrarTexto; // Nuevo: controla si se muestra el campo de texto
  final bool
  mostrarImagen; // Nuevo: controla si se muestra la sección de imagen
  final bool textoArriba; // Nuevo: true = texto arriba, false = texto abajo
  final int? lineasTexto; // Nuevo: controla la altura del campo de texto

  const ObjFotoTexto({
    super.key,
    this.imagenInicialPath,
    required this.titulo,
    this.textoPlaceholder,
    this.textoInicial,
    this.onTextoChanged,
    this.onFotoChanged,
    this.esObligatorio = false,
    this.alturaImagen,
    this.anchoImagen,
    this.mostrarTexto = true, // Por defecto mostrar texto
    this.mostrarImagen = true, // Por defecto mostrar imagen
    this.textoArriba = true, // Por defecto texto arriba
    this.lineasTexto, // Por defecto 4 líneas
  });

  @override
  State<ObjFotoTexto> createState() => _ObjFotoTextoState();
}

class _ObjFotoTextoState extends State<ObjFotoTexto> {
  final TextEditingController _textoController = TextEditingController();
  XFile? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.textoInicial != null) {
      _textoController.text = widget.textoInicial!;
    }
    if (widget.imagenInicialPath != null &&
        widget.imagenInicialPath!.isNotEmpty) {
      _imagenSeleccionada = XFile(widget.imagenInicialPath!);
    }
  }

  @override
  void dispose() {
    _textoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    try {
      final XFile? imagen = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: widget.anchoImagen ?? 800,
        maxHeight: widget.alturaImagen ?? 600,
        imageQuality: 85,
      );

      if (imagen != null) {
        setState(() {
          _imagenSeleccionada = imagen;
        });
        widget.onFotoChanged?.call(imagen);
      }
    } catch (e) {
      _mostrarError('Error al seleccionar imagen: $e');
    }
  }

  Future<void> _tomarFoto() async {
    try {
      final XFile? imagen = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: widget.anchoImagen ?? 800,
        maxHeight: widget.alturaImagen ?? 600,
        imageQuality: 85,
      );

      if (imagen != null) {
        setState(() {
          _imagenSeleccionada = imagen;
        });
        widget.onFotoChanged?.call(imagen);
      }
    } catch (e) {
      _mostrarError('Error al tomar foto: $e');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _seleccionarImagen();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.of(context).pop();
                  _tomarFoto();
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
                    Navigator.of(context).pop();
                    setState(() {
                      _imagenSeleccionada = null;
                    });
                    widget.onFotoChanged?.call(null);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCampoTexto() {
    if (!widget.mostrarTexto) return const SizedBox.shrink();

    return Column(
      children: [
        TextField(
          controller: _textoController,
          onChanged: widget.onTextoChanged,
          maxLines: widget.lineasTexto ?? 4, // Usa el parámetro o 4 por defecto
          decoration: InputDecoration(
            hintText: widget.textoPlaceholder ?? 'Escribe aquí...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSeccionImagen() {
    if (!widget.mostrarImagen) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: Column(
        children: [
          // Botón para seleccionar imagen
          ElevatedButton.icon(
            onPressed: _mostrarOpcionesImagen,
            icon: const Icon(Icons.add_a_photo),
            label: Text(
              _imagenSeleccionada == null ? 'Agregar imagen' : 'Cambiar imagen',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Vista previa de la imagen
          if (_imagenSeleccionada != null) ...[
            Container(
              constraints: BoxConstraints(
                maxHeight: widget.alturaImagen ?? 200,
                maxWidth: widget.anchoImagen ?? 300,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_imagenSeleccionada!.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ] else ...[
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No hay imagen seleccionada',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Text(
          widget.titulo,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (widget.esObligatorio)
          const Text(
            ' *',
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        const SizedBox(height: 16),

        // Contenido con posición configurable
        if (widget.textoArriba) ...[
          // Texto arriba, imagen abajo
          _buildCampoTexto(),
          _buildSeccionImagen(),
        ] else ...[
          // Imagen arriba, texto abajo
          _buildSeccionImagen(),
          _buildCampoTexto(),
        ],
      ],
    );
  }
}

