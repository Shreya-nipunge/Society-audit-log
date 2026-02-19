import '../../../core/utils/mock_data.dart';

class PaymentService {
  static double calculateOutstanding(String memberId) {
    // Total Billed from Demand Notices
    final totalBilled = MockData.demandNotices
        .where((dn) => dn.memberId == memberId)
        .fold(0.0, (sum, dn) => sum + dn.total);

    // Total Paid from Transactions
    final totalPaid = MockData.transactions
        .where((t) => t.memberId == memberId)
        .fold(0.0, (sum, t) => sum + t.amount);

    return totalBilled - totalPaid;
  }

  static double getMonthlyCollection() {
    final now = DateTime.now();
    return MockData.transactions
        .where(
          (t) =>
              t.recordedAt.month == now.month && t.recordedAt.year == now.year,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static double getPendingDues() {
    return MockData.users
        .where((u) => u.role.name == 'member' && u.isActive)
        .fold(0.0, (sum, u) => sum + calculateOutstanding(u.id));
  }
}
