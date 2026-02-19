class BillModel {
  final String id;
  final String memberId;
  final String month; // e.g., "October 2026"
  final double maintenanceAmount;
  final double waterCharges;
  final double otherCharges;
  final double total;
  final DateTime generatedAt;
  final bool isPaid;

  BillModel({
    required this.id,
    required this.memberId,
    required this.month,
    required this.maintenanceAmount,
    required this.waterCharges,
    required this.otherCharges,
    required this.total,
    required this.generatedAt,
    this.isPaid = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'month': month,
      'maintenanceAmount': maintenanceAmount,
      'waterCharges': waterCharges,
      'otherCharges': otherCharges,
      'total': total,
      'generatedAt': generatedAt.toIso8601String(),
      'isPaid': isPaid,
    };
  }

  BillModel copyWith({bool? isPaid}) {
    return BillModel(
      id: id,
      memberId: memberId,
      month: month,
      maintenanceAmount: maintenanceAmount,
      waterCharges: waterCharges,
      otherCharges: otherCharges,
      total: total,
      generatedAt: generatedAt,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
