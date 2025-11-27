class UserCard {
  final String id;
  final String displayName;
  final Map<String, dynamic> answers;
  final String emojiPregunta;
  final Map<String, List<String>> groupImages;

  UserCard({
    required this.id,
    required this.displayName,
    required this.answers,
    required this.emojiPregunta,
    this.groupImages = const {},
  });

  factory UserCard.fromMap(String id, Map<String, dynamic> data) {
    final defaultDisplayName = data['displayName'] ?? 'No name';

    final formResponses = data['form_responses'] as Map<String, dynamic>?;
    final Map<String, dynamic> answers = {};
    final Map<String, List<String>> groupImages = {};

    if (formResponses != null) {
      if (formResponses.containsKey('grupos')) {
        final grupos = formResponses['grupos'] as Map<String, dynamic>?;
        if (grupos != null) {
          grupos.forEach((groupName, groupData) {
            if (groupData is Map<String, dynamic>) {
              answers.addAll(groupData);

              // Extract images for this group
              List<String> collectedImages = [];
              groupData.forEach((key, value) {
                if (value is Map<String, dynamic>) {
                  // Check for 'respuestaImagen' (comma separated string)
                  if (value.containsKey('respuestaImagen')) {
                    final img = value['respuestaImagen'];
                    if (img is String && img.isNotEmpty) {
                      collectedImages.addAll(
                        img
                            .split(',')
                            .map((url) => url.trim())
                            .where((url) => url.isNotEmpty)
                            .toList(),
                      );
                    }
                  }
                  // Check for 'respuestaImagenes' (list) - just in case
                  if (value.containsKey('respuestaImagenes')) {
                    final imgs = value['respuestaImagenes'];
                    if (imgs is List) {
                      collectedImages.addAll(
                        imgs
                            .map((e) => e.toString().trim())
                            .where((url) => url.isNotEmpty),
                      );
                    }
                  }
                }
              });

              if (collectedImages.isNotEmpty) {
                groupImages[groupName] = collectedImages;
              }
            }
          });
        }
      } else if (formResponses.containsKey('answers')) {
        final oldAnswers = formResponses['answers'] as Map<String, dynamic>?;
        if (oldAnswers != null) {
          answers.addAll(oldAnswers);
        }
      }
    }

    // Find display name from answers
    String finalDisplayName = defaultDisplayName;
    if (answers.isNotEmpty) {
      for (var value in answers.values) {
        if (value is Map<String, dynamic>) {
          final question = value['descripcionPregunta'] as String?;
          final answerText = value['respuestaTexto'] as String?;

          if (question != null &&
              question.toLowerCase().contains('cuál es tu nombre') &&
              answerText != null &&
              answerText.isNotEmpty) {
            finalDisplayName = answerText;
            break;
          }
        }
      }
    }

    return UserCard(
      id: id,
      displayName: finalDisplayName,
      answers: answers,
      emojiPregunta: '',
      groupImages: groupImages,
    );
  }
}
