import 'package:flutter/material.dart';
import 'package:calet/shared/widgets/vertical_view_standard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calet/features/cards/presentation/widgets/cards.dart';
import 'dart:developer' show log;
import 'package:calet/features/cards/presentation/widgets/modal_perfiles.dart';
import 'package:calet/features/cards/presentation/widgets/pildora.dart';

class ScreenCards extends StatefulWidget {
  const ScreenCards({super.key});

  @override
  State<ScreenCards> createState() => _ScreenCardsState();
}

class _ScreenCardsState extends State<ScreenCards> {
  List<QueryDocumentSnapshot> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRandomUsers();
  }

  Future<void> _fetchRandomUsers() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      final allUsers = usersSnapshot.docs;

      // Shuffle the list of users
      allUsers.shuffle();

      // Take the first 15 users, or fewer if there aren't that many
      final randomUsers = allUsers.take(15).toList();

      setState(() {
        _users = randomUsers;
        _isLoading = false;
      });
      log('Fetched ${_users.length} random users.');
    } catch (e) {
      log('Error fetching users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VerticalViewStandardScrollable(
      title: 'Cards',
      appBarFloats: true,
      headerColor: const Color.fromARGB(255, 248, 226, 185),
      backgroundColor: const Color.fromARGB(255, 248, 226, 185),
      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
      centerTitle: true,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? const Center(child: Text('No users found.'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _users.map((user) {
                final userData = user.data() as Map<String, dynamic>;
                // TODO: Replace 'name' with the actual field from your user document.
                final userName = userData['displayName'] ?? 'No name';

                return Cards(
                  squareColor: Colors.white,
                  squareHeight: 200,
                  squareWidth: 380,
                  borderRadius: 20,
                  text: userName,
                  textColor: const Color.fromARGB(199, 41, 41, 41),
                  textSize: 20,
                  onTapAction: () {
                    log('Card for $userName tapped');

                    final formResponses =
                        userData['form_responses'] as Map<String, dynamic>?;
                    final answers =
                        formResponses?['answers'] as Map<String, dynamic>?;

                    final List<Widget> contentWidgets = [];

                    if (answers != null) {
                      // Sort keys to display questions in order, assuming keys are like 'pregunta_1', 'pregunta_2', etc.
                      final sortedKeys = answers.keys.toList()
                        ..sort((a, b) {
                          final aNum = int.tryParse(a.split('_').last) ?? 0;
                          final bNum = int.tryParse(b.split('_').last) ?? 0;
                          return aNum.compareTo(bNum);
                        });

                      for (var key in sortedKeys) {
                        final answerData = answers[key] as Map<String, dynamic>;
                        final question =
                            answerData['descripcionPregunta'] as String?;
                        final optionsAnswer =
                            answerData['respuestaOpciones'] as List<dynamic>?;
                        final textAnswer =
                            answerData['respuestaTexto'] as String?;
                        final respuestaImagen =
                            answerData['respuestaImagen'] as String?;

                        String? displayAnswer;
                        String? linkImage;

                        // Asignar la imagen si existe
                        if (respuestaImagen != null &&
                            respuestaImagen.isNotEmpty) {
                          linkImage = respuestaImagen;
                        }

                        // Asignar la respuesta de texto o de opciones
                        if (optionsAnswer != null && optionsAnswer.isNotEmpty) {
                          displayAnswer = optionsAnswer.join(', ');
                        } else if (textAnswer != null &&
                            textAnswer.isNotEmpty) {
                          displayAnswer = textAnswer;
                        }
                        //Si la respuesta es null no se muestra nada xD
                        if (question != null &&
                            (displayAnswer != null || linkImage != null)) {
                          contentWidgets.add(
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
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
                                  if (displayAnswer != null)
                                    Text(
                                      displayAnswer,
                                      style: const TextStyle(fontSize: 14),
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
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const SizedBox(
                                                height: 100,
                                                width: double.infinity,
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                ),
                                              ), // Widget en caso de error
                                    ),
                                  if (linkImage == null &&
                                      (textAnswer == null ||
                                          textAnswer.isEmpty) &&
                                      (optionsAnswer == null ||
                                          optionsAnswer.isEmpty))
                                    Container(
                                      height: 100,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
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
                        const Center(
                          child: Text(
                            'This user has not answered the form yet.',
                          ),
                        ),
                      );
                    }

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomModal(
                          text: userName,
                          width: 800,
                          height: 900,
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: contentWidgets,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }).toList(),
            ),
    );
  }
}
