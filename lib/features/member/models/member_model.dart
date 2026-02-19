class MemberModel {
  final String id;
  final String name;
  final String flatNo;
  final String mobile;
  final String email;
  final DateTime joiningDate;
  final String societyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  MemberModel({
    required this.id,
    required this.name,
    required this.flatNo,
    required this.mobile,
    required this.email,
    required this.joiningDate,
    required this.societyId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'flatNo': flatNo,
      'mobile': mobile,
      'email': email,
      'joiningDate': joiningDate.toIso8601String(),
      'societyId': societyId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      flatNo: map['flatNo'] ?? '',
      mobile: map['mobile'] ?? '',
      email: map['email'] ?? '',
      joiningDate: DateTime.parse(map['joiningDate']),
      societyId: map['societyId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  MemberModel copyWith({
    String? name,
    String? flatNo,
    String? mobile,
    String? email,
    DateTime? joiningDate,
    DateTime? updatedAt,
  }) {
    return MemberModel(
      id: id,
      name: name ?? this.name,
      flatNo: flatNo ?? this.flatNo,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      joiningDate: joiningDate ?? this.joiningDate,
      societyId: societyId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
