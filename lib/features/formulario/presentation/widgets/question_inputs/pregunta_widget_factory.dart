import 'package:calet/features/formulario/application/dto/dto.dart';
import 'package:calet/features/formulario/presentation/widgets/question_inputs/country_picker_widget.dart';
import 'package:calet/features/formulario/presentation/widgets/question_inputs/date_picker_widget.dart';
import 'package:calet/features/formulario/presentation/widgets/question_inputs/image_picker_widget.dart';
import 'package:calet/features/formulario/presentation/widgets/question_inputs/obj_foto_texto_widget.dart';
import 'package:calet/features/formulario/presentation/widgets/question_inputs/obj_numero.dart';
import 'package:calet/features/formulario/presentation/widgets/question_inputs/phone_number_input_widget.dart';
import 'package:calet/features/formulario/presentation/widgets/question_inputs/pill_question_widget.dart';
import 'package:flutter/material.dart';

/// Factory para crear widgets de preguntas según su tipo
class PreguntaWidgetFactory {
  /// Crea el widget apropiado para una pregunta según su tipo
  static Widget create({
    required PreguntaDTO pregunta,
    required RespuestaDTO? respuestaGuardada,
    required Function(String preguntaId, String grupoId, String tipo, String descripcion, String encabezado, String? emoji, List<String> respuestas, Map<String, String>? opcionesConEmoji, Map<String, String>? opcionesConText) onMultipleChanged,
    required Function(String preguntaId, String grupoId, String tipo, String descripcion, String encabezado, String? emoji, String texto) onTextoChanged,
    required Function(String preguntaId, String grupoId, String tipo, String descripcion, String encabezado, String? emoji, String numero) onNumeroChanged,
    required Function(String preguntaId, String grupoId, String tipo, String descripcion, String encabezado, String? emoji, List<String> imagenes) onImagenChanged,
    required Function(String preguntaId, String grupoId, String tipo, String descripcion, String encabezado, String? emoji, String telefono) onTelefonoChanged,
    required Function(String preguntaId, String grupoId, String tipo, String descripcion, String encabezado, String? emoji, String codigoPais) onPaisChanged,
    required Function(String preguntaId, String grupoId, String tipo, String descripcion, String encabezado, String? emoji, String fecha) onFechaChanged,
  }) {
    final preguntaId = pregunta.id;
    final grupoId = pregunta.grupoId;
    final emoji = pregunta.emoji.isNotEmpty ? pregunta.emoji : null;

    // Extraer valores de la respuesta guardada
    final List<String>? respuestasOpcionesActuales = respuestaGuardada?.respuestaOpcionesCompletas != null
        ? respuestaGuardada!.respuestaOpcionesCompletas!
            .map((op) => op.value)
            .toList()
        : respuestaGuardada?.respuestaOpciones;

    final String? respuestaTextoActual = respuestaGuardada?.respuestaTexto;
    final List<String>? respuestaImagenesActuales = respuestaGuardada?.respuestaImagenes;
    final cantidadImagenes = pregunta.cantidadImagenes ?? 1;

    switch (pregunta.tipo.toLowerCase().trim()) {
      case 'multiple':
        // Crear mapas de value -> emoji y value -> text para las opciones
        final Map<String, String> opcionesConEmoji = {};
        final Map<String, String> opcionesConText = {};
        
        for (final opcion in pregunta.opciones) {
          if (opcion.emoji.isNotEmpty) {
            opcionesConEmoji[opcion.value] = opcion.emoji;
          }
          opcionesConText[opcion.value] = opcion.text;
        }

        return PillQuestionWidget(
          pregunta: pregunta.descripcion,
          emojiPregunta: emoji,
          opciones: pregunta.opciones,
          allowCustomOption: pregunta.allowCustomOption,
          customOptionLabel: pregunta.customOptionLabel,
          respuestasActuales: respuestasOpcionesActuales,
          maxOpcionesSeleccionables: pregunta.maxOpcionesSeleccionables,
          onRespuestasChanged: (respuestas) {
            onMultipleChanged(
              preguntaId,
              grupoId,
              pregunta.tipo,
              pregunta.descripcion,
              pregunta.encabezado,
              emoji,
              respuestas,
              opcionesConEmoji.isNotEmpty ? opcionesConEmoji : null,
              opcionesConText.isNotEmpty ? opcionesConText : null,
            );
          },
        );

      case 'imagen_texto':
        return ObjFotoTexto(
          key: ValueKey(preguntaId),
          titulo: pregunta.descripcion,
          emoji: emoji,
          textoPlaceholder: pregunta.encabezado,
          textoInicial: respuestaTextoActual,
          imagenInicialPath: respuestaImagenesActuales?.isNotEmpty == true 
              ? respuestaImagenesActuales!.first 
              : null,
          textoArriba: false,
          lineasTexto: 1,
          onFotoChanged: (imageUrl) {
            onImagenChanged(
              preguntaId,
              grupoId,
              pregunta.tipo,
              pregunta.descripcion,
              pregunta.encabezado,
              emoji,
              imageUrl != null ? [imageUrl] : [],
            );
          },
          onTextoChanged: (texto) {
            onTextoChanged(
              preguntaId,
              grupoId,
              pregunta.tipo,
              pregunta.descripcion,
              pregunta.encabezado,
              emoji,
              texto,
            );
          },
        );

      case 'texto':
        return ObjFotoTexto(
          key: ValueKey(preguntaId),
          titulo: pregunta.descripcion,
          emoji: emoji,
          textoPlaceholder: pregunta.encabezado,
          textoInicial: respuestaTextoActual,
          mostrarImagen: false,
          onTextoChanged: (texto) {
            onTextoChanged(
              preguntaId,
              grupoId,
              pregunta.tipo,
              pregunta.descripcion,
              pregunta.encabezado,
              emoji,
              texto,
            );
          },
        );

      case 'numero':
        return ObjNumero(
          key: ValueKey(preguntaId),
          titulo: pregunta.descripcion,
          emoji: emoji,
          textoPlaceholder: pregunta.encabezado,
          maxNumber: pregunta.maxNumber,
          minNumber: pregunta.minNumber,
          controller: TextEditingController(text: respuestaTextoActual ?? ''),
          onChanged: (numero) {
            onNumeroChanged(
              preguntaId,
              grupoId,
              pregunta.tipo,
              pregunta.descripcion,
              pregunta.encabezado,
              emoji,
              numero,
            );
          },
        );

      case 'imagen':
        return ImagePickerWidget(
          iconData: Icons.add_photo_alternate,
          imgSize: 200,
          key: ValueKey(preguntaId),
          titulo: pregunta.descripcion,
          emoji: emoji,
          textoPlaceholder: pregunta.encabezado,
          imagenInicialPath: cantidadImagenes == 1 && respuestaImagenesActuales?.isNotEmpty == true 
              ? respuestaImagenesActuales!.first 
              : null,
          imagenesIniciales: cantidadImagenes > 1 ? respuestaImagenesActuales : null,
          cantidadImagenes: cantidadImagenes,
          onFotoChanged: cantidadImagenes == 1
              ? (imageUrl) {
                  onImagenChanged(
                    preguntaId,
                    grupoId,
                    pregunta.tipo,
                    pregunta.descripcion,
                    pregunta.encabezado,
                    emoji,
                    imageUrl != null ? [imageUrl] : [],
                  );
                }
              : null,
          onFotosChanged: cantidadImagenes > 1
              ? (imageUrls) {
                  onImagenChanged(
                    preguntaId,
                    grupoId,
                    pregunta.tipo,
                    pregunta.descripcion,
                    pregunta.encabezado,
                    emoji,
                    imageUrls,
                  );
                }
              : null,
        );

      case 'numerodetelefono':
        return PhoneNumberInputWidget(
          key: ValueKey(preguntaId),
          titulo: pregunta.descripcion,
          emoji: emoji,
          textoPlaceholder: pregunta.encabezado,
          numeroInicial: respuestaTextoActual,
          onChanged: (numeroCompleto) {
            onTelefonoChanged(
              preguntaId,
              grupoId,
              pregunta.tipo,
              pregunta.descripcion,
              pregunta.encabezado,
              emoji,
              numeroCompleto,
            );
          },
        );

      case 'pais':
        return CountryPickerWidget(
          key: ValueKey(preguntaId),
          titulo: pregunta.descripcion,
          emoji: emoji,
          textoPlaceholder: pregunta.encabezado,
          codigoPaisInicial: respuestaTextoActual, // El código del país guardado
          onChanged: (codigoPais) {
            onPaisChanged(
              preguntaId,
              grupoId,
              pregunta.tipo,
              pregunta.descripcion,
              pregunta.encabezado,
              emoji,
              codigoPais, // Guardar código ISO 3166-1 alpha-2 (ej: "US", "MX", "ES")
            );
          },
        );

      case 'fecha':
        return DatePickerWidget(
          key: ValueKey(preguntaId),
          titulo: pregunta.descripcion,
          emoji: emoji,
          textoPlaceholder: pregunta.encabezado,
          fechaInicial: respuestaTextoActual, // La fecha guardada en formato ISO 8601
          fechaMinima: pregunta.fechaInicial, // Límite inferior
          fechaMaxima: pregunta.fechaFinal, // Límite superior
          onChanged: (fecha) {
            onFechaChanged(
              preguntaId,
              grupoId,
              pregunta.tipo,
              pregunta.descripcion,
              pregunta.encabezado,
              emoji,
              fecha, // Guardar fecha en formato ISO 8601 (YYYY-MM-DD)
            );
          },
        );

      default:
        return Column(
          children: [
            Text('Tipo de pregunta no reconocido: "${pregunta.tipo}"'),
            const SizedBox(height: 10),
            Text('Descripción: ${pregunta.descripcion}'),
            const SizedBox(height: 10),
            Text('Opciones: ${pregunta.opcionesStrings}'),
          ],
        );
    }
  }
}

