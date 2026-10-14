
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register a new patient or doctor
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    if (role != 'patient' && role != 'doctor') {
      throw ArgumentError('Invalid user role.');
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    try {
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'uid': credential.user!.uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return credential;
    } catch (_) {
      // Avoid leaving an account without its profile if saving fails.
      await credential.user?.delete();
      rethrow;
    }
  }

  // Log in an existing user
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Log out the current user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get the signed-in user's Firestore profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    return snapshot.data();
  }
}
