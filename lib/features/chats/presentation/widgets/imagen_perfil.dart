import 'package:flutter/material.dart';

class ImagenPerfil extends StatelessWidget {
  final String linkImagen;
  final String mensaje;
  final String nombre;
  final String hora;
  final VoidCallback onTap;
  const ImagenPerfil({
    super.key,
    this.linkImagen = '',
    this.mensaje = '',
    this.nombre = '',
    this.hora = '',
    this.onTap = _defaultOnTap,
  });

  static void _defaultOnTap() {}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 25),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    image: linkImagen.isNotEmpty
                        ? DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(linkImagen),
                          )
                        : null,
                  ),
                  child: linkImagen.isEmpty
                      ? Icon(Icons.person, color: Colors.grey[600], size: 30)
                      : null,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mensaje,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(hora),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_ios, size: 16),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
