import '../../../core/utils/mock_data.dart';

class ReportService {
  static Map<String, double> getFundBalances() {
    // This already exists in MockData, but we'll wrap it for the service layer
    return MockData.getFundBalances();
  }

  static List<Map<String, dynamic>> getMemberPaymentSummary() {
    final members = MockData.getMembers();
    return members.map((member) {
      final totalPaid = MockData.getTransactionsForMember(
        member.id,
      ).fold(0.0, (sum, t) => sum + t.amount);
      final outstanding = MockData.getOutstandingAmount(member.id);

      return {
        'name': member.name,
        'flat': member.flatNumber,
        'paid': totalPaid,
        'pending': outstanding,
      };
    }).toList();
  }

  static List<Map<String, dynamic>> getExpenseSummary() {
    return MockData.expenses.map((e) {
      return {
        'date': e.date.toString().split(' ')[0],
        'category': e.displayCategory,
        'amount': e.amount,
        'vendor': e.vendorName,
        'status': e.approvedBy != null ? 'Approved' : 'Pending',
      };
    }).toList();
  }
}
