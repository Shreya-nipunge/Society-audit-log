import '../../auth/models/user_model.dart';

class AuditLogModel {
  final String id;
  final String actionType;
  final String performedBy;
  final UserRole role;
  final String targetEntity;
  final String? oldValue;
  final String? newValue;
  final DateTime timestamp;

  AuditLogModel({
    required this.id,
    required this.actionType,
    required this.performedBy,
    required this.role,
    required this.targetEntity,
    this.oldValue,
    this.newValue,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'action': actionType,
      'timestamp': timestamp.toIso8601String(),
      'performedBy': performedBy,
      'details': 'Action on $targetEntity. ${oldValue != null ? "Changed from $oldValue to $newValue" : ""}',
      // Local App properties
      'id': id,
      'actionType': actionType,
      'role': role.name,
      'targetEntity': targetEntity,
      'oldValue': oldValue,
      'newValue': newValue,
    };
  }

  factory AuditLogModel.fromMap(Map<String, dynamic> map, String docId) {
    return AuditLogModel(
      id: docId,
      actionType: map['action'] ?? map['actionType'] ?? '',
      performedBy: map['performedBy'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.member,
      ),
      targetEntity: map['targetEntity'] ?? '',
      oldValue: map['oldValue'],
      newValue: map['newValue'],
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
    );
  }
}
