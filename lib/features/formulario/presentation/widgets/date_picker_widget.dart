import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget para seleccionar una fecha con límites de fecha inicial y final
class DatePickerWidget extends StatefulWidget {
  /// El texto que se muestra como título
  final String titulo;
  
  /// Emoji para mostrar junto al título
  final String? emoji;
  
  /// El texto que se muestra como placeholder
  final String textoPlaceholder;
  
  /// Fecha inicial guardada (en formato ISO 8601 string o Timestamp)
  final String? fechaInicial;
  
  /// Fecha mínima permitida (límite inferior)
  final DateTime? fechaMinima;
  
  /// Fecha máxima permitida (límite superior)
  final DateTime? fechaMaxima;
  
  /// Callback cuando se selecciona una fecha
  /// Recibe la fecha en formato ISO 8601 string (YYYY-MM-DD)
  final Function(String fecha)? onChanged;

  const DatePickerWidget({
    super.key,
    required this.titulo,
    this.emoji,
    required this.textoPlaceholder,
    this.fechaInicial,
    this.fechaMinima,
    this.fechaMaxima,
    this.onChanged,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime? _fechaSeleccionada;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    // Si hay una fecha inicial, parsearla
    if (widget.fechaInicial != null && widget.fechaInicial!.isNotEmpty) {
      try {
        // Intentar parsear como ISO 8601 (YYYY-MM-DD)
        _fechaSeleccionada = DateTime.parse(widget.fechaInicial!);
      } catch (e) {
        // Si falla, intentar otros formatos comunes
        try {
          _fechaSeleccionada = DateFormat('dd/MM/yyyy').parse(widget.fechaInicial!);
        } catch (e2) {
          // Si no se puede parsear, dejar en null
          _fechaSeleccionada = null;
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // Si no hay restricciones (fechaMinima y fechaMaxima son null), usar rangos muy amplios
    final DateTime firstDate = widget.fechaMinima ?? DateTime(1900, 1, 1);
    final DateTime lastDate = widget.fechaMaxima ?? DateTime(2100, 12, 31);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('es', 'ES'), // Usar español (ahora está configurado en MaterialApp)
      helpText: widget.textoPlaceholder,
      cancelText: 'Cancelar',
      confirmText: 'Seleccionar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
      // Llamar al callback con la fecha en formato ISO 8601 (YYYY-MM-DD)
      final fechaString = _dateFormat.format(picked);
      widget.onChanged?.call(fechaString);
    }
  }

  String _formatDate(DateTime date) {
    // Formatear fecha para mostrar al usuario (formato localizado)
    return DateFormat('dd/MM/yyyy', 'es').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: widget.textoPlaceholder,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _fechaSeleccionada != null
                        ? _formatDate(_fechaSeleccionada!)
                        : 'Selecciona una fecha',
                    style: TextStyle(
                      fontSize: 16,
                      color: _fechaSeleccionada != null
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Mostrar información sobre los límites de fecha solo si existen restricciones
        if (widget.fechaMinima != null || widget.fechaMaxima != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _getDateRangeText(),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).hintColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  String _getDateRangeText() {
    final DateFormat displayFormat = DateFormat('dd/MM/yyyy', 'es');
    if (widget.fechaMinima != null && widget.fechaMaxima != null) {
      return 'Rango permitido: ${displayFormat.format(widget.fechaMinima!)} - ${displayFormat.format(widget.fechaMaxima!)}';
    } else if (widget.fechaMinima != null) {
      return 'Fecha mínima: ${displayFormat.format(widget.fechaMinima!)}';
    } else if (widget.fechaMaxima != null) {
      return 'Fecha máxima: ${displayFormat.format(widget.fechaMaxima!)}';
    }
    return '';
  }
}

