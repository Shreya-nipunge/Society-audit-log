class FundAllocation {
  final double maintenance;
  final double sinkingFund;
  final double repairsFund;
  final double waterCharges;
  final double other;

  FundAllocation({
    this.maintenance = 0.0,
    this.sinkingFund = 0.0,
    this.repairsFund = 0.0,
    this.waterCharges = 0.0,
    this.other = 0.0,
  });

  double get total =>
      maintenance + sinkingFund + repairsFund + waterCharges + other;

  Map<String, dynamic> toMap() {
    return {
      'maintenance': maintenance,
      'sinkingFund': sinkingFund,
      'repairsFund': repairsFund,
      'waterCharges': waterCharges,
      'other': other,
    };
  }

  factory FundAllocation.fromMap(Map<String, dynamic> map) {
    return FundAllocation(
      maintenance: (map['maintenance'] ?? 0.0).toDouble(),
      sinkingFund: (map['sinkingFund'] ?? 0.0).toDouble(),
      repairsFund: (map['repairsFund'] ?? 0.0).toDouble(),
      waterCharges: (map['waterCharges'] ?? 0.0).toDouble(),
      other: (map['other'] ?? 0.0).toDouble(),
    );
  }
}
