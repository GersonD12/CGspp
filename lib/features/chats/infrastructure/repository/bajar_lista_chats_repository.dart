import 'package:calet/features/chats/infrastructure/data/bajar_lista_chats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BajarListaChatsRepository {
  /// Escucha la lista de chats en tiempo real desde la colección 'lista_chats'
  Stream<List<BajarListaChats>> escucharListaChats() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('lista_chats')
        .doc(currentUser.uid)
        .snapshots()
        .asyncMap((docSnapshot) async {
          if (!docSnapshot.exists || docSnapshot.data() == null) return [];

          final data = docSnapshot.data()!;
          final List<BajarListaChats> chats = [];

          for (var entry in data.entries) {
            final chatData = entry.value as Map<String, dynamic>;
            final String idChat = entry.key;
            final String otherUserUid = chatData['otherUserUid'] ?? '';

            if (otherUserUid.isEmpty) continue;

            // Fetch fresh user data for display from the 'users' collection
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(otherUserUid)
                .get();

            final String otherUserName = userDoc.exists
                ? (userDoc.data()?['displayName'] ?? 'Usuario')
                : 'Usuario';

            final String otherUserPhoto = userDoc.exists
                ? (userDoc.data()?['photoUrl'] ?? '')
                : '';

            chats.add(
              BajarListaChats.fromFirestore(
                json: chatData,
                idChat: idChat,
                currentUserUid: currentUser.uid,
                otherUserDisplayName: otherUserName,
                otherUserProfileImage: otherUserPhoto,
              ),
            );
          }

          chats.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return chats;
        });
  }
}
