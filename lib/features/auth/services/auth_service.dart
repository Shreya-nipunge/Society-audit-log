import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String mobile,
    required UserRole role,
    required String societyId,
  }) async {
    // Stubbed for mock phase
    return null;
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    // Stubbed for mock phase
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
