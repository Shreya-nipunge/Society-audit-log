import 'package:flutter/foundation.dart';
import '../../../core/utils/mock_data.dart';
import '../models/bill_model.dart';

class BillingService {
  static void generateMonthlyBills({
    required String month,
    required double maintenance,
    required double water,
    required double other,
  }) {
    final activeMembers = MockData.getMembers();
    final now = DateTime.now();

    for (final member in activeMembers) {
      final total = maintenance + water + other;
      final bill = BillModel(
        id: 'bill_${now.millisecondsSinceEpoch}_${member.id}',
        memberId: member.id,
        month: month,
        maintenanceAmount: maintenance,
        waterCharges: water,
        otherCharges: other,
        total: total,
        generatedAt: now,
        isPaid: false,
      );
      MockData.addBill(bill);
    }
    debugPrint(
      'Generated bills for ${activeMembers.length} members for $month',
    );
  }
}
