import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calet/core/domain/entities/entities.dart';
import 'dart:developer' show log;

class SessionData {
  final UserEntity? user;
  final bool isNew;

  SessionData(this.user, this.isNew);
}

/// Provider that listens to Firebase session changes and converts them to domain entities
final sessionProvider = StreamProvider<SessionData>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncMap((
    firebaseUser,
  ) async {
    if (firebaseUser == null) {
      return SessionData(null, false);
    }

    // Verificar que el token siga siendo válido en el servidor
    // Esto detecta si el usuario fue eliminado
    User? currentUser = firebaseUser;
    try {
      await firebaseUser.reload();
      // Obtener el usuario actualizado después de reload
      currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return SessionData(null, false);
      }
    } catch (e) {
      log('Token inválido o usuario eliminado: $e');
      // Forzar cierre de sesión si el token es inválido
      await FirebaseAuth.instance.signOut();
      return SessionData(null, false);
    }

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid);

    final doc = await userDoc.get();
    final bool isNew = !doc.exists;

    if (isNew) {
      log('New user detected: ${currentUser.email}');
      await userDoc.set({
        'email': currentUser.email,
        'displayName': currentUser.displayName,
        'photoURL': currentUser.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    final userEntity = UserEntity.fromFirebaseUser(currentUser);
    return SessionData(userEntity, isNew);
  });
});

/// Provider que indica si el usuario está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final session = ref.watch(sessionProvider);
  return session.when(
    data: (sessionData) => sessionData.user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider que proporciona el usuario actual como entidad del dominio
final currentUserProvider = Provider<UserEntity?>((ref) {
  final session = ref.watch(sessionProvider);
  return session.when(
    data: (sessionData) => sessionData.user,
    loading: () => null,
    error: (_, __) => null,
  );
});
