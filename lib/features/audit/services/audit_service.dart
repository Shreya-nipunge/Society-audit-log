import 'package:flutter/foundation.dart';
import '../../../core/utils/session_manager.dart';
import '../models/audit_log_model.dart';

class AuditService {
  static final List<AuditLogModel> _auditLogs = [];

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
