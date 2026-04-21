class MaintenanceReceiptModel {
  final String id;
  final String memberId;
  final String flatOwnerName;
  final String floor; // '1st Floor', '2nd Floor', '3rd Floor', '4th Floor'
  final String roomNo;
  final DateTime periodFrom;
  final DateTime periodTo;

  // Charge Breakdown
  final double sinkingFund;
  final double maintenance;
  final double municipalTax;
  final double noc;
  final double parkingCharges;
  final double miscellaneous;
  final double buildingFund;

  // Penalty
  final double penaltyAmount; // ₹25 × late months
  final int lateMonths;

  // Totals
  final double totalAmount;
  final String receivedRupeesInWords;

  // Payment Details
  final String paymentMode; // 'Cash', 'Cheque', 'UPI'
  final String? chequeNo;
  final String? drawnOn;
  final String? upiId;

  // Metadata
  final String generatedBy;
  final DateTime generatedAt;
  final String receiptNo;

  MaintenanceReceiptModel({
    required this.id,
    required this.memberId,
    required this.flatOwnerName,
    required this.floor,
    required this.roomNo,
    required this.periodFrom,
    required this.periodTo,
    required this.sinkingFund,
    required this.maintenance,
    required this.municipalTax,
    this.noc = 0,
    this.parkingCharges = 0,
    this.miscellaneous = 0,
    required this.buildingFund,
    this.penaltyAmount = 0,
    this.lateMonths = 0,
    required this.totalAmount,
    required this.receivedRupeesInWords,
    required this.paymentMode,
    this.chequeNo,
    this.drawnOn,
    this.upiId,
    required this.generatedBy,
    required this.generatedAt,
    required this.receiptNo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'flatOwnerName': flatOwnerName,
      'floor': floor,
      'roomNo': roomNo,
      'periodFrom': periodFrom.toIso8601String(),
      'periodTo': periodTo.toIso8601String(),
      'sinkingFund': sinkingFund,
      'maintenance': maintenance,
      'municipalTax': municipalTax,
      'noc': noc,
      'parkingCharges': parkingCharges,
      'miscellaneous': miscellaneous,
      'buildingFund': buildingFund,
      'penaltyAmount': penaltyAmount,
      'lateMonths': lateMonths,
      'totalAmount': totalAmount,
      'receivedRupeesInWords': receivedRupeesInWords,
      'paymentMode': paymentMode,
      'chequeNo': chequeNo,
      'drawnOn': drawnOn,
      'upiId': upiId,
      'generatedBy': generatedBy,
      'generatedAt': generatedAt.toIso8601String(),
      'receiptNo': receiptNo,
    };
  }

  factory MaintenanceReceiptModel.fromMap(Map<String, dynamic> map) {
    return MaintenanceReceiptModel(
      id: map['id'] ?? '',
      memberId: map['memberId'] ?? '',
      flatOwnerName: map['flatOwnerName'] ?? '',
      floor: map['floor'] ?? '',
      roomNo: map['roomNo'] ?? '',
      periodFrom: DateTime.parse(map['periodFrom']),
      periodTo: DateTime.parse(map['periodTo']),
      sinkingFund: (map['sinkingFund'] ?? 0).toDouble(),
      maintenance: (map['maintenance'] ?? 0).toDouble(),
      municipalTax: (map['municipalTax'] ?? 0).toDouble(),
      noc: (map['noc'] ?? 0).toDouble(),
      parkingCharges: (map['parkingCharges'] ?? 0).toDouble(),
      miscellaneous: (map['miscellaneous'] ?? 0).toDouble(),
      buildingFund: (map['buildingFund'] ?? 0).toDouble(),
      penaltyAmount: (map['penaltyAmount'] ?? 0).toDouble(),
      lateMonths: map['lateMonths'] ?? 0,
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      receivedRupeesInWords: map['receivedRupeesInWords'] ?? '',
      paymentMode: map['paymentMode'] ?? 'Cash',
      chequeNo: map['chequeNo'],
      drawnOn: map['drawnOn'],
      upiId: map['upiId'],
      generatedBy: map['generatedBy'] ?? '',
      generatedAt: DateTime.parse(map['generatedAt']),
      receiptNo: map['receiptNo'] ?? '',
    );
  }

  /// Sum of all charges before penalty
  double get subtotal =>
      sinkingFund +
      maintenance +
      municipalTax +
      noc +
      parkingCharges +
      miscellaneous +
      buildingFund;
}
