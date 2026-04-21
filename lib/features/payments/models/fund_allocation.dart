class FundAllocation {
  final double maintenance;
  final double sinkingFund;
  final double repairsFund;
  final double buildingFund;
  final double municipalTax;
  final double other;

  FundAllocation({
    this.maintenance = 0.0,
    this.sinkingFund = 0.0,
    this.repairsFund = 0.0,
    this.buildingFund = 0.0,
    this.municipalTax = 0.0,
    this.other = 0.0,
  });

  double get total =>
      maintenance + sinkingFund + repairsFund + buildingFund + municipalTax + other;

  Map<String, dynamic> toMap() {
    return {
      'maintenance': maintenance,
      'sinkingFund': sinkingFund,
      'repairsFund': repairsFund,
      'buildingFund': buildingFund,
      'municipalTax': municipalTax,
      'other': other,
    };
  }

  factory FundAllocation.fromMap(Map<String, dynamic> map) {
    return FundAllocation(
      maintenance: (map['maintenance'] ?? 0.0).toDouble(),
      sinkingFund: (map['sinkingFund'] ?? 0.0).toDouble(),
      repairsFund: (map['repairsFund'] ?? 0.0).toDouble(),
      buildingFund: (map['buildingFund'] ?? 0.0).toDouble(),
      municipalTax: (map['municipalTax'] ?? 0.0).toDouble(),
      other: (map['other'] ?? 0.0).toDouble(),
    );
  }
}
