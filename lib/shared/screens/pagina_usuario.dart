import 'package:calet/shared/widgets/barra_flotante.dart';
import 'package:calet/features/cards/presentation/widgets/mostrar_imagen.dart';
import 'package:calet/features/cards/presentation/widgets/pildora.dart';
import 'package:calet/shared/widgets/boton_widget.dart';
import 'package:flutter/material.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';
import 'package:calet/features/cards/domain/models/user_card.dart';
import 'package:calet/core/theme/app_theme_extension.dart';
import 'dart:developer' show log;
import 'package:calet/shared/widgets/cuadro_texto.dart';
import 'package:calet/features/solicitudes/infrastructure/data/enviar_solicitud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calet/features/solicitudes/infrastructure/repository/bajar_solicitudes_repository.dart';
import 'package:calet/features/solicitudes/infrastructure/data/bajar_solicitudes.dart';
import 'package:calet/features/chats/infrastructure/data/iniciar_chat.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final TextEditingController _mensajeController = TextEditingController();
  String estado = '';
  String? currentSolicitudId; // To store the key of the current request
  String? currentMensaje; // To store the message from database
  String? currentFromUsuario;
  String? currentToUsuario;
  String? currentCreatedAt; // To store the creation time of the request

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _verificarEstadoSolicitud();
  }

  Future<void> _verificarEstadoSolicitud() async {
    final user = ModalRoute.of(context)!.settings.arguments as UserCard;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final repository = BajarSolicitudesRepository();
      List<BajarSolicitudes> solicitudes = [];

      final solicitudesCurrentUser = await repository.bajarSolicitudesPorUID(
        currentUser.uid,
      );
      solicitudes.addAll(solicitudesCurrentUser);

      try {
        // Buscar si existe una solicitud entre estos dos usuarios
        final solicitud = solicitudes.firstWhere(
          (s) =>
              (s.fromUsuario == currentUser.uid && s.toUsuario == user.id) ||
              (s.fromUsuario == user.id && s.toUsuario == currentUser.uid),
        );

        if (mounted) {
          setState(() {
            estado = solicitud.estado;
            currentSolicitudId = solicitud.idSolicitud; // Store the ID
            currentMensaje = solicitud.mensaje; // Store the message
            currentFromUsuario = solicitud.fromUsuario;
            currentToUsuario = solicitud.toUsuario;
            currentCreatedAt = solicitud.createdAt; // Store the creation time
          });
        }
      } catch (e) {
        log(
          'No se encontró solicitud previa entre ${currentUser.uid} y ${user.id}',
        );
      }
    }
  }

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

      // Group answers by grupoId
      Map<String, List<MapEntry<String, dynamic>>> groupedAnswers = {};

      for (var entry in answers.entries) {
        if (entry.value is! Map<String, dynamic>) continue;

        final answerData = entry.value as Map<String, dynamic>;
        final grupoId = answerData['grupoId'] as String? ?? 'sin_grupo';

        if (!groupedAnswers.containsKey(grupoId)) {
          groupedAnswers[grupoId] = [];
        }
        groupedAnswers[grupoId]!.add(entry);
      }

      // Sort groups (optional: you can define a custom order)
      final sortedGroupIds = groupedAnswers.keys.toList();

      // Display questions grouped by grupoId
      for (var grupoId in sortedGroupIds) {
        final questionsInGroup = groupedAnswers[grupoId]!;

        // Sort questions within the group by their key
        questionsInGroup.sort((a, b) {
          final aNum = int.tryParse(a.key.split('_').last) ?? 0;
          final bNum = int.tryParse(b.key.split('_').last) ?? 0;
          return aNum.compareTo(bNum);
        });

        // Get group title from the first question in the group
        final firstQuestion =
            questionsInGroup.first.value as Map<String, dynamic>;
        final groupTitle = firstQuestion['groupTitle'] as String? ?? grupoId;

        // Add group header (optional: you can customize this)
        contentWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              groupTitle, // You can add a group title here if you have group metadata
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );

        // Display each question in this group
        for (var entry in questionsInGroup) {
          final answerData = entry.value as Map<String, dynamic>;

          // Try new field names first, fallback to old names for backwards compatibility
          final question =
              answerData['encabezado'] as String? ??
              answerData['descripcionPregunta'] as String?;
          final emojiPregunta =
              answerData['emoji'] as String? ??
              answerData['emojiPregunta'] as String?;
          final optionsAnswer =
              answerData['respuestaOpciones'] as List<dynamic>?;
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
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
                              textColor: Theme.of(
                                context,
                              ).colorScheme.onSurface,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
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

      final currentUser = FirebaseAuth.instance.currentUser;
      final bool isSender =
          currentUser != null &&
          currentFromUsuario == currentUser.uid &&
          estado == 'pendiente';

      contentWidgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (estado != 'aceptado' &&
                estado != 'rechazado' &&
                (estado == '' || estado == 'pendiente'))
              Boton(
                texto: 'Rechazar',
                icon: Icons.clear_rounded,
                onPressed: isSender
                    ? null
                    : () async {
                        final user =
                            ModalRoute.of(context)!.settings.arguments
                                as UserCard;
                        final currentUser = FirebaseAuth.instance.currentUser;

                        if (currentUser != null) {
                          try {
                            if (currentSolicitudId != null) {
                              // Si ya existe solicitud, actualizamos a rechazado
                              await actualizarEstadoSolicitud(
                                idSolicitud: currentSolicitudId!,
                                estado: 'rechazado',
                                fromUsuario:
                                    currentFromUsuario ?? currentUser.uid,
                                toUsuario: currentToUsuario ?? user.id,
                              );
                            } else {
                              // Si no existe, creamos una nueva como rechazado
                              final now = DateTime.now().toIso8601String();
                              // Generar ID de chat ordenado
                              List<String> ids = [currentUser.uid, user.id];
                              ids.sort();
                              String idChat = ids.join('_');

                              await enviarSolicitud(
                                idUsuario: currentUser.uid,
                                createdAt: now,
                                mensaje: '',
                                estado: 'rechazado',
                                fromUsuario: currentUser.uid,
                                toUsuario: user.id,
                                idChat: idChat,
                                updateAt: now,
                              );
                            }

                            if (context.mounted) {
                              setState(() {
                                estado = 'rechazado';
                              });
                              // Opcional: Mostrar feedback
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Usuario rechazado'),
                                    content: const Text(
                                      'Has rechazado la solicitud correctamente',
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
                            }
                          } catch (e) {
                            log('Error al rechazar: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        }
                      },
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
            if (estado != 'aceptado' &&
                estado != 'rechazado' &&
                (estado == '' || estado == 'pendiente'))
              Boton(
                texto: isSender
                    ? 'Esperando...'
                    : (estado == 'pendiente' ? 'Aceptar' : 'Responder'),
                icon: Icons.border_color_rounded,
                onPressed: isSender
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: estado == 'pendiente'
                                  ? Text('Responder Solicitud')
                                  : Text('Enviar Solicitud'),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    if (currentMensaje != null &&
                                        currentMensaje!.isNotEmpty) ...[
                                      Text(
                                        '"$currentMensaje"',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                    TextBox(
                                      controller: _mensajeController,
                                      hintText: estado == 'pendiente'
                                          ? 'Responde para aceptar la solicitud'
                                          : 'Escribe un mensaje (Solo sera visible si aceptan tu solicitud)',
                                      maxLines: 2,
                                    ),
                                  ],
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
                                  child: estado == 'pendiente'
                                      ? Text('Aceptar')
                                      : Text('Enviar'),
                                  onPressed: () async {
                                    final String mensaje = _mensajeController
                                        .text
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
                                        throw Exception(
                                          'Usuario no autenticado',
                                        );
                                      }

                                      final now = DateTime.now()
                                          .toIso8601String();

                                      // Enviar solicitud o Actualizar estado
                                      if (estado == 'pendiente' &&
                                          currentSolicitudId != null) {
                                        // Ya existe y está pendiente -> ACEPTAR (Actualizar estado)
                                        // NOTA: 'fromUsuario' y 'toUsuario' en 'actualizarEstadoSolicitud' son los DOCS donde se busca.
                                        // Mis Docs son 'currentUser.uid' y 'user.id'.
                                        await actualizarEstadoSolicitud(
                                          idSolicitud: currentSolicitudId!,
                                          estado: 'aceptado',
                                          fromUsuario: currentUser.uid,
                                          toUsuario: user.id,
                                        );

                                        // INTEGRACIÓN: Iniciar el chat al aceptar
                                        // Generar ID de chat ordenando UIDs alfabéticamente
                                        List<String> ids = [
                                          currentUser.uid,
                                          user.id,
                                        ];
                                        ids.sort();
                                        String idChat = ids.join('_');

                                        // 1. Guardar el mensaje ORIGINAL (el que envió la solicitud inicial)
                                        if (currentMensaje != null &&
                                            currentCreatedAt != null) {
                                          await iniciarNuevoChat(
                                            idChat: idChat,
                                            fromUsuario:
                                                currentFromUsuario ?? user.id,
                                            toUsuario:
                                                currentToUsuario ??
                                                currentUser.uid,
                                            createdAt: currentCreatedAt!,
                                            mensaje: currentMensaje!,
                                            estado:
                                                'leido', // El mensaje original ya se leyó
                                          );
                                        }

                                        // 2. Guardar la RESPUESTA (el mensaje actual del usuario)
                                        await iniciarNuevoChat(
                                          idChat: idChat,
                                          fromUsuario: currentUser.uid,
                                          toUsuario: user.id,
                                          createdAt: now,
                                          mensaje: mensaje,
                                          estado: 'pendiente',
                                        );
                                      } else {
                                        // No existe -> CREAR (Enviar nueva)
                                        // Generar ID de chat ordenado
                                        List<String> ids = [
                                          currentUser.uid,
                                          user.id,
                                        ];
                                        ids.sort();
                                        String idChat = ids.join('_');

                                        await enviarSolicitud(
                                          idUsuario: currentUser.uid,
                                          createdAt: now,
                                          mensaje: mensaje,
                                          estado: 'pendiente',
                                          fromUsuario: currentUser.uid,
                                          toUsuario: user.id,
                                          idChat: idChat,
                                          updateAt: now,
                                        );
                                      }

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
                                              content: estado == 'pendiente'
                                                  ? Text('Aceptada con éxito')
                                                  : Text(
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
                                              content: Text(
                                                'Error al enviar: $e',
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
