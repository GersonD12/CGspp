import 'package:calet/features/cards/presentation/widgets/barra_flotante.dart';
import 'package:calet/features/cards/presentation/widgets/mostrar_imagen.dart';
import 'package:calet/features/cards/presentation/widgets/pildora.dart';
import 'package:calet/shared/widgets/boton_widget.dart';
import 'package:flutter/material.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';
import 'package:calet/features/cards/domain/models/user_card.dart';
import 'package:calet/core/theme/app_theme_extension.dart';
import 'dart:developer' show log;

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as UserCard;

    final answers = user.answers;
    final List<Widget> contentWidgets = [];

    if (answers.isNotEmpty) {
      final sortedKeys = answers.keys.toList()
        ..sort((a, b) {
          final aNum = int.tryParse(a.split('_').last) ?? 0;
          final bNum = int.tryParse(b.split('_').last) ?? 0;
          return aNum.compareTo(bNum);
        });

      log(user.groupImages['questionsPerfil'].toString());

      // 👇 AÑADIR AL INICIO
      contentWidgets.add(
        MostrarImagen(
          squareHeight: 400,
          squareWidth: double.infinity,
          linkImage:
              user.groupImages['questionsPerfil'] ??
              [], // Muestra imágenes de questionsPerfil
          squareColor: Theme.of(
            context,
          ).extension<AppThemeExtension>()!.buttonColor,
          shadowColor: Theme.of(
            context,
          ).extension<AppThemeExtension>()!.shadowColor,
          borderColor: Theme.of(
            context,
          ).extension<AppThemeExtension>()!.barBorder,
          onTapAction: () {},
          textColor: Theme.of(context).colorScheme.onSurface,
        ),
      );

      for (var key in sortedKeys) {
        // Evitar errores si el valor no es un Mapa
        if (answers[key] is! Map<String, dynamic>) continue;

        final answerData = answers[key] as Map<String, dynamic>;
        final question = answerData['descripcionPregunta'] as String?;
        final emojiPregunta = answerData['emojiPregunta'] as String?;
        final optionsAnswer = answerData['respuestaOpciones'] as List<dynamic>?;
        final textAnswer = answerData['respuestaTexto'] as String?;
        final respuestaImagen = answerData['respuestaImagen'] as String?;

        List<String> multipleAnswers = [];
        String singleAnswer = '';
        List<String> linkImage = [];

        // Asignar la imagen si existe
        if (respuestaImagen != null && respuestaImagen.isNotEmpty) {
          linkImage = respuestaImagen
              .split(',')
              .map((url) => url.trim())
              .where((url) => url.isNotEmpty)
              .toList();
        }

        if (linkImage.isNotEmpty) {
          contentWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: MostrarImagen(
                squareHeight: 250,
                squareWidth: double.infinity,
                linkImage: linkImage,
                squareColor: Colors.transparent,
                shadowColor: Colors.transparent,
                borderColor: Colors.transparent,
                onTapAction: () {},
                textColor: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        }

        // Asignar la respuesta de texto o de opciones
        if (optionsAnswer != null && optionsAnswer.isNotEmpty) {
          multipleAnswers = optionsAnswer.map((e) => e.toString()).toList();
        } else if (textAnswer != null && textAnswer.isNotEmpty) {
          singleAnswer = textAnswer;
        }

        // Mostrar preguntas con respuestas múltiples (con píldoras)
        if (question != null && multipleAnswers.isNotEmpty) {
          contentWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${emojiPregunta ?? ''} $question',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    alignment: WrapAlignment.start,
                    children: multipleAnswers
                        .map(
                          (multipleAnswer) => Pildora(
                            text: multipleAnswer,
                            color: Theme.of(
                              context,
                            ).extension<AppThemeExtension>()!.buttonColor,
                            textColor: Theme.of(context).colorScheme.onSurface,
                            borderColor: Theme.of(
                              context,
                            ).extension<AppThemeExtension>()!.buttonColor,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        }
        // Mostrar preguntas de solo texto (sin píldoras)
        else if (question != null && singleAnswer.isNotEmpty) {
          contentWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${emojiPregunta ?? ''} $question ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    singleAnswer,
                    style: TextStyle(fontSize: 15),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
          );
        }
      }

      // 👇 AÑADIR AL FINAL
      contentWidgets.add(
        MostrarImagen(
          squareHeight: 350,
          squareWidth: double.infinity,
          linkImage:
              user.groupImages['ceCDytDoV0g01BHegzHA'] ??
              [], // Sin imagen al final, solo muestra el placeholder
          squareColor: Theme.of(
            context,
          ).extension<AppThemeExtension>()!.buttonColor,
          shadowColor: Theme.of(
            context,
          ).extension<AppThemeExtension>()!.shadowColor,
          borderColor: Theme.of(
            context,
          ).extension<AppThemeExtension>()!.barBorder,
          onTapAction: () {},
          textColor: Theme.of(context).colorScheme.onSurface,
        ),
      );
      contentWidgets.add(const SizedBox(height: 15));
      contentWidgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Boton(
              texto: 'Rechazar',
              icon: Icons.clear_rounded,
              onPressed: () {},
              color: Theme.of(
                context,
              ).extension<AppThemeExtension>()!.buttonColor,
              textColor: Theme.of(context).colorScheme.onSurface,
              shadowColor: Theme.of(
                context,
              ).extension<AppThemeExtension>()!.shadowColor,
              elevation: 2,
            ),
            const SizedBox(width: 15),
            Boton(
              texto: 'Responder',
              icon: Icons.border_color_rounded,
              onPressed: () {},
              color: Theme.of(
                context,
              ).extension<AppThemeExtension>()!.buttonColor,
              textColor: Theme.of(context).colorScheme.onSurface,
              elevation: 2,
              shadowColor: Theme.of(
                context,
              ).extension<AppThemeExtension>()!.shadowColor,
            ),
          ],
        ),
      );
    }

    if (contentWidgets.isEmpty) {
      contentWidgets.add(
        const Center(child: Text('This user has not answered the form yet.')),
      );
    }

    return Stack(
      children: [
        VerticalViewStandardScrollable(
          title: 'Pais',
          appBarFloats: true,
          headerColor: Theme.of(context).appBarTheme.backgroundColor,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          centerTitle: true,
          hasFloatingNavBar: true, // Añadir espacio extra al final
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: contentWidgets,
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: BarraFlotante(
            text: user.displayName,
            onTap: () {},
            backgroundColor: Theme.of(
              context,
            ).extension<AppThemeExtension>()!.barColor,
            borderColor: Theme.of(
              context,
            ).extension<AppThemeExtension>()!.barBorder.withOpacity(0.2),
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}
