import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._();
  static final instance = GoogleAuthService._();

  Future<UserCredential?> signInWithGoogle() async {
    // Flujo móvil (Android/iOS)
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null; // cancelado por el usuario

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOut({bool revoke = false}) async {
    // 1) Firebase
    await FirebaseAuth.instance.signOut();

    // 2) Cerrar / revocar GoogleSignIn para evitar reuso automático
    final g = GoogleSignIn();
    try {
      if (revoke) {
        // Fuerza a volver a consentir/seleccionar cuenta la próxima vez
        await g.disconnect();
      } else {
        await g.signOut();
      }
    } catch (_) {
      // Ignorar si ya estaba desconectado
    }
  }
}

