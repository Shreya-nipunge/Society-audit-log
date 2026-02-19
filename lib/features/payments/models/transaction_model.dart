import 'fund_allocation.dart';

class TransactionModel {
  final String id;
  final String memberId;
  final String memberName;
  final String flatNo;
  final double amount;
  final String paymentMode; // e.g., Cash, UPI, Cheque
  final String? referenceNo;
  final FundAllocation allocation;
  final String receiptNo;
  final String recordedBy; // Admin ID
  final DateTime recordedAt;

  TransactionModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.flatNo,
    required this.amount,
    required this.paymentMode,
    this.referenceNo,
    required this.allocation,
    required this.receiptNo,
    required this.recordedBy,
    required this.recordedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'flatNo': flatNo,
      'amount': amount,
      'paymentMode': paymentMode,
      'referenceNo': referenceNo,
      'allocation': allocation.toMap(),
      'receiptNo': receiptNo,
      'recordedBy': recordedBy,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      flatNo: map['flatNo'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      paymentMode: map['paymentMode'] ?? '',
      referenceNo: map['referenceNo'],
      allocation: FundAllocation.fromMap(map['allocation'] ?? {}),
      receiptNo: map['receiptNo'] ?? '',
      recordedBy: map['recordedBy'] ?? '',
      recordedAt: DateTime.parse(map['recordedAt']),
    );
  }
}
