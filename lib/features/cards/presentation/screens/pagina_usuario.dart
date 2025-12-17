import 'package:calet/features/cards/presentation/widgets/barra_flotante.dart';
import 'package:calet/features/cards/presentation/widgets/mostrar_imagen.dart';
import 'package:calet/features/cards/presentation/widgets/pildora.dart';
import 'package:calet/shared/widgets/boton_widget.dart';
import 'package:flutter/material.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';
import 'package:calet/features/cards/domain/models/user_card.dart';
import 'package:calet/core/theme/app_theme_extension.dart';
import 'dart:developer' show log;
import 'package:calet/features/cards/presentation/widgets/cuadro_texto.dart';
import 'package:calet/features/cards/infrastructure/data/enviar_solicitud.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final TextEditingController _mensajeController = TextEditingController();

  @override
  void dispose() {
    _mensajeController.dispose();
    super.dispose();
  }

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
          ).extension<AppThemeExtension>()!.shadowColor.withOpacity(0.2),
          onTapAction: () {},
          textColor: Theme.of(context).colorScheme.onSurface,
        ),
      );

      for (var key in sortedKeys) {
        // Evitar errores si el valor no es un Mapa
        if (answers[key] is! Map<String, dynamic>) continue;

        final answerData = answers[key] as Map<String, dynamic>;

        // Try new field names first, fallback to old names for backwards compatibility
        final question =
            answerData['encabezado'] as String? ??
            answerData['descripcionPregunta'] as String?;
        final emojiPregunta =
            answerData['emoji'] as String? ??
            answerData['emojiPregunta'] as String?;
        final optionsAnswer = answerData['respuestaOpciones'] as List<dynamic>?;
        final textAnswer = answerData['respuestaTexto'] as String?;
        final respuestaImagen = answerData['respuestaImagen'] as String?;
        final respuestaImagenes =
            answerData['respuestaImagenes'] as List<dynamic>?;

        List<String> multipleAnswers = [];
        String singleAnswer = '';
        List<String> linkImage = [];

        // Asignar las imágenes si existen (priorizar nuevo formato array)
        if (respuestaImagenes != null && respuestaImagenes.isNotEmpty) {
          linkImage = respuestaImagenes
              .map((url) => url.toString().trim())
              .where((url) => url.isNotEmpty)
              .toList();
        } else if (respuestaImagen != null && respuestaImagen.isNotEmpty) {
          linkImage = respuestaImagen
              .split(',')
              .map((url) => url.trim())
              .where((url) => url.isNotEmpty)
              .toList();
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
          ).extension<AppThemeExtension>()!.shadowColor.withOpacity(0.2),
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
              ).extension<AppThemeExtension>()!.shadowColor.withOpacity(0.2),
              elevation: 2,
            ),
            const SizedBox(width: 15),
            Boton(
              texto: 'Responder',
              icon: Icons.border_color_rounded,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Enviar Solicitud'),
                      content: SingleChildScrollView(
                        child: TextBox(
                          controller: _mensajeController,
                          hintText:
                              'Escribe un mensaje inicial (solo sera visible si aceptan la solicitud)',
                          maxLines: 3,
                          textColor: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancelar'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Enviar'),
                          onPressed: () async {
                            final String mensaje = _mensajeController.text
                                .trim();

                            if (mensaje.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Campo vacío'),
                                    content: const Text(
                                      'Por favor escribe un mensaje',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return;
                            }

                            try {
                              // Obtener el usuario actual
                              final currentUser =
                                  FirebaseAuth.instance.currentUser;
                              if (currentUser == null) {
                                throw Exception('Usuario no autenticado');
                              }

                              final now = DateTime.now().toIso8601String();

                              // Enviar solicitud
                              await enviarSolicitud(
                                idUsuario: currentUser.uid,
                                createdAt: now,
                                mensaje: mensaje,
                                estado: 'pendiente',
                                formUsuario: currentUser.uid,
                                toUsuario: user.id,
                                idChat: '${currentUser.uid}_${user.id}',
                                updateAt: now,
                              );

                              // Limpiar el campo de texto
                              _mensajeController.clear();

                              if (context.mounted) {
                                // Cerrar el dialog de solicitud
                                Navigator.of(context).pop();

                                // Mostrar modal de éxito
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('¡Éxito!'),
                                      content: const Text(
                                        'Solicitud enviada con éxito',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                // Cerrar el perfil
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Error'),
                                      content: Text('Error al enviar: $e'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              color: Theme.of(
                context,
              ).extension<AppThemeExtension>()!.buttonColor,
              textColor: Theme.of(context).colorScheme.onSurface,
              elevation: 2,
              shadowColor: Theme.of(
                context,
              ).extension<AppThemeExtension>()!.shadowColor.withOpacity(0.2),
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
