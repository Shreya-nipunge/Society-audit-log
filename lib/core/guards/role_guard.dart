import 'package:flutter/material.dart';
import '../utils/session_manager.dart';
import '../../features/auth/models/user_model.dart';

class RoleGuard extends StatelessWidget {
  final Widget child;
  final List<UserRole> allowedRoles;

  const RoleGuard({super.key, required this.child, required this.allowedRoles});

  @override
  Widget build(BuildContext context) {
    final user = SessionManager.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to access this page')),
      );
    }

    if (allowedRoles.contains(user.role)) {
      return child;
    }

    return const Scaffold(
      body: Center(child: Text('Access Denied: Insufficient Permissions')),
    );
  }
}
