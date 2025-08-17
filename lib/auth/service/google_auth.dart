// class to handle google sign-in and sign-out
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseServices {
  final auth = FirebaseAuth.instance;
  // create googleSignIn instance
  final googleSignIn = GoogleSignIn();

  // method to sign in using google
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn
          .signIn();

      // Check if user cancelled the sign in
      if (googleSignInAccount == null) {
        return false; // User cancelled
      }

      // get authentication tokens
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      // create a firebase credential using the tokens from google
      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // sign in to firebase using the googlel credential
      await auth.signInWithCredential(authCredential);
      return true; // Sign-in successful
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return false; // Error occurred
    }
  }

  // method to sign out from both firebase and google
  Future<void> signOut() async {
    // sign out from firebase
    await auth.signOut();
    // from google
    await googleSignIn.signOut();
  }
}
