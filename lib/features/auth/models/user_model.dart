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
  final String uid; // ERD: uid
  final String name; 
  final String email;
  final String phone; // ERD: phone (was mobile)
  final String password; // Kept local assuming auth layer uses it
  final String flatNumber;
  final UserRole role;
  final String societyId; // Kept local
  final String status; // ERD: status (was isActive boolean)
  final String createdBy; // Kept local
  final DateTime createdAt;

  // Ledger Data (B-O)
  final double openingBalance;
  final double sinkingFund;
  final double maintenanceAmount;
  final double municipalTax;
  final double noc;
  final double parkingCharges;
  final double delayCharges;
  final double buildingFund;
  final double roomTransferFees;
  final double totalReceivable;
  final double totalReceived;
  final double closingBalance;

  // Charges Types (Q-S)
  final double fixedMonthlyCharges;
  final double annualCharges;
  final double variableCharges;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    this.flatNumber = '',
    required this.role,
    required this.societyId,
    this.status = 'active',
    this.createdBy = 'System',
    this.openingBalance = 0,
    this.sinkingFund = 0,
    this.maintenanceAmount = 0,
    this.municipalTax = 0,
    this.noc = 0,
    this.parkingCharges = 0,
    this.delayCharges = 0,
    this.buildingFund = 0,
    this.roomTransferFees = 0,
    this.totalReceivable = 0,
    this.totalReceived = 0,
    this.closingBalance = 0,
    this.fixedMonthlyCharges = 0,
    this.annualCharges = 0,
    this.variableCharges = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'flatNumber': flatNumber,
      'role': role.name,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'openingBalance': openingBalance,
      'sinkingFund': sinkingFund,
      'maintenanceAmount': maintenanceAmount,
      'municipalTax': municipalTax,
      'noc': noc,
      'parkingCharges': parkingCharges,
      'delayCharges': delayCharges,
      'buildingFund': buildingFund,
      'roomTransferFees': roomTransferFees,
      'totalReceivable': totalReceivable,
      'totalReceived': totalReceived,
      'closingBalance': closingBalance,
      'fixedMonthlyCharges': fixedMonthlyCharges,
      'annualCharges': annualCharges,
      'variableCharges': variableCharges,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? map['mobile'] ?? '',
      password: map['password'] ?? '', // Default to empty string if missing as it might not be in the map
      flatNumber: map['flatNumber'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.member,
      ),
      societyId: map['societyId'] ?? '',
      status: map['status'] ?? (map['isActive'] == true ? 'active' : 'inactive'),
      createdBy: map['createdBy'] ?? 'System',
      openingBalance: (map['openingBalance'] ?? 0).toDouble(),
      sinkingFund: (map['sinkingFund'] ?? 0).toDouble(),
      maintenanceAmount: (map['maintenanceAmount'] ?? 0).toDouble(),
      municipalTax: (map['municipalTax'] ?? 0).toDouble(),
      noc: (map['noc'] ?? 0).toDouble(),
      parkingCharges: (map['parkingCharges'] ?? 0).toDouble(),
      delayCharges: (map['delayCharges'] ?? 0).toDouble(),
      buildingFund: (map['buildingFund'] ?? 0).toDouble(),
      roomTransferFees: (map['roomTransferFees'] ?? 0).toDouble(),
      totalReceivable: (map['totalReceivable'] ?? 0).toDouble(),
      totalReceived: (map['totalReceived'] ?? 0).toDouble(),
      closingBalance: (map['closingBalance'] ?? 0).toDouble(),
      fixedMonthlyCharges: (map['fixedMonthlyCharges'] ?? 0).toDouble(),
      annualCharges: (map['annualCharges'] ?? 0).toDouble(),
      variableCharges: (map['variableCharges'] ?? 0).toDouble(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  // Backwards compatibility getter for existing mocks where `id` was used
  String get id => uid;
  bool get isActive => status == 'active';

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? flatNumber,
    UserRole? role,
    String? societyId,
    String? status,
    String? createdBy,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      flatNumber: flatNumber ?? this.flatNumber,
      role: role ?? this.role,
      societyId: societyId ?? this.societyId,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt,
    );
  }
}
