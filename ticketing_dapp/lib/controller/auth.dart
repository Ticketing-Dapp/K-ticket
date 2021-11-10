import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseAuth auth = FirebaseAuth.instance;
final googleSignIn = GoogleSignIn();

Future<bool> googleLogin() async {
  final googleUser = await googleSignIn.signIn();

  final googleAuth = await googleUser!.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final result = await auth.signInWithCredential(credential);
  User user = await auth.currentUser!;
  print(user);
  return Future.value(true);
}

Future<bool> signIn(String email, String password) async {
  try {
    final result =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    // User? user = result.user;
    return Future.value(true);
  } on FirebaseAuthException catch (e) {
    print('Sign In Error');
    print(e.message);
    return Future.value(false);
  }
}

Future<bool> signUp(String email, String password, int typeUser) async {
  try {
    final result = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    // User? user = result.user;
    FirebaseFirestore.instance
        .collection('users')
        .doc(result.user!.uid)
        .set({'email': email, 'type': typeUser});
    return Future.value(true);
  } on FirebaseAuthException catch (e) {
    print('Sign Up Error');
    print(e.message);
    return Future.value(false);
  }
}

Future<bool> signOutUser() async {
  User user = auth.currentUser!;

  if (user.providerData[1].providerId == 'google.com') {
    await googleSignIn.disconnect();
  }
  await auth.signOut();
  return Future.value(true);
}
