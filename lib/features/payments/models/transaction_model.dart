import 'fund_allocation.dart';

class TransactionModel {
  final String id;
  final String memberId;
  final DateTime date;
  final String transactionType;
  final double amount;
  final String status;
  final String? referenceId;
  final String paymentMethod;

  // Local/UI properties (Can be kept outside Firestore mapping or handled explicitly)
  final String memberName;
  final String flatNo;
  final FundAllocation allocation;
  final String receiptNo;
  final String recordedBy;
  final DateTime recordedAt;

  TransactionModel({
    required this.id,
    required this.memberId,
    required this.date,
    required this.transactionType,
    required this.amount,
    required this.status,
    this.referenceId,
    required this.paymentMethod,
    // Local
    required this.memberName,
    required this.flatNo,
    required this.allocation,
    required this.receiptNo,
    required this.recordedBy,
    required this.recordedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'date': date.toIso8601String(),
      'transactionType': transactionType,
      'amount': amount,
      'status': status,
      'referenceId': referenceId,
      'paymentMethod': paymentMethod,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, String docId) {
    return TransactionModel(
      id: docId,
      memberId: map['memberId']?.toString() ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      transactionType: map['transactionType'] ?? 'Maintenance',
      amount: (map['amount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'Success',
      referenceId: map['referenceId'],
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      // Provide defaults for local/UI fields if fetched directly from Firestore
      memberName: map['memberName'] ?? 'Unknown',
      flatNo: map['flatNo'] ?? 'Unknown',
      allocation: FundAllocation.fromMap(map['allocation'] ?? {}),
      receiptNo: map['receiptNo'] ?? 'Unknown',
      recordedBy: map['recordedBy'] ?? 'System',
      recordedAt: map['recordedAt'] != null ? DateTime.parse(map['recordedAt']) : DateTime.now(),
    );
  }
}
