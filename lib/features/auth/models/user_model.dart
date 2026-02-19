enum UserRole {
  chairman,
  secretary,
  treasurer,
  member;

  String get name => toString().split('.').last;
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final UserRole role;
  final String societyId;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.role,
    required this.societyId,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'role': role.name,
      'societyId': societyId,
      'isActive': isActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      mobile: map['mobile'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.member,
      ),
      societyId: map['societyId'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? mobile,
    UserRole? role,
    String? societyId,
    bool? isActive,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      role: role ?? this.role,
      societyId: societyId ?? this.societyId,
      isActive: isActive ?? this.isActive,
    );
  }
}
