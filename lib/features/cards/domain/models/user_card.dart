class UserCard {
  final String id;
  final String displayName;
  final Map<String, dynamic> answers;

  UserCard({
    required this.id,
    required this.displayName,
    required this.answers,
  });

  factory UserCard.fromMap(String id, Map<String, dynamic> data) {
    final defaultDisplayName = data['displayName'] ?? 'No name';

    final formResponses = data['form_responses'] as Map<String, dynamic>?;
    final Map<String, dynamic> answers = {};

    if (formResponses != null) {
      if (formResponses.containsKey('grupos')) {
        final grupos = formResponses['grupos'] as Map<String, dynamic>?;
        if (grupos != null) {
          grupos.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              answers.addAll(value);
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

    return UserCard(id: id, displayName: finalDisplayName, answers: answers);
  }
}
