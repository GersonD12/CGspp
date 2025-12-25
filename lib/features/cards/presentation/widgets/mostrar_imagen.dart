import 'package:flutter/material.dart';

class MostrarImagen extends StatefulWidget {
  // 1. Parámetros disponibles
  final Color squareColor; // Color del cuadrado
  final double squareHeight; // Altura del cuadrado
  final double squareWidth; // Anchura del cuadrado
  final IconData icon;
  final List<String> linkImage;
  final Color shadowColor; //color de sombra
  final double borderRadius;
  final Color textColor;
  final double textSize;
  final VoidCallback onTapAction;
  const MostrarImagen({
    Key? key,
    this.squareColor = Colors.white,
    this.squareHeight = 100,
    this.squareWidth = 100,
    this.icon = Icons.image,
    this.linkImage = const [],
    this.borderRadius = 30.0,
    this.shadowColor = Colors.black26,
    this.textColor = Colors.black,
    this.textSize = 16.0,
    required this.onTapAction,
  }) : super(key: key);

  @override
  State<MostrarImagen> createState() => _MostrarImagenState();
}

class _MostrarImagenState extends State<MostrarImagen> {
  int _currentPageIndex = 0;
  void _openImageFullScreen() {
    if (widget.linkImage.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Center(
              child: PageView.builder(
                controller: PageController(initialPage: _currentPageIndex),
                itemCount: widget.linkImage.length,
                itemBuilder: (context, index) {
                  final imageUrl = widget.linkImage[index].trim();
                  return InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 50,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 2. Usamos InkWell se usa para detectar toques y mostrar efectos visuales
    return InkWell(
      onTap: () {
        _openImageFullScreen();
        widget.onTapAction();
      }, // 3. Acción al tocar el cuadrado
      child: Container(
        margin: const EdgeInsets.all(8.0),
        height: widget.squareHeight, // 4. Altura
        width: widget.squareWidth, // 5. Anchura
        decoration: BoxDecoration(
          color: widget.squareColor, // 6. Color
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: widget.shadowColor,
              blurRadius: 0.0,
              offset: const Offset(5, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: widget.linkImage.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: PageView.builder(
                        onPageChanged: (index) {
                          setState(() {
                            _currentPageIndex = index;
                          });
                        },
                        itemCount: widget.linkImage.length,
                        itemBuilder: (context, index) {
                          final imageUrl = widget.linkImage[index].trim();
                          return Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: widget.textSize * 5,
                                    color: widget.textColor,
                                  ),
                                  Text(
                                    'Error',
                                    style: TextStyle(
                                      color: widget.textColor,
                                      fontSize: widget.squareHeight * 0.08,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.icon,
                          size: widget.textSize * 5,
                          color: widget.textColor,
                        ),
                        Text(
                          'No hay imagen',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: widget.textColor,
                            fontSize: widget.squareHeight * 0.08,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
            // Indicador de página (solo se muestra si hay múltiples imágenes)
            if (widget.linkImage.length > 1)
              Positioned(
                bottom: 8.0,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.linkImage.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: _currentPageIndex == index ? 11.0 : 8.0,
                      height: _currentPageIndex == index ? 11.0 : 10.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPageIndex == index
                            ? widget.textColor
                            : widget.textColor.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
