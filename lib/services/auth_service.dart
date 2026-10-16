import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around FirebaseAuth that also provisions the Firestore
/// profile document (`users/{uid}`) on registration.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  String get currentUid => _auth.currentUser?.uid ?? '';

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signIn({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Creates the auth account and the matching Firestore operator profile.
  Future<UserCredential> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    final handle = normalizeUsername(username);

    await _db.collection('users').doc(user.uid).set({
      'name': handle,
      'username': handle,
      'email': email.trim(),
      'bio': '',
      'pronouns': '',
      'website': '',
      'avatarUrl': 'https://i.pravatar.cc/200?img=12',
      'pinsCount': 0,
      'boardsCount': 0,
      'savesReceived': 0,
      'followersCount': 0,
      'followingCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await user.updateDisplayName(handle);
    return credential;
  }

  Future<bool> isUsernameTaken(String username) async {
    final handle = normalizeUsername(username).toLowerCase();
    final query = await _db
        .collection('users')
        .where('username', isEqualTo: handle)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() => _auth.signOut();

  static String normalizeUsername(String username) {
    return username.trim().replaceAll('@', '').toLowerCase();
  }

  /// Maps FirebaseAuth error codes to the terminal style copy used by the UI.
  static String friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'MALFORMED EMAIL LINE // CHECK ADDRESS';
        case 'user-disabled':
          return 'OPERATOR SUSPENDED // CONTACT CONTROL';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'ACCESS DENIED // INVALID CREDENTIALS';
        case 'email-already-in-use':
          return 'EMAIL ALREADY REGISTERED // SIGN IN INSTEAD';
        case 'weak-password':
          return 'WEAK SECRET // MIN 6 CHARACTERS';
        case 'too-many-requests':
          return 'RATE LIMITED // RETRY LATER';
        case 'network-request-failed':
          return 'NETWORK UPLINK FAILED // CHECK CONNECTION';
        default:
          return 'AUTH FAULT: ${error.code.toUpperCase()}';
      }
    }
    return 'UNEXPECTED FAULT // RETRY';
  }
}
