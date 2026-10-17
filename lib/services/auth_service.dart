
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the currently logged-in user
  User? get currentUser => _auth.currentUser;

  // Register a new patient or doctor
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? specialization,
    String? qualification,
    int? experience,
    double? consultationFee,
    String? bio,
  }) async {
    if (role != 'patient' && role != 'doctor') {
      throw ArgumentError('Role must be patient or doctor.');
    }

    final cleanName = name.trim();
    final cleanEmail = email.trim();

    if (cleanName.isEmpty) {
      throw ArgumentError('Name cannot be empty.');
    }

    if (cleanEmail.isEmpty) {
      throw ArgumentError('Email cannot be empty.');
    }

    if (password.length < 6) {
      throw ArgumentError('Password must contain at least 6 characters.');
    }

    // Step 1: Create the Firebase Authentication account.
    final UserCredential credential =
    await _auth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    final User? user = credential.user;

    if (user == null) {
      throw Exception('Firebase did not return a user account.');
    }

    try {
      // Step 2: Prepare the user profile.
      final Map<String, dynamic> userData = {
        'uid': user.uid,
        'name': cleanName,
        'email': cleanEmail,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Step 3: Save the profile to Firestore.
      if (role == 'patient') {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userData);
      } else {
        // Doctor profile fields
        final doctorData = <String, dynamic>{
          'ownerUid': user.uid,
          'name': cleanName,
          'specialization': (specialization ?? '').trim(),
          'qualification': (qualification ?? '').trim(),
          'experience': experience ?? 0,
          'consultationFee': consultationFee ?? 0.0,
          'bio': (bio ?? '').trim(),
          'available': false,
          'approvalStatus': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        };

        // Save user and doctor profiles together.
        final batch = _firestore.batch();

        batch.set(
          _firestore.collection('users').doc(user.uid),
          userData,
        );

        batch.set(
          _firestore.collection('doctors').doc(user.uid),
          doctorData,
        );

        await batch.commit();
      }

      // Step 4: Return the successfully registered account.
      return credential;
    } catch (e) {
      // Do not delete the Authentication account.
      // This lets you investigate and repair a failed Firestore write.
      print('FIRESTORE PROFILE SAVE FAILED: $e');
      rethrow;
    }
  }

  // Log in an existing user
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Log out
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get the user's profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final snapshot =
    await _firestore.collection('users').doc(user.uid).get();

    return snapshot.data();
  }

  // Listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
