enum UserRole {
  chairman,
  secretary,
  treasurer,
  member;

  String get label {
    switch (this) {
      case UserRole.chairman:
        return 'Chairman';
      case UserRole.secretary:
        return 'Secretary';
      case UserRole.treasurer:
        return 'Treasurer';
      case UserRole.member:
        return 'Member';
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String mobile;
  final String flatNumber;
  final UserRole role;
  final String societyId;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.mobile,
    this.flatNumber = '',
    required this.role,
    required this.societyId,
    this.isActive = true,
    this.createdBy = 'System',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'mobile': mobile,
      'flatNumber': flatNumber,
      'role': role.name,
      'societyId': societyId,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      mobile: map['mobile'] ?? '',
      flatNumber: map['flatNumber'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.member,
      ),
      societyId: map['societyId'] ?? '',
      isActive: map['isActive'] ?? true,
      createdBy: map['createdBy'] ?? 'System',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? password,
    String? mobile,
    String? flatNumber,
    UserRole? role,
    String? societyId,
    bool? isActive,
    String? createdBy,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      mobile: mobile ?? this.mobile,
      flatNumber: flatNumber ?? this.flatNumber,
      role: role ?? this.role,
      societyId: societyId ?? this.societyId,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt,
    );
  }
}
