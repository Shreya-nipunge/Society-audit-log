import '../../features/auth/models/user_model.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  static UserModel? currentUser;

  void login(UserModel user) {
    currentUser = user;
  }

  void logout() {
    currentUser = null;
  }

  bool get isLoggedIn => currentUser != null;
  bool get isAdmin =>
      currentUser != null && currentUser!.role != UserRole.member;
}
