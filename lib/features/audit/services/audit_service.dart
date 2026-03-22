import 'package:flutter/foundation.dart';
import '../../../core/utils/session_manager.dart';
import '../../auth/models/user_model.dart';
import '../models/audit_log_model.dart';

class AuditService {
  static final List<AuditLogModel> _auditLogs = [
    AuditLogModel(
      id: 'aud_1',
      actionType: 'MEMBER_CREATE',
      performedBy: 'John Chairman',
      role: UserRole.chairman,
      targetEntity: 'Rajesh Sharma',
      newValue: 'Flat A-101',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AuditLogModel(
      id: 'aud_2',
      actionType: 'PAYMENT_RECORD',
      performedBy: 'Bob Treasurer',
      role: UserRole.treasurer,
      targetEntity: 'Member One',
      newValue: '₹4500 (UPI)',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AuditLogModel(
      id: 'aud_3',
      actionType: 'BILL_GENERATE',
      performedBy: 'Alice Secretary',
      role: UserRole.secretary,
      targetEntity: 'All Members',
      newValue: 'January 2025 Bills',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  static List<AuditLogModel> get auditLogs => List.unmodifiable(_auditLogs);

  static void logAction({
    required String actionType,
    required String targetEntity,
    String? oldValue,
    String? newValue,
  }) {
    final currentUser = SessionManager.currentUser;
    if (currentUser == null) return;

    final log = AuditLogModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      actionType: actionType,
      performedBy: currentUser.name,
      role: currentUser.role,
      targetEntity: targetEntity,
      oldValue: oldValue,
      newValue: newValue,
      timestamp: DateTime.now(),
    );

    _auditLogs.insert(0, log); // Newest first
    debugPrint(
      'AUDIT_LOG: [${log.timestamp}] ${log.performedBy} (${log.role.name}) -> ${log.actionType} on ${log.targetEntity}',
    );
  }

  static List<AuditLogModel> getLogsByFilter(String category) {
    if (category == 'All') return auditLogs;

    return _auditLogs.where((log) {
      if (category == 'Members') {
        return log.actionType.contains('MEMBER') ||
            log.actionType.contains('USER');
      }
      if (category == 'Payments') {
        return log.actionType.contains('PAYMENT') ||
            log.actionType.contains('BILL');
      }
      if (category == 'Reports') {
        return log.actionType.contains('REPORT');
      }
      return true;
    }).toList();
  }
}
