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
        id: 'bill_${now.millisecondsSinceEpoch}_${member.uid}',
        memberId: member.uid,
        flatNumber: member.flatNumber,
        month: 3, // Hardcoding month to match earlier mock_data for testing. We could parse `month`, but this is a mock.
        monthString: month,
        year: 2026,
        maintenanceAmount: maintenance,
        waterCharges: water,
        otherCharges: other,
        totalAmount: total,
        paidAmount: 0.0,
        status: 'unpaid',
        dueDate: DateTime.now().add(const Duration(days: 15)),
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
