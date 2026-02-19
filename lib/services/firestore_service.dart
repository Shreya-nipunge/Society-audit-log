import '../features/auth/models/user_model.dart';

class FirestoreService {
  Future<void> createUserProfile(UserModel user) async {
    // Stubbed
  }

  Future<UserModel?> getUserProfile(String uid) async {
    // Stubbed
    return null;
  }

  Future<bool> isUserAdmin(String uid) async {
    // Stubbed
    return false;
  }
}
