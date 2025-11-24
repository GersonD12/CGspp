import 'package:flutter/material.dart';
import 'package:calet/features/formulario/application/dto/dto.dart';

class PillQuestionWidget extends StatefulWidget {
  final String pregunta;
  final String? emojiPregunta; // Emoji de la pregunta
  final List<OpcionDTO> opciones; // Cambiado a OpcionDTO para incluir emojis
  final bool allowCustomOption;
  final String customOptionLabel;
  final List<String>? respuestasActuales; // Lista de respuestas seleccionadas
  final int? maxOpcionesSeleccionables; // Máximo de opciones seleccionables (null = 1, selección única)
  final Function(List<String>) onRespuestasChanged; // Callback con lista de respuestas

  const PillQuestionWidget({
    super.key,
    required this.pregunta,
    this.emojiPregunta,
    required this.opciones,
    this.allowCustomOption = false,
    this.customOptionLabel = 'Otro',
    this.respuestasActuales,
    this.maxOpcionesSeleccionables,
    required this.onRespuestasChanged,
  });

  @override
  State<PillQuestionWidget> createState() => _PillQuestionWidgetState();
}

class _PillQuestionWidgetState extends State<PillQuestionWidget> {
  late List<String> _seleccionadas;
  String? _customText;

  @override
  void initState() {
    super.initState();
    // Inicializar con respuestas actuales o lista vacía
    _seleccionadas = List<String>.from(widget.respuestasActuales ?? []);
    // Extraer texto personalizado si existe
    _customText = _seleccionadas.firstWhere(
      (r) => !widget.opciones.any((op) => op.value == r) && r != widget.customOptionLabel,
      orElse: () => '',
    );
    if (_customText!.isEmpty) _customText = null;
    // Remover texto personalizado de seleccionadas para manejo separado
    _seleccionadas.removeWhere((r) => r == _customText);
  }

  bool get _esSeleccionMultiple => 
      widget.maxOpcionesSeleccionables != null && widget.maxOpcionesSeleccionables! > 1;

  int get _maxSelecciones => 
      widget.maxOpcionesSeleccionables ?? 1;

  void _toggleOpcion(String valor) {
    setState(() {
      if (_seleccionadas.contains(valor)) {
        // Deseleccionar
        _seleccionadas.remove(valor);
      } else {
        // Seleccionar
        if (_esSeleccionMultiple) {
          // Selección múltiple: verificar límite
          if (_seleccionadas.length < _maxSelecciones) {
            _seleccionadas.add(valor);
          } else {
            // Mostrar mensaje de límite alcanzado
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Solo puedes seleccionar hasta $_maxSelecciones opción(es)'),
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }
        } else {
          // Selección única: reemplazar selección anterior
          _seleccionadas = [valor];
        }
      }
      _notificarCambio();
    });
  }

  void _toggleCustomOption() {
    setState(() {
      if (_seleccionadas.contains(widget.customOptionLabel)) {
        _seleccionadas.remove(widget.customOptionLabel);
        _customText = null;
      } else {
        if (_esSeleccionMultiple) {
          if (_seleccionadas.length < _maxSelecciones) {
            _seleccionadas.add(widget.customOptionLabel);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Solo puedes seleccionar hasta $_maxSelecciones opción(es)'),
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }
        } else {
          _seleccionadas = [widget.customOptionLabel];
        }
      }
      _notificarCambio();
    });
  }

  void _actualizarCustomText(String texto) {
    setState(() {
      if (texto.isNotEmpty) {
        _customText = texto;
        // Asegurar que customOptionLabel esté seleccionado
        if (!_seleccionadas.contains(widget.customOptionLabel)) {
          if (_esSeleccionMultiple) {
            if (_seleccionadas.length < _maxSelecciones) {
              _seleccionadas.add(widget.customOptionLabel);
            }
          } else {
            _seleccionadas = [widget.customOptionLabel];
          }
        }
      } else {
        _customText = null;
        _seleccionadas.remove(widget.customOptionLabel);
      }
      _notificarCambio();
    });
  }

  void _notificarCambio() {
    final respuestasFinales = List<String>.from(_seleccionadas);
    // Si hay texto personalizado, agregarlo como respuesta
    if (_customText != null && _customText!.isNotEmpty) {
      respuestasFinales.add(_customText!);
    }
    widget.onRespuestasChanged(respuestasFinales);
  }

  bool _isSelected(String valor) {
    return _seleccionadas.contains(valor);
  }

  bool get _showCustomTextField {
    return widget.allowCustomOption && 
           (_isSelected(widget.customOptionLabel) || _customText != null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              if (widget.emojiPregunta != null && widget.emojiPregunta!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    widget.emojiPregunta!,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              Expanded(
                child: Text(
                  widget.pregunta,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        
        // Mostrar información de selección múltiple si aplica
        if (_esSeleccionMultiple)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              'Puedes seleccionar hasta $_maxSelecciones opción(es) (${_seleccionadas.length}/$_maxSelecciones)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        // Opciones como píldoras (ChoiceChips)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...widget.opciones.map((opcion) {
                final bool selected = _isSelected(opcion.value);
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (opcion.emoji.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Text(
                            opcion.emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      Text(opcion.text),
                    ],
                  ),
                  selected: selected,
                  onSelected: (_) => _toggleOpcion(opcion.value),
                  shape: const StadiumBorder(),
                );
              }),
              if (widget.allowCustomOption)
                ChoiceChip(
                  label: Text(widget.customOptionLabel),
                  selected: _isSelected(widget.customOptionLabel),
                  onSelected: (_) => _toggleCustomOption(),
                  shape: const StadiumBorder(),
                ),
            ],
          ),
        ),

        // Campo de texto para opción personalizada (si corresponde)
        if (_showCustomTextField)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: TextEditingController(text: _customText ?? ''),
              decoration: const InputDecoration(
                hintText: 'Escribe tu respuesta...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: _actualizarCustomText,
            ),
          ),
      ],
    );
  }
}
