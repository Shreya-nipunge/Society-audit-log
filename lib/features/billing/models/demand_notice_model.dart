class DemandNoticeModel {
  final String id;
  final String memberId;
  final String month;
  final int year;
  final double maintenance;
  final double waterCharges;
  final double otherCharges;
  final DateTime dueDate;
  final DateTime generatedAt;

  DemandNoticeModel({
    required this.id,
    required this.memberId,
    required this.month,
    required this.year,
    required this.maintenance,
    this.waterCharges = 0.0,
    this.otherCharges = 0.0,
    required this.dueDate,
    required this.generatedAt,
  });

  double get total => maintenance + waterCharges + otherCharges;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'month': month,
      'year': year,
      'maintenance': maintenance,
      'waterCharges': waterCharges,
      'otherCharges': otherCharges,
      'dueDate': dueDate.toIso8601String(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory DemandNoticeModel.fromMap(Map<String, dynamic> map) {
    return DemandNoticeModel(
      id: map['id'] ?? '',
      memberId: map['memberId'] ?? '',
      month: map['month'] ?? '',
      year: map['year'] ?? 2025,
      maintenance: (map['maintenance'] ?? 0.0).toDouble(),
      waterCharges: (map['waterCharges'] ?? 0.0).toDouble(),
      otherCharges: (map['otherCharges'] ?? 0.0).toDouble(),
      dueDate: DateTime.parse(map['dueDate']),
      generatedAt: DateTime.parse(map['generatedAt']),
    );
  }
}
