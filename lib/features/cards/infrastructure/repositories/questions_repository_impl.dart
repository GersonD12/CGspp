import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calet/features/cards/domain/repositories/questions_repository.dart';
import 'dart:developer' show log;

class QuestionsRepositoryImpl implements QuestionsRepository {
  final FirebaseFirestore _firestore;

  QuestionsRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Map<String, Map<String, dynamic>>> fetchAllQuestions() async {
    try {
      final Map<String, Map<String, dynamic>> questionsMap = {};

      // Fetch all group documents from the 'questions' collection
      final groupsSnapshot = await _firestore.collection('questions').get();

      // Iterate through each group
      for (var groupDoc in groupsSnapshot.docs) {
        final groupId = groupDoc.id;
        final groupData = groupDoc.data();
        final groupTitle = groupData['titulo'] as String? ?? '';

        try {
          // Fetch all questions in this group's 'questions' subcollection
          final questionsSnapshot = await _firestore
              .collection('questions')
              .doc(groupId)
              .collection('questions')
              .get();

          // Add each question to the map
          for (var questionDoc in questionsSnapshot.docs) {
            final preguntaId = questionDoc.id;
            final questionData = questionDoc.data();

            // Add the groupId to the question data for reference
            questionData['grupoId'] = groupId;
            // Add the group title to the question data
            questionData['groupTitle'] = groupTitle;

            questionsMap[preguntaId] = questionData;
          }
        } catch (e) {
          log('Error fetching questions for group $groupId: $e');
        }
      }

      log('Fetched ${questionsMap.length} questions from all groups.');
      return questionsMap;
    } catch (e) {
      log('Error fetching questions: $e');
      return {};
    }
  }
}
