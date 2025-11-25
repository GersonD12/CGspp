import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calet/features/cards/domain/models/user_card.dart';
import 'package:calet/features/cards/domain/repositories/cards_repository.dart';
import 'dart:developer' show log;

class CardsRepositoryImpl implements CardsRepository {
  final FirebaseFirestore _firestore;

  CardsRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<UserCard>> fetchRandomUsers(int limit) async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final allUsers = usersSnapshot.docs;

      // Shuffle the list of users
      allUsers.shuffle();

      // Take the first [limit] users, or fewer if there aren't that many
      final randomUserDocs = allUsers.take(limit).toList();

      return randomUserDocs.map((doc) {
        return UserCard.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      log('Error fetching users: $e');
      return [];
    }
  }
}
