class BillModel {
  final String id;
  final String memberId;
  final String flatNumber; // New for ERD
  final int month; // New for ERD (Number instead of string)
  final int year; // New for ERD
  final double maintenanceAmount;
  final double otherCharges; // Combines local ones for ERD
  final double totalAmount; // 'totalAmount' for ERD (was 'total')
  final double paidAmount; // New for ERD
  final String status; // New for ERD
  final DateTime generatedAt;
  final DateTime dueDate; // New for ERD

  // Keep these locals for the frontend mock if needed
  final double buildingFund;
  final double municipalTax;
  final String monthString;
  final bool isPaid;

  BillModel({
    required this.id,
    required this.memberId,
    this.flatNumber = '',
    this.month = 1,
    this.year = 2026,
    required this.maintenanceAmount,
    this.buildingFund = 0,
    this.municipalTax = 0,
    required this.otherCharges,
    required this.totalAmount,
    this.paidAmount = 0,
    this.status = 'pending',
    required this.generatedAt,
    DateTime? dueDate,
    this.monthString = '',
    this.isPaid = false,
  }) : dueDate = dueDate ?? DateTime.now().add(const Duration(days: 15));

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'flatNumber': flatNumber,
      'month': month,
      'year': year,
      'maintenanceAmount': maintenanceAmount,
      'otherCharges': otherCharges,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'status': status,
      'generatedAt': generatedAt.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'] ?? '',
      memberId: map['memberId'] ?? '',
      flatNumber: map['flatNumber'] ?? '',
      month: map['month'] ?? 1,
      year: map['year'] ?? 2026,
      maintenanceAmount: (map['maintenanceAmount'] ?? 0).toDouble(),
      buildingFund: (map['buildingFund'] ?? 0).toDouble(),
      municipalTax: (map['municipalTax'] ?? 0).toDouble(),
      otherCharges: (map['otherCharges'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? map['total'] ?? 0).toDouble(),
      paidAmount: (map['paidAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      generatedAt: map['generatedAt'] != null ? DateTime.parse(map['generatedAt']) : DateTime.now(),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : DateTime.now().add(const Duration(days: 15)),
      isPaid: map['status'] == 'paid',
    );
  }

  BillModel copyWith({bool? isPaid, String? status}) {
    return BillModel(
      id: id,
      memberId: memberId,
      flatNumber: flatNumber,
      month: month,
      year: year,
      maintenanceAmount: maintenanceAmount,
      buildingFund: buildingFund,
      municipalTax: municipalTax,
      otherCharges: otherCharges,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      status: status ?? this.status,
      generatedAt: generatedAt,
      dueDate: dueDate,
      monthString: monthString,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
