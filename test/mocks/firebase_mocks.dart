import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mock para Firebase Auth en tests
class MockFirebaseAuth {
  static Stream<User?> get authStateChanges => Stream.value(null);
}

/// Provider mock para tests
final mockSessionProvider = StreamProvider<User?>((ref) {
  return MockFirebaseAuth.authStateChanges;
});
