import '../../features/auth/models/user_model.dart';
import 'session_manager.dart';

class PermissionManager {
  static UserRole? get _role => SessionManager.currentUser?.role;

  static bool isChairman() => _role == UserRole.chairman;
  static bool isSecretary() => _role == UserRole.secretary;
  static bool isTreasurer() => _role == UserRole.treasurer;
  static bool isMember() => _role == UserRole.member;

  // Permission Checks
  static bool canEditMembers() =>
      isChairman() || isSecretary() || isTreasurer();
  static bool canAssignRoles() => isChairman();

  static bool canRecordPayments() => isChairman() || isTreasurer();

  static bool canGenerateReports() =>
      isChairman() || isSecretary() || isTreasurer();

  static bool canGenerateBills() =>
      isChairman() || isTreasurer() || isSecretary();

  static bool canUploadDocs() => isChairman() || isSecretary();
}
