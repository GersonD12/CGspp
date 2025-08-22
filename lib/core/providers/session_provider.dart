import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calet/core/domain/entities/entities.dart';

/// Provider que escucha cambios en la sesión de Firebase
/// y los convierte a entidades del dominio
final sessionProvider = StreamProvider<UserEntity?>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((firebaseUser) {
    if (firebaseUser == null) return null;
    return UserEntity.fromFirebaseUser(firebaseUser);
  });
});

/// Provider que indica si el usuario está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final session = ref.watch(sessionProvider);
  return session.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider que proporciona el usuario actual como entidad del dominio
final currentUserProvider = Provider<UserEntity?>((ref) {
  final session = ref.watch(sessionProvider);
  return session.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});
