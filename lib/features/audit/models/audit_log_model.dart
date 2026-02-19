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
      'id': id,
      'actionType': actionType,
      'performedBy': performedBy,
      'role': role.name,
      'targetEntity': targetEntity,
      'oldValue': oldValue,
      'newValue': newValue,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AuditLogModel.fromMap(Map<String, dynamic> map) {
    return AuditLogModel(
      id: map['id'] ?? '',
      actionType: map['actionType'] ?? '',
      performedBy: map['performedBy'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.member,
      ),
      targetEntity: map['targetEntity'] ?? '',
      oldValue: map['oldValue'],
      newValue: map['newValue'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
