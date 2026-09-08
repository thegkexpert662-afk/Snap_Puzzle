import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  static Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
      await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await auth.signInWithCredential(credential);

      final User user = userCredential.user!;

      final playerRef =
      firestore.collection("players").doc(user.uid);

      final playerDoc = await playerRef.get();

      if (playerDoc.exists) {
        await playerRef.update({
          "isOnline": true,
          "lastLogin": FieldValue.serverTimestamp(),
        });

        return user;
      }

      await playerRef.set({
        "uid": user.uid,
        "playerId": "SP${DateTime.now().millisecondsSinceEpoch}",
        "name": user.displayName ?? "Player",
        "email": user.email ?? "",
        "photoUrl": user.photoURL ?? "",
        "coins": 100,
        "bestScore": 0,
        "bestTime": 0,
        "totalScore": 0,
        "totalPuzzlesSolved": 0,
        "isOnline": true,
        "isBanned": false,
        "level": 1,
        "xp": 0,
        "nextLevelXp": 100,
        "totalPuzzleCompleted": 0,
        "createdAt": FieldValue.serverTimestamp(),
        "lastLogin": FieldValue.serverTimestamp(),
      });

      return user;
    } catch (e) {
      print("Google Login Error: $e");
      return null;
    }
  }

  static Future<void> signOut() async {
    await firestore
        .collection("players")
        .doc(auth.currentUser!.uid)
        .update({
      "isOnline": false,
    });

    await GoogleSignIn().signOut();
    await auth.signOut();
  }
}