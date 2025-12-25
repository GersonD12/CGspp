import 'package:firebase_auth/firebase_auth.dart';
import 'package:calet/features/auth/infrastructure/google_auth_service.dart';

abstract class AuthRepository {
  Future<UserCredential?> signInWithGoogle();
  Future<void> signOut({bool revoke = false});
  Stream<User?> get authStateChanges;
}

class AuthRepositoryImpl implements AuthRepository {
  final GoogleAuthService _googleAuthService;
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl({
    GoogleAuthService? googleAuthService,
    FirebaseAuth? firebaseAuth,
  }) : _googleAuthService = googleAuthService ?? GoogleAuthService.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<UserCredential?> signInWithGoogle() async {
    return await _googleAuthService.signInWithGoogle();
  }

  @override
  Future<void> signOut({bool revoke = false}) async {
    return await _googleAuthService.signOut(revoke: revoke);
  }

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
