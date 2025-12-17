abstract class QuestionsRepository {
  /// Fetches all questions from the 'questions' collection
  /// Returns a map of {preguntaId: questionData}
  Future<Map<String, Map<String, dynamic>>> fetchAllQuestions();
}
