import 'package:calet/features/cards/domain/models/user_card.dart';

abstract class CardsRepository {
  Future<List<UserCard>> fetchRandomUsers(int limit);
}
