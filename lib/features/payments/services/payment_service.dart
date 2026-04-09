import '../../../core/utils/mock_data.dart';

class PaymentService {
  static double calculateOutstanding(String memberId) {
    return MockData.getOutstandingAmount(memberId);
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
