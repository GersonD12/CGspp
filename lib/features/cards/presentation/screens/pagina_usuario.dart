import 'package:calet/features/cards/presentation/widgets/pildora.dart';
import 'package:flutter/material.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';
import 'package:calet/features/cards/domain/models/user_card.dart';

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

      for (var key in sortedKeys) {
        final answerData = answers[key] as Map<String, dynamic>;
        final question = answerData['descripcionPregunta'] as String?;
        final optionsAnswer = answerData['respuestaOpciones'] as List<dynamic>?;
        final textAnswer = answerData['respuestaTexto'] as String?;
        final respuestaImagen = answerData['respuestaImagen'] as String?;

        List<String> displayAnswers = [];
        String? linkImage;

        // Asignar la imagen si existe
        if (respuestaImagen != null && respuestaImagen.isNotEmpty) {
          linkImage = respuestaImagen;
        }

        // Asignar la respuesta de texto o de opciones
        if (optionsAnswer != null && optionsAnswer.isNotEmpty) {
          displayAnswers = optionsAnswer.map((e) => e.toString()).toList();
        } else if (textAnswer != null && textAnswer.isNotEmpty) {
          displayAnswers = [textAnswer];
        }

        //Si la respuesta es null no se muestra nada xD
        if (question != null &&
            (displayAnswers.isNotEmpty || linkImage != null)) {
          contentWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    question,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  if (displayAnswers.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      alignment: WrapAlignment.center,
                      children: displayAnswers
                          .map(
                            (answer) => Pildora(
                              text: answer,
                              color: const Color.fromARGB(94, 255, 255, 255),
                              textColor: Colors.black,
                              borderColor: const Color.fromARGB(
                                255,
                                77,
                                77,
                                77,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  if (linkImage != null)
                    Image.network(
                      linkImage,
                      loadingBuilder:
                          (
                            BuildContext context,
                            Widget child,
                            ImageChunkEvent? loadingProgress,
                          ) {
                            if (loadingProgress == null) {
                              return child; // La imagen ya se cargó
                            }
                            return const Center(
                              child:
                                  CircularProgressIndicator(), // Círculo de carga
                            );
                          },
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(
                            height: 100,
                            width: double.infinity,
                            child: Icon(Icons.image_not_supported),
                          ), // Widget en caso de error
                    ),
                  if (linkImage == null &&
                      (textAnswer == null || textAnswer.isEmpty) &&
                      (optionsAnswer == null || optionsAnswer.isEmpty))
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          );
        }
      }
    }

    if (contentWidgets.isEmpty) {
      contentWidgets.add(
        const Center(child: Text('This user has not answered the form yet.')),
      );
    }

    return VerticalViewStandardScrollable(
      title: user.displayName,
      appBarFloats: true,
      headerColor: const Color.fromARGB(255, 248, 226, 185),
      backgroundColor: const Color.fromARGB(255, 248, 226, 185),
      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
      centerTitle: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: contentWidgets,
      ),
    );
  }
}
