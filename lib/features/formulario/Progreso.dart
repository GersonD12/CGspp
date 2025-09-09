import 'package:flutter/material.dart';

class Progreso extends StatelessWidget {
  final double progress; // Valor entre 0.0 y 1.0
  final Color color; // Color de la barra de progreso
  final double height; // Altura de la barra
  final Color backgroundColor; // Color de fondo
  final BorderRadius? borderRadius; // Bordes redondeados opcionales
  final Widget? child; // Widget personalizado opcional
  final double? width; // Ancho personalizado (opcional)
  final EdgeInsets? padding; // Padding interno (opcional)

  const Progreso({
    super.key,
    required this.progress,
    required this.color,
    this.height = 8.0,
    this.backgroundColor = Colors.grey,
    this.borderRadius,
    this.child,
    this.width,
    this.padding,
  }) : assert(
         progress >= 0.0 && progress <= 1.0,
         'El progreso debe estar entre 0.0 y 1.0',
       );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = width ?? screenWidth;
    final progressWidth = effectiveWidth * progress;

    return Container(
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
            ),
          ),
          Container(
            width: progressWidth,
            decoration: BoxDecoration(
              color: color,
              borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

// Widget de progreso animado opcional
class ProgresoAnimado extends StatefulWidget {
  final double progress;
  final Color color;
  final double height;
  final Color backgroundColor;
  final BorderRadius? borderRadius;
  final Duration duration;
  final Curve curve;
  final double? width;
  final EdgeInsets? padding;
  final Widget? child;

  const ProgresoAnimado({
    super.key,
    required this.progress,
    required this.color,
    this.height = 8.0,
    this.backgroundColor = Colors.grey,
    this.borderRadius,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
    this.width,
    this.padding,
    this.child,
  });

  @override
  State<ProgresoAnimado> createState() => _ProgresoAnimadoState();
}

class _ProgresoAnimadoState extends State<ProgresoAnimado>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _controller.forward();
  }

  @override
  void didUpdateWidget(ProgresoAnimado oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Progreso(
          progress: _animation.value,
          color: widget.color,
          height: widget.height,
          backgroundColor: widget.backgroundColor,
          borderRadius: widget.borderRadius,
          width: widget.width,
          padding: widget.padding,
          child: widget.child,
        );
      },
    );
  }
}
