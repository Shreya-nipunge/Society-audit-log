enum ComplaintStatus { pending, inProgress, resolved, rejected }

enum ComplaintCategory {
  maintenance,
  billing,
  security,
  noise,
  parking,
  cleanliness,
  water,
  electricity,
  other,
}

extension ComplaintCategoryLabel on ComplaintCategory {
  String get label {
    switch (this) {
      case ComplaintCategory.maintenance:
        return 'Maintenance';
      case ComplaintCategory.billing:
        return 'Billing';
      case ComplaintCategory.security:
        return 'Security';
      case ComplaintCategory.noise:
        return 'Noise';
      case ComplaintCategory.parking:
        return 'Parking';
      case ComplaintCategory.cleanliness:
        return 'Cleanliness';
      case ComplaintCategory.water:
        return 'Water Supply';
      case ComplaintCategory.electricity:
        return 'Electricity';
      case ComplaintCategory.other:
        return 'Other';
    }
  }
}

extension ComplaintStatusLabel on ComplaintStatus {
  String get label {
    switch (this) {
      case ComplaintStatus.pending:
        return 'Pending';
      case ComplaintStatus.inProgress:
        return 'In Progress';
      case ComplaintStatus.resolved:
        return 'Resolved';
      case ComplaintStatus.rejected:
        return 'Rejected';
    }
  }
}

class ComplaintModel {
  final String id;
  final String memberId;
  final String memberName;
  final String flatNumber;
  final ComplaintCategory category;
  final String title;
  final String description;
  ComplaintStatus status;
  final DateTime createdAt;
  DateTime updatedAt;
  String? adminRemarks;
  String? resolvedBy;

  ComplaintModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.flatNumber,
    required this.category,
    required this.title,
    required this.description,
    this.status = ComplaintStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    this.adminRemarks,
    this.resolvedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'flatNumber': flatNumber,
      'category': category.name,
      'title': title,
      'description': description,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'adminRemarks': adminRemarks,
      'resolvedBy': resolvedBy,
    };
  }

  factory ComplaintModel.fromMap(Map<String, dynamic> map) {
    return ComplaintModel(
      id: map['id'] ?? '',
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      flatNumber: map['flatNumber'] ?? '',
      category: ComplaintCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ComplaintCategory.other,
      ),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: ComplaintStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ComplaintStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      adminRemarks: map['adminRemarks'],
      resolvedBy: map['resolvedBy'],
    );
  }
}
